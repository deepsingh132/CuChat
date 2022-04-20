import 'package:CuChat/Configs/Enum.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Services/Providers/Observer.dart';
import 'package:CuChat/Services/localization/language_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class tab_bar extends StatelessWidget {
  const tab_bar({
    Key? key,
    required this.observer,
    required this.controllerIfcallallowed,
    required this.controllerIfcallNotallowed,
  }) : super(key: key);

  final Observer observer;
  final TabController? controllerIfcallallowed;
  final TabController? controllerIfcallNotallowed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      height: 80,
      //decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50) , bottomRight: Radius.circular(40))),

      child: TabBar(
        indicator: ShapeDecoration(
            color: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        labelColor: DESIGN_TYPE == Themetype.whatsapp
            ? fiberchatWhite
            : fiberchatBlack,
        unselectedLabelColor:
        DESIGN_TYPE == Themetype.whatsapp
            ? fiberchatWhite.withOpacity(0.6)
            : fiberchatBlack.withOpacity(0.6),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor:
        DESIGN_TYPE == Themetype.whatsapp
            ? Colors.white
            : campusChat,
        controller:
        observer.isCallFeatureTotallyHide == false
            ? controllerIfcallallowed
            : controllerIfcallNotallowed,
        tabs: observer.isCallFeatureTotallyHide ==
            false
            ? <Widget>[
          /*Tab(
            icon: Icon(
              Icons.search,
              size: 22,
            ),
          ),*/



          Tab(
            child: Text(
              getTranslated(context, 'status'),
              textAlign: TextAlign.center,
            ),
          ),

          Tab(
            child: Text(
              getTranslated(context, 'chats'),
              textAlign: TextAlign.center,
            ),
          ),

          Tab(
            child: Text(
              getTranslated(context, 'calls'),
              textAlign: TextAlign.center,
            ),
          ),
        ]
            : <Widget>[
          /*Tab(
                  icon: Icon(
                    Icons.search,
                    size: 22,
                  ),
                ),*/

          Tab(
            child: Text(
              getTranslated(context, 'status'),
              textAlign: TextAlign.center,
            ),
          ),

          Tab(
            child: Text(
              getTranslated(context, 'chats'),
              textAlign: TextAlign.center,
            ),
          ),


        ],
      ),
    );
  }
}