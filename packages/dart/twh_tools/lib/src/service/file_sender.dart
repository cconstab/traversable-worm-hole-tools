import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:at_client/at_client.dart';
import 'package:at_chops/at_chops.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'package:twh_dart/src/file_send_params.dart';

class FileSender {
  final AtClient atClient;

  FileSender(this.atClient);

  Future<void> sendFile(FileSendParams params) async {
    var rand = Random.secure();
    String filename;
    String filebin = params.fileBin;
    double random = rand.nextDouble();
    var bytes = utf8.encode(random.toString());
    String digest = sha224.convert(bytes).toString();
    String fullUrl = '';
    bool loop = true;
    end() {
      loop = false;
    }

    var fileToSend = File(params.filePath);
    if (!fileToSend.existsSync()) {
      throw Exception("File doesn't exits in path ${params.filePath}");
    }
    stderr.writeln('Generating AES key and IV');
    var fileEncryptionKey =
        AtChopsUtil.generateSymmetricKey(EncryptionKeyType.aes256).key;
    var encryptionService = atClient.encryptionService!;
    String iv = EncryptionUtil.generateIV();

    stderr.writeln('Encrypting file');
    var encryptedFile = await encryptionService.encryptFileInChunks(
        fileToSend, fileEncryptionKey, params.chunkSize,
        ivBase64: iv);
      filename = basename(encryptedFile.path);
    var encryptedFileName = md5.convert(filename.codeUnits);

    try {
      fullUrl = '$filebin/$digest/$encryptedFileName';
      var request = http.Request('POST', Uri.parse(fullUrl));
      stderr.write('Uploading $filename\r\n');
      request.bodyBytes = encryptedFile.readAsBytesSync();

      Future<http.StreamedResponse> response = request.send();
      response.whenComplete(end);
      while (loop) {
        await Future.delayed(Duration(milliseconds: 250));
        stderr.write(".");
      }
      var realresponse = await response;
      if (realresponse.statusCode == 201) {}
    } catch (e) {
      stderr.write('$e\n\r');
    }

    if (encryptedFile.existsSync()) {
      encryptedFile.deleteSync();
    }

    var fileTransferObject = FileTransferObject(
        'acme_transfer',
        fileEncryptionKey,
        fullUrl,
        basename(fileToSend.path),
        params.receiverAtSign,
        params.chunkSize,
        iv);

    String? namespace = atClient.getPreferences()!.namespace;
    namespace = '$namespace.twh_tools';

    var atKey = AtKey()
          ..key = '${DateTime.now().millisecondsSinceEpoch}'
              '.files'
              '.$namespace'
          ..sharedBy = atClient.getCurrentAtSign()
          ..sharedWith = params.receiverAtSign
          ..metadata.namespaceAware =
              true // we've included the namespace already
        ;

    stderr.writeln('\n\rSending notification');
    await atClient.notificationService.notify(
      NotificationParams.forUpdate(
        atKey,
        value: jsonEncode(fileTransferObject.toJson()),
      ),
      waitForFinalDeliveryStatus: false,
      checkForFinalDeliveryStatus: false,
    );
  }
}

// add any additional params if required
class FileTransferObject {
  final String transferId;

  //final List<FileStatus> fileStatus;
  final String fileEncryptionKey;
  final String fileUrl;
  final String fileName;
  final String sharedWith;
  String? notes;
  final String iv;
  DateTime? date;
  int chunkSize;

  FileTransferObject(this.transferId, this.fileEncryptionKey, this.fileUrl,
      this.fileName, this.sharedWith, this.chunkSize, this.iv,
      {this.date}) {
    date ??= DateTime.now().toUtc();
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map toJson() {
    var map = {};
    map['transferId'] = transferId;
    map['fileEncryptionKey'] = fileEncryptionKey;
    map['fileUrl'] = fileUrl;
    map['fileName'] = fileName;
    map['sharedWith'] = sharedWith;
    map['chunkSize'] = chunkSize;
    map['iv'] = iv;
    map['date'] = date!.toUtc().toString();
    map['notes'] = notes;
    return map;
  }
}
