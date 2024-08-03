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
        help: 'The atSign we want to communicate with')
    ..addOption('timeout',
        abbr: 't',
        mandatory: false,
        defaultsTo: "No TimeOut",
        help: 'TimeOut the message after X seconds')
    ..addOption('message',
        abbr: 'm', mandatory: false,defaultsTo: "helloworld", help: 'The message we want to send');

  late final AtClient atClient;
  late final String myAtsign, otherAtsign, timeout, message;
  late String nameSpace;
  try {
    var parsed = argsParser.parse(args);
    otherAtsign = parsed['other-atsign'];
    message = parsed['message'];
    timeout = parsed['timeout'];

    CLIBase cliBase =
        await CLIBase.fromCommandLineArgs(args, parser: argsParser);
    atClient = cliBase.atClient;

    nameSpace = atClient.getPreferences()!.namespace!;
    nameSpace = "$nameSpace.twh";
    myAtsign = atClient.getCurrentAtSign()!;
  } catch (e) {
    print(argsParser.usage);
    print(e);
    exit(1);
  }

  String keyName = 'message';

  // We will talk direct to the remote atServer rather than
  // use the local datastore, so we don't have to wait for a local-to-atServer
  // sync to complete.
  PutRequestOptions pro = PutRequestOptions()..useRemoteAtServer = true;

  AtKey sharedRecordID = AtKey()
    ..key = keyName
    ..sharedBy = myAtsign
    ..sharedWith = otherAtsign
    ..namespace = nameSpace
    ..metadata = (Metadata()
      ..ttl = (int.parse(timeout) * 1000) // expire after X seconds
      ..ttr = -1); // allow recipient to keep a cached copy

  try {
    await atClient.put(sharedRecordID, message, putRequestOptions: pro);
    stderr.writeln(chalk.green("sent: ") + chalk.white(message));
  } catch (e) {
    stderr.write(chalk.brightRed('Error: '));
    stderr.writeln(chalk.white(e.toString()));
  }

  exit(0);
}
