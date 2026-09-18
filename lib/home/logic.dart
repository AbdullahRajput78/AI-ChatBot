import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/chat_history_service.dart';

class HomeLogic extends GetxController {
  final ChatHistoryService _historyService = ChatHistoryService();

  final RxList<Map<String, dynamic>> recentSessions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingSessions = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSessions();
  }

  Future<void> loadRecentSessions() async {
    isLoadingSessions.value = true;
    final sessions = await _historyService.getRecentSessions(4);
    recentSessions.assignAll(sessions);
    isLoadingSessions.value = false;
  }

  Future<void> deleteSession(int sessionId) async {
    await _historyService.deleteSession(sessionId);
    await loadRecentSessions();
  }

  Future<void> renameSession(int sessionId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _historyService.updateSessionTitle(sessionId, newTitle.trim());
    await loadRecentSessions();
  }

  void showDeleteDialog(int sessionId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text('This will permanently delete this conversation.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteSession(sessionId);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
