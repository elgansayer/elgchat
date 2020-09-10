// import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { USERS, CHAT_GROUPS, CHAT_MESSAGES } from './shared';

// const admin = require('firebase-admin');
// const auth = admin.auth();


class ChatGroup {
    public id: string;
    public name: string;
    public photoUrl: string;
    public lastMessage: string;
    // public creatorId: string;
    public receiverIds: string[];
    public created: Date;
    public updated: Date;
    public archived: boolean;
    public muted: boolean;
    public pinned: boolean;
    public read: boolean;
    // public messageIds: string[];

    constructor(id: string, name: string, photoUrl: string, lastMessage: string,
        receiverIds: string[], created: Date, updated: Date, archived:
            boolean, muted: boolean,
        pinned: boolean, read: boolean //, messageIds: string[]
    ) {
        this.id = id;
        this.name = name;
        this.photoUrl = photoUrl;
        this.lastMessage = lastMessage;
        this.receiverIds = receiverIds;
        this.created = created;
        this.updated = updated;
        this.archived = archived;
        this.muted = muted;
        this.pinned = pinned;
        this.read = read;
        // this.messageIds = messageIds;
    }
}

class ChatMessage {
    // public id: string;
    // public groupId: string;
    public message: string;
    public created: Date;
    public senderId: string;
    // public receiverIds: string[];
    public mediaUrls: string[];
    public reactions: string[];
    public starred: boolean;
    public deleted: boolean;
    public groupIds: string[];

    constructor(message: string, created: Date,
        senderId: string, mediaUrls: string[],
        reactions: string[], starred:
            boolean, deleted: boolean, groupIds: string[]) {

        // this.id = id;
        this.message = message;
        this.created = created;
        this.senderId = senderId;
        this.mediaUrls = mediaUrls;
        this.reactions = reactions;
        this.starred = starred;
        this.deleted = deleted;
        this.groupIds = groupIds;
    }
}

class NewMessage {
    public chatGroup: ChatGroup;
    public chatMessage: ChatMessage;

    constructor(
        chatGroup: ChatGroup,
        chatMessage: ChatMessage
    ) {
        // this.groupId = groupId;
        this.chatGroup = chatGroup;
        this.chatMessage = chatMessage;
        // this.name = name;
        // this.photoUrl = photoUrl;
    }
}


export async function newMessage(request: any, response: any) {

    const newMessage: NewMessage = request.body as NewMessage;

    // Get a new chat group
    const newChatGroup: ChatGroup = await getChatGroup(newMessage);

    const chatGroupPath: string = `${USERS}/${newMessage.chatMessage.senderId}/${CHAT_GROUPS}`;
    const chatGroupCollection = admin.firestore().collection(chatGroupPath);
    const chatMessageDocument = chatGroupCollection.doc(newChatGroup.id);
    await chatMessageDocument.set({
        ...newChatGroup
    });

    const messagePath: string = CHAT_MESSAGES;
    const chatMessagesGroupCollection = admin.firestore().collection(messagePath);
    const chatMessagesDocument = chatMessagesGroupCollection.doc();
    await chatMessagesDocument.set({
        ...newMessage.chatMessage,
        groupIds: [newChatGroup.id],
        created: new Date(),
        mediaUrls: [],
        reactions: [],
        starred: false,
        deleted: false
    });

    // Return the chat group id
    const feedBackJson = JSON.stringify({
        chatGroupId: newChatGroup.id
    });

    response.end(feedBackJson);
}


// // Firestore data converter
// var chatGroupConverter = {
//     toFirestore: function (chatGroup: ChatGroup) {
//         return {}
//     },
//     fromFirestore: function (snapshot: FirebaseFirestore.DocumentData): ChatGroup {
//         console.log("here");
//         return snapshot.data() as ChatGroup;
//     }
// }

//: Promise<ChatGroup>
async function getChatGroup(newMessage: NewMessage): Promise<ChatGroup> {

    const groupId = newMessage.chatGroup.id;
    const chatGroupPath: string = `${USERS}/${newMessage.chatMessage.senderId}/${CHAT_GROUPS}`;

    const chatGroupCollection = admin.firestore().collection(chatGroupPath);
    const document = chatGroupCollection.doc(groupId);
    // .withConverter(chatGroupConverter);

    const buildOldCHatGroup = (oldChatGroup: ChatGroup) => {
        const newChatGroup: ChatGroup = {
            id: oldChatGroup.id,
            name: newMessage.chatGroup.name,
            photoUrl: newMessage.chatGroup.photoUrl,
            lastMessage: newMessage.chatMessage.message,
            // creatorId: newMessage.chatMessage.
            receiverIds: newMessage.chatGroup.receiverIds,
            created: oldChatGroup.created,
            updated: new Date(),
            archived: oldChatGroup.archived,
            muted: oldChatGroup.muted,
            pinned: oldChatGroup.pinned,
            read: oldChatGroup.read,
            // messageIds: [...oldChatGroup.messageIds, messageID]
        }

        return newChatGroup;
    }

    const dataDocument = await document.get();
    if (dataDocument.exists) {
        const oldChatGroup = dataDocument.data() as ChatGroup;
        return buildOldCHatGroup(oldChatGroup);
    }
    else {
        const chatGroupCollection = admin.firestore().collection(chatGroupPath);

        // Check if we have an existing group but no id
        const chatGroupCollectionDiscover = chatGroupCollection
            .where('receiverIds', '==', newMessage.chatGroup.receiverIds).limit(1);

        const allExistingDocs = (await chatGroupCollectionDiscover.get()).docs;
        const existingChatGroup: ChatGroup[] = allExistingDocs.map((doc) => doc.data() as ChatGroup);

        if (existingChatGroup.length > 0) {
            return buildOldCHatGroup(existingChatGroup[0]);
        }

        // // Make a new one
        // const document = chatGroupCollection.doc(groupId)

        const newID = chatGroupCollection.doc();
        const newChatGroup: ChatGroup = {
            id: newID.id,
            name: newMessage.chatGroup.name,
            photoUrl: newMessage.chatGroup.photoUrl,
            lastMessage: newMessage.chatMessage.message,
            // creatorId: newMessage.chatMessage.
            receiverIds: newMessage.chatGroup.receiverIds,
            created: new Date(),
            updated: new Date(),
            archived: false,
            muted: false,
            pinned: false,
            read: false,
            // messageIds: [messageID]
        }

        return newChatGroup;
    }
}