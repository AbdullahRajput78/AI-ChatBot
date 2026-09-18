import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../customwidgets/pdf_preview_page.dart';
import '../models/chatsession_model.dart';
import '../models/message_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import '../services/ChatApiService.dart';
import '../services/chat_history_service.dart';
import '../services/pdf_export_service.dart';

class StartChatLogic extends GetxController with WidgetsBindingObserver {
  final ChatHistoryService _historyService = ChatHistoryService();
  StartChatLogic({this.initialPrompt});

  //-------------------- for regenerating only one message at a time
  final RxBool regenerationInProgress = false.obs;

  //-------------------- for promptpage > startchat (if chat exist)
  final RxBool hasStartedChat = false.obs;
  final String? initialPrompt;

  //---------------------- for has startedchat (back to home or prompt)
  final RxBool hasChatted = false.obs;

  //---- for API
  final ChatApiService _apiService = ChatApiService();
  CancelToken? _cancelToken;

  final TextEditingController textController = TextEditingController();

  //------------------------ for going to End line after Bot message -----------------
  final ScrollController scrollController = ScrollController();
  //------------- for speak stopping -------------------
  MessageModel? currentlySpeakingMessage;

  final Rx<ChatSessionModel> session = ChatSessionModel().obs;
  final RxBool isGenerating = false.obs;

  //-------------------------- for PDF exporter -----------
  final PdfExportService _pdfService = PdfExportService();
  final RxBool isExporting = false.obs;

  // for speaking
  final FlutterTts flutterTts = FlutterTts();
  int _speechGeneration = 0;
  Timer? _speechCompletionFallbackTimer;

  bool isCancelled = false;

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

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    if (isGenerating.value) return; // Prevent multiple simultaneous requests

    FocusManager.instance.primaryFocus?.unfocus();
    stopSpeakingIfActive();

    // User message
    final userMessage = MessageModel(type: MessageType.user, message: text);

    session.value.addMessage(userMessage);
    hasChatted.value = true;
    session.refresh();
    textController.clear();

    scrollToBottom();

    isGenerating.value = true;
    isCancelled = false;
    _cancelToken = CancelToken();

    // Create loading bot message
    final botMessage = MessageModel(type: MessageType.bot, message: '');

    botMessage.isLoading.value = true;

    session.value.addMessage(botMessage);
    session.refresh();
    scrollToBottom();

    try {
      // Build conversation
      final conversation = session.value.messages
          .where((msg) => !msg.isLoading.value) // Don't send loading message
          .map((msg) {
            return {
              'role': msg.type == MessageType.user ? 'user' : 'assistant',
              'content': msg.message,
            };
          })
          .toList();

      final reply = await _apiService.sendMessage(
        conversation,
        cancelToken: _cancelToken,
      );

      if (isCancelled || reply == 'CANCELLED') {
        botMessage.updateMessage("Request cancelled by user");
      } else {
        // Replace loading with actual response
        botMessage.updateMessage(reply);

        if (!ChatApiService.isError(reply)) {
          // Persist in background to not block UI if DB is slow
          _persistExchange(userMessage, botMessage, reply).catchError((e) {
            debugPrint("Error persisting exchange: $e");
          });
        }
      }
    } catch (e) {
      botMessage.updateMessage(
        "Error: Something went wrong. Please try again.",
      );
      debugPrint("SendMessage error: $e");
    } finally {
      botMessage.isLoading.value = false;
      isGenerating.value = false;
      session.refresh();
      scrollToBottom();
    }
  }

  Future<void> loadSession(int sessionId) async {
    stopSpeakingIfActive();

    final sessionRows = await _historyService.getAllSessions();
    final sessionRow = sessionRows.firstWhere((s) => s['id'] == sessionId);
    final messageRows = await _historyService.getMessagesForSession(sessionId);

    final loadedMessages = <MessageModel>[];

    for (final row in messageRows) {
      final msgId = row['id'] as int;
      final type = row['type'] == 'user' ? MessageType.user : MessageType.bot;

      if (type == MessageType.bot) {
        final versionRows = await _historyService.getVersionsForMessage(msgId);
        final versions = versionRows
            .map((v) => v['content'] as String)
            .toList();

        loadedMessages.add(
          MessageModel(
            id: msgId,
            type: type,
            message: versions.isNotEmpty
                ? versions.last
                : row['content'] as String,
            versions: versions.isNotEmpty
                ? versions
                : [row['content'] as String],
            initialVersionIndex: versions.isNotEmpty ? versions.length - 1 : 0,
          ),
        );
      } else {
        loadedMessages.add(
          MessageModel(
            id: msgId,
            type: type,
            message: row['content'] as String,
          ),
        );
      }
    }

    session.value = ChatSessionModel(
      id: sessionRow['id'] as int,
      title: sessionRow['title'] as String,
      messages: loadedMessages,
    );

    hasChatted.value = loadedMessages.isNotEmpty;
    session.refresh();
    scrollToBottom();
  }

  void cancelGeneration() {
    stopSpeakingIfActive();
    isCancelled = true;
    _cancelToken?.cancel('User cancelled the request');
  }

  Future<void> regenerateMessage(MessageModel message) async {
    if (regenerationInProgress.value) return;
    stopSpeakingIfActive();
    regenerationInProgress.value = true;
    message.isRegenerating.value = true;
    message.isLoading.value = true;

    try {
      isGenerating.value = true;
      session.refresh();

      isCancelled = false;
      _cancelToken = CancelToken();

      final index = session.value.messages.indexOf(message);
      if (index == -1) return;

      final historyUpToHere = session.value.messages.sublist(0, index);

      final conversation = historyUpToHere.map((msg) {
        return {
          'role': msg.type == MessageType.user ? 'user' : 'assistant',
          'content': msg.message,
        };
      }).toList();

      final reply = await _apiService.sendMessage(
        conversation,
        cancelToken: _cancelToken,
      );

      if (isCancelled || reply == 'CANCELLED') {
        final text = 'Request cancelled by user';
        if (message.lastVersionFailed.value) {
          message.updateMessage(text);
        } else {
          message.addVersion(text);
          message.lastVersionFailed.value = true;
        }
      } else if (ChatApiService.isError(reply)) {
        if (message.lastVersionFailed.value) {
          message.updateMessage(reply);
        } else {
          message.addVersion(reply);
          message.lastVersionFailed.value = true;
        }
      } else {
        // real success
        if (message.lastVersionFailed.value) {
          message.updateMessage(reply);
          message.lastVersionFailed.value = false;
        } else {
          message.addVersion(reply);
        }

        if (index > 0) {
          final precedingUserMsg = session.value.messages[index - 1];
          _persistExchange(precedingUserMsg, message, reply).catchError((e) {
            debugPrint("Error persisting regenerated exchange: $e");
          });
        }
      }
    } catch (e) {
      debugPrint("RegenerateMessage error: $e");
    } finally {
      message.isLoading.value = false;
      message.isRegenerating.value = false;
      regenerationInProgress.value = false;
      isGenerating.value = false;
      session.refresh();
    }
  }

  //-------------------------- for every new chat
  void startNewChat() {
    stopSpeakingIfActive();
    session.value = ChatSessionModel();
    // textController.clear();
    isGenerating.value = false;
    isCancelled = false;
    session.refresh();
  }

  void clearChat() {
    startNewChat();
    textController.clear();
  }

  void copyMessage(MessageModel message) {
    Clipboard.setData(ClipboardData(text: message.message)); // copy text
    message.copy.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      message.copy.value = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    startNewChat();
    if (initialPrompt != null && initialPrompt!.isNotEmpty) {
      textController.text = initialPrompt!;
    }

    // Re-enable awaitSpeakCompletion(true) for modern flutter_tts versions.
    // This allows us to simply 'await' the speak call.
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

  //------------------------- for speaking -----------
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

  void goToPreviousVersion(MessageModel message) {
    stopSpeakingIfActive();
    message.goToPrevious();
    session.refresh();
  }

  void goToNextVersion(MessageModel message) {
    stopSpeakingIfActive();
    message.goToNext();
    session.refresh();
  }

  //---------------------- stop function for generating message ---------
  void stopGenerating() {
    stopSpeakingIfActive();
    isCancelled = true;
    isGenerating.value = false;
    // later use API with cancellable requests
  }

  //----------------- for stop speaking function -----------
  Future<void> stopSpeakingIfActive() async {
    _speechGeneration++;
    _cancelSpeechCompletionFallback();
    if (currentlySpeakingMessage != null) {
      await flutterTts.stop();
      currentlySpeakingMessage!.speak.value = false;
      currentlySpeakingMessage = null;
    }
  }

  void _cancelSpeechCompletionFallback() {
    _speechCompletionFallbackTimer?.cancel();
    _speechCompletionFallbackTimer = null;
  }

  //--------------------- for database ------------------
  Future<void> _persistExchange(
    MessageModel userMsg,
    MessageModel botMsg,
    String reply,
  ) async {
    final isFirstExchange = session.value.id == null;

    if (isFirstExchange) {
      final tempTitle = userMsg.message.length > 30
          ? '${userMsg.message.substring(0, 30)}...'
          : userMsg.message;
      session.value.id = await _historyService.insertSession(tempTitle);
      session.value.title.value = tempTitle;
    }

    if (userMsg.id == null) {
      userMsg.id = await _historyService.insertMessage(
        sessionId: session.value.id!,
        type: MessageType.user,
        content: userMsg.message,
      );
    }

    if (botMsg.id == null) {
      // first successful reply for this message — insert row + its first version
      botMsg.id = await _historyService.insertMessage(
        sessionId: session.value.id!,
        type: MessageType.bot,
        content: reply,
      );
      await _historyService.insertMessageVersion(
        messageId: botMsg.id!,
        content: reply,
      );
    } else {
      // a later successful regenerate — update the "current" content, AND log a new version row
      await _historyService.updateMessageContent(botMsg.id!, reply);
      await _historyService.insertMessageVersion(
        messageId: botMsg.id!,
        content: reply,
      );
    }

    if (isFirstExchange) {
      final aiTitle = await _apiService.generateTitle(userMsg.message, reply);
      session.value.title.value = aiTitle;
      await _historyService.updateSessionTitle(session.value.id!, aiTitle);
      session.refresh();
    }

    await _historyService.touchSessionUpdatedAt(session.value.id!);
  }

  //------------------------- for exporting PDF ---------------------
  Future<void> exportToPdf() async {
    stopSpeakingIfActive();
    if (session.value.id == null) {
      Get.snackbar(
        'Nothing to export',
        'Send a message first to generate exportable content.',
      );
      return;
    }

    isExporting.value = true;
    final result = await _pdfService.exportSessionFromDb(
      sessionId: session.value.id!,
      title: session.value.title.value,
    );
    isExporting.value = false;

    if (result.success && result.filePath != null) {
      Get.to(
        () => PdfPreviewPage(
          pdfPath: result.filePath!,
          title: session.value.title.value,
        ),
      );
    } else {
      Get.snackbar('Export failed', result.message);
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
    textController.dispose();
    scrollController.dispose();
    flutterTts.stop();
    super.onClose();
  }

  //--------------------- for going to end function -----------------------
}
