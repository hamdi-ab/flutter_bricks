import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'config/env/env_config.dart';
import 'config/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Production entry point (no DevicePreview)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = await bootstrap(flavor: Flavor.prod);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: '{{project_name.titleCase()}}',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
