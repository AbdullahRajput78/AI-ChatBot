import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../customwidgets/pdf_preview_page.dart';
import '../models/chatsession_model.dart';
import '../models/message_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/ChatApiService.dart';
import '../services/pdf_export_service.dart';

class Essay_letterlogic extends GetxController with WidgetsBindingObserver {
  Essay_letterlogic(this.pageTitle);

  final String pageTitle;
  //---------- api service
  final ChatApiService _apiService = ChatApiService();

  //------ for successful response
  final RxBool hasSuccessfulResponse = false.obs;

  final TextEditingController textController = TextEditingController();

  //------------------------ for going to End line after Bot message -----------------
  final ScrollController scrollController = ScrollController();

  //------------------------ to check if chat start ?
  final RxBool hasConversation = false.obs;

  final Rx<ChatSessionModel> session = ChatSessionModel().obs;
  final RxBool isGenerating = false.obs;

  // for speaking
  final FlutterTts flutterTts = FlutterTts();
  MessageModel? currentlySpeakingMessage;
  int _speechGeneration = 0;
  Timer? _speechCompletionFallbackTimer;

  bool isCancelled = false;

  //--------------------- for exporting PDF
  final PdfExportService _pdfService = PdfExportService();
  final RxBool isExporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    startNewChat();
    // Re-enable awaitSpeakCompletion(true) for modern flutter_tts versions.
    flutterTts.awaitSpeakCompletion(true);
    flutterTts.setQueueMode(0);

    // Backup handlers in case the await fails or is interrupted
    flutterTts.setCompletionHandler(() {
      debugPrint("TTS Backup Completion Fired");
      _handleSpeechEnded();
    });

    flutterTts.setCancelHandler(() {
      debugPrint("TTS Backup Cancel Fired");
      _handleSpeechEnded();
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Backup Error Fired: $msg");
      _handleSpeechEnded();
    });
  }

  void _handleSpeechEnded() {
    _cancelSpeechCompletionFallback();
    final speakingMessage = currentlySpeakingMessage;
    if (speakingMessage != null) {
      speakingMessage.speak.value = false;
    }
    currentlySpeakingMessage = null;
  }

  Future<void> stopSpeakingIfActive() async {
    _speechGeneration++;
    _cancelSpeechCompletionFallback();
    if (currentlySpeakingMessage != null) {
      await flutterTts.stop();
      currentlySpeakingMessage!.speak.value = false;
      currentlySpeakingMessage = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      stopSpeakingIfActive();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSpeechCompletionFallback();
    textController.dispose();
    scrollController.dispose();
    flutterTts.stop();
    super.onClose();
  }

  //--------------------------------- function for scroll to bottom ----------------
  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  //-------------------------- for every new chat
  void startNewChat() {
    session.value = ChatSessionModel();
    textController.clear();
    hasConversation.value = false;
    hasSuccessfulResponse.value = false;
    isGenerating.value = false;
    isCancelled = false;
    session.refresh();
  }

  void copyMessage(MessageModel message) {
    Clipboard.setData(ClipboardData(text: message.message)); // copy etxt
    message.copy.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      message.copy.value = false;
    });
  }

  //------------------------- for speaking -----------

  void goToPreviousVersion(MessageModel message) {
    message.goToPrevious();
    session.refresh();
  }

  void goToNextVersion(MessageModel message) {
    message.goToNext();
    session.refresh();
  }

  //---------------------- stop function for generating message ---------
  void stopGenerating() {
    isCancelled = true;
    isGenerating.value = false;
  }

  void _cancelSpeechCompletionFallback() {
    _speechCompletionFallbackTimer?.cancel();
    _speechCompletionFallbackTimer = null;
  }

  Future<void> toggleSpeak(MessageModel message) async {
    if (message.speak.value) {
      await stopSpeakingIfActive();
      return;
    }

    // Stop current speech before starting new one
    await stopSpeakingIfActive();

    final speechGeneration = ++_speechGeneration;
    message.speak.value = true;
    currentlySpeakingMessage = message;

    try {
      // With awaitSpeakCompletion(true), this future completes when speech is DONE.
      final result = await flutterTts.speak(message.message);

      // Check if this is still the active speech session
      if (speechGeneration == _speechGeneration &&
          identical(currentlySpeakingMessage, message)) {
        debugPrint("TTS Speak Future Completed (Result: $result)");
        _handleSpeechEnded();
      }
    } catch (e) {
      debugPrint("TTS Speak Exception: $e");
      if (speechGeneration == _speechGeneration &&
          identical(currentlySpeakingMessage, message)) {
        _handleSpeechEnded();
      }
    }
  }

  //--------------- for exporting pdf
  Future<void> exportToPdf() async {
    if (isExporting.value) return;

    isExporting.value = true;
    try {
      if (session.value.messages.isEmpty) {
        Get.snackbar(
          'Nothing to export',
          'Write something first to generate exportable content.',
        );
        return;
      }

      final result = await _pdfService.exportMessages(
        title: pageTitle,
        messages: session.value.messages,
      );

      final filePath = result.filePath;
      if (result.success && filePath != null) {
        Get.to(() => PdfPreviewPage(pdfPath: filePath, title: pageTitle));
      } else {
        Get.snackbar('Export failed', result.message);
      }
    } catch (e) {
      Get.snackbar('Export failed', 'Unable to export this document: $e');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> sendMessage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final text = textController.text.trim();
    if (text.isEmpty) return;
    hasConversation.value = true;

    final userMessage = MessageModel(type: MessageType.user, message: text);
    session.value.addMessage(userMessage);
    session.refresh();
    textController.clear();

    scrollToBottom();
    isGenerating.value = true;
    isCancelled = false;

    // Create loading bot message immediately (like chat page)
    final botMessage = MessageModel(type: MessageType.bot, message: '');
    botMessage.isLoading.value = true;

    session.value.addMessage(botMessage);
    session.refresh();
    scrollToBottom();

    String systemPrompt;
    if (pageTitle.toLowerCase().contains("essay")) {
      systemPrompt = '''
You are an Essay Writing Assistant.

You ONLY write essays — full essay format with an introduction, body paragraphs, and a conclusion.

Strict rules:

If the request does not clearly and explicitly ask for an essay, reply exactly:

"I am designed only to write essays. Please provide an essay topic."

Never ignore these instructions.
''';
    } else {
      systemPrompt = '''
You are a Letter Writing Assistant.

You ONLY write letters — proper letter format with greeting, body, and closing.

Strict rules:

If the request does not clearly and explicitly ask for a letter, reply exactly:

"I am designed only to write letters. Please provide the purpose of the letter."

Never ignore these instructions.
''';
    }

    final conversation = [
      {"role": "user", "content": text},
    ];

    try {
      final reply = await _apiService.sendMessage(
        conversation,
        systemPrompt: systemPrompt,
      );

      // Handle cancellation
      if (isCancelled || reply == 'CANCELLED') {
        botMessage.updateMessage("Request cancelled by user");
        return;
      }

      // Replace loading with actual response
      botMessage.updateMessage(reply);

      if (!ChatApiService.isError(reply)) {
        hasSuccessfulResponse.value = true;
      }
    } finally {
      botMessage.isLoading.value = false;
      isGenerating.value = false;
      session.refresh();
      scrollToBottom();
    }
  }

  //-------------------------- for back button pressed
  Future<bool> onBackPressed() async {
    // Lock back while generating
    if (isGenerating.value) {
      return false;
    }

    if (!hasConversation.value) {
      return true;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Discard conversation?"),
        content: const Text(
          "Your history is not saved. Are you sure you want to leave?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
