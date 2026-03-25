const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const moment = require("moment-timezone");
admin.initializeApp();

exports.sendNotificationOnCreate = onDocumentCreated(
    "users/{userId}/notifications/{notificationId}",
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            console.log("No data associated with the event");
            return;
        }

        const notificationData = snapshot.data();
        const userId = event.params.userId;

        console.log(`New notification created for user ${userId}:`, notificationData.title);

        // Fetch the user's doc to get FCM tokens
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        if (!userDoc.exists) {
            console.log(`User ${userId} does not exist`);
            return;
        }

        const userData = userDoc.data();
        const tokens = userData.fcmTokens || [];

        if (tokens.length === 0) {
            console.log(`User ${userId} has no registered FCM tokens.`);
            return;
        }

        console.log(`Found ${tokens.length} tokens for user ${userId}. Sending message...`);

        // Prepare the push notification payload
        const payload = {
            notification: {
                title: notificationData.title || "New Notification",
                body: notificationData.body || "",
            },
            data: {
                type: notificationData.type || "system",
                notificationId: event.params.notificationId,
                ...(notificationData.metadata || {}), // Spread custom payload (e.g. chatId)
            },
            tokens: tokens, // sendEachForMulticast uses an array of tokens
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(payload);
            console.log(`Successfully sent message. Success count: ${response.successCount}, Failure count: ${response.failureCount}`);

            // Optional: Clean up invalid tokens
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        const error = resp.error;
                        if (error.code === 'messaging/invalid-registration-token' ||
                            error.code === 'messaging/registration-token-not-registered') {
                            failedTokens.push(tokens[idx]);
                        }
                    }
                });

                if (failedTokens.length > 0) {
                    console.log(`Removing ${failedTokens.length} invalid tokens for user ${userId}`);
                    await admin.firestore().collection("users").doc(userId).update({
                        fcmTokens: admin.firestore.FieldValue.arrayRemove(...failedTokens)
                    });
                }
            }
        } catch (error) {
            console.error("Error sending FCM message:", error);
        }
    }
);

// --- SET & FORGET RECURRENCE ENGINE ---
async function generateForTemplate(db, batch, templateDoc, colName) {
    const template = templateDoc.data();
    if (template.archivedAt != null) return 0;
    const rule = template.recurrenceRule;
    if (!rule || rule.frequency === 'none') return 0;

    const now = moment().tz("America/New_York"); // Assuming EST fallback
    const windowDays = 14;
    const targetDates = [];
    for (let i = 0; i <= windowDays; i++) {
        targetDates.push(now.clone().startOf('day').add(i, 'days'));
    }

    const startPropName = template.startTime ? 'startTime' : 'endsAt';
    const startPropVal = template.startTime ? template.startTime : template.endsAt;
    
    const templateStart = typeof startPropVal.toDate === 'function' 
        ? moment(startPropVal.toDate()) 
        : moment(startPropVal);
        
    const templateEnd = template.endTime 
        ? (typeof template.endTime.toDate === 'function' ? moment(template.endTime.toDate()) : moment(template.endTime)) 
        : null;
    
    const startHour = templateStart.hour();
    const startMinute = templateStart.minute();
    const endHour = templateEnd ? templateEnd.hour() : null;
    const endMinute = templateEnd ? templateEnd.minute() : null;

    let localWriteCount = 0;

    for (const targetDate of targetDates) {
        let shouldGenerate = false;
        
        if (rule.endCondition === 'date' && rule.endDate) {
            const endDateVal = typeof rule.endDate.toDate === 'function' 
                ? moment(rule.endDate.toDate()) 
                : moment(rule.endDate);
            const endDate = endDateVal.startOf('day');
            if (targetDate.isAfter(endDate)) continue;
        }
        
        // 2. Evaluate Frequency Matches
        if (rule.frequency === 'daily') {
            const daysDiff = targetDate.diff(templateStart.clone().startOf('day'), 'days');
            if (daysDiff >= 0 && daysDiff % (rule.interval || 1) === 0) {
                shouldGenerate = true;
            }
        } else if (rule.frequency === 'weekly') {
            const JS_Day = targetDate.day();
            const Dart_Day = JS_Day === 0 ? 7 : JS_Day; 
            
            if (rule.daysOfWeek && rule.daysOfWeek.includes(Dart_Day)) {
                const weeksDiff = targetDate.clone().startOf('isoWeek').diff(templateStart.clone().startOf('isoWeek'), 'weeks');
                if (weeksDiff >= 0 && weeksDiff % (rule.interval || 1) === 0) {
                    shouldGenerate = true;
                }
            }
        } else if (rule.frequency === 'monthly') {
            const monthsDiff = targetDate.clone().startOf('month').diff(templateStart.clone().startOf('month'), 'months');
            if (monthsDiff >= 0 && monthsDiff % (rule.interval || 1) === 0 && targetDate.date() === templateStart.date()) {
                shouldGenerate = true;
            }
        } else if (rule.frequency === 'yearly') {
            const yearsDiff = targetDate.year() - templateStart.year();
            if (yearsDiff >= 0 && yearsDiff % (rule.interval || 1) === 0 && targetDate.month() === templateStart.month() && targetDate.date() === templateStart.date()) {
                shouldGenerate = true;
            }
        }
        
        if (shouldGenerate) {
            // IDEMPOTENCY CHECK
            const exactStartTarget = targetDate.clone().hour(startHour).minute(startMinute).second(0).toDate();
            const startString = exactStartTarget.toISOString(); // Freezed native format
            
            const existingCheck = await db.collection(colName)
                .where("templateId", "==", templateDoc.id)
                .where(startPropName, "==", startString)
                .limit(1)
                .get();
                
            if (existingCheck.empty) {
                console.log(`Generating [${colName}] instance for ${template.title} on ${targetDate.format('YYYY-MM-DD')}`);
                
                const newRef = db.collection(colName).doc();
                const newId = newRef.id;
                const clone = { ...template };
                
                clone.id = newId;
                clone.isTemplate = false;
                clone.templateId = templateDoc.id;
                clone.isCancelled = false; // Reset explicitly
                
                clone.reactionUserIds = [];
                clone.interestedUserIds = [];
                clone.commentCount = 0;
                clone.latestComment = null;
                
                clone[startPropName] = startString;
                
                if (templateEnd) {
                     const exactEndTarget = targetDate.clone().hour(endHour).minute(endMinute).second(0);
                     if (templateEnd.isBefore(templateStart)) {
                         exactEndTarget.add(1, 'day');
                     }
                     clone.endTime = exactEndTarget.toDate().toISOString();
                }
                
                batch.set(newRef, clone);
                localWriteCount++;
            }
        }
    }
    return localWriteCount;
}

exports.generateRecurringEvents = onSchedule("0 2 * * *", async (event) => {
    console.log("Starting daily recurrence metronome...");
    const db = admin.firestore();
    const collections = ["specials", "tournaments", "raffles"];
    
    let totalWrites = 0;
    
    for (const colName of collections) {
        console.log(`Scanning collection: ${colName}`);
        
        const snapshot = await db.collection(colName)
            .where("isTemplate", "==", true)
            .get();
            
        console.log(`Found ${snapshot.docs.length} templates in ${colName}`);
        
        for (const doc of snapshot.docs) {
             const batch = db.batch();
             const writes = await generateForTemplate(db, batch, doc, colName);
             if (writes > 0) {
                 await batch.commit();
                 totalWrites += writes;
                 console.log(`Template batch committed ${writes} writes.`);
             }
        }
    }
    
    console.log(`Recurrence metronome executed successfully with ${totalWrites} total creations.`);
});

const { onDocumentWritten } = require("firebase-functions/v2/firestore");

exports.onSpecialWritten = onDocumentWritten("specials/{docId}", async (event) => {
    const snapshot = event.data.after;
    if (!snapshot) return; // Deleted
    
    const data = snapshot.data();
    if (data.isTemplate === true) {
        console.log(`Blueprint [specials] saved natively! Instantly spawning...`);
        const db = admin.firestore();
        const batch = db.batch();
        const writes = await generateForTemplate(db, batch, snapshot, "specials");
        if (writes > 0) {
             await batch.commit();
             console.log(`Instant generation committed ${writes} writes for special blueprint.`);
        }
    }
});

exports.onTournamentWritten = onDocumentWritten("tournaments/{docId}", async (event) => {
    const snapshot = event.data.after;
    if (!snapshot) return; // Deleted
    
    const data = snapshot.data();
    if (data.isTemplate === true) {
        console.log(`Blueprint [tournaments] saved natively! Instantly spawning...`);
        const db = admin.firestore();
        const batch = db.batch();
        const writes = await generateForTemplate(db, batch, snapshot, "tournaments");
        if (writes > 0) {
             await batch.commit();
             console.log(`Instant generation committed ${writes} writes for tournament blueprint.`);
        }
    }
});

exports.onRaffleWritten = onDocumentWritten("raffles/{docId}", async (event) => {
    const snapshot = event.data.after;
    if (!snapshot) return; // Deleted
    
    const data = snapshot.data();
    if (data.isTemplate === true) {
        console.log(`Blueprint [raffles] saved natively! Instantly spawning...`);
        const db = admin.firestore();
        const batch = db.batch();
        const writes = await generateForTemplate(db, batch, snapshot, "raffles");
        if (writes > 0) {
             await batch.commit();
             console.log(`Instant generation committed ${writes} writes for raffle blueprint.`);
        }
    }
});
