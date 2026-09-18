import 'package:get/get.dart';
import '../services/chat_history_service.dart';
import '../home/logic.dart';
import 'package:flutter/material.dart';

class ChathistoryLogic extends GetxController {

  final ChatHistoryService _historyService = ChatHistoryService();

  final RxBool isLoadingSessions = false.obs;

  /// Grouped as { "23-05-2024": [session, session...], "22-05-2024": [...] }
  final RxMap<String, List<Map<String, dynamic>>> groupedSessions =
      <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllSessions();
  }

  Future<void> loadAllSessions() async {
    isLoadingSessions.value = true;
    try {
      final sessions = await _historyService.getAllSessions();
      _groupByDate(sessions);
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void _groupByDate(List<Map<String, dynamic>> sessions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in sessions) {
      final date = DateTime.parse(row['updatedAt'] as String);
      final label = _formatDate(date);
      grouped.putIfAbsent(label, () => []).add(row);
    }
    groupedSessions.assignAll(grouped);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  Future<void> renameSession(int sessionId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    await _historyService.updateSessionTitle(sessionId, newTitle.trim());

    await loadAllSessions();

    if (Get.isRegistered<HomeLogic>()) {
      await Get.find<HomeLogic>().loadRecentSessions();
    }
  }

  Future<void> deleteSession(int sessionId) async {
    await _historyService.deleteSession(sessionId);

    await loadAllSessions();

    if (Get.isRegistered<HomeLogic>()) {
      await Get.find<HomeLogic>().loadRecentSessions();
    }
  }

  Future<void> clearAllSessions() async {
    await _historyService.deleteAllSessions();

    await loadAllSessions();

    if (Get.isRegistered<HomeLogic>()) {
      await Get.find<HomeLogic>().loadRecentSessions();
    }
  }

  //--------------- for delete  history per dialog box
  void showDeleteDialog(int sessionId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text('This will permanently delete this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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

  //--------------- for rename the title
  void showRenameDialog(BuildContext context, ChathistoryLogic logic, Map<String, dynamic> sessionRow) {
    final controller = TextEditingController(text: sessionRow['title'] as String);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              logic.renameSession(sessionRow['id'] as int, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  //---------------- for permenant delete history
  void showClearAllDialog(
      BuildContext context,
      ChathistoryLogic logic,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear all history"),
        content: const Text(
          "Are you sure you want to delete all chat history? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await logic.clearAllSessions();
              Navigator.pop(context);
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}