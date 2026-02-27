const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
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
