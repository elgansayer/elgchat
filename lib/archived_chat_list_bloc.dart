import 'package:elgchat/bloc/chat_list_bloc.dart';
import 'bloc/chat_list_callback_events.dart';
import 'models.dart';

class ArchivedChatListScreenLogic<T extends ChatGroup>
    extends ChatListScreenLogic<T> {
  @override
  archiveSelectedEvent() {
    List<T> allSelected = chatGroups.selected();

    chatGroups = chatGroups.map((T cg) {
      bool selected = allSelected.contains(cg);
      if (selected) {
        return cg.copyWith(archived: false, selected: false);
      }
      return cg;
    }).toList();

    // Get all selected, remove them from the list
    chatGroups.removeWhere((cg) => allSelected.contains(cg));

    unselectAll();
    stateStreamController.add(ChatListState.list);

    // This fires widget.onUnArchived
    this.dispatchCallback.add(UnarchivedCallbackEvent(allSelected));
  }
}
