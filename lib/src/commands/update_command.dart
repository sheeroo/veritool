import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:veritool/src/command_runner.dart';
import 'package:veritool/src/version.dart';
import 'package:yaml/yaml.dart';

import '../utils/yaml_writer.dart';

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Update the CLI.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    // Read the current version number from the pubspec.yaml file
    final pubspecFile = File('pubspec.yaml');
    final pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final currentVersion = Version.parse(pubspecYaml['version'] as String);

    final buildNumber = int.parse(currentVersion.toString().split('+').last);
    // Print the current version number to the console

    _logger.info(
      lightCyan.wrap('Current version: $currentVersion + $buildNumber'),
    );

    // Update the pubspec.yaml file with the new version number
    final mutableYamlMap = {...pubspecYaml};

    final result = _logger.chooseOne(
      'What version would you like to update to?',
      choices: Choices.all,
    );

    Version nextVersion;

    switch (result) {
      case Choices.current: // current
        nextVersion = currentVersion;
        break;
      case Choices.nextMajor: // next major
        nextVersion = currentVersion.nextMajor;
        break;
      case Choices.nextMinor: // next minor
        nextVersion = currentVersion.nextMinor;
        break;
      case Choices.nextPatchVersion: // next patch
        nextVersion = currentVersion.nextPatch;
        break;
      default:
        throw Exception('Invalid choice');
    }

    final newVersionWithBuild = '$nextVersion+${buildNumber + 1}';
    mutableYamlMap['version'] = newVersionWithBuild;

    final writer = YamlWriter();

    pubspecFile.writeAsStringSync(writer.write(mutableYamlMap));

    _logger.success('Version updated to $newVersionWithBuild');

    return ExitCode.success.code;
  }
}

class Choices {
  static const current = 'current';
  static const nextMajor = 'nextMajor';
  static const nextMinor = 'nextMinor';
  static const nextPatchVersion = 'nextPatchVersion';

  static const all = [
    current,
    nextMajor,
    nextMinor,
    nextPatchVersion,
  ];
}
