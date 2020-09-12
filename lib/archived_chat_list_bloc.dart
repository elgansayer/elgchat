// import 'package:elgchat/bloc/chat_list_bloc.dart';
// import 'bloc/chat_list_callback_events.dart';
// import 'models.dart';

// class ArchivedChatListScreenLogic<T extends ChatRoom>
//     extends ChatRoomListLogic<T> {
//   @override
//   archiveSelectedEvent() {
//     List<T> allSelected = chatRooms.selected();

//     chatRooms = chatRooms.map((T cg) {
//       bool selected = allSelected.contains(cg);
//       if (selected) {
//         return cg.copyWith(archived: false, selected: false);
//       }
//       return cg;
//     }).toList();

//     // Get all selected, remove them from the list
//     chatRooms.removeWhere((cg) => allSelected.contains(cg));

//     unselectAll();
//     stateStreamController.add(ChatListState.list);

//     // This fires widget.onUnArchived
//     this.dispatchCallback.add(UnarchivedCallbackEvent(allSelected));
//   }

//   selectAllEvent() {
//     chatRooms = chatRooms.map((T cg) {
//       if (cg.archived != true) {
//         return cg.copyWith(selected: true);
//       }
//       return cg.copyWith(selected: false);
//     }).toList();

//     chatRoomsStreamController.add(this.chatRooms);
//     this.selectedStreamController.add(this.chatRooms);
//   }
// }
