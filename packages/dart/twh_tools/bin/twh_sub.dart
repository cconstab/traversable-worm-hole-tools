// dart packages
import 'dart:io';

// atPlatform packages
import 'package:at_client/at_client.dart';
import 'package:at_cli_commons/at_cli_commons.dart';
import 'package:at_utils/at_logger.dart';

// External Packages
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  ArgParser argsParser = CLIBase.argsParser
    ..addOption('other-atsign',
        abbr: 'o',
        mandatory: false,
        defaultsTo: "any",
        help: 'The comma delimted list of atSigns that can send messages')
    ..addOption('count',
        abbr: 'C',
        mandatory: false,
        defaultsTo: '-1',
        help: "Exit after X number of messages");
  late final AtClient atClient;
  late final String otherAtsign;
  late int count;
  late String nameSpace;
  try {
    CLIBase cliBase =
        await CLIBase.fromCommandLineArgs(args, parser: argsParser);
    var parsed = argsParser.parse(args);
    otherAtsign = parsed['other-atsign'] + ",";
    count = int.parse(parsed['count']);
    atClient = cliBase.atClient;

    nameSpace = atClient.getPreferences()!.namespace!;
    nameSpace = "$nameSpace.twh_tools";
    //myAtsign = atClient.getCurrentAtSign()!;
  } catch (e) {
    print(CLIBase.argsParser.usage);
    print(e);
    exit(1);
  }

  final AtSignLogger logger = AtSignLogger(' at_notify ');

  atClient.notificationService
      .subscribe(regex: 'message.$nameSpace@', shouldDecrypt: true)
      .listen(((notification) async {
    String keyName = notification.key
        .replaceAll('${notification.to}:', '')
        .replaceAll('.$nameSpace${notification.from}', '');
    if (keyName == 'message' &&
        (otherAtsign.contains("${notification.from},") ||
            otherAtsign == "any")) {
      logger.info(
          'message received from ${notification.from} notification id : ${notification.id}');
      var talk = notification.value;
      stdout.writeln(talk);
      count--;
      if(count == 0 ) exit(0);
    }
  }),
          onError: (e) => logger.severe('Notification Failed: $e'),
          onDone: () => logger.info('Notification listener stopped'));
}
