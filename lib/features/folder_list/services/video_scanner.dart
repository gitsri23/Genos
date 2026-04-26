import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class VideoScanner {
  static Future<Map<String, List<File>>> getVideosGroupedByFolder() async {
    Map<String, List<File>> groupedVideos = {};
    
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      await Permission.videos.request();
    }

    Directory root = Directory('/storage/emulated/0/'); 
    final videoExtensions = ['.mp4', '.mkv', '.avi', '.mov', '.flv'];

    try {
      List<FileSystemEntity> files = root.listSync(recursive: true, followLinks: false);
      for (var file in files) {
        if (file is File) {
          String extension = p.extension(file.path).toLowerCase();
          if (videoExtensions.contains(extension)) {
            String folderName = p.basename(file.parent.path);
            if (!groupedVideos.containsKey(folderName)) {
              groupedVideos[folderName] = [];
            }
            groupedVideos[folderName]!.add(file);
          }
        }
      }
    } catch (e) {
      // Ignore protected directories
    }
    return groupedVideos;
  }
}
