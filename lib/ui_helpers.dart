import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Image provider for a game item / draw: a cached NETWORK image when [path] is
/// a URL (the dynamic admin-managed images), else a bundled AssetImage (initial
/// fallback before the dynamic list loads). The ?v=<mtime> on dynamic URLs makes
/// a re-uploaded image refresh automatically.
ImageProvider itemImageProvider(String path) =>
    path.startsWith('http') ? CachedNetworkImageProvider(path) : AssetImage(path);

/// Centered success dialog (e.g. after a ticket purchase). Stays on screen,
/// clearly visible, until the user taps OK.
void showSuccessDialog(String message) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 56),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E2B76),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

/// Yes/No confirmation dialog. Resolves to true only if the user confirms.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
  Color confirmColor = Colors.red,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
    barrierDismissible: false,
  );
  return result ?? false;
}

/// A small white spinner sized to sit inside a button in place of its label,
/// used to show an action is in progress (and the button is disabled).
Widget buttonSpinner() => const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );

/// Removes HTML tags / entities (e.g. the `<br><span>JACKPOT 2X</span>` the
/// server stores in 'drawopen') and collapses whitespace, so values render as
/// clean readable text in the history table.
String stripHtml(String? s) {
  if (s == null) return '';
  return s
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Groups draw rows that share the same (drawdate, drawtime) into ONE entry:
/// the names are joined with ' / ' (in id order, e.g. "A / B") and the first
/// selected row's image is kept. Mirrors the web's getGroupedDrawCards so a
/// "Double Dhamaka" (two draws in one slot) shows a single image with both
/// names instead of two separate cards.
///
/// Input rows are the raw API maps (keys 'image','tktname','drawdate'/'date',
/// 'drawtime'/'time', optional 'id'), newest-first; output keeps that slot order.
List<Map<String, dynamic>> groupDrawsBySlot(List<dynamic> rows) {
  final List<String> order = [];
  final Map<String, List<Map<String, dynamic>>> groups = {};
  for (final raw in rows) {
    if (raw is! Map) continue;
    final row = Map<String, dynamic>.from(raw);
    final date = (row['drawdate'] ?? row['date'] ?? '').toString();
    final time = (row['drawtime'] ?? row['time'] ?? '').toString();
    final key = '$date|$time';
    if (!groups.containsKey(key)) {
      groups[key] = [];
      order.add(key);
    }
    groups[key]!.add(row);
  }

  final List<Map<String, dynamic>> out = [];
  for (final key in order) {
    final g = groups[key]!;
    g.sort((a, b) => (int.tryParse('${a['id']}') ?? 0)
        .compareTo(int.tryParse('${b['id']}') ?? 0));
    final names = g
        .map((r) => (r['tktname'] ?? r['title'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .join(' / ');
    out.add({
      'image': g.first['image'],
      'tktname': names,
      'drawdate': (g.first['drawdate'] ?? g.first['date'] ?? '').toString(),
      'drawtime': (g.first['drawtime'] ?? g.first['time'] ?? '').toString(),
    });
  }
  return out;
}

/// One cell of the compact history [Table]. Text wraps to fit the column so the
/// whole 7-column table fits the screen width with no horizontal scrolling.
Widget historyCell(String text,
    {bool header = false, Color? color, TextAlign align = TextAlign.center}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
    child: Text(
      text,
      textAlign: align,
      softWrap: true,
      style: TextStyle(
        fontSize: header ? 11 : 11.5,
        height: 1.15,
        fontWeight: header ? FontWeight.bold : FontWeight.w500,
        color: header ? Colors.white : color,
      ),
    ),
  );
}
