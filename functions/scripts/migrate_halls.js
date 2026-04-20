const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

async function migrateHallsToVenues() {
    console.log("🚀 Starting Database Migration: bingo_halls -> venues");
    
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

    // 1. Migrate root collections
    console.log("Migrating core collections and subcollections...");
    const hallsRef = db.collection('bingo_halls');
    const snapshot = await hallsRef.get();

    for (const doc of snapshot.docs) {
        const venueRef = db.collection('venues').doc(doc.id);
        let data = doc.data();
        if(data.hallId) {
            data.venueId = data.hallId;
            delete data.hallId;
        }
        batch.set(venueRef, data);
        batchCount++;
        await commitBatchIfNeeded();

        // Subcollections
        const subcollections = ['tournaments', 'store_items', 'assets', 'team'];
        for (const sub of subcollections) {
            const subDocs = await doc.ref.collection(sub).get();
            for (const subDoc of subDocs.docs) {
                const newSubRef = venueRef.collection(sub).doc(subDoc.id);
                let subData = subDoc.data();
                if(subData.hallId) {
                    subData.venueId = subData.hallId;
                    delete subData.hallId;
                }
                batch.set(newSubRef, subData);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }

    // 2. Migrate Root Program Collections
    const collectionsToUpdate = ['specials', 'raffles', 'tournaments', 'trivia', 'bar_games'];
    for (const col of collectionsToUpdate) {
        console.log(`Migrating fields in collection: ${col}...`);
        const snap = await db.collection(col).get();
        for (const doc of snap.docs) {
            const data = doc.data();
            let changed = false;
            if (data.hallId) {
                data.venueId = data.hallId;
                delete data.hallId;
                changed = true;
            }
            if (changed) {
                batch.set(doc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }

    // 3. Migrate Users (transactions, notifications, memberships, etc)
    console.log("Migrating User Subcollections...");
    const usersSnap = await db.collection('users').get();
    for (const userDoc of usersSnap.docs) {
        
        // Check core fields in User Model
        let userData = userDoc.data();
        if (userData.activeHallId) {
            userData.activeVenueId = userData.activeHallId;
            delete userData.activeHallId;
            batch.set(userDoc.ref, userData);
            batchCount++;
            await commitBatchIfNeeded();
        }

        const transSnap = await userDoc.ref.collection('transactions').get();
        for (const tDoc of transSnap.docs) {
            const data = tDoc.data();
            if (data.hallId) {
                data.venueId = data.hallId;
                delete data.hallId;
                batch.set(tDoc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }

        const notifSnap = await userDoc.ref.collection('notifications').get();
        for (const nDoc of notifSnap.docs) {
            const data = nDoc.data();
            if (data.hallId) {
                data.venueId = data.hallId;
                delete data.hallId;
                batch.set(nDoc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }

        const memberSnap = await userDoc.ref.collection('memberships').get();
        for (const mDoc of memberSnap.docs) {
            const data = mDoc.data();
            if (data.hallId) {
                data.venueId = data.hallId;
                delete data.hallId;
                batch.set(mDoc.ref, data);
                batchCount++;
                await commitBatchIfNeeded();
            }
        }
    }

    if (batchCount > 0) {
        await batch.commit();
    }
    console.log("✅ Database Migration Successfully Completed!");
}

migrateHallsToVenues().catch(e => {
    console.error("Migration Error:", e);
    process.exit(1);
});
