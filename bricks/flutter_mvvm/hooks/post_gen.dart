import 'dart:io';

void run(HookContext context) async {
  final progress = context.logger.progress('Running flutter pub get');

  try {
    await Process.run('flutter', ['pub', 'get']);
    progress.complete('Dependencies installed');

    context.logger.info('');
    context.logger.info('✅ Project created successfully!');
    context.logger.info('');
    context.logger.info('Next steps:');
    context.logger.info('  1. cd ${context.vars['project_name']}');
    context.logger.info(
      '  2. dart run build_runner build --delete-conflicting-outputs',
    );
    context.logger.info('  3. flutter run');
    context.logger.info('');
  } catch (e) {
    progress.fail('Failed to install dependencies');
    context.logger.err('Error: $e');
  }
}
