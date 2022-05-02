
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:CuChat/Screens/homepage/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CuChat/Configs/Dbkeys.dart';
import 'package:CuChat/Configs/Dbpaths.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Screens/Groups/AddContactsToGroup.dart';
import 'package:CuChat/Screens/Groups/GroupChatPage.dart';
import 'package:CuChat/Screens/contact_screens/SmartContactsPage.dart';
import 'package:CuChat/Services/Admob/admob.dart';
import 'package:CuChat/Services/Providers/BroadcastProvider.dart';
import 'package:CuChat/Services/Providers/GroupChatProvider.dart';
import 'package:CuChat/Services/Providers/Observer.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:CuChat/Screens/chat_screen/utils/messagedata.dart';
import 'package:CuChat/Screens/call_history/callhistory.dart';
import 'package:CuChat/Screens/chat_screen/chat.dart';
import 'package:CuChat/Models/DataModel.dart';
import 'package:CuChat/Services/Providers/user_provider.dart';
import 'package:CuChat/Utils/alias.dart';
import 'package:CuChat/Utils/chat_controller.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:CuChat/Utils/unawaited.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RecentChats extends StatefulWidget {
  RecentChats(
      {required this.currentUserNo,
      required this.prefs,
      key, required this.controller, })
      : super(key: key);

  //final ScrollController controller;
  //List<Map<String, dynamic>> streamdocsnap = [];
  //StreamController<String> userQuery =
  //new StreamController<String>.broadcast();
  //final TextEditingController filter = new TextEditingController();

  /*const PanelWidget({
    Key? key,
    required this.controller, this.currentUserNo, required this.prefs, required this.isSecuritySetupDone,
  }) : super(key: key);*/

  final String? currentUserNo;
  final SharedPreferences prefs;
  final ScrollController controller;

  @override
  State createState() =>
      new RecentChatsState(currentUserNo: this.currentUserNo, controller: controller);

  }


class RecentChatsState extends State<RecentChats>
with WidgetsBindingObserver
 {
   final ScrollController controller;
  final panelController = PanelController();

  TabController? controllerIfcallallowed;
  TabController? controllerIfcallNotallowed;
  RecentChatsState({Key? key, this.currentUserNo, required this.controller}) {
    filter.addListener(() {
      userQuery.add(filter.text.isEmpty ? '' : filter.text);
    });

  }



  final TextEditingController filter = new TextEditingController();
  bool isAuthenticating = false;
  String? userPhotourl;
  String? userFullname;
  List phoneNumberVariants = [];

  List<StreamSubscription> unreadSubscriptions = [];

  List<StreamController> controllers = [];
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  void initState() {
    super.initState();
    CuChat.internetLookUp();
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        if(mounted)
        setState(() {});
      }
    });
  }

  getuid(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserDetails(currentUserNo);
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  String? currentUserNo;

  bool isLoading = false;
  //List<Map<String, dynamic>> filtered;





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
                              prefs: widget.prefs,
                               onSuccess: () {
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
                                    ? campusChat
                                    : campusChat,
                              ),
                            )
                          : user[Dbkeys.lastSeen] == true
                              ? Container(
                                  child: Container(width: 0, height: 0),
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: campusChat),
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

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = CuChat.getChatId(currentUserNo, user[Dbkeys.phone]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[currentUserNo!] != null && doc[currentUserNo!] is int) {
        unreadSubscriptions.add(FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(
              MessageData(snapshot: snapshot, lastSeen: doc[currentUserNo!]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(phoneNo) {
    Map<String, dynamic> _currentUser = _cachedModel!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  StreamController<String> userQuery =
      new StreamController<String>.broadcast();

  List<Map<String, dynamic>> streamdocsnap = [];



  _chats(Map<String?, Map<String, dynamic>?> _userData,
      Map<String, dynamic>? currentUser, ScrollController controller) {
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) => Consumer<List<BroadcastModel>>(
                builder: (context, broadcastList, _child) {
                  controller: controller;
              streamdocsnap = Map.from(_userData)
                  .values
                  .where((_user) => _user.keys.contains(Dbkeys.chatStatus))
                  .toList()
                  .cast<Map<String, dynamic>>();
              Map<String?, int?> _lastSpokenAt = _cachedModel!.lastSpokenAt;
              List<Map<String, dynamic>> filtered =
                  List.from(<Map<String, dynamic>>[]);
              groupList.forEach((element) {
                streamdocsnap.add(element.docmap);
              });
              broadcastList.forEach((element) {
                streamdocsnap.add(element.docmap);
              });
              streamdocsnap.sort((a, b) {
                int aTimestamp = a.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? a[Dbkeys.groupLATESTMESSAGETIME]
                    : a.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? a[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[a[Dbkeys.phone]] ?? 0;
                int bTimestamp = b.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? b[Dbkeys.groupLATESTMESSAGETIME]
                    : b.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? b[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[b[Dbkeys.phone]] ?? 0;
                return bTimestamp - aTimestamp;
              });

              if (!showHidden) {
                streamdocsnap.removeWhere((_user) =>
                    !_user.containsKey(Dbkeys.groupISTYPINGUSERID) &&
                    !_user.containsKey(Dbkeys.broadcastBLACKLISTED) &&
                    _isHidden(_user[Dbkeys.phone]));
              }

              //return chat_data_widget(filtered, groupList).chatData(filtered, groupList);
                return ListView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  shrinkWrap: true,
                  children: [

                  Container(
                    child: streamdocsnap.isNotEmpty
                        ? StreamBuilder(
                        stream: userQuery.stream.asBroadcastStream(),
                        builder: (context, snapshot) {
                          if (filter.text.isNotEmpty ||
                              snapshot.hasData) {
                            filtered = this.streamdocsnap.where((user) {
                              return user[Dbkeys.nickname]
                                  .toLowerCase()
                                  .trim()
                                  .contains(new RegExp(r'' +
                                  filter.text.toLowerCase().trim() +
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
                              if (streamdocsnap[index].containsKey(
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
                                              url: streamdocsnap[
                                              index][
                                              Dbkeys
                                                  .groupPHOTOURL],
                                              radius: 22),
                                          title: Text(
                                            streamdocsnap[index]
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
                                            '${streamdocsnap[index][Dbkeys
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
                                                        streamdocsnap[
                                                        index]
                                                        [
                                                        '${widget
                                                            .currentUserNo}-joinedOn'],
                                                        currentUserno: widget
                                                            .currentUserNo!,
                                                        groupID:
                                                        streamdocsnap[
                                                        index]
                                                        [Dbkeys
                                                            .groupID])));
                                          },
                                          trailing: StreamBuilder(
                                            stream: FirebaseFirestore
                                                .instance
                                                .collection(DbPaths
                                                .collectiongroups)
                                                .doc(streamdocsnap[index]
                                            [Dbkeys.groupID])
                                                .collection(DbPaths
                                                .collectiongroupChats)
                                                .where(
                                                Dbkeys.groupmsgTIME,
                                                isGreaterThan:
                                                streamdocsnap[
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
                                                    campusChat,
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
                                    streamdocsnap.elementAt(index));
                              }
                            },
                            itemCount: streamdocsnap.length,
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
                        ]))],
                  );
              }));
  }

  Widget buildGroupitem() {
    return Text(
      Dbkeys.groupNAME,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

   

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    //final observer = Provider.of<Observer>(this.context, listen: false);
    final panelHeightClosed = MediaQuery.of(context).size.height*0.6;
    final panelHeightOpen = MediaQuery.of(context).size.height*0.9;
    return CuChat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child:
          ScopedModelDescendant<DataModel>(builder: (context, child, _model) {
        _cachedModel = _model;
        return Scaffold(
          bottomSheet: IsBannerAdShow == true &&
                  observer.isadmobshow == true &&
                  adWidget != null
              ? Container(
                  height: 60,
                  margin: EdgeInsets.only(
                      bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
                  child: Center(child: adWidget),
                )
              : SizedBox(
                  height: 0,
                ),
          backgroundColor: fiberchatWhite,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
                bottom: IsBannerAdShow == true && observer.isadmobshow == true
                    ? 60
                    : 0),
            child: FloatingActionButton(
                backgroundColor: campusChat,
                child: Icon(
                  Icons.chat,
                  size: 30.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SmartContactsPage(
                              onTapCreateGroup: () {
                                if (observer.isAllowCreatingGroups == false) {
                                  CuChat.showRationale(
                                      getTranslated(this.context, 'disabled'));
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddContactsToGroup(
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                model: _cachedModel,
                                                biometricEnabled: false,
                                                prefs: widget.prefs,
                                                isAddingWhileCreatingGroup:
                                                    true,
                                              )));
                                }
                              },
                              prefs: widget.prefs,
                              biometricEnabled: biometricEnabled,
                              currentUserNo: currentUserNo!,
                              model: _cachedModel!)));
                }),
          ),
          body:


          RefreshIndicator(
            color: campusChat,
            onRefresh: () {
              isAuthenticating = !isAuthenticating;
              if(mounted)
              setState(() {
                showHidden = !showHidden;
              });
              return Future.value(true);
            },

            child:

            SlidingUpPanel(
                controller: panelController,
                minHeight: panelHeightClosed,
                maxHeight: panelHeightOpen,
                parallaxEnabled: true,
                parallaxOffset: .5,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                body: //_chats(_model.userData, _model.currentUser)




    Container(
        /*alignment: Alignment.center,
        color: campusChat,
        decoration: BoxDecoration(color: campusChat),
        height: 0,
        width: double.infinity,*/
        color: campusChat,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Icon(Icons.chat,size: 60,color: Colors.black),
            //Text("CuChat", style: TextStyle(fontSize: 10))
          ],
        ),
        padding: EdgeInsets.only(top: 30),

        //alignment: Alignment.bottomCenter,
        //child: Text("CuChat",textAlign: TextAlign.center,style: TextStyle(color: Colors.black, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 35))
    ),

              panelBuilder: (controller) => _chats(_model.userData, _model.currentUser,controller),


              ),
          ),
        );
      }),
    ));
  }


}
