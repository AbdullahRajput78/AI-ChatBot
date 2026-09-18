import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/ChatApiService.dart';

class GrammarLogic extends GetxController {
  final ChatApiService _apiService = ChatApiService();

  bool get hasData => textController.text.trim().isNotEmpty || result.value.isNotEmpty;

  final TextEditingController textController = TextEditingController();

  RxBool isChecker = true.obs;
  RxBool copied = false.obs;
  RxInt characterCount = 0.obs;
  RxString result = "".obs;
  RxBool isLoading = false.obs;

  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      characterCount.value = textController.text.length;
    });
  }

  String get _systemPrompt {
    if (isChecker.value) {
      return 'You are a grammar checker. Only fix grammar, spelling, and punctuation mistakes in the text given to you. Do not change meaning, tone, or style. Return only the corrected text.';
    } else {
      return 'You are a writing enhancer. Improve clarity, tone, and word choice of the text given to you, while keeping the original meaning. Return only the enhanced text.';
    }
  }

  Future<void> checkGrammar() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      result.value = "Please enter some text first.";
      return;
    }

    isLoading.value = true;
    _cancelToken = CancelToken();
    try {
      final reply = await _apiService.sendMessage(
        [
          {'role': 'user', 'content': text}
        ],
        cancelToken: _cancelToken,
        systemPrompt: _systemPrompt,
      );
      result.value = reply;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enhanceText() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      result.value = "Please enter some text first.";
      return;
    }

    isLoading.value = true;
    _cancelToken = CancelToken();
    try {
      final reply = await _apiService.sendMessage(
        [
          {'role': 'user', 'content': text}
        ],
        cancelToken: _cancelToken,
        systemPrompt: _systemPrompt,
      );
      result.value = reply;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> copyResult() async {
    await Clipboard.setData(ClipboardData(text: result.value));
    copied.value = true;
    await Future.delayed(const Duration(seconds: 2));
    copied.value = false;
  }

  Future<void> performAction() async {
    if (isChecker.value) {
      await checkGrammar();
    } else {
      await enhanceText();
    }
  }

  void stopGenerating() {
    _cancelToken?.cancel('User cancelled the request');
    isLoading.value = false;
  }

  void clearAll() {
    textController.clear();
    result.value = "";
    characterCount.value = 0;
    isLoading.value = false;
    isChecker.value = true;
    copied.value = false;
  }

  void switchMode(bool checker) {
    if (isLoading.value) return;
    isChecker.value = checker;
    result.value = '';
  }

  /// Shared back-navigation logic used by both the hardware back button
  /// and the app bar's back arrow — keeps both in sync.
  Future<bool> onBackPressed() async {
    if (isLoading.value) {
      return false; // silently blocked while generating
    }

    if (!hasData) {
      clearAll();
      return true;
    }

    final shouldLeave = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Discard Conversation?'),
        content: const Text('You have unsaved text or results. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      clearAll();
      return true;
    }
    return false;
  }

  @override
  void onClose() {
    clearAll();
    textController.dispose();
    super.onClose();
  }
}