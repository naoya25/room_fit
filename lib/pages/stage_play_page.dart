import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:room_fit/components/grid_display.dart';
import 'package:room_fit/models/furniture_model.dart';
import 'package:room_fit/providers/furniture/continuous_furniture_provider.dart';
import '../providers/stage_provider.dart';

class StagePlayPage extends HookConsumerWidget {
  final String stageId;

  const StagePlayPage({super.key, required this.stageId});

  @override
  Widget build(context, ref) {
    final stageAsync = ref.watch(stageDetailProvider(stageId));
    final furnitureQueue = ref.watch(continuousFurnitureQueueProvider);
    final currentFurniture =
        furnitureQueue?.isNotEmpty == true ? furnitureQueue!.first : null;

    final placedFurnitures = useState<List<PlacedFurniture>>([]);

    void placeFurnitureAt(int x, int y) {
      if (currentFurniture == null) return;
      placedFurnitures.value = [
        ...placedFurnitures.value,
        PlacedFurniture(furniture: currentFurniture, x: x, y: y, rotation: 0),
      ];
      ref.read(continuousFurnitureQueueProvider.notifier).removeFirst();
    }

    return Scaffold(
      appBar: AppBar(title: Text("ステージプレイ")),
      body: stageAsync.when(
        data: (stage) {
          final grid = stage.roomGrid;
          final cellSize = MediaQuery.of(context).size.width ~/ stage.width;

          return Column(
            children: [
              CustomGridDisplay(
                grid: grid,
                width: stage.width,
                height: stage.height,
                cellSize: cellSize,
                onCellTap: placeFurnitureAt,
                placedFurnitures: placedFurnitures.value,
              ),
              if (currentFurniture != null) ...[
                Text("次の家具: ${currentFurniture.name}"),
                CustomGridDisplay(
                  grid: currentFurniture.grid,
                  width: currentFurniture.width,
                  height: currentFurniture.height,
                  cellSize: cellSize,
                ),
              ],
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("読み込みエラー: $e")),
      ),
    );
  }
}
