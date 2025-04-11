import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../components/error.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            LoginButtons(
              emailController: emailController,
              passwordController: passwordController,
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButtons extends ConsumerWidget {
  const LoginButtons({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Future<void> onSignIn() async {
      await ref
          .read(authProvider.notifier)
          .signInWithEmail(emailController.text, passwordController.text);
    }

    Future<void> onSignUp() async {
      await ref
          .read(authProvider.notifier)
          .signUpWithEmail(emailController.text, passwordController.text);
    }

    return authState.when(
      data:
          (_) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: onSignIn, child: const Text('Login')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: onSignUp, child: const Text('Sign Up')),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) {
        if (context.mounted) {
          showErrorSnackBar(context, 'エラーが発生しました');
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: onSignIn, child: const Text('Login')),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: onSignUp, child: const Text('Sign Up')),
          ],
        );
      },
    );
  }
}
