import 'package:get/get.dart';
import 'message_model.dart';

class ChatSessionModel {
  int? id;
  final RxString title;
  final RxList<MessageModel> messages;

  ChatSessionModel({
    this.id,
    String title = 'Untitled Chat',
    List<MessageModel>? messages,
  })  : title = RxString(title),
        messages = RxList(messages ?? []);

  void addMessage(MessageModel message) {
    messages.add(message);
  }
}