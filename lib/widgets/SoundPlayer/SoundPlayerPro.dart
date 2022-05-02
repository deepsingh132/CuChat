
import 'dart:async';
import 'dart:typed_data';
import 'package:CuChat/Configs/Enum.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

///
typedef Fn = void Function();

/// Example app.
class MultiPlayback extends StatefulWidget {
  final String? url;
  final bool? isMe;
  final Function? onTapDownloadFn;
  MultiPlayback({this.url, this.isMe, this.onTapDownloadFn});
  @override
  _MultiPlaybackState createState() => _MultiPlaybackState();
}

class _MultiPlaybackState extends State<MultiPlayback> {
  FlutterSoundPlayer? _mPlayer1 = FlutterSoundPlayer();
  bool _mPlayer1IsInited = false;
  Uint8List? buffer1;
  String _playerTxt1 = '';
  // ignore: cancel_subscriptions
  StreamSubscription? _playerSubscription1;

  // Future<Uint8List> _getAssetData(String path) async {
  //   var asset = await rootBundle.load(path);
  //   return asset.buffer.asUint8List();
  // }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    _mPlayer1!.openAudioSession().then((value) {
      setState(() {
        _mPlayer1IsInited = true;
      });
    });
  }

  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    cancelPlayerSubscriptions1();
    _mPlayer1!.closeAudioSession();
    _mPlayer1 = null;

    super.dispose();
  }

  // -------  Player1 play a remote file -----------------------
  bool showPlayingLoader = false;
  void play1() async {
    try {
      setState(() {
        showPlayingLoader = true;
      });
      await _mPlayer1!.setSubscriptionDuration(Duration(milliseconds: 10));
      _addListener1();

      await _mPlayer1!.startPlayer(
          fromURI: widget.url,
          codec: Codec.mp3,
          whenFinished: () {
            setState(() {});
          });
    } catch (e) {
      setState(() {
        showPlayingLoader = false;
      });
      CuChat.toast('This message is deleted by sender');
    }
  }

  void cancelPlayerSubscriptions1() {
    if (_playerSubscription1 != null) {
      _playerSubscription1!.cancel();
      _playerSubscription1 = null;
    }
  }

  Future<void> stopPlayer1() async {
    cancelPlayerSubscriptions1();
    if (_mPlayer1 != null) {
      await _mPlayer1!.stopPlayer();
    }
    setState(() {});
  }

  Future<void> pause1() async {
    if (_mPlayer1 != null) {
      await _mPlayer1!.pausePlayer();
    }
    setState(() {});
  }

  Future<void> resume1() async {
    if (_mPlayer1 != null) {
      await _mPlayer1!.resumePlayer();
    }
    setState(() {});
  }

  // ------------------------------------------------------------------------------------

  void _addListener1() {
    cancelPlayerSubscriptions1();
    _playerSubscription1 = _mPlayer1!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds,
          isUtc: true);
      var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _playerTxt1 = txt.substring(0, 8);
        showPlayingLoader = false;
      });
    });
  }

  Fn? getPlaybackFn1() {
    try {
      print(widget.url);
      if (!_mPlayer1IsInited) {
        return null;
      }
      return _mPlayer1!.isStopped
          ? play1
          : () {
              stopPlayer1().then((value) => setState(() {}));
            };
    } catch (e) {
      setState(() {
        showPlayingLoader = false;
      });
      CuChat.toast('This message is deleted by sender');
    }
  }

  Fn? getPauseResumeFn1() {
    if (!_mPlayer1IsInited || _mPlayer1!.isStopped) {
      return null;
    }
    return _mPlayer1!.isPaused ? resume1 : pause1;
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.fromLTRB(7, 2, 14, 7),
          height: 60,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: !widget.isMe!
                ? campusChat
                : Colors.black,
            border: Border.all(
              color: Colors.blueGrey.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            showPlayingLoader == true
                ? Padding(
                    padding: const EdgeInsets.only(top: 7, left: 12, right: 7),
                    child: SizedBox(
                      height: 29,
                      width: 29,
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.7,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(campusChat),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: getPlaybackFn1(),
                    icon: Icon(
                      _mPlayer1!.isStopped
                          ? Icons.play_circle_outline_outlined
                          : Icons.stop_circle_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
            SizedBox(
              width: 2,
            ),
            /*IconButton(
              onPressed: getPauseResumeFn1(),
              icon: Icon(
                     Icons.play_circle_filled_sharp,
                size: 40,
                color: getPauseResumeFn1() == null
                    ? widget.isMe!
                        ? DESIGN_TYPE == Themetype.whatsapp
                            ? Colors.white
                            : Colors.white
                        : Colors.white
                    : Colors.white,
              ),
            ),*/
            SizedBox(
              width: 11,
            ),
            _playerTxt1 == '' || _mPlayer1!.isStopped
                ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.onTapDownloadFn!();
                          },
                          icon: Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        /*Positioned(
                            bottom: 6,
                            right: 0,
                            child: Icon(
                              Icons.download,
                              size: 16,
                              color: Colors.white,
                            ))*/
                      ],
                    ),
                  )
                : Text(
                    _playerTxt1,
                    style: TextStyle(
                      height: 1.76,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ]),
        ),
      );
    }

    return makeBody();
  }
}
