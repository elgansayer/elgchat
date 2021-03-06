part of 'finduser_bloc.dart';

class FindUserState extends Equatable {
  final List<ElgContact> contacts;

  FindUserState({this.contacts});

  factory FindUserState.initial() {
    return FindUserState(contacts: []);
  }

  @override
  List<Object> get props => [contacts];
}
