import 'database_helper.dart';
import '../models/message_model.dart';

class ChatHistoryService {
  final _dbHelper = DatabaseHelper.instance;

  /// Creates a new session row, returns its DB id.
  Future<int> insertSession(String title) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('sessions', {
      'title': title,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> touchSessionUpdatedAt(int sessionId) async {
    final db = await _dbHelper.database;
    await db.update(
      'sessions',
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> updateSessionTitle(int sessionId, String title) async {
    final db = await _dbHelper.database;
    await db.update(
      'sessions',
      {'title': title},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Inserts a new message row, returns its DB id.
  Future<int> insertMessage({
    required int sessionId,
    required MessageType type,
    required String content,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('messages', {
      'sessionId': sessionId,
      'type': type == MessageType.user ? 'user' : 'bot',
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Overwrites an existing message's content (used when regenerate succeeds again).
  Future<void> updateMessageContent(int messageId, String content) async {
    final db = await _dbHelper.database;
    await db.update(
      'messages',
      {'content': content},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// All sessions, newest first — for the History list page.
  Future<List<Map<String, dynamic>>> getAllSessions() async {
    final db = await _dbHelper.database;
    return await db.query('sessions', orderBy: 'updatedAt DESC');
  }

  /// All messages for one session, oldest first — to rebuild a ChatSessionModel.
  Future<List<Map<String, dynamic>>> getMessagesForSession(
    int sessionId,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'createdAt ASC',
    );
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<List<Map<String, dynamic>>> getRecentSessions(int limit) async {
    final db = await _dbHelper.database;
    return await db.query('sessions', orderBy: 'updatedAt DESC', limit: limit);
  }

  Future<void> deleteAllSessions() async {
    final db = await _dbHelper.database;
    await db.delete('sessions');
  }

  Future<int> insertMessageVersion({
    required int messageId,
    required String content,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('message_versions', {
      'messageId': messageId,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getVersionsForMessage(
    int messageId,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'message_versions',
      where: 'messageId = ?',
      whereArgs: [messageId],
      orderBy: 'createdAt ASC',
    );
  }
}
