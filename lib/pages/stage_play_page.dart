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
    final currentFurniture =
        furnitureQueue?.isNotEmpty == true ? furnitureQueue!.first : null;
    final placedFurnitures = useState<List<PlacedFurniture>>([]);

    bool validPlacement(
      int x,
      int y,
      FurnitureModel currentFurniture,
      List<PlacedFurniture> placedFurnitures,
    ) {
      if (x < 0 ||
          y < 0 ||
          x + currentFurniture.width > stageAsync.value!.width ||
          y + currentFurniture.height > stageAsync.value!.height) {
        return false;
      }

      for (var i = y; i < y + currentFurniture.height; i++) {
        for (var j = x; j < x + currentFurniture.width; j++) {
          if (!stageAsync.value!.roomGrid[i][j]) return false;
        }
      }

      for (var placedFurniture in placedFurnitures) {
        for (var i = y; i < y + currentFurniture.height; i++) {
          for (var j = x; j < x + currentFurniture.width; j++) {
            if (i >= placedFurniture.y &&
                i < placedFurniture.y + placedFurniture.furniture.height &&
                j >= placedFurniture.x &&
                j < placedFurniture.x + placedFurniture.furniture.width) {
              return false;
            }
          }
        }
      }

      return true;
    }

    void placeFurnitureAt(int x, int y) {
      if (currentFurniture == null) return;

      final furniture = currentFurniture;

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
          final cellSize = MediaQuery.of(context).size.width ~/ stage.width;
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
              if (currentFurniture != null) ...[
                Text("次の家具: ${currentFurniture.name}"),
                CustomGridDisplay(
                  grid: currentFurniture.grid,
                  colNum: currentFurniture.width,
                  rowNum: currentFurniture.height,
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
