import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/models/stage_model.dart';
import '../providers/stage_provider.dart';

class StageSelectPage extends HookConsumerWidget {
  const StageSelectPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageListAsync = ref.watch(stageListProvider);

    return Scaffold(
      appBar: AppBar(title: Text("ステージを選ぶ")),
      body: stageListAsync.when(
        data:
            (stages) => GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: stages.length,
              itemBuilder: (_, index) {
                final stage = stages[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/play/${stage.id}');
                  },
                  child: _StageCard(stage: stage),
                );
              },
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("エラーが発生しました")),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage});

  final StageModel stage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          children: [
            Text(stage.name, style: TextStyle(fontSize: 18)),
            Text(stage.height.toString(), style: TextStyle(fontSize: 18)),
            Text(stage.width.toString(), style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
