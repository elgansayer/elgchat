// import { firestore } from "firebase-admin";
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import { firestore } from "firebase-admin";

const USERS = 'users';


export const onNewUserTrigger = functions.auth.user().onCreate(async (user) => {
    functions.logger.info("Creating new user");
    const collection = admin.firestore().collection(USERS);
    await collection.doc(user.uid).set({
        uid: user.uid,
        name: user.displayName,
        photoUrl: user.photoURL,
        lastSignInTime: Date(),
    });
});

functions.auth.user().onDelete(async (user) => {
    const collection = admin.firestore().collection(USERS);
    await collection.doc(user.uid).delete();
});
