part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class SwitchTab extends HomeEvent {
  final int index;
  SwitchTab(this.index);

  @override
  List<Object> get props =>[index];
}

class ChangeHomePageMessagesIcon extends HomeEvent {
  final bool showBadge;
  ChangeHomePageMessagesIcon(this.showBadge);

  @override
  List<Object> get props => throw UnimplementedError();
}