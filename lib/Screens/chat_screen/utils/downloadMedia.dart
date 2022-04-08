
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:CuChat/Services/Providers/DownloadInfoProvider.dart';
import 'package:CuChat/Utils/open_settings.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<Directory?> _getDownloadDirectory() async {
  return await getApplicationDocumentsDirectory();
}

Future<void> downloadFile(
    {required BuildContext context,
    required uri,
    fileName,
    bool? isonlyview,
    GlobalKey? keyloader}) async {
  try {
    final downloadinfo =
        Provider.of<DownloadInfoprovider>(context, listen: false);
    CuChat.checkAndRequestPermission(
            Platform.isIOS ? Permission.storage : Permission.storage)
        .then((res) async {
      if (res) {
        var knockDir = Platform.isIOS
            ? await _getDownloadDirectory()
            : await new Directory('/storage/emulated/0/$Appname')
                .create(recursive: true);
        File outputFile = File('${knockDir!.path}/$fileName');
        bool fileExists = await outputFile.exists();
        if (fileExists == true) {
          CuChat.toast(
            getTranslated(context, 'fileexists') + ' $Appname',
          );
        } else {
          // Either the permission was already granted before or the user just granted it.

          // setState(() {
          //   downloading = true;
          // });

          String savePath = '${knockDir.path}/$fileName';
          showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return new WillPopScope(
                    onWillPop: () async => false,
                    child: SimpleDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        // side: BorderSide(width: 5, color: Colors.green)),
                        key: keyloader,
                        backgroundColor: Colors.white,
                        children: <Widget>[
                          Consumer<DownloadInfoprovider>(
                              builder: (context, classroomm, _child) => Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        new CircularPercentIndicator(
                                          radius: 55.0,
                                          lineWidth: 4.0,
                                          percent: downloadinfo
                                                  .downloadedpercentage /
                                              100,
                                          center: new Text(
                                              "${downloadinfo.downloadedpercentage.floor()}%"),
                                          progressColor: Colors.blue[400],
                                        ),
                                        Container(
                                          width: 180,
                                          padding: EdgeInsets.only(left: 7),
                                          child: ListTile(
                                            dense: false,
                                            title: Text(
                                              getTranslated(
                                                  context, 'downloading'),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  height: 1.3,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              '${((((downloadinfo.totalsize / 1024) / 1000) * 100).roundToDouble()) / 100}  MB',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(height: 2.2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                        ]));
              });

          Dio dio = Dio();

          await dio.download(
            uri,
            savePath,
            onReceiveProgress: (rcv, total) {
              downloadinfo.calculatedownloaded(rcv / total * 100, total);
            },
            deleteOnError: true,
          ).then((_) async {
            Navigator.of(keyloader!.currentContext!, rootNavigator: true)
                .pop(); //
            downloadinfo.calculatedownloaded(0.00, 0);
            CuChat.toast(
              getTranslated(context, 'fileexists') + ' $Appname',
            );
          }).onError((err, er) {
            print('ERROR OCCURED WHILE DOWNLOADING MEDIA: ' + err.toString());
            Navigator.of(keyloader!.currentContext!, rootNavigator: true)
                .pop(); //
            CuChat.toast(getTranslated(context, 'eps'));
          });
        }
      } else {
        CuChat.showRationale(getTranslated(context, 'ps'));
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    });
  } catch (e) {
    CuChat.toast(
      getTranslated(context, 'alreadydeleted'),
    );
  }
}
