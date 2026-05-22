import 'dart:convert';
import 'dart:io';

Future<String> downloadBillFile({
  required String fileName,
  required String content,
}) async {
  final bytes = utf8.encode(content);
  final userProfile = Platform.environment['USERPROFILE'];
  final home = Platform.environment['HOME'];
  final root = (userProfile != null && userProfile.isNotEmpty) ? userProfile : home;
  if (root == null || root.isEmpty) {
    throw Exception('Unable to locate user home folder');
  }

  final downloadsPath = Platform.isWindows ? '$root\\Downloads' : '$root/Downloads';
  final downloadsDir = Directory(downloadsPath);
  if (!downloadsDir.existsSync()) {
    downloadsDir.createSync(recursive: true);
  }

  final file = File(
    Platform.isWindows ? '${downloadsDir.path}\\$fileName' : '${downloadsDir.path}/$fileName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
