import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/stage_provider.dart';

class StagePlayPage extends HookConsumerWidget {
  final String stageId;

  const StagePlayPage({super.key, required this.stageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageAsync = ref.watch(stageDetailProvider(stageId));

    return Scaffold(
      appBar: AppBar(title: Text("ステージプレイ")),
      body: stageAsync.when(
        data: (stage) {
          final grid = stage.roomGrid;

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: stage.width,
                  ),
                  itemCount: stage.height * stage.width,
                  itemBuilder: (context, index) {
                    final x = index % stage.width;
                    final y = index ~/ stage.width;
                    final cellValue = grid[y][x];

                    return Container(
                      margin: EdgeInsets.all(1),
                      color: cellValue == 1 ? Colors.white : Colors.grey[300],
                      child: Center(child: Text("$x,$y")),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("読み込みエラー: $e")),
      ),
    );
  }
}
