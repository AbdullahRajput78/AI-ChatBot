import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import '../models/message_model.dart';
import 'ChatApiService.dart';
import 'chat_history_service.dart';

class PdfExportResult {
  final bool success;

  final String message;
  final String? filePath;

  PdfExportResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

//---------- outside class functions ---------------
String formatDateTime(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$day-$month-${dt.year}, $hour:$minute $period';
}

class PdfExportService {
  final ChatHistoryService _historyService = ChatHistoryService();

  static pw.Font? _cachedBaseFont;
  static pw.Font? _cachedBoldFont;
  static List<pw.Font>? _cachedFallbackFonts;
  static pw.Font? _cachedEmojiFont;
  static Future<void>? _fontLoadFuture;

  Future<void> _loadFontsIfNeeded() async {
    if (_cachedBaseFont != null &&
        _cachedBoldFont != null &&
        _cachedFallbackFonts != null &&
        _cachedEmojiFont != null) {
      return;
    }

    final existingLoad = _fontLoadFuture;
    if (existingLoad != null) {
      await existingLoad;
      return;
    }

    final loadFuture = _loadFonts();
    _fontLoadFuture = loadFuture;
    try {
      await loadFuture;
    } catch (_) {
      _fontLoadFuture = null;
      rethrow;
    }
  }

  Future<void> _loadFonts() async {
    final baseData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf');
    final devanagariData = await rootBundle.load(
      'assets/fonts/NotoSansDevanagari-Regular.ttf',
    );
    final scData = await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf');
    final emojiData = await rootBundle.load(
      'assets/fonts/NotoSansSymbols2-Regular.ttf',
    );
    final emojiFont = await PdfGoogleFonts.notoEmojiRegular();

    _cachedBaseFont = pw.Font.ttf(baseData);
    _cachedBoldFont = pw.Font.ttf(boldData);

    _cachedFallbackFonts = [
      pw.Font.ttf(devanagariData),
      pw.Font.ttf(scData),
      pw.Font.ttf(emojiData),
    ];
    _cachedEmojiFont = emojiFont;
  }

  Future<PdfExportResult> exportSessionFromDb({
    required int sessionId,
    required String title,
    Map<int, PdfVersionSelection> selectedVersions = const {},
  }) async {
    try {
      final messageRows = await _historyService.getMessagesForSession(
        sessionId,
      );

      if (messageRows.isEmpty) {
        return PdfExportResult(
          success: false,
          message: 'Nothing to export yet — this chat has no saved messages.',
        );
      }

      final List<_MessagePair> pairs = [];

      for (final row in messageRows) {
        final isUser = row['type'] == 'user';
        final baseTime = DateTime.parse(row['createdAt'] as String);

        if (isUser) {
          pairs.add(
            _MessagePair(
              isUser: true,
              content: row['content'] as String,
              timestamp: baseTime,
            ),
          );
          continue;
        }

        final selection = selectedVersions[row['id'] as int];
        if (selection == null) {
          pairs.add(
            _MessagePair(
              isUser: false,
              content: row['content'] as String,
              timestamp: baseTime,
            ),
          );
        } else {
          pairs.add(
            _MessagePair(
              isUser: false,
              content: selection.content,
              timestamp: baseTime,
              versionNumber: selection.versionNumber,
              totalVersions: selection.totalVersions,
            ),
          );
        }
      }

      return await _buildAndSave(title: title, pairs: pairs);
    } catch (e) {
      return PdfExportResult(
        success: false,
        message: 'Failed to read chat data: $e',
      );
    }
  }

  Future<PdfExportResult> exportMessages({
    required String title,
    required List<MessageModel> messages,
  }) async {
    try {
      final pairs = messages
          .where(
            (m) =>
                !ChatApiService.isError(m.message) &&
                m.message != 'Request cancelled by user' &&
                m.message.trim().isNotEmpty,
          )
          .map(
            (m) => _MessagePair(
              isUser: m.type == MessageType.user,
              content: m.message,
              timestamp: DateTime.now(),
            ),
          )
          .toList();

      if (pairs.isEmpty) {
        return PdfExportResult(
          success: false,
          message:
              'Nothing to export yet — no successful response has been generated.',
        );
      }

      return await _buildAndSave(title: title, pairs: pairs);
    } catch (e) {
      return PdfExportResult(
        success: false,
        message: 'Failed to prepare export: $e',
      );
    }
  }

  Future<PdfExportResult> _buildAndSave({
    required String title,
    required List<_MessagePair> pairs,
  }) async {
    try {
      await _loadFontsIfNeeded();

      final baseFont = _cachedBaseFont;
      final boldFont = _cachedBoldFont;
      final fallbackFonts = _cachedFallbackFonts;
      final emojiFont = _cachedEmojiFont;
      if (baseFont == null ||
          boldFont == null ||
          fallbackFonts == null ||
          emojiFont == null) {
        return PdfExportResult(
          success: false,
          message: 'Failed to load PDF fonts. Please try again.',
        );
      }

      final List<pw.Widget> contentWidgets = [];
      for (final pair in pairs) {
        final roleLabel = pair.isUser ? 'User' : 'Assistant';

        // Header for the message
        contentWidgets.add(
          pw.Text(
            roleLabel,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepPurple700,
            ),
          ),
        );
        contentWidgets.add(pw.SizedBox(height: 4));

        if (pair.isUser) {
          contentWidgets.add(
            pw.Paragraph(
              text: pair.content,
              style: const pw.TextStyle(fontSize: 12),
              margin: const pw.EdgeInsets.only(bottom: 14),
            ),
          );
        } else {
          final html = md.markdownToHtml(pair.content);
          final markdownWidgets = await HTMLToPdf().convert(html);

          for (var mw in markdownWidgets) {
            contentWidgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: mw,
              ),
            );
          }
          contentWidgets.add(pw.SizedBox(height: 10));
        }
      }

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          maxPages: 500,
          theme: pw.ThemeData.withFont(
            base: baseFont,
            bold: boldFont,
            fontFallback: [...fallbackFonts, emojiFont],
          ),
          header: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  formatDateTime(DateTime.now()),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          build: (context) => contentWidgets,
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ),
      );

      final bytes = await doc.save();
      final dir = await getTemporaryDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final fileName = '${safeTitle.isEmpty ? 'Chat Export' : safeTitle}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      return PdfExportResult(
        success: true,
        message: 'PDF ready to share.',
        filePath: file.path,
      );
    } catch (e) {
      return PdfExportResult(
        success: false,
        message: 'Failed to generate PDF: $e',
      );
    }
  }

  Future<PdfExportResult> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
      return PdfExportResult(success: true, message: 'PDF shared.');
    } catch (e) {
      return PdfExportResult(
        success: false,
        message: 'Failed to open share sheet: $e',
      );
    }
  }
}

class _MessagePair {
  final bool isUser;
  final String content;
  final DateTime timestamp;
  final int? versionNumber;
  final int? totalVersions;

  _MessagePair({
    required this.isUser,
    required this.content,
    required this.timestamp,
    this.versionNumber,
    this.totalVersions,
  });
}

class PdfVersionSelection {
  final String content;
  final int versionNumber;
  final int totalVersions;

  const PdfVersionSelection({
    required this.content,
    required this.versionNumber,
    required this.totalVersions,
  });
}
