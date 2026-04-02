const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
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

        const threadId = (notificationData.metadata && notificationData.metadata.chatId) 
            ? notificationData.metadata.chatId 
            : event.params.notificationId;

        // Strip the root 'notification' property entirely.
        // This forces Android into a Data-Only background isolated state,
        // allowing FreeSpc to natively build InboxStyle expanded message cards exactly like Messenger. 
        // iOS will read the 'alert' natively via the nested APNs parameter seamlessly.
        
        const payload = {
            data: {
                type: notificationData.type || "system",
                notificationId: event.params.notificationId,
                title: notificationData.title || "New Notification",
                body: notificationData.body || "",
                ...(notificationData.metadata || {}), 
            },
            android: {
                priority: "high",
            },
            apns: {
                payload: {
                    aps: {
                        alert: {
                            title: notificationData.title || "New Message",
                            body: notificationData.body || "",
                        },
                        "thread-id": threadId,
                    }
                }
            },
            tokens: tokens, 
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
                
                // CRITICAL FIX: Update the posting timestamp so chronological sorting and UI timestamps are accurate!
                if (colName === 'specials') {
                    clone.postedAt = startString; 
                } else if (colName === 'raffles' || colName === 'tournaments') {
                    clone.createdAt = startString;
                }
                
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

// --- B2B SUPERADMIN VERIFICATION ---
exports.onApproveClaim = onCall(async (request) => {
    // 1. Authenticate Request
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Endpoint requires authentication.');
    }
    
    const callerId = request.auth.uid;
    const db = admin.firestore();
    const callerDoc = await db.collection("users").doc(callerId).get();
    
    if (!callerDoc.exists || callerDoc.data().systemRole !== "superadmin") {
        throw new HttpsError('permission-denied', 'Only Superadmins can approve B2B claims.');
    }

    const { claimId } = request.data;
    if (!claimId) {
         throw new HttpsError('invalid-argument', 'The "claimId" parameter is required.');
    }

    // 2. Fetch Claim
    const claimRef = db.collection("venue_claims").doc(claimId);
    const claimDoc = await claimRef.get();
    
    if (!claimDoc.exists) {
        throw new HttpsError('not-found', 'Venue claim document not found.');
    }
    
    const claimData = claimDoc.data();
    if (claimData.status !== 'pending') {
         throw new HttpsError('failed-precondition', 'Claim is not in a pending state.');
    }

    // 3. Execute Batch Role Elevation via Team Subcollection
    const batch = db.batch();
    const targetUserId = claimData.userId;
    const venueId = claimData.requestedVenueId;
    
    // Update Claim Status
    batch.update(claimRef, { status: 'approved' });
    
    // Fetch target user data for Team Model
    const targetUserDoc = await db.collection("users").doc(targetUserId).get();
    const targetData = targetUserDoc.data();
    
    // Fetch Venue Name for Team Model
    const venueDoc = await db.collection("bingo_halls").doc(venueId).get();
    const venueName = venueDoc.exists ? venueDoc.data().name : "Unknown Venue";

    // Elevate Target User by creating an Owner VenueTeamMemberModel
    const teamRef = db.collection("venues").doc(venueId).collection("team").doc(targetUserId);
    batch.set(teamRef, {
        uid: targetUserId,
        firstName: targetData.firstName || "",
        lastName: targetData.lastName || "",
        username: targetData.username || "",
        photoUrl: targetData.photoUrl || null,
        venueId: venueId,
        venueName: venueName,
        assignedRole: "owner",
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        addedByUid: callerId
    });
    
    // Clear legacy pending claim from root user document
    const userRef = db.collection("users").doc(targetUserId);
    batch.update(userRef, {
        pendingVenueClaimId: admin.firestore.FieldValue.delete()
    });
    
    await batch.commit();
    return { success: true, message: `User ${targetUserId} elevated to Owner of ${venueId}.` };
});

exports.onRejectClaim = onCall(async (request) => {
    // 1. Authenticate Request
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Endpoint requires authentication.');
    }
    
    const callerId = request.auth.uid;
    const db = admin.firestore();
    const callerDoc = await db.collection("users").doc(callerId).get();
    
    if (!callerDoc.exists || callerDoc.data().systemRole !== "superadmin") {
        throw new HttpsError('permission-denied', 'Only Superadmins can reject B2B claims.');
    }

    const { claimId } = request.data;
    if (!claimId) {
         throw new HttpsError('invalid-argument', 'The "claimId" parameter is required.');
    }

    // 2. Execute Reject
    const claimRef = db.collection("venue_claims").doc(claimId);
    
    const claimDoc = await claimRef.get();
    if (claimDoc.exists) {
        const targetUserId = claimDoc.data().userId;
        const userRef = db.collection("users").doc(targetUserId);
        
        const batch = db.batch();
        batch.update(claimRef, { status: 'rejected' });
        batch.update(userRef, { pendingVenueClaimId: admin.firestore.FieldValue.delete() });
        await batch.commit();
    }
    
    return { success: true, message: `Claim ${claimId} securely rejected.` };
});

// --- STAFF LIFECYCLE MANAGEMENT ---

exports.joinVenue = onCall(async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'User must be logged in.');
    const callerId = request.auth.uid;
    const { venueId } = request.data;
    if (!venueId) throw new HttpsError('invalid-argument', 'venueId required.');
    
    const db = admin.firestore();
    const venueRef = db.collection("bingo_halls").doc(venueId);
    const venueDoc = await venueRef.get();
    if (!venueDoc.exists) throw new HttpsError('not-found', 'Venue not found.');
    
    const callerDoc = await db.collection("users").doc(callerId).get();
    const targetData = callerDoc.data();
    
    const teamRef = db.collection("venues").doc(venueId).collection("team").doc(callerId);
    const teamDoc = await teamRef.get();
    if (teamDoc.exists) {
        return { success: true, message: 'Already a member' };
    }
    
    await teamRef.set({
        uid: callerId,
        firstName: targetData.firstName || "",
        lastName: targetData.lastName || "",
        username: targetData.username || "",
        photoUrl: targetData.photoUrl || null,
        venueId: venueId,
        venueName: venueDoc.data().name,
        assignedRole: "worker", // default
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        addedByUid: callerId // self-joined via link
    });
    
    return { success: true, message: 'Joined successfully' };
});

exports.mutateStaffRole = onCall(async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'User must be logged in.');
    const callerId = request.auth.uid;
    const { venueId, targetUid, newRole } = request.data; // newRole can be 'manager', 'worker', or 'REMOVE'
    
    if (!venueId || !targetUid || !newRole) {
        throw new HttpsError('invalid-argument', 'Missing parameters.');
    }
    
    const db = admin.firestore();
    
    // Check Caller Role
    const callerTeamDoc = await db.collection("venues").doc(venueId).collection("team").doc(callerId).get();
    const callerSystemRoleDoc = await db.collection("users").doc(callerId).get();
    const isSuperAdmin = callerSystemRoleDoc.exists && callerSystemRoleDoc.data().systemRole === 'superadmin';
    
    if (!callerTeamDoc.exists && !isSuperAdmin) {
         return { success: false, message: 'You are not a member of this team.' };
    }
    const callerRole = isSuperAdmin ? 'owner' : callerTeamDoc.data().assignedRole;
    
    if (callerRole === 'worker') {
        throw new HttpsError('permission-denied', 'Workers cannot mutate roles.');
    }
    
    const targetTeamRef = db.collection("venues").doc(venueId).collection("team").doc(targetUid);
    const targetTeamDoc = await targetTeamRef.get();
    if (!targetTeamDoc.exists) throw new HttpsError('not-found', 'Target user is not on the team.');
    const targetRole = targetTeamDoc.data().assignedRole;
    
    // Authorization Matrix
    if (callerRole === 'manager' && (targetRole === 'owner' || targetRole === 'manager' || newRole === 'owner')) {
        throw new HttpsError('permission-denied', 'Managers can only mutate workers.');
    }
    if (targetRole === 'owner' && !isSuperAdmin && callerId !== targetUid) {
        // Only super admin or self can demote owner
        throw new HttpsError('permission-denied', 'Cannot mutate another owner.');
    }
    
    // Orphan Lock Check
    if (targetRole === 'owner' && newRole !== 'owner') {
        const teamDocs = await db.collection("venues").doc(venueId).collection("team").where("assignedRole", "==", "owner").get();
        if (teamDocs.size <= 1) {
             throw new HttpsError('failed-precondition', 'Cannot demote/remove the last owner of a venue.');
        }
    }
    
    if (newRole === 'REMOVE') {
        await targetTeamRef.delete();
        return { success: true, message: 'Staff removed.' };
    } else {
        await targetTeamRef.update({ assignedRole: newRole });
        return { success: true, message: 'Role updated.' };
    }
});

// --- TYPO-TOLERANT SEARCH (TYPESENSE/ALGOLIA SYNC) ---
exports.syncProfileToSearch = onDocumentWritten("public_profiles/{uid}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log(`Profile \${event.params.uid} deleted. Remove from search index proxy...`);
        // await searchClient.deleteObject(event.params.uid);
        return;
    }
    
    const afterData = snapshot.after ? snapshot.after.data() : null;
    if (!afterData) return;
    
    console.log(`Syncing Profile \${event.params.uid} to Typo-Tolerant Search provider...`);
    
    // Scaffold payload matching Algolia/Typesense schema
    const searchPayload = {
        objectID: event.params.uid,
        username: afterData.username,
        firstName: afterData.firstName,
        lastName: afterData.lastName,
        photoUrl: afterData.photoUrl,
        _tags: [afterData.role], // Role-based filtering capabilities
    };
    
    // TODO: Connect Algolia client instance and push `searchPayload` natively.
    // await index.saveObject(searchPayload);
    console.log(`Search payload scaffolded securely for \${afterData.username}.`);
});

