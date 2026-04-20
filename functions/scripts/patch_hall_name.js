const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

async function patchHallName() {
    console.log("🚀 Starting Patch: hallName -> venueName");
    let batch = db.batch();
    let batchCount = 0;

    async function commitBatchIfNeeded() {
        if (batchCount >= 400) {
            await batch.commit();
            batch = db.batch();
            batchCount = 0;
            console.log("...committed chunk...");
        }
    }

    const collectionsToUpdate = ['specials', 'raffles', 'tournaments', 'trivia', 'bar_games'];
    for (const col of collectionsToUpdate) {
        console.log(`Patching fields in collection: ${col}...`);
        const snap = await db.collection(col).get();
        for (const doc of snap.docs) {
            const data = doc.data();
            if (data.hallName !== undefined) {
                data.venueName = data.hallName;
                delete data.hallName;
                batch.set(doc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }

    // Subcollections team members
    const venuesSnap = await db.collection('venues').get();
    for (const venueDoc of venuesSnap.docs) {
        const teamSnap = await venueDoc.ref.collection('team').get();
        for (const tDoc of teamSnap.docs) {
            const data = tDoc.data();
            if (data.hallName !== undefined) {
                data.venueName = data.hallName;
                delete data.hallName;
                batch.set(tDoc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }
    
    // Check notifications
    const usersSnap = await db.collection('users').get();
    for (const userDoc of usersSnap.docs) {
        const notifSnap = await userDoc.ref.collection('notifications').get();
        for (const nDoc of notifSnap.docs) {
            const data = nDoc.data();
            let changed = false;
            if (data.hallName !== undefined) {
                data.venueName = data.hallName;
                delete data.hallName;
                changed = true;
            }
            if (changed) {
                batch.set(nDoc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }

    if (batchCount > 0) {
        await batch.commit();
    }
    console.log("✅ Database Patch Successfully Completed!");
}

patchHallName().catch(e => {
    console.error("Patch Error:", e);
    process.exit(1);
});
