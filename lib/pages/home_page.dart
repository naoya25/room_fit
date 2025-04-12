import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to RoomFit!'),
            TextButton(
              onPressed: () => context.push('/select'),
              child: const Text('ステージを選ぶ'),
            ),
            TextButton(
              onPressed: () => context.push('/stage_creation'),
              child: const Text('ステージを作成する'),
            ),
          ],
        ),
      ),
    );
  }
}
