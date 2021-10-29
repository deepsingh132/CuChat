//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/security_screens/security.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/Passcode/circle.dart';
import 'package:fiberchat/widgets/Passcode/keyboard.dart';
import 'package:fiberchat/widgets/Passcode/shake_curve.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PasswordEnteredCallback = void Function(String text);

class PasscodeScreen extends StatefulWidget {
  final String? title, question, answer, phoneNo;
  final int passwordDigits;
  final PasswordEnteredCallback passwordEnteredCallback;
  final String cancelLocalizedText;
  final String deleteLocalizedText;
  final Stream<bool> shouldTriggerVerification;
  final Widget? bottomWidget;
  final bool shouldPop;
  final CircleUIConfig? circleUIConfig;
  final KeyboardUIConfig? keyboardUIConfig;
  final bool wait, authentication;
  final SharedPreferences prefs;
  final Function? onSubmit;

  PasscodeScreen(
      {Key? key,
      required this.onSubmit,
      required this.title,
      this.passwordDigits = 6,
      required this.prefs,
      required this.passwordEnteredCallback,
      required this.cancelLocalizedText,
      required this.deleteLocalizedText,
      required this.shouldTriggerVerification,
      required this.wait,
      this.circleUIConfig,
      this.keyboardUIConfig,
      this.bottomWidget,
      this.authentication = false,
      this.question,
      this.answer,
      this.phoneNo,
      this.shouldPop = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  late AnimationController controller;
  late Animation<double> animation;
  bool _isValid = false;
  TextEditingController _answer = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int passcodeTries = 0;
  int answerTries = 0;
  bool forgetVisible = false;

  bool forgetActionable() {
    int tries = widget.prefs.getInt(Dbkeys.answerTries) ?? 0;
    int lastAnswered = widget.prefs.getInt(Dbkeys.lastAnswered) ??
        DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch;

    DateTime lastTried = DateTime.fromMillisecondsSinceEpoch(lastAnswered);
    return (tries <= Dbkeys.triesThreshold ||
        DateTime.now().isAfter(lastTried.add(Duration(
            minutes: math.pow(Dbkeys.timeBase, tries - Dbkeys.triesThreshold)
                as int))));
  }

  @override
  void initState() {
    super.initState();
    if (widget.authentication) {
      passcodeTries = widget.prefs.getInt(Dbkeys.passcodeTries) ?? 0;
      forgetVisible = passcodeTries > Dbkeys.triesThreshold - 1;
      answerTries = widget.prefs.getInt(Dbkeys.answerTries) ?? 0;
    }
    streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
      _showValidation(isValid);
      setState(() {
        _isValid = isValid;
      });
    });
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve as Animation<double>)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enteredPasscode = '';
            controller.value = 0;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(Scaffold(
      appBar: widget.wait
          ? AppBar(
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
              elevation: 0,
              backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatDeepGreen
                  : fiberchatWhite,
              title: Text(
                widget.title!,
                style: TextStyle(
                  color: DESIGN_TYPE == Themetype.whatsapp
                      ? fiberchatWhite
                      : fiberchatBlack,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: DESIGN_TYPE == Themetype.whatsapp
                        ? fiberchatWhite
                        : fiberchatBlack,
                  ),
                  onPressed: _isValid
                      ? () {
                          if (widget.onSubmit != null)
                            widget.onSubmit!(enteredPasscode);
                          Navigator.maybePop(context);
                        }
                      : null,
                )
              ],
            )
          : null,
      backgroundColor: DESIGN_TYPE == Themetype.whatsapp
          ? fiberchatDeepGreen
          : fiberchatWhite,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.wait ? getTranslated(context, 'hardguess') : widget.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildCircles(),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Keyboard(
                  onDeleteCancelTap: _onDeleteCancelButtonPressed,
                  onKeyboardTap: _onKeyboardButtonPressed,
                  shouldShowCancel: enteredPasscode.isEmpty,
                  cancelLocalizedText: widget.cancelLocalizedText,
                  deleteLocalizedText: widget.deleteLocalizedText,
                  keyboardUIConfig: widget.keyboardUIConfig != null
                      ? widget.keyboardUIConfig
                      : KeyboardUIConfig(
                          primaryColor: DESIGN_TYPE == Themetype.whatsapp
                              ? fiberchatWhite
                              : fiberchatBlack,
                          digitTextStyle: TextStyle(
                              fontSize: 30,
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? fiberchatWhite
                                  : fiberchatBlack)),
                ),
              ),
            ),
            widget.bottomWidget != null
                ? widget.bottomWidget ?? SizedBox()
                : Container(),
            widget.authentication && forgetVisible
                // ignore: deprecated_member_use
                ? FlatButton(
                    onPressed: () {
                      if (forgetActionable()) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(widget.question!),
                                content: SingleChildScrollView(
                                    child: Form(
                                  key: _formKey,
                                  child: Column(children: <Widget>[
                                    TextFormField(
                                      controller: _answer,
                                      decoration: InputDecoration(
                                          labelText:
                                              getTranslated(context, 'sans')),
                                      validator: (val) {
                                        if (val!.isEmpty)
                                          return getTranslated(
                                              context, 'ansempty');
                                        if (Fiberchat.getHashedAnswer(val) !=
                                            widget.answer) {
                                          setState(() {
                                            answerTries += 1;
                                            widget.prefs.setInt(
                                                Dbkeys.answerTries,
                                                answerTries);
                                            widget.prefs.setInt(
                                                Dbkeys.lastAnswered,
                                                DateTime.now()
                                                    .millisecondsSinceEpoch);
                                            if (answerTries >
                                                Dbkeys.triesThreshold) {
                                              Fiberchat.toast(getTranslated(
                                                      context, 'trylater') +
                                                  ' ${math.pow(Dbkeys.timeBase, answerTries - Dbkeys.triesThreshold)} minutes');
                                              Navigator.maybePop(context);
                                            }
                                          });
                                          return getTranslated(
                                              context, 'wrongans');
                                        } else {
                                          widget.prefs
                                              .setInt(Dbkeys.answerTries, 0);
                                          widget.prefs.setInt(
                                              Dbkeys.passcodeTries,
                                              0); // reset tries
                                          Navigator.pushReplacement(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new Security(
                                                        widget.phoneNo,
                                                        prefs: widget.prefs,
                                                        title: getTranslated(
                                                            context,
                                                            'updatesecurity'),
                                                        shouldPop: true,
                                                        setPasscode: true,
                                                        answer: widget.answer,
                                                        onSuccess: () {
                                                          Navigator.popUntil(
                                                              context,
                                                              (route) => route
                                                                  .isFirst);
                                                        },
                                                      )));
                                        }
                                        return null;
                                      },
                                    )
                                  ]),
                                )),
                                actions: <Widget>[
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    child: Text(getTranslated(context, 'done')),
                                    onPressed: () {
                                      _formKey.currentState!.validate();
                                    },
                                  )
                                ],
                              );
                            });
                      } else
                        Fiberchat.toast(getTranslated(context, 'trylater'));
                    },
                    child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(getTranslated(context, 'forgotpassword'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w300))),
                  )
                : SizedBox()
          ],
        ),
      )),
    ));
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null
        ? widget.circleUIConfig!
        : CircleUIConfig(
            fillColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
            borderColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          );
    config.extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(Circle(
        filled: i < enteredPasscode.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.isNotEmpty) {
      setState(() {
        enteredPasscode =
            enteredPasscode.substring(0, enteredPasscode.length - 1);
        widget.passwordEnteredCallback(enteredPasscode);
      });
    } else {
      Navigator.maybePop(context);
    }
  }

  _onKeyboardButtonPressed(String text) {
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        widget.passwordEnteredCallback(enteredPasscode);
        if (enteredPasscode.length == widget.passwordDigits) {
          if (widget.authentication &&
              widget.prefs.getInt(Dbkeys.passcodeTries)! >
                  Dbkeys.triesThreshold - 1) {
            if (forgetVisible != true) {
              setState(() {
                forgetVisible = true;
              });
            }
          }
        }
      }
    });
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
        _showValidation(isValid);
        setState(() {
          _isValid = isValid;
        });
      });
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
    streamSubscription.cancel();
  }

  _showValidation(bool isValid) {
    if (!widget.wait) {
      if (isValid && widget.shouldPop) {
        Navigator.maybePop(context);
      } else {
        controller.forward();
      }
    }
  }
}
