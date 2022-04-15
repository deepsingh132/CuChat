/*import 'dart:async';

import 'package:CuChat/Configs/Dbkeys.dart';
import 'package:CuChat/Configs/Dbpaths.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Screens/Groups/GroupChatPage.dart';
import 'package:CuChat/Screens/call_history/callhistory.dart';
import 'package:CuChat/Services/Providers/GroupChatProvider.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chat_data_widget extends StatefulWidget {

  chat_data_widget(List<Map<String, dynamic>> filtered, List<GroupModel> groupList);

  List<Map<String, dynamic>> _streamDocSnap = [];
  StreamController<String> _userQuery =
  new StreamController<String>.broadcast();

  final TextEditingController _filter = new TextEditingController();

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {

    if (user[Dbkeys.phone] == currentUserNo) {
      return Container(width: 0, height: 0);
    } else {
      return StreamBuilder(
        stream: getUnread(user).asBroadcastStream(),
        builder: (context, AsyncSnapshot<MessageData> unreadData) {
          int unread = unreadData.hasData &&
              unreadData.data!.snapshot.docs.isNotEmpty
              ? unreadData.data!.snapshot.docs
              .where((t) => t[Dbkeys.timestamp] > unreadData.data!.lastSeen)
              .length
              : 0;
          return Theme(

              data: ThemeData(

                  splashColor: campusChat,
                  highlightColor: Colors.transparent),
              child: Column(
                children: [
                  ListTile(
                      contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      onLongPress: () {
                        unawaited(showDialog(
                            context: context,
                            builder: (context) {
                              return AliasForm(user, _cachedModel);
                            }));
                      },
                      leading:
                      customCircleAvatar(url: user['photoUrl'], radius: 22),
                      title: Text(
                        CuChat.getNickname(user)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fiberchatBlack,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        if (_cachedModel!.currentUser![Dbkeys.locked] != null &&
                            _cachedModel!.currentUser![Dbkeys.locked]
                                .contains(user[Dbkeys.phone])) {
                          NavigatorState state = Navigator.of(context);
                          ChatController.authenticate(_cachedModel!,
                              getTranslated(context, 'auth_neededchat'),
                              state: state,
                              shouldPop: false,
                              type: CuChat.getAuthenticationType(
                                  biometricEnabled, _cachedModel),
                              prefs: widget.prefs, onSuccess: () {
                                state.pushReplacement(new MaterialPageRoute(
                                    builder: (context) => new ChatScreen(
                                        isSharingIntentForwarded: false,
                                        prefs: widget.prefs,
                                        unread: unread,
                                        model: _cachedModel!,
                                        currentUserNo: currentUserNo,
                                        peerNo: user[Dbkeys.phone] as String?)));
                              });
                        } else {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new ChatScreen(
                                      isSharingIntentForwarded: false,
                                      prefs: widget.prefs,
                                      unread: unread,
                                      model: _cachedModel!,
                                      currentUserNo: currentUserNo,
                                      peerNo: user[Dbkeys.phone] as String?)));
                        }
                      },
                      trailing: unread != 0
                          ? Container(
                        child: Text(unread.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        padding: const EdgeInsets.all(7.0),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: user[Dbkeys.lastSeen] == true
                              ? Colors.blue[400]
                              : Colors.blue[400],
                        ),
                      )
                          : user[Dbkeys.lastSeen] == true
                          ? Container(
                        child: Container(width: 0, height: 0),
                        padding: const EdgeInsets.all(7.0),
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue[400]),
                      )
                          : SizedBox(
                        height: 0,
                        width: 0,
                      )),
                  Divider(
                    height: 0,
                  ),
                ],
              ));
        },
      );
    }
  }

   chatData(List<Map<String, dynamic>> filtered,
      List<GroupModel> groupList) {
    return ListView(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      shrinkWrap: true,
      children: [
        Container(

            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30))),
            child: _streamDocSnap.isNotEmpty
                ? StreamBuilder(
                stream: _userQuery.stream.asBroadcastStream(),
                builder: (context, snapshot) {
                  if (_filter.text.isNotEmpty ||
                      snapshot.hasData) {
                    filtered = this._streamDocSnap.where((user) {
                      return user[Dbkeys.nickname]
                          .toLowerCase()
                          .trim()
                          .contains(new RegExp(r'' +
                          _filter.text.toLowerCase().trim() +
                          ''));
                    }).toList();
                    if (filtered.isNotEmpty)
                      return ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context,
                                filtered.elementAt(index)),
                        itemCount: filtered.length,
                      );
                    else
                      return ListView(
                          physics:
                          AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery
                                        .of(context)
                                        .size
                                        .height /
                                        3.5),
                                child: Center(
                                  child: Text(
                                      getTranslated(context,
                                          'nosearchresult'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: fiberchatGrey,
                                      )),
                                ))
                          ]);
                  }
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 120),
                    itemBuilder: (context, index) {
                      if (_streamDocSnap[index].containsKey(
                          Dbkeys.groupISTYPINGUSERID)) {
                        ///----- Build Group Chat Tile ----
                        return Theme(
                            data: ThemeData(
                                splashColor: campusChat,
                                highlightColor:
                                Colors.transparent),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                  EdgeInsets.fromLTRB(
                                      20, 0, 20, 0),
                                  leading:
                                  customCircleAvatarGroup(
                                      url: _streamDocSnap[
                                      index][
                                      Dbkeys
                                          .groupPHOTOURL],
                                      radius: 22),
                                  title: Text(
                                    _streamDocSnap[index]
                                    [Dbkeys.groupNAME],
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: fiberchatBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_streamDocSnap[index][Dbkeys
                                        .groupMEMBERSLIST]
                                        .length} ${getTranslated(
                                        context, 'participants')}',
                                    style: TextStyle(
                                      color: fiberchatGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                            new GroupChatPage(
                                                isSharingIntentForwarded:
                                                false,
                                                model:
                                                _cachedModel!,
                                                prefs:
                                                widget.prefs,
                                                joinedTime:
                                                _streamDocSnap[
                                                index]
                                                [
                                                '${widget
                                                    .currentUserNo}-joinedOn'],
                                                currentUserno: widget
                                                    .currentUserNo!,
                                                groupID:
                                                _streamDocSnap[
                                                index]
                                                [Dbkeys
                                                    .groupID])));
                                  },
                                  trailing: StreamBuilder(
                                    stream: FirebaseFirestore
                                        .instance
                                        .collection(DbPaths
                                        .collectiongroups)
                                        .doc(_streamDocSnap[index]
                                    [Dbkeys.groupID])
                                        .collection(DbPaths
                                        .collectiongroupChats)
                                        .where(
                                        Dbkeys.groupmsgTIME,
                                        isGreaterThan:
                                        _streamDocSnap[
                                        index][
                                        widget
                                            .currentUserNo])
                                        .snapshots(),
                                    builder:
                                        (BuildContext context,
                                        AsyncSnapshot<
                                            QuerySnapshot<
                                                dynamic>>
                                        snapshot) {
                                      if (snapshot
                                          .connectionState ==
                                          ConnectionState
                                              .waiting) {
                                        return SizedBox(
                                          height: 0,
                                          width: 0,
                                        );
                                      } else if (snapshot
                                          .hasData &&
                                          snapshot.data!.docs
                                              .length >
                                              0) {
                                        return Container(
                                          child: Text(
                                              '${snapshot.data!.docs.length}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors
                                                      .white,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold)),
                                          padding:
                                          const EdgeInsets
                                              .all(7.0),
                                          decoration:
                                          new BoxDecoration(
                                            shape:
                                            BoxShape.circle,
                                            color:
                                            Colors.blue[400],
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 0,
                                        width: 0,
                                      );
                                    },
                                  ),
                                ),
                                Divider(
                                  height: 0,
                                ),
                              ],
                            ));
                      } else {
                        return buildItem(context,
                            _streamDocSnap.elementAt(index));
                      }
                    },
                    itemCount: _streamDocSnap.length,
                  );
                })
                : ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height /
                              3.5),
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Text(
                                groupList.length != 0
                                    ? ''
                                    : getTranslated(
                                    context, 'startchat'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.59,
                                  color: fiberchatGrey,
                                ))),
                      ))
                ])),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}*/