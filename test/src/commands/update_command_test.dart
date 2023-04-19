import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:veritool/src/command_runner.dart';
import 'package:veritool/src/commands/commands.dart';

class _MockLogger extends Mock implements Logger {}

class _MockProcessResult extends Mock implements ProcessResult {}

class _MockProgress extends Mock implements Progress {}

void main() {
  const latestVersion = '0.0.0';

  group('update', () {
    late Logger logger;
    late ProcessResult processResult;
    late VeritoolCommandRunner commandRunner;

    setUp(() {
      final progress = _MockProgress();
      final progressLogs = <String>[];
      logger = _MockLogger();
      processResult = _MockProcessResult();
      commandRunner = VeritoolCommandRunner(
        logger: logger,
      );

      when(() => progress.complete(any())).thenAnswer((_) {
        final message = _.positionalArguments.elementAt(0) as String?;
        if (message != null) progressLogs.add(message);
      });
      when(() => logger.progress(any())).thenReturn(progress);
      when(() => processResult.exitCode).thenReturn(ExitCode.success.code);
    });

    test('can be instantiated without a pub updater', () {
      final command = UpdateCommand(logger: logger);
      expect(command, isNotNull);
    });
  });
}
