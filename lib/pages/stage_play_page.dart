import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/components/error.dart';
import '../components/grid/custom_grid_display.dart';
import '../models/furniture_model.dart';
import '../providers/furniture/continuous_furniture_provider.dart';
import '../providers/stage_provider.dart';

class StagePlayPage extends HookConsumerWidget {
  final String stageId;

  const StagePlayPage({super.key, required this.stageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageAsync = ref.watch(stageDetailProvider(stageId));
    final furnitureQueue = ref.watch(continuousFurnitureQueueProvider);
    final placedFurnitures = useState<List<PlacedFurniture>>([]);

    bool validPlacement(
      int x,
      int y,
      FurnitureModel currentFurniture,
      List<PlacedFurniture> placedFurnitures,
    ) {
      if (stageAsync.value == null) return false;
      if (x < 0 ||
          y < 0 ||
          x > stageAsync.value!.width ||
          y > stageAsync.value!.height) {
        return false;
      }

      // ステージの範囲チェック
      for (var i = y; i < y + currentFurniture.height; i++) {
        for (var j = x; j < x + currentFurniture.width; j++) {
          if (!stageAsync.value!.roomGrid[i][j] &&
              currentFurniture.grid[i - y][j - x]) {
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

    void placeFurnitureAt(int x, int y) {
      if (furnitureQueue?.isEmpty == true) return;

      final furniture = furnitureQueue!.first;

      if (!validPlacement(x, y, furniture, placedFurnitures.value)) {
        showErrorSnackBar(context, '家具が配置できません');
        return;
      }

      placedFurnitures.value = [
        ...placedFurnitures.value,
        PlacedFurniture(furniture: furniture, x: x, y: y),
      ];
      ref.read(continuousFurnitureQueueProvider.notifier).removeFirst();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ステージプレイ')),
      body: stageAsync.when(
        data: (stage) {
          final cellSize =
              MediaQuery.of(context).size.width * 0.9 ~/ stage.width;
          return Column(
            children: [
              CustomGridDisplay(
                grid: stage.roomGrid,
                colNum: stage.width,
                rowNum: stage.height,
                cellSize: cellSize,
                onCellTap: placeFurnitureAt,
                placedFurnitures: placedFurnitures.value,
              ),
              if (furnitureQueue?.isNotEmpty == true) ...[
                Text("次の家具: ${furnitureQueue!.first.name}"),
                CustomGridDisplay(
                  grid: furnitureQueue.first.grid,
                  colNum: furnitureQueue.first.width,
                  rowNum: furnitureQueue.first.height,
                  cellSize: cellSize,
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
