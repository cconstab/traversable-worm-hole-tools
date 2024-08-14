// dart packages
import 'dart:io';

// atPlatform packages
import 'package:at_client/at_client.dart';
import 'package:at_cli_commons/at_cli_commons.dart';

// External Packages
import 'package:args/args.dart';
import 'package:chalkdart/chalk.dart';

Future<void> main(List<String> args) async {
  ArgParser argsParser = CLIBase.argsParser
    ..addOption('other-atsign',
        abbr: 'o',
        mandatory: true,
        help: 'The atSign we want to communicate with');

  late final AtClient atClient;
  late final String myAtsign, otherAtsign;
  late String nameSpace;

  try {
    var parsed = argsParser.parse(args);
    otherAtsign = parsed['other-atsign'];

    CLIBase cliBase =
        await CLIBase.fromCommandLineArgs(args, parser: argsParser);
    atClient = cliBase.atClient;

    nameSpace = atClient.getPreferences()!.namespace!;
    myAtsign = atClient.getCurrentAtSign()!;
  } catch (e) {
    print(argsParser.usage);
    print(e);
    exit(1);
  }

  String keyName = 'message';
  nameSpace = "$nameSpace.twh_tools";

  // Construct the ID object we will use to do the fetch
  AtKey sharedRecordID = AtKey()
    ..key = keyName
    ..sharedBy = otherAtsign
    ..sharedWith = myAtsign
    ..namespace = nameSpace;
  //print(sharedRecordID);

  try {
    var val = await atClient.get(sharedRecordID);
    //stdout.writeln(val.toString());
    //stdout.writeln(chalk.brightGreen(val.value));
    stdout.writeln(val.value);
  } catch (e) {
    print(e.toString());
    print(chalk.brightRed('Null'));
  }
  exit(0);
}
