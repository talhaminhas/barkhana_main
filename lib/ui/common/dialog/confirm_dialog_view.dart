import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/utils/utils.dart';

class ConfirmDialogView extends StatefulWidget {
  const ConfirmDialogView(
      {Key? key,
      this.description,
      this.leftButtonText,
      this.rightButtonText,
      this.onAgreeTap})
      : super(key: key);

  final String? description, leftButtonText, rightButtonText;
  final Function? onAgreeTap;

  @override
  _LogoutDialogState createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<ConfirmDialogView> {
  @override
  Widget build(BuildContext context) {
    return NewDialog(widget: widget);
  }
}

class NewDialog extends StatelessWidget {
  const NewDialog({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final ConfirmDialogView widget;

  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      width: PsDimens.space4,
    );
    const Widget _largeSpacingWidget = SizedBox(
      height: PsDimens.space20,
    );
    final Widget _headerWidget = Row(
      children: <Widget>[
        _spacingWidget,
        Icon(
          Icons.help_outline,
          color: PsColors.white,
        ),
        _spacingWidget,
        Text(
          Utils.getString(context, 'logout_dialog__confirm'),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: PsColors.white,
          ),
        ),
      ],
    );

    final Widget _messageWidget = Text(
      widget.description!,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
          //color: PsColors.white,
          fontWeight: FontWeight.bold
      ),
    );
    return Dialog(
        backgroundColor: PsColors.backgroundColor.withOpacity(0.6),
        shadowColor: PsColors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsDimens.space20),
          side: BorderSide(
            color: PsColors.mainColor,
            width: 2.0,
          ),
        ),
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: <Color>[
                  PsColors.mainColor.withOpacity(0.9),
                  PsColors.backgroundColor.withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space20)),
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          height: PsDimens.space60,
                          width: double.infinity,
                          padding: const EdgeInsets.all(PsDimens.space8),
                          /*decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))
                          ),*/
                          child: _headerWidget),
                      _largeSpacingWidget,
                      Container(
                        padding: const EdgeInsets.only(
                            left: PsDimens.space16,
                            right: PsDimens.space16,
                            top: PsDimens.space8,
                            bottom: PsDimens.space8),
                        child: _messageWidget,
                      ),
                      _largeSpacingWidget,
                      Container(
                        color: PsColors.mainColor,
                        height: 2,
                      ),
                      Row(children: <Widget>[
                        Expanded(
                            child: MaterialButton(
                              height: 50,
                              minWidth: double.infinity,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(widget.leftButtonText!,
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  //color: PsColors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            )),
                        Container(
                            height: 50,
                            width: 2,
                            color: PsColors.mainColor
                        ),
                        Expanded(
                            child: MaterialButton(
                              height: 50,
                              minWidth: double.infinity,
                              onPressed: () {
                                widget.onAgreeTap!();
                              },
                              child: Text(
                                widget.rightButtonText!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: PsColors.mainColor,fontWeight: FontWeight.bold),
                              ),
                            )),
                      ])
                    ],
                  ),
                ))));


  }
}
