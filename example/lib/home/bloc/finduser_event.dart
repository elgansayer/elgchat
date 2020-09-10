part of 'finduser_bloc.dart';

abstract class FindUserEvent extends Equatable {
  const FindUserEvent();

  @override
  List<Object> get props => [];
}

class UserSearch extends FindUserEvent {
  final String phrase;
  UserSearch(this.phrase);
}
