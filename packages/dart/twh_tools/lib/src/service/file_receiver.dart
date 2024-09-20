import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:at_client/at_client.dart';

class FileReceiver {
  final AtClient atClient;
  final String downloadPath;
  final Map<int, String> senders;

  bool _listening = false;

  final StreamController<String> sc = StreamController<String>.broadcast();

  FileReceiver(this.atClient, this.downloadPath, this.senders);

  Stream<String> get received => sc.stream;

  Future<void> startListening() async {
    if (!_listening) {
      _listening = true;
      String? namespace = atClient.getPreferences()!.namespace;
      namespace = '$namespace.twh_tools';
      final topic = '.files'
          '.$namespace';
      stderr.writeln('Subscribing to $topic');
      print(topic);
      atClient.notificationService
          .subscribe(regex: topic, shouldDecrypt: true)
          .listen((AtNotification atNotification) async {
        if (atNotification.id != '-1') {
          String? fileName;
            stderr.writeln('Got notification from: ${atNotification.from}');
            if (senders.containsValue(atNotification.from) || senders.containsValue('@') ){
          try {
            var valueJson = jsonDecode(atNotification.value!);
            var fileStorageUrl = valueJson['fileUrl'];
            fileName = valueJson['fileName'];

            await downloadFileWithProgress(
                fileStorageUrl, downloadPath, fileName!, valueJson);
            String filePath = '$downloadPath/$fileName'
                .replaceAll("/", Platform.pathSeparator);
            sc.add(filePath);
          } catch (e, trace) {
            stderr.writeln(e);
            stderr.writeln(trace);
          }
          }
        }
      }
    );
    }
  }

  Future<void> _decryptFile(
      String downloadPath, String fileName, dynamic valueJson) async {
    try {
      var startTime = DateTime.now();
      var encryptionService = atClient.encryptionService!;
      var encryptedFile =
          File('$downloadPath${Platform.pathSeparator}encrypted_$fileName');
      await encryptionService.decryptFileInChunks(
          encryptedFile, valueJson['fileEncryptionKey'], valueJson['chunkSize'],
          ivBase64: valueJson['iv']);
      var endTime = DateTime.now();
      stderr.writeln('Time taken to decrypt file:'
          ' ${endTime.difference(startTime).inSeconds}');
      var decryptedFile = File(
          "$downloadPath${Platform.pathSeparator}decrypted_encrypted_$fileName");
      if (decryptedFile.existsSync()) {
        decryptedFile
            .renameSync(downloadPath + Platform.pathSeparator + fileName);
      } else {
        throw Exception('coult downloaded file');
      }
    } on Exception catch (e, trace) {
      stderr.writeln(e);
      stderr.writeln(trace);
    } on Error catch (e, trace) {
      stderr.writeln(e);
      stderr.writeln(trace);
    } finally {
      var encryptedFile =
          File("$downloadPath${Platform.pathSeparator}encrypted_$fileName");
      if (encryptedFile.existsSync()) {
        encryptedFile.deleteSync();
      }
    }
  }

  Future<void> downloadFileWithProgress(String fileUrl, String downloadPath,
      String fileName, dynamic valueJson) async {
    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(fileUrl));
    request.headers.putIfAbsent('Accept', () => '*/*');
    request.headers.putIfAbsent('User-Agent', () => 'curl/8.7.1');
    var response = httpClient.send(request);
    List<List<int>> chunks = [];
    int downloaded = 0;

    final completer = Completer();

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        if (r.contentLength == null) {
          stderr.writeln('content length is null.');
          return;
        }
        // Display percentage of completion
        var percentage = downloaded / r.contentLength! * 100;
        int roundedPercent = percentage.round();
        updateProgress(roundedPercent);

        chunks.add(chunk);
        downloaded += chunk.length;
      }, onDone: () async {
        updateProgress(100, done: true);

        // Save the file
        print('$downloadPath${Platform.pathSeparator}encrypted_$fileName');
        File file =
            File('$downloadPath${Platform.pathSeparator}encrypted_$fileName');

        final Uint8List bytes = Uint8List(r.contentLength!);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);
        await _decryptFile(downloadPath, fileName, valueJson);
        completer.complete();
      });
    });
    var d = await response;
    print(d.request);
    return completer.future;
  }

  void updateProgress(int progress, {bool done = false}) {
    // Move cursor to the beginning of the line
    stderr.write('\r');

    // Print the progress in percentage
    stderr.write('Download progress: $progress%                   ');

    if (done) {
      stderr.writeln();
    }
  }
}
