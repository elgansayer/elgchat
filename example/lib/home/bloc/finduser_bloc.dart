import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elgchat/models.dart';
import 'package:elgchat_example/models.dart';
import 'package:equatable/equatable.dart';
import '../../user_repository.dart';
part 'finduser_event.dart';
part 'finduser_state.dart';

class FindUserBloc extends Bloc<FindUserEvent, FindUserState> {
  final UserRepository userRepository;
  FindUserBloc(this.userRepository) : super(FindUserState.initial());

  @override
  Stream<FindUserState> mapEventToState(
    FindUserEvent event,
  ) async* {
    if (event is UserSearch) {
      yield* _convertSearchedUsers(event);
    }
  }

  Stream<FindUserState> _convertSearchedUsers(UserSearch event) async* {
    // Find usersthat match the phrase
    // turn those users in to elgchat contacts
    List<User> users = userRepository.users;

    String searchPhrase = event.phrase.toLowerCase();

    int i = 0;
    List<ElgContact> allContacts = users
        .where((element) =>
            element.email.toLowerCase().contains(searchPhrase) ||
            element.displayName.toLowerCase().contains(searchPhrase))
        .map((e) {
      i++;
      return ElgContact(
          id: e.uid,
          username: e.displayName ?? e.email,
          photoUrl: e.photoUrl ?? "https://picsum.photos/100/100?i=$i)}",
          lastOnline: DateTime.now(),
          isActive: true);
    }).toList();

    yield FindUserState(contacts: allContacts);
  }
}
