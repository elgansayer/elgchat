import 'package:equatable/equatable.dart';



abstract class ConversationLogicState extends Equatable {
  const ConversationLogicState();
}

class ConversationInitial extends ConversationLogicState {
  @override
  List<Object> get props => [];
}
