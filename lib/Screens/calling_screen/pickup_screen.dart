
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CuChat/Configs/Dbpaths.dart';
import 'package:CuChat/Configs/Enum.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Screens/homepage/homepage.dart';
import 'package:CuChat/Services/Providers/call_history_provider.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:CuChat/Screens/calling_screen/audio_call.dart';
import 'package:CuChat/Screens/calling_screen/video_call.dart';
import 'package:CuChat/widgets/Common/cached_image.dart';
import 'package:CuChat/Utils/open_settings.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:CuChat/Models/call.dart';
import 'package:CuChat/Models/call_methods.dart';
import 'package:CuChat/Utils/permissions.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PickupScreen extends StatelessWidget {
  final Call call;
  final String? currentuseruid;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    required this.call,
    required this.currentuseruid,
  });
  ClientRole _role = ClientRole.Broadcaster;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Consumer<FirestoreDataProviderCALLHISTORY>(
        builder: (context, firestoreDataProviderCALLHISTORY, _child) => h > w &&
                ((h / w) > 1.5)
            ? Scaffold(
                backgroundColor: campusChat,
                body: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [ Expanded(child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          color: DESIGN_TYPE == Themetype.messenger
                              ? campusChat
                              : campusChat,
                          height: h / 4,
                          width: w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 7,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    call.isvideocall == true
                                        ? Icons.videocam
                                        : Icons.mic_rounded,
                                    size: 40,
                                    color: DESIGN_TYPE == Themetype.whatsapp
                                        ? campusChatLight2
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    call.isvideocall == true
                                        ? getTranslated(context, 'incomingvideo')
                                        : getTranslated(context, 'incomingaudio'),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: DESIGN_TYPE == Themetype.whatsapp
                                            ? campusChatLight2
                                            : Colors.white.withOpacity(0.5),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: h / 9,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 7),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 1.1,
                                      child: Text(
                                        call.callerName!,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: DESIGN_TYPE == Themetype.whatsapp
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 27,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      call.callerId!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: DESIGN_TYPE == Themetype.whatsapp
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.85),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: h / 25),

                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        call.callerPic == null || call.callerPic == ''
                            ? Container(
                                height: w + (w / 140),
                                width: w,
                                color: Colors.white12,
                                child: Icon(
                                  Icons.person,
                                  size: 140,
                                  color: campusChat,
                                ),
                              )
                            : Stack(
                                children: [
                                  Container(
                                      height: w + (w / 140),
                                      width: w,
                                      color: Colors.white,
                                      child: CachedNetworkImage(
                                        imageUrl: call.callerPic!,
                                        fit: BoxFit.cover,
                                        height: w + (w / 140),
                                        width: w,
                                        placeholder: (context, url) => Center(
                                            child: Container(
                                          height: w + (w / 140),
                                          width: w,
                                          color: Colors.white12,
                                          child: Icon(
                                            Icons.person,
                                            size: 140,
                                            color: Colors.black,
                                          ),
                                        )),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          height: w + (w / 140),
                                          width: w,
                                          color: Colors.white12,
                                          child: Icon(
                                            Icons.person,
                                            size: 140,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )),
                                  Container(
                                    height: w + (w / 140),
                                    width: w,
                                    color: Colors.transparent,
                                  ),
                                ],
                              ),
                        Container(
                          height: h / 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RawMaterialButton(
                                onPressed: () async {
                                  flutterLocalNotificationsPlugin.cancelAll();
                                  await callMethods.endCall(call: call);
                                  FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(call.callerId)
                                      .collection(DbPaths.collectioncallhistory)
                                      .doc(call.timeepoch.toString())
                                      .set({
                                    'STATUS': 'rejected',
                                    'ENDED': DateTime.now(),
                                  }, SetOptions(merge: true));
                                  FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(call.receiverId)
                                      .collection(DbPaths.collectioncallhistory)
                                      .doc(call.timeepoch.toString())
                                      .set({
                                    'STATUS': 'rejected',
                                    'ENDED': DateTime.now(),
                                  }, SetOptions(merge: true));
                                  //----------
                                  await FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(call.receiverId)
                                      .collection('recent')
                                      .doc('callended')
                                      .set({
                                    'id': call.receiverId,
                                    'ENDED': DateTime.now().millisecondsSinceEpoch
                                  }, SetOptions(merge: true));

                                  firestoreDataProviderCALLHISTORY.fetchNextData(
                                      'CALLHISTORY',
                                      FirebaseFirestore.instance
                                          .collection(DbPaths.collectionusers)
                                          .doc(call.receiverId)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .orderBy('TIME', descending: true)
                                          .limit(14),
                                      true);
                                },
                                child: Icon(
                                  Icons.call_end,
                                  color: campusChat,
                                  size: 35.0,
                                ),
                                shape: CircleBorder(),
                                elevation: 10,
                                fillColor: Colors.black,
                                padding: const EdgeInsets.all(15.0),
                              ),
                              SizedBox(width: 45),
                              RawMaterialButton(
                                onPressed: () async {
                                  flutterLocalNotificationsPlugin.cancelAll();
                                  await Permissions
                                          .cameraAndMicrophonePermissionsGranted()
                                      .then((isgranted) async {
                                    if (isgranted == true) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => call
                                                      .isvideocall ==
                                                  true
                                              ? VideoCall(
                                                  currentuseruid: currentuseruid,
                                                  call: call,
                                                  channelName: call.channelId,
                                                  role: _role,
                                                )
                                              : AudioCall(
                                                  currentuseruid: currentuseruid,
                                                  call: call,
                                                  channelName: call.channelId,
                                                  role: _role,
                                                ),
                                        ),
                                      );
                                    } else {
                                      CuChat.showRationale(
                                          getTranslated(context, 'pmc'));
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  OpenSettings()));
                                    }
                                  }).catchError((onError) {
                                    CuChat.showRationale(
                                        getTranslated(context, 'pmc'));
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                OpenSettings()));
                                  });
                                },
                                child: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                shape: CircleBorder(),
                                elevation: 10,
                                fillColor: Colors.green,
                                padding: const EdgeInsets.all(15.0),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    )],
                  )
                ))
            : Scaffold(
                backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                    ? campusChat
                    : fiberchatWhite,
                body: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: w > h ? 60 : 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        w > h
                            ? SizedBox(
                                height: 0,
                              )
                            : Icon(
                                call.isvideocall == true
                                    ? Icons.videocam_outlined
                                    : Icons.mic,
                                size: 80,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite.withOpacity(0.3)
                                    : fiberchatBlack.withOpacity(0.3),
                              ),
                        w > h
                            ? SizedBox(
                                height: 0,
                              )
                            : SizedBox(
                                height: 20,
                              ),
                        Text(
                          call.isvideocall == true
                              ? getTranslated(context, 'incomingvideo')
                              : getTranslated(context, 'incomingaudio'),
                          style: TextStyle(
                            fontSize: 19,
                            color: DESIGN_TYPE == Themetype.whatsapp
                                ? Colors.black
                                : fiberchatBlack.withOpacity(0.54),
                          ),
                        ),
                        SizedBox(height: w > h ? 16 : 50),
                        CachedImage(
                          call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 110,
                          width: w > h ? 60 : 110,
                          radius: w > h ? 70 : 138,
                        ),
                        SizedBox(height: 15),
                        Text(
                          call.callerName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatWhite
                                : fiberchatBlack,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: w > h ? 30 : 75),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () async {
                                flutterLocalNotificationsPlugin.cancelAll();
                                await callMethods.endCall(call: call);
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.callerId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                //----------
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection('recent')
                                    .doc('callended')
                                    .set({
                                  'id': call.receiverId,
                                  'ENDED': DateTime.now().millisecondsSinceEpoch
                                }, SetOptions(merge: true));

                                firestoreDataProviderCALLHISTORY.fetchNextData(
                                    'CALLHISTORY',
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(call.receiverId)
                                        .collection(
                                            DbPaths.collectioncallhistory)
                                        .orderBy('TIME', descending: true)
                                        .limit(14),
                                    true);
                              },
                              child: Icon(
                                Icons.call_end,
                                color: campusChat,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 10,
                              fillColor: Colors.black,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: () async {
                                flutterLocalNotificationsPlugin.cancelAll();
                                await Permissions
                                        .cameraAndMicrophonePermissionsGranted()
                                    .then((isgranted) async {
                                  if (isgranted == true) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => call
                                                    .isvideocall ==
                                                true
                                            ? VideoCall(
                                                currentuseruid: currentuseruid,
                                                call: call,
                                                channelName: call.channelId,
                                                role: _role,
                                              )
                                            : AudioCall(
                                                currentuseruid: currentuseruid,
                                                call: call,
                                                channelName: call.channelId,
                                                role: _role,
                                              ),
                                      ),
                                    );
                                  } else {
                                    CuChat.showRationale(
                                        getTranslated(context, 'pmc'));
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                OpenSettings()));
                                  }
                                }).catchError((onError) {
                                  CuChat.showRationale(
                                      getTranslated(context, 'pmc'));
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              OpenSettings()));
                                });
                              },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 10,
                              fillColor: campusChatLight2,
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
