const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

async function patchUserHalls() {
    console.log("🚀 Starting Patch: User Subcollections hallName -> venueName");
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

    const usersSnap = await db.collection('users').get();
    const subsToPatch = [
        'transactions', 
        'memberships', 
        'raffle_tickets', 
        'my_items', 
        'tournaments'
    ];

    for (const userDoc of usersSnap.docs) {
        for (const sub of subsToPatch) {
            const subSnap = await userDoc.ref.collection(sub).get();
            for (const doc of subSnap.docs) {
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
    }

    if (batchCount > 0) {
        await batch.commit();
    }
    console.log("✅ User Subcollections Patch Successfully Completed!");
}

patchUserHalls().catch(e => {
    console.error("Patch Error:", e);
    process.exit(1);
});
