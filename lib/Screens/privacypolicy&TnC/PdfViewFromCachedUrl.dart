
import 'package:CuChat/Configs/Enum.dart';
import 'package:CuChat/Configs/app_constants.dart';
import 'package:CuChat/Screens/calling_screen/pickup_layout.dart';
import 'package:CuChat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl(
      {Key? key, required this.url, required this.title})
      : super(key: key);

  final String? url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        scaffold: CuChat.getNTPWrappedWidget(Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatWhite
                  : fiberchatBlack,
              fontSize: 18),
        ),
        backgroundColor: DESIGN_TYPE == Themetype.whatsapp
            ? campusChat
            : fiberchatWhite,
      ),
      body: const PDF().cachedFromUrl(
        url!,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    )));
  }
}
