// import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { USERS, CHAT_GROUPS, CHAT_MESSAGES, ROOM_INFO } from './shared'; //
import { User, getUser } from './users';

// const admin = require('firebase-admin');
// const auth = admin.auth();

// class Member {
//     public id: string;
//     public name: string;
//     public photoUrl: string;

//     constructor(id: string, name: string, photoUrl: string
//     ) {
//         this.id = id;
//         this.name = name;
//         this.photoUrl = photoUrl;
//     }
// }


class UserChatRoomInfo {
    public readonly roomId: string;
    public readonly roomName: string;
    public readonly roomPhotoUrl: string;
    public readonly lastRead: Date;
    public readonly archived: boolean;
    public readonly muted: boolean;
    public readonly pinned: boolean;
    public readonly read: boolean;

    public readonly lastMessage: string;
    public readonly updated: Date;


    constructor(userId: string, roomName: string,
        roomPhotoUrl: string, lastRead: Date,
        archived: boolean, muted: boolean,
        pinned: boolean, read: boolean,
        lastMessage: string, updated: Date
    ) {
        this.roomId = userId;
        this.roomPhotoUrl = roomPhotoUrl;
        this.roomName = roomName;
        this.lastRead = lastRead;
        this.archived = archived;
        this.muted = muted;
        this.pinned = pinned;
        this.read = read;
        this.lastMessage = lastMessage;
        this.updated = updated;
    }
}

class ChatRoom {
    public id: string;
    public groupName: string;
    public groupPhotoUrl: string;
    public lastMessage: string;
    // public members: Member[];
    public memberIds: string[];
    public created: Date;
    public updated: Date;
    // public archived: boolean;
    // public muted: boolean;
    // public pinned: boolean;
    // public read: boolean;

    constructor(id: string, name: string, photoUrl: string, lastMessage: string,
        memberIds: string[], created: Date, updated: Date,
        //  archived:
        // boolean, muted: boolean,
        // pinned: boolean, read: boolean //, messageIds: string[]
    ) {
        this.id = id;
        this.groupName = name;
        this.groupPhotoUrl = photoUrl;
        this.lastMessage = lastMessage;
        this.memberIds = memberIds;
        this.created = created;
        this.updated = updated;
        // this.archived = archived;
        // this.muted = muted;
        // this.pinned = pinned;
        // this.read = read;
    }
}

class ChatMessage {

    public roomId: string;
    public receiverIds: string[];
    public senderId: string;

    public message: string;
    public created: Date;
    public mediaUrls: string[];
    public reactions: string[];
    public starred: boolean;
    public deleted: boolean;

    constructor(message: string, created: Date,
        senderId: string, mediaUrls: string[],
        reactions: string[], starred:
            boolean, deleted: boolean, roomId: string, receiverIds: string[]) {

        this.message = message;
        this.created = created;
        this.senderId = senderId;
        this.mediaUrls = mediaUrls;
        this.reactions = reactions;
        this.starred = starred;
        this.deleted = deleted;
        this.roomId = roomId;
        this.receiverIds = receiverIds;
    }
}

// class NewMessage {
//     // public chatRoom: ChatRoom;
//     public chatMessage: ChatMessage;

//     constructor(
//         // chatRoom: ChatRoom,
//         chatMessage: ChatMessage
//     ) {
//         // this.chatRoom = chatRoom;
//         this.chatMessage = chatMessage;
//     }
// }


export async function newMessage(request: any, response: any, next: any) {

    const newMessage: ChatMessage = request.body as ChatMessage;
    console.log(newMessage);

    if (newMessage == undefined) {
        next('New message is undefined');
    }

    try {
        const newChatRoom: ChatRoom = await getChatRoom(newMessage);

        if (newChatRoom == undefined) {
            throw new Error("Could not create chat room.");
        }

        // const read = userId === chatMessage.senderId || forceRead;
        await insertChatRoom(newChatRoom);

        // await insertChatRoom(newMessage.chatMessage, newChatRoom, newMessage.chatMessage.senderId, true);
        // allRoomIds.push(newChatRoom.id);

        // Insert chat message
        await insertChatMessage(newMessage, newChatRoom.id);

        // Makes it easier if chat rooms contain ids of all the users ina  room
        // const receiverIds: string[] = [...newMessage.receiverIds, newMessage.senderId];

        // // Grab all the room ids for the message.
        // // using room ids allow us to delete a room chat
        // // without losing messages on all receivers. Like whats app
        // const allRoomIds: string[] = [];

        // Insert receiver chat room
        for (const receiverId of newMessage.receiverIds) {
            // Get a new chat room each time so we can
            // safely delete history per user
            // const newChatRoom: ChatRoom = await getChatRoom(newMessage, receiverId, receiverIds);
            // await insertChatRoom(newMessage.chatMessage, newChatRoom, receiverId);
            insertChatRoomUserInfo(newChatRoom, receiverId, newMessage.senderId, newMessage);

            // allRoomIds.push(newChatRoom.id);
        }

        // // Insert sender chat room
        // // sender has already read the chat
        // // Get a new chat room each time so we can
        // // safely delete history per user
        // const senderId: string = newMessage.chatMessage.senderId;
        // const newChatRoom: ChatRoom = await getChatRoom(newMessage, senderId, receiverIds);
        insertChatRoomUserInfo(newChatRoom, newMessage.senderId, newMessage.receiverIds[0], newMessage);

        // Return the chat room id
        const feedBackJson = JSON.stringify({
            chatRoomId: newChatRoom.id
        });

        response.send(feedBackJson);

    } catch (error) {
        next(error);
    }
}

async function insertChatRoomUserInfo(newChatRoom: ChatRoom, userId: string, receiverId: string, chatMessage: ChatMessage): Promise<FirebaseFirestore.WriteResult> {

    const chatRoomPath: string = `${USERS}/${userId}/${ROOM_INFO}`;
    const chatRoomCollection = admin.firestore().collection(chatRoomPath);
    const chatMessageRef = chatRoomCollection.doc(newChatRoom.id);
    const chatMessageDocument = await chatMessageRef.get();

    const isGroup = newChatRoom.memberIds.length > 1;

    let groupName = newChatRoom.groupName;
    let groupPhotoUrl = newChatRoom.groupPhotoUrl;

    if (!isGroup) {
        const theUserId = chatMessage.receiverIds[0];
        const receiver: User = await getUser(theUserId);

        groupName = receiver.displayName;
        groupPhotoUrl = receiver.photoUrl;
    }

    const isRead: boolean = chatMessage.senderId !== userId;

    if (chatMessageDocument.exists) {
        var existingChatRoomUserInfo = chatMessageDocument.data() as UserChatRoomInfo;
        return chatMessageRef.update({
            ...existingChatRoomUserInfo,
            read: isRead,
            updated: new Date(),
            lastMessage: chatMessage.message,
        });
    }
    else {
        const roomInfo: UserChatRoomInfo = new UserChatRoomInfo(userId,
            groupName,
            groupPhotoUrl, new Date(),
            false, false,
            false, isRead,
            chatMessage.message, new Date()
        );

        return chatMessageRef.set({...roomInfo});
    }
}

function insertChatRoom(newChatRoom: ChatRoom): Promise<FirebaseFirestore.WriteResult> {

    // const chatRoomPath: string = `${USERS}/${userId}/${CHAT_GROUPS}`;
    const chatRoomPath: string = `${CHAT_GROUPS}`;
    const chatRoomCollection = admin.firestore().collection(chatRoomPath);
    const chatMessageDocument = chatRoomCollection.doc(newChatRoom.id);

    return chatMessageDocument.set({
        ...newChatRoom,
        // read: read,
    });
}

function insertChatMessage(chatMessage: ChatMessage, roomId: string) //: Promise<FirebaseFirestore.WriteResult> {
{
    const messagePath: string = CHAT_MESSAGES;
    const chatMessagesRoomCollection = admin.firestore().collection(messagePath);
    const chatMessagesDocument = chatMessagesRoomCollection.doc();

    const newChatMessage = {
        ...chatMessage,
        roomIds: roomId,
        created: new Date(),
        mediaUrls: [],
        reactions: [],
        starred: false,
        deleted: false
    };

    return chatMessagesDocument.set(newChatMessage);
}

// // Firestore data converter
// var chatRoomConverter = {
//     toFirestore: function (chatRoom: ChatRoom) {
//         return {}
//     },
//     fromFirestore: function (snapshot: FirebaseFirestore.DocumentData): ChatRoom {
//         console.log("here");
//         return snapshot.data() as ChatRoom;
//     }
// }

//: Promise<ChatRoom>
async function getChatRoom(chatMessage: ChatMessage): Promise<ChatRoom> {

    const roomId = chatMessage.roomId;
    const chatRoomPath: string = `${CHAT_GROUPS}`; // `${USERS}/${userId}/${CHAT_GROUPS}`;

    const chatRoomCollection = admin.firestore().collection(chatRoomPath);
    const document = chatRoomCollection.doc(roomId);

    const allMembers: string[] = [...chatMessage.receiverIds, chatMessage.senderId];

    const buildOldChatRoom = (oldChatRoom: ChatRoom) => {
        const newChatRoom: ChatRoom = {
            ...oldChatRoom,
            lastMessage: chatMessage.message,
            updated: new Date(),
            // pinned: true,
            // read: oldChatRoom.read
        }

        return newChatRoom;
    }

    const dataDocument = await document.get();
    if (dataDocument.exists) {
        const oldChatRoom = dataDocument.data() as ChatRoom;
        return buildOldChatRoom(oldChatRoom);
    }
    else {
        // Check if we have an existing room but no id
        const chatRoomCollectionDiscover = chatRoomCollection
            .where('memberIds', '==', allMembers).limit(1);

        const allExistingDocs = (await chatRoomCollectionDiscover.get()).docs;
        const existingChatRoom: ChatRoom[] = allExistingDocs.map((doc) => doc.data() as ChatRoom);

        if (existingChatRoom.length > 0) {
            return buildOldChatRoom(existingChatRoom[0]);
        }

        // Make a new one but to do that we first need the users involved.
        let roomName: string = "Group Chat";
        let photoUrl: string = "";

        if (chatMessage.receiverIds.length == 1) {
            const theUserId = chatMessage.receiverIds[0];
            const user: User = await getUser(theUserId);

            if (user == undefined) {
                throw new Error("Could not create chat room. User not found");
            }

            roomName = user.displayName;
            photoUrl = user.photoUrl;
        }

        // if it's a group then
        const newID = chatRoomCollection.doc();
        const newChatRoom: ChatRoom = {
            id: newID.id,
            groupName: roomName,
            groupPhotoUrl: photoUrl,
            lastMessage: chatMessage.message,
            memberIds: allMembers,
            created: new Date(),
            updated: new Date(),
            // archived: false,
            // muted: false,
            // pinned: false,
            // read: false,
        }

        return newChatRoom;
    }
}