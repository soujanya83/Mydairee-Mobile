import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void _requestDownload(
    String link, String filename, String dirloc, var context) async {
  print(link);
  await FlutterDownloader.enqueue(
    url: link,
    savedDir: dirloc,
    fileName: filename,
    showNotification:
        true, // show download progress in status bar (for Android)
    openFileFromNotification:
        true, // click on notification to open downloaded file (for Android)
  ).then((value) {
    print(value);
    print('success');
    MyApp.ShowToast('downloaded successfully', context);
  });
}

Future<void> downloadFile(String link, String filename, var context) async {
  var status = await Permission.storage.status;
  if (status.isGranted) {
    String dirloc = (await getExternalStorageDirectory())!.absolute.path;
    _requestDownload(link, filename, dirloc, context);
  } else {
    await Permission.storage
        .request()
        .then((value) => downloadFile(link, filename, context));
  }
}
