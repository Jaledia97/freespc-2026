const admin = require('firebase-admin');

// Initialize the app with default credentials (must be logged in via `firebase login`)
admin.initializeApp();
const db = admin.firestore();

async function syncMissingProfiles() {
    try {
        const usersSnap = await db.collection('users').get();
        console.log(`Found ${usersSnap.docs.length} users in 'users' collection.`);
        
        let syncedCount = 0;
        
        for (const doc of usersSnap.docs) {
            const data = doc.data();
            const profileRef = db.collection('public_profiles').doc(doc.id);
            const profileSnap = await profileRef.get();
            
            if (!profileSnap.exists) {
                console.log(`Missing public_profile for user ${doc.id} (${data.username}). Syncing now...`);
                
                await profileRef.set({
                    uid: doc.id,
                    username: data.username || 'unknown',
                    firstName: data.firstName || '',
                    lastName: data.lastName || '',
                    photoUrl: data.profileImageUrl || null,
                    bio: data.bio || null,
                    points: data.currentPoints || 0,
                    realNameVisibility: data.realNameVisibility || 'Private',
                    onlineStatus: data.onlineStatus || 'Online',
                    currentCheckInHallId: data.currentCheckInHallId || null
                });
                
                syncedCount++;
            }
        }
        
        console.log(`Sync complete. Created ${syncedCount} missing public profiles.`);
    } catch (e) {
        console.error("Error syncing profiles:", e);
    }
}

syncMissingProfiles();
