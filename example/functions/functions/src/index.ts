const admin = require('firebase-admin');
admin.initializeApp();
import { newMessage } from "./messages";

const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded());

app.post('/newMessage', (req: any, res: any, next: any) => {
    newMessage(req, res, next);
});

// // build multiple CRUD interfaces:
// app.get('/:id', (req: any, res: any) => res.send(Widgets.getById(req.params.id)));
// app.post('/', (req: any, res: any) => res.send(Widgets.create()));
// app.put('/:id', (req: any, res: any) => res.send(Widgets.update(req.params.id, req.body)));
// app.delete('/:id', (req: any, res: any) => res.send(Widgets.delete(req.params.id)));
// app.get('/', (req: any, res: any) => res.send(Widgets.list()));


// Expose Express API as a single Cloud Function:
exports.api = functions.https.onRequest(app);



// export * from './users';
// export  * from './messages';
// export * from './user_triggers';

// import * as functions from 'firebase-functions';
// const admin = require('firebase-admin');
// admin.initializeApp();
// const auth = admin.auth();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
