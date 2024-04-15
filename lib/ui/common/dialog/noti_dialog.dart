import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/utils/utils.dart';

class NotiDialog extends StatefulWidget {
  const NotiDialog({this.message});
  final String? message;
  @override
  _NotiDialogState createState() => _NotiDialogState();
}

class _NotiDialogState extends State<NotiDialog> {
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

  final NotiDialog widget;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: PsColors.transparent,
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
                borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space20)), // Adjust the border radius as needed
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            height: 60,
                            width: double.infinity,
                            padding: const EdgeInsets.all(PsDimens.space8),
                            /*decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    color: PsColors.mainColor.withOpacity(0.7)),*/
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: PsDimens.space4,
                                ),
                                Icon(
                                  Icons.message_outlined,
                                  color: PsColors.white,
                                ),
                                const SizedBox(
                                  width: PsDimens.space4,
                                ),
                                Text('Notification',
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(color: PsColors.white)),
                              ],
                            )),

                        const SizedBox(
                          height: PsDimens.space20,
                        ),

                        Container(
                          padding: const EdgeInsets.only(
                              left: PsDimens.space16,
                              right: PsDimens.space16,
                              top: PsDimens.space8,
                              bottom: PsDimens.space8),
                          child: Text(
                              widget.message!,
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(
                          height: PsDimens.space20,
                        ),
                        Divider(
                          thickness: 2,
                          height: 2,
                          color: PsColors.mainColor,
                        ),
                        MaterialButton(
                          height: 50,
                          minWidth: double.infinity,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            Utils.getString(context, 'dialog__ok'),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: PsColors.mainColor,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      ],
                    )
                )
            )));
  }
}

