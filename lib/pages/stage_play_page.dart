import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/components/grid_display.dart';
import 'package:room_fit/models/furniture_model.dart';
import 'package:room_fit/providers/furniture_provider.dart';
import '../providers/stage_provider.dart';

class StagePlayPage extends HookConsumerWidget {
  final String stageId;

  const StagePlayPage({super.key, required this.stageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageAsync = ref.watch(stageDetailProvider(stageId));
    final furnitureQueue = ref.watch(randomFurnitureQueueProvider);

    FurnitureModel? currentFurniture =
        furnitureQueue.value?.isNotEmpty ?? false
            ? furnitureQueue.value?.first
            : null;

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
