import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class VideoScanner {
  static Future<Map<String, List<File>>> getVideosGroupedByFolder() async {
    Map<String, List<File>> groupedVideos = {};
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      var status = await Permission.videos.request();
      if (!status.isGranted) return groupedVideos; 
    } else {
      var status = await Permission.storage.request();
      if (!status.isGranted) return groupedVideos;
    }

    Directory root = Directory('/storage/emulated/0/'); 
    final videoExtensions = ['.mp4', '.mkv', '.avi', '.mov', '.flv'];

    if (!await root.exists()) return groupedVideos;

    try {
      await for (var entity in root.list(recursive: true, followLinks: false).handleError((e) => null)) {
        if (entity is File) {
          String extension = p.extension(entity.path).toLowerCase();
          if (videoExtensions.contains(extension)) {
            String folderName = p.basename(entity.parent.path);
            if (!groupedVideos.containsKey(folderName)) {
              groupedVideos[folderName] = [];
            }
            groupedVideos[folderName]!.add(entity);
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    
    return groupedVideos;
  }
}
