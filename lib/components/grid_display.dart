import 'package:flutter/material.dart';
import 'package:room_fit/models/furniture_model.dart';

class CustomGridDisplay extends StatelessWidget {
  const CustomGridDisplay({
    super.key,
    required this.grid,
    required this.width,
    required this.height,
    this.cellSize = 10,
    this.onCellTap,
    this.placedFurnitures = const [],
  });

  final List<List<bool>> grid;
  final int width;
  final int height;
  final int cellSize;
  final Function(int x, int y)? onCellTap;
  final List<PlacedFurniture>? placedFurnitures;

  bool _isFurnitureInBounds(PlacedFurniture furniture) {
    return furniture.x >= 0 &&
        furniture.y >= 0 &&
        furniture.x + furniture.furniture.width <= width &&
        furniture.y + furniture.furniture.height <= height;
  }

  bool _isFurnitureOverlapping(PlacedFurniture furniture) {
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
          return true;
        }
      }
    }
    return false;
  }

  Border? _getBorder(int x, int y) {
    if (!grid[y][x]) return null;

    final directions = [
      [0, -1],
      [0, 1],
      [-1, 0],
      [1, 0],
    ];

    BorderSide? top;
    BorderSide? bottom;
    BorderSide? left;
    BorderSide? right;

    for (var dir in directions) {
      final newX = x + dir[0];
      final newY = y + dir[1];

      final isBoundary =
          newX < 0 ||
          newX >= width ||
          newY < 0 ||
          newY >= height ||
          !grid[newY][newX];

      if (isBoundary) {
        if (dir[0] == 0 && dir[1] == -1) {
          top = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == 0 && dir[1] == 1) {
          bottom = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == -1 && dir[1] == 0) {
          left = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == 1 && dir[1] == 0) {
          right = BorderSide(color: Colors.black, width: 1);
        }
      }
    }

    if (top == null && bottom == null && left == null && right == null) {
      return null;
    }

    return Border(
      top: top ?? BorderSide.none,
      bottom: bottom ?? BorderSide.none,
      left: left ?? BorderSide.none,
      right: right ?? BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (placedFurnitures != null) {
      for (var furniture in placedFurnitures!) {
        if (!_isFurnitureInBounds(furniture)) {
          return Center(
            child: Text(
              '家具が部屋の範囲外に配置されています',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (_isFurnitureOverlapping(furniture)) {
          return Center(
            child: Text(
              '家具が壁や他の家具と重なっています',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
      }
    }

    return Padding(
      padding: EdgeInsets.all(8),
      child: SizedBox(
        width: width * cellSize.toDouble(),
        height: height * cellSize.toDouble(),
        child: Stack(
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width,
              ),
              physics: NeverScrollableScrollPhysics(),
              itemCount: height * width,
              itemBuilder: (context, index) {
                final x = index % width;
                final y = index ~/ width;
                final cellValue = grid[y][x];

                return GestureDetector(
                  onTap: () => onCellTap?.call(x, y),
                  child: Container(
                    width: cellSize.toDouble(),
                    height: cellSize.toDouble(),
                    decoration: BoxDecoration(
                      color: cellValue ? Colors.white : Colors.transparent,
                      border: _getBorder(x, y),
                    ),
                  ),
                );
              },
            ),
            ...?placedFurnitures?.map((furniture) {
              return Positioned(
                left: furniture.x * cellSize.toDouble(),
                top: furniture.y * cellSize.toDouble(),
                width: furniture.furniture.width * cellSize.toDouble(),
                height: furniture.furniture.height * cellSize.toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(77),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      furniture.furniture.name,
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
