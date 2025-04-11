import 'package:flutter/material.dart';
import 'package:room_fit/models/furniture_model.dart';
import 'grid_view.dart';

class CustomGridDisplay extends StatelessWidget {
  const CustomGridDisplay({
    super.key,
    required this.grid,
    required this.colNum,
    required this.rowNum,
    this.cellSize = 10,
    this.onCellTap,
    this.placedFurnitures = const [],
  });

  final List<List<bool>> grid;
  final int colNum;
  final int rowNum;
  final int cellSize;
  final Function(int x, int y)? onCellTap;
  final List<PlacedFurniture>? placedFurnitures;

  bool _validPlacement(PlacedFurniture furniture) {
    // グリッドの範囲チェック
    if (furniture.x < 0 ||
        furniture.y < 0 ||
        furniture.x + furniture.furniture.width > colNum ||
        furniture.y + furniture.furniture.height > rowNum) {
      return false;
    }

    // 配置可能なセルかチェック
    for (
      var y = furniture.y;
      y < furniture.y + furniture.furniture.height;
      y++
    ) {
      for (
        var x = furniture.x;
        x < furniture.x + furniture.furniture.width;
        x++
      ) {
        if (!grid[y][x]) {
          return false;
        }
      }
    }

    // 他の家具との重なりチェック
    if (placedFurnitures != null) {
      for (var otherFurniture in placedFurnitures!) {
        if (furniture == otherFurniture) continue;

        if (furniture.x < otherFurniture.x + otherFurniture.furniture.width &&
            furniture.x + furniture.furniture.width > otherFurniture.x &&
            furniture.y < otherFurniture.y + otherFurniture.furniture.height &&
            furniture.y + furniture.furniture.height > otherFurniture.y) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (placedFurnitures != null) {
      for (var furniture in placedFurnitures!) {
        if (!_validPlacement(furniture)) {
          return Center(
            child: Text('家具が配置できません', style: TextStyle(color: Colors.red)),
          );
        }
      }
    }

    return Padding(
      padding: EdgeInsets.all(8),
      child: SizedBox(
        width: colNum * cellSize.toDouble(),
        height: rowNum * cellSize.toDouble(),
        child: Stack(
          children: [
            CustomGridView(
              grid: grid,
              colNum: colNum,
              rowNum: rowNum,
              cellSize: cellSize.toDouble(),
              onCellTap: onCellTap,
            ),
            ...?placedFurnitures?.map((furniture) {
              return Positioned(
                left: furniture.x * cellSize.toDouble(),
                top: furniture.y * cellSize.toDouble(),
                width: furniture.furniture.width * cellSize.toDouble(),
                height: furniture.furniture.height * cellSize.toDouble(),
                child: CustomGridView(
                  grid: furniture.furniture.grid,
                  colNum: furniture.furniture.width,
                  rowNum: furniture.furniture.height,
                  cellSize: cellSize.toDouble(),
                  cellColor: Colors.blue.withAlpha(77),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
