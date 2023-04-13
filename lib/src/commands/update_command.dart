import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:veritool/src/utils/yaml_writer.dart';
import 'package:yaml/yaml.dart';

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

    final currentVersionWithBuild = pubspecYaml['version'] as String;

    final currentVersion = Version.parse(
      currentVersionWithBuild.split('+').first,
    );

    final buildNumber = int.parse(currentVersionWithBuild.split('+').last);

    _logger.info(
      'Current version:  😩 ${lightCyan.wrap(currentVersion.toString())}',
    );

    // Get a mutable copy of the pubspec.yaml file
    final mutableYamlMap = {...pubspecYaml};

    final result = _logger.chooseOne(
      'What version would you like to update to?',
      choices: Choices.all,
      display: (choice) => lightYellow.wrap(choice)!,
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
      case Choices.firstPreRelease: // next prelease
        nextVersion = currentVersion.firstPreRelease;
        break;
      default:
        throw Exception('Invalid choice');
    }

    final newVersionWithBuild = '$nextVersion+${buildNumber + 1}';
    mutableYamlMap['version'] = newVersionWithBuild;

    final writer = YamlWriter();

    pubspecFile.writeAsStringSync(writer.write(mutableYamlMap));

    _logger.info(
      'Version updated to: 🚀 ${lightCyan.wrap(newVersionWithBuild)}',
    );

    return ExitCode.success.code;
  }
}

class Choices {
  static const current = '🤪 Current';
  static const firstPreRelease =
      '🥵 First possible pre-release of this version.';
  static const nextMajor = '🥇 Next Major';
  static const nextMinor = '🥈 Next Minor';
  static const nextPatchVersion = '🥉 Next Patch Version';

  static const all = [
    current,
    firstPreRelease,
    nextPatchVersion,
    nextMinor,
    nextMajor,
  ];
}
