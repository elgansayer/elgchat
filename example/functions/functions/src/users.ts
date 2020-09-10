import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

export const getAllUsers = functions.https.onRequest((request, response) => {
    admin.auth().listUsers().then((userRecords: { users: any[]; }) => {
        response.send(userRecords.users);
    }).catch((error: any) => {
        functions.logger.error(error, { structuredData: true });
    });
});

