import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/viewobject/reservation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/ps_colors.dart';
import '../../../constant/ps_dimens.dart';
import '../../../utils/utils.dart';

class ReservationListItem extends StatelessWidget {
  const ReservationListItem(
      {Key? key,
      required this.reservation,
      this.onTap,
      this.updateReservationStatus,
      this.animationController,
      required this.scaffoldKey,
      this.animation})
      : super(key: key);

  final Reservation reservation;
  final Function? onTap;
  final Function? updateReservationStatus;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (reservation != null) {
      animationController!.forward();
      return AnimatedBuilder(
          animation: animationController!,
          child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Container(
              margin: const EdgeInsets.only(top: 10, right:  20, left: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Set the radius as needed
                border: Border.all(
                  color: PsColors.mainColor, // You can replace PsColors.borderColor with the color you desire
                  width: 2.0, // Set the border width as needed
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TransactionNoWidget(
                    reservation: reservation,
                    scaffoldKey: scaffoldKey,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 20, left: 20),
                    child: Divider(
                      color: PsColors.mainColor,
                      height: PsDimens.space2,
                      thickness: 2,
                    ),
                  ),
                  _TransactionTextWidget(
                    reservation: reservation,
                    updateReservationStatus: updateReservationStatus!,
                  ),
                ],
              ),
            ),

          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child,
              ),
            );
          });
    } else {
      return Container();
    }
  }
}

class _TransactionNoWidget extends StatelessWidget {
  const _TransactionNoWidget({
    Key? key,
    required this.reservation,
    required this.scaffoldKey,
  }) : super(key: key);

  final Reservation reservation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(
      reservation.resvDate!,
      textAlign: TextAlign.left,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: PsColors.mainColor, // Replace PsColors.yourDesiredColor with the color you want
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space20,
          right: PsDimens.space20,
          top: PsDimens.space10,
          bottom: PsDimens.space10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.calendar_month_outlined,
                size: PsDimens.space24,
                color: PsColors.mainColor,
              ),
              const SizedBox(
                width: PsDimens.space8,
              ),
              _textWidget,
            ],
          ),
          Text(
            reservation.reservationstatus!.title ?? '-',
            style:
            Theme.of(context).textTheme.titleMedium!.copyWith(
              color: reservation.reservationstatus!.id == '1'
                  ? PsConst.PENDING_COLOR
                  : reservation.reservationstatus!.id == '2'
                  ? PsConst.CANCEL_COLOR
                  : reservation.reservationstatus!.id == '3'
                  ? PsConst.CONFIRM_COLOR
                  : reservation.reservationstatus!.id == '4'
                  ? PsConst.COMPLETE_COLOR
                  : reservation.reservationstatus!.id == '5'
                  ? PsConst.REJECTE_COLOR
                  : PsColors.mainColor,
            ),
          ),
        ],
      ),
    );
  }
}


class _TransactionTextWidget extends StatelessWidget {
  const _TransactionTextWidget(
      {Key? key,
      required this.reservation,
      required this.updateReservationStatus})
      : super(key: key);

  final Reservation reservation;
  final Function updateReservationStatus;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space20,
      right: PsDimens.space20,
      top: PsDimens.space10,
    );

    final Widget _nameTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Name : ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${reservation.userName}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );
    final Widget _dateTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Time :' ,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${reservation.resvTime}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );
    final Widget _noOfPeopleTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Number Of People :' ,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${reservation.noOfPeople}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );

    final Widget _callRestaurnatTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
            visible: reservation.reservationstatus!.id == '1',
            child: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Container(
                        height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: PsColors.discountColor, // Replace PsColors.yourDesiredColor with your desired color
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.white
                        ),
                      ),
                      onPressed: () async {
                        showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmDialogView(
                                  description:
                                  Utils.getString(context, 'reservation_confirm'),
                                  leftButtonText: Utils.getString(
                                      context, 'app_info__cancel_button_name'),
                                  rightButtonText:
                                  Utils.getString(context, 'dialog__ok'),
                                  onAgreeTap: () async {
                                    Navigator.pop(context);
                                    updateReservationStatus();
                                  });
                            });
                      }),
              )

                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            )),
        Expanded(
          child: Container(
            height: 50,
            child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(right: 5,),
                        child: const Icon(Icons.call,
                            size: PsDimens.space18, color: Colors.white),
                      ),
                      Text(
                        Utils.getString(context, 'transaction_call_restaurant'),
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(
                        'tel://${reservation.shopInfo!.aboutPhone1}'))) {
                      await launchUrl(Uri.parse('tel://${reservation.shopInfo!.aboutPhone1}'));
                    } else {
                      throw 'Could not Call Phone Number 1';
                    }
                  },
                ),
          ),
        ),



      ],
    );

    // ignore: unnecessary_null_comparison
    if (reservation != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _nameTextWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _dateTextWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _noOfPeopleTextWidget,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: _callRestaurnatTextWidget,
          ),
          const SizedBox(
            height: 10,
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
