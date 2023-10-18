part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded(
    this.messages,
    this.color,
  );
  final List<Message> messages;
  final int color;
}

class ChatEmpty extends ChatState {
  ChatEmpty(this.color);
  final int color;
}

class ChatError extends ChatState {
  ChatError(this.message);

  final String message;
}
