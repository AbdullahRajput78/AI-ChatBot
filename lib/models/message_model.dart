import 'package:get/get.dart';

enum MessageType { user, bot }

class MessageModel {
  int? id;
  final MessageType type;

  // For regenerating
  RxBool isRegenerating = false.obs;

  // For loading animation
  RxBool isLoading = false.obs;
  // For regenerate failed version
  RxBool lastVersionFailed = false.obs;
  //---- for regenerate error
  RxString regenerateError = ''.obs;
  // Message versions
  final RxList<String> versions;
  final RxInt currentVersionIndex;

  // UI states
  final RxBool speak;
  final RxBool copy;

  MessageModel({
    this.id,
    required this.type,
    required String message,
    List<String>? versions,
    int initialVersionIndex = 0,
    bool speak = false,
    bool copy = false,
  })  : versions = RxList(versions ?? [message]),
        currentVersionIndex = RxInt(initialVersionIndex),
        speak = RxBool(speak),
        copy = RxBool(copy);

  /// Current message
  String get message => versions[currentVersionIndex.value];

  /// NEW: Update current message
  void updateMessage(String newMessage) {
    versions[currentVersionIndex.value] = newMessage;
    versions.refresh(); // notify Obx listeners
  }

  /// Version helpers
  bool get hasMultipleVersions => versions.length > 1;
  bool get canGoPrevious => currentVersionIndex.value > 0;
  bool get canGoNext => currentVersionIndex.value < versions.length - 1;

  void addVersion(String newMessage) {
    versions.add(newMessage);
    currentVersionIndex.value = versions.length - 1;
  }

  void goToPrevious() {
    if (canGoPrevious) currentVersionIndex.value--;
  }

  void goToNext() {
    if (canGoNext) currentVersionIndex.value++;
  }

  MessageModel copyWith({
    int? id,
    MessageType? type,
    String? message,
    List<String>? versions,
    int? currentVersionIndex,
    bool? speak,
    bool? copy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      versions: versions ?? this.versions.toList(),
      initialVersionIndex:
      currentVersionIndex ?? this.currentVersionIndex.value,
      speak: speak ?? this.speak.value,
      copy: copy ?? this.copy.value,
    );
  }
}