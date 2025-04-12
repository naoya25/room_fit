import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/components/error.dart';
import 'package:room_fit/core/utils/valid_grid_placement.dart';
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

    void placeFurnitureAt(int x, int y) {
      if (furnitureQueue?.isEmpty == true) return;

      final furniture = furnitureQueue!.first;

      if (stageAsync.value == null ||
          !validPlacement(
            x,
            y,
            furniture,
            placedFurnitures.value,
            stageAsync.value!,
          )) {
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
