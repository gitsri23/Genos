import 'package:photo_manager/photo_manager.dart';

class VideoScanner {
  static Future<List<AssetPathEntity>> getAlbums() async {
    // Smooth permission request
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
    if (ps.isAuth || ps.hasAccess) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        filterOption: FilterOptionGroup(
          videoOption: const FilterOption(
            needTitle: true,
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
        ),
      );
      return albums;
    } 
    // Permission ivvakapothe empty list isthundi kani settings loki force ga pampadhu
    return [];
  }
}
