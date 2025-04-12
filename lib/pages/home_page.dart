import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../components/action_card.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomFit'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.inversePrimary),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Welcome to RoomFit!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '理想の部屋を作ってみよう！',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ActionCard(
                    title: 'お部屋一覧',
                    icon: Icons.home_work_outlined,
                    description: '作った部屋を見てみよう',
                    onTap: () => context.push('/select'),
                  ),
                  const SizedBox(height: 16),
                  ActionCard(
                    title: 'お部屋を作成する',
                    icon: Icons.architecture_outlined,
                    description: '新しい部屋を作ってみよう',
                    onTap: () => context.push('/stage_creation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
