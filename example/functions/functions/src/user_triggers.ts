// import { firestore } from "firebase-admin";
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import { firestore } from "firebase-admin";

const USERS = 'users';

// interface User {
//     uid: string;
//     name: string;
//     photoURL: string;
//     lastSignInTime: string;
// }

export const onNewUserTrigger = functions.auth.user().onCreate(async (user) => {
    functions.logger.info("Creating new user");
    const collection = admin.firestore().collection(USERS);
    await collection.doc(user.uid).set({
        uid: user.uid,
        name: user.displayName,
        photoURL: user.photoURL,
        lastSignInTime: Date(),
    });
});


functions.auth.user().onDelete(async (user) => {
    const collection = admin.firestore().collection(USERS);
    await collection.doc(user.uid).delete();
});


export const userToElastic = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snapshot: any, context: any) => {
        console.log("userToElastic");
    });