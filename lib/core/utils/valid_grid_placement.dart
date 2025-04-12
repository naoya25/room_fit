import 'package:room_fit/models/furniture_model.dart';
import 'package:room_fit/models/stage_model.dart';

bool validPlacement(
  int x,
  int y,
  FurnitureModel currentFurniture,
  List<PlacedFurniture> placedFurnitures,
  StageModel stage,
) {
  if (x < 0 || y < 0 || x > stage.width || y > stage.height) {
    return false;
  }

  // ステージの範囲チェック
  for (var i = y; i < y + currentFurniture.height; i++) {
    for (var j = x; j < x + currentFurniture.width; j++) {
      if (!stage.roomGrid[i][j] && currentFurniture.grid[i - y][j - x]) {
        return false;
      }
    }
  }
  // 既存の家具との重なりチェック
  for (var placedFurniture in placedFurnitures) {
    final placedX = placedFurniture.x;
    final placedY = placedFurniture.y;
    final placedGrid = placedFurniture.furniture.grid;
    // 配置しようとしている家具の各セルをチェック
    for (var i = 0; i < currentFurniture.height; i++) {
      for (var j = 0; j < currentFurniture.width; j++) {
        if (!currentFurniture.grid[i][j]) continue;

        final checkX = x + j;
        final checkY = y + i;
        // 既存の家具の範囲内かチェック
        if (checkX >= placedX &&
            checkX < placedX + placedFurniture.furniture.width &&
            checkY >= placedY &&
            checkY < placedY + placedFurniture.furniture.height) {
          // 既存の家具のその位置にセルがあるかチェック
          final relativeX = checkX - placedX;
          final relativeY = checkY - placedY;
          if (placedGrid[relativeY][relativeX]) {
            return false;
          }
        }
      }
    }
  }
  return true;
}
