
import 'dart:io';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:CuChat/Screens/chat_screen/utils/downloadMedia.dart';
import 'package:CuChat/Utils/open_settings.dart';
import 'package:CuChat/Utils/save.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoViewWrapper extends StatelessWidget {
  PhotoViewWrapper(
      {this.imageProvider,
      this.message,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.tag});

  final String tag;
  final String? message;

  final ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  final GlobalKey<ScaffoldState> _scaffoldd = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoaderr =
      new GlobalKey<State>(debugLabel: 'qqgfggqesqeqsseaadqeqe');
  @override
  Widget build(BuildContext context) {
    return CuChat.getNTPWrappedWidget(Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldd,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: fiberchatWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: campusChatLight2,
          onPressed: Platform.isIOS
              ? () {
                  launch(message!);
                }
              : () async {
                  CuChat.checkAndRequestPermission(Permission.storage)
                      .then((res) async {
                    if (res) {
                      Save.saveToDisk(imageProvider, tag);
                      await downloadFile(
                        context: _scaffoldd.currentContext!,
                        fileName:
                            '${DateTime.now().millisecondsSinceEpoch}appicon.png',
                        isonlyview: false,
                        keyloader: _keyLoaderr,
                        uri: message,
                      );
                    } else {
                      CuChat.showRationale(getTranslated(context, 'pms'));
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => OpenSettings()));
                    }
                  });
                },
          child: Icon(
            Icons.file_download,
          ),
        ),
        body: Container(
            color: Colors.black,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              loadingBuilder: (BuildContext context, var image) {
                return loadingChild ??
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(campusChat),
                        ),
                      ),
                    );
              },
              imageProvider: imageProvider,
              backgroundDecoration: backgroundDecoration as BoxDecoration?,
              minScale: minScale,
              maxScale: maxScale,
            ))));
  }
}
