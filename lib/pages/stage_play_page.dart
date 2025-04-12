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
                placedFurnitures: placedFurnitures.value,
                child: Builder(
                  builder:
                      (gridContext) => DragTarget<FurnitureModel>(
                        onAcceptWithDetails: (details) {
                          final renderBox =
                              gridContext.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(
                            details.offset,
                          );

                          final adjustedX = localPosition.dx - 8;
                          final adjustedY = localPosition.dy - 8;

                          final x = (adjustedX / cellSize).round();
                          final y = (adjustedY / cellSize).round();

                          if (!validPlacement(
                            x,
                            y,
                            details.data,
                            placedFurnitures.value,
                            stage,
                          )) {
                            showErrorSnackBar(context, '家具が配置できません');
                            return;
                          }

                          placedFurnitures.value = [
                            ...placedFurnitures.value,
                            PlacedFurniture(
                              furniture: details.data,
                              x: x,
                              y: y,
                            ),
                          ];
                          ref
                              .read(continuousFurnitureQueueProvider.notifier)
                              .removeFirst();
                        },
                        builder: (context, candidateData, rejectedData) {
                          return SizedBox(
                            width: stage.width * cellSize.toDouble(),
                            height: stage.height * cellSize.toDouble(),
                          );
                        },
                      ),
                ),
              ),
              if (furnitureQueue?.isNotEmpty == true) ...[
                Text("次の家具: ${furnitureQueue!.first.name}"),
                Draggable<FurnitureModel>(
                  data: furnitureQueue.first,
                  feedback: CustomGridDisplay(
                    grid: furnitureQueue.first.grid,
                    colNum: furnitureQueue.first.width,
                    rowNum: furnitureQueue.first.height,
                    cellSize: cellSize,
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: CustomGridDisplay(
                      grid: furnitureQueue.first.grid,
                      colNum: furnitureQueue.first.width,
                      rowNum: furnitureQueue.first.height,
                      cellSize: cellSize,
                    ),
                  ),
                  child: CustomGridDisplay(
                    grid: furnitureQueue.first.grid,
                    colNum: furnitureQueue.first.width,
                    rowNum: furnitureQueue.first.height,
                    cellSize: cellSize,
                  ),
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
