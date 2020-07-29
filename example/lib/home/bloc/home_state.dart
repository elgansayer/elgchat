part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int pageIndex;
  HomeState(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class HomeInitial extends HomeState {
  HomeInitial() : super(0);

  @override
  List<Object> get props => [];
}
