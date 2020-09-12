import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { USERS } from './shared';

export class User {
    public readonly uid: string;
    public readonly displayName: string;
    public readonly photoUrl: string;
    public readonly lastSignInTime: Date;

    constructor(uid: string, displayName: string, photoUrl: string, lastSignInTime: Date) {
        this.uid = uid;
        this.displayName = displayName;
        this.photoUrl = photoUrl;
        this.lastSignInTime = lastSignInTime;
    }
}

export const getUser = async (userId: string): Promise<User> => {
    const userPath: string = `${USERS}`;
    const userCollection = admin.firestore().collection(userPath);
    const userDocument = userCollection.doc(userId);
    const userData = await userDocument.get();
    const user: User = userData.data() as User;
    return user;
}

export const getAllUsers = functions.https.onRequest((request, response) => {
    admin.auth().listUsers().then((userRecords: { users: any[]; }) => {
        response.send(userRecords.users);
    }).catch((error: any) => {
        functions.logger.error(error, { structuredData: true });
    });
});
