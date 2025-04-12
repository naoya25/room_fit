import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/stage_provider.dart';
import '../components/action_card.dart';

class StageSelectPage extends HookConsumerWidget {
  const StageSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageListAsync = ref.watch(stageListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("お部屋一覧"),
        leading: IconButton(
          icon: Icon(Icons.home, color: theme.colorScheme.inversePrimary),
          onPressed: () => context.go('/'),
        ),
      ),
      body: stageListAsync.when(
        data:
            (stages) => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                childAspectRatio: 3.5,
              ),
              itemCount: stages.length,
              itemBuilder: (_, index) {
                final stage = stages[index];
                return ActionCard(
                  title: stage.name,
                  icon: Icons.home_work_outlined,
                  description: '${stage.width} × ${stage.height}',
                  onTap: () => context.push('/play/${stage.id}'),
                );
              },
            ),
        loading:
            () => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
        error:
            (e, _) => Center(
              child: Text(
                "エラーが発生しました",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
      ),
    );
  }
}
