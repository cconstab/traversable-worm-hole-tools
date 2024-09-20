import 'dart:io';

import 'package:args/args.dart';
import 'package:twh_dart/src/file_send_params.dart';
import 'package:twh_dart/src/service/file_receiver.dart';
import 'package:twh_dart/src/service/file_sender.dart';
import 'package:at_cli_commons/at_cli_commons.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return CLIBase.argsParser
    ..addOption('mode',
        abbr: 'm', mandatory: true, help: 'File sharing mode - send or receive')
    ..addOption('receiver',
        abbr: 'r', mandatory: true, help: 'atsign receiving the shared file')
    ..addOption('filePath',
        abbr: 'f', mandatory: false, help: 'path of file in local to share')
    ..addOption('downloadDir',
        abbr: 'o', mandatory: false, help: 'download dir when receiving files')
    ..addOption('fileBin',
        abbr: 'b',
        mandatory: false,
        help: 'specify filebin server url',
        defaultsTo: 'https://filebin.net')
    ..addOption('senders',
        abbr: 'p',
        mandatory: false,
        help: 'Comma separated list of permited sender atSigns',
        defaultsTo: "@,");
}

void printUsage(ArgParser argParser) {
  stderr.writeln('''Usage: 
  To Receive files
  twh_sft -m receive -a <@receiver_device> -n <namespace> -o <directory>
  To Send files
  twh_sft -m send -a <sender_client> -n <namespace> -f <file to send>
  
  Arguments
  ''');
  stderr.writeln(argParser.usage);
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    String mode = results['mode'];
    var atClient = (await CLIBase.fromCommandLineArgs(arguments)).atClient;
    stderr.writeln('mode: $mode');
    if (mode == 'send') {
      String receiver = results['receiver'];
      var params = FileSendParams()
        ..receiverAtSign = receiver
        ..fileBin = results['fileBin']
        ..filePath = results['filePath'];

      await FileSender(atClient).sendFile(params);
      exit(0);
    } else if (mode == 'receive') {
      String sender = results['senders'];
      final split = sender.split(',');
      final Map<int, String> senders = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };

      final receiver = FileReceiver(atClient, results['downloadDir'], senders);
      await receiver.startListening();
      receiver.received.listen((filePath) {
        stderr.writeln('Downloaded file: $filePath');
      });
    }
  } on Error catch (e) {
    // Print usage information if an invalid argument was provided.
    printUsage(argParser);
    stderr.writeln('');
    stderr.writeln(e.toString());
    stderr.writeln('');
  }
}
