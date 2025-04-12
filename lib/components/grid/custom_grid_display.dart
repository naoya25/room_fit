import 'package:flutter/material.dart';
import 'package:room_fit/core/utils/uuid_to_color.dart';
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
    this.child,
  });

  final List<List<bool>> grid;
  final int colNum;
  final int rowNum;
  final int cellSize;
  final Function(int x, int y)? onCellTap;
  final List<PlacedFurniture>? placedFurnitures;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
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
              cellSize: cellSize,
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
                  cellSize: cellSize,
                  cellColor: generateColorFromUUID(furniture.furniture.id),
                  onCellTap: (x, y) {
                    onCellTap?.call(x + furniture.x, y + furniture.y);
                  },
                ),
              );
            }),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
