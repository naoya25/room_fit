import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_fit/pages/stage_play_page.dart';
import 'package:room_fit/pages/stage_select_page.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/select', builder: (_, __) => const StageSelectPage()),
      GoRoute(
        path: '/play/:stageId',
        builder:
            (_, state) =>
                StagePlayPage(stageId: state.pathParameters['stageId']!),
      ),
    ],
  );
});
