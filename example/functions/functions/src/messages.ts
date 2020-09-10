import * as functions from 'firebase-functions';
// import * as admin from 'firebase-admin';

// const admin = require('firebase-admin');
// const auth = admin.auth();

// const CHAT_GROUPS = 'chat_groups';

interface IChatGroup {
    id: string;
    name: string;
    imageUrl: string;
    lastMessage: string;
    creatorId: string;
    created: string;
    updated: string;
    archived: boolean;
    muted: boolean;
    pinned: boolean;
    read: boolean;
}

interface IChatMessage {
    id: string;
    message: string;
    creationDate: string;
    senderId: string;
    mediaUrls: [];
    reactions: [];
    starred: string;
    deleted: string;
}

interface INewMessage {
    // id: string;
    chatGroup: IChatGroup;
    chatMessage: IChatMessage;
}


export const newMessage = functions.https.onRequest(async (request: any, res: any) => {

    const chatMessage: INewMessage = request.query as INewMessage;
    const chatGroup: IChatGroup = chatMessage.chatGroup;

    // const newChatGroup = getChatGroup(INewMessage);
    console.log("newMessage");
    console.log(chatGroup);

    // const querySnapshot = await collection.get();
    // const listOfPosts = querySnapshot.docs.map((doc) => doc.data());


    // return listOfPosts;
});

// async function getChatGroup(newMessage: INewMessage) {

//     const chatGroup = newMessage.chatGroup;
//     const collection = admin.firestore().collection(CHAT_GROUPS);
//     const document = collection.doc(chatGroup.id);
//     const dataDocument = await document.get();

//     if (dataDocument.exists) {
//         return dataDocument;
//     }

//     const newID = collection.doc();

//     const newChatGroup: IChatGroup = {
//         id: newID.id,
//         name: chatGroup.name,
//         imageUrl: chatGroup.imageUrl,
//         lastMessage: chatGroup.lastMessage,
//         creatorId: chatGroup.creatorId,
//         created: chatGroup.created,
//         updated: chatGroup.updated,
//         archived: false,
//         muted: false,
//         pinned: false,
//         read: false,
//     }

//     return newChatGroup;

// }