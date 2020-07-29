part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final int pageIndex;
  ProfileState(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class ProfileInitial extends ProfileState {
  ProfileInitial() : super(0);

  @override
  List<Object> get props => [];
}
