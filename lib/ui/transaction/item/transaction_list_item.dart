import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:provider/provider.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.animationController,
    this.animation,
    this.onTap,
    required this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    if ( transaction.transCode != null) {
      return AnimatedBuilder(
          animation: animationController!,
          child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Container(
              margin: const EdgeInsets.only(
                  top: PsDimens.space10,
                right: PsDimens.space16,
                left:PsDimens.space16,
              ),
              decoration: BoxDecoration(
                color: PsColors.backgroundColor,
                border: Border.all(
                  color: PsColors.mainColor, // Set your desired border color here
                  width: 2.0, // Set the border width
                ),
                borderRadius: BorderRadius.circular(10.0), // Set the border radius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TransactionNoWidget(
                    transaction: transaction,
                    scaffoldKey: scaffoldKey,
                  ),

                  _TransactionTextWidget(
                    transaction: transaction,
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
    required this.transaction,
    required this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(
      '${Utils.getString(context, 'transaction_detail__trans_no')} : ${transaction.transCode}',
      textAlign: TextAlign.left,
      style: Theme.of(context).textTheme.titleSmall,
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space14,
          right: PsDimens.space14,
          top: PsDimens.space8,
          bottom: PsDimens.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
                  /*Text(
                      transaction.transStatus!.title!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!
                          .copyWith(
                          fontSize: 20,
                          color: Utils.hexToColor(transaction.transStatus!.colorValue!)
                      )
                  ),*/
              Text(
                  'Order No :',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!
                      .copyWith(
                      fontSize: 20,
                      color: PsColors.mainColor
                  )
              ),
              Expanded(
                child: Text(
                    transaction.transCode!,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium!
                        .copyWith(
                        fontSize: 20,
                        color: PsColors.mainColor
                    )
                ),
              )
             /* const Icon(
                Icons.offline_pin,
                size: PsDimens.space24,
              ),
              const SizedBox(
                width: PsDimens.space8,
              ),
              _textWidget,*/
            ],
          ),
          /*IconButton(
            icon: const Icon(Icons.content_copy),
            iconSize: 24,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: transaction.transCode!));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme.of(context).iconTheme.color,
                content: Tooltip(
                  message: Utils.getString(context, 'transaction_detail__copy'),
                  child: Text(
                    Utils.getString(context, 'transaction_detail__copied_data'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: PsColors.mainColor),
                  ),
                  showDuration: const Duration(seconds: 5),
                ),
              ));
            },
          ),*/
    );
  }
}

class _TransactionTextWidget extends StatelessWidget {
  const _TransactionTextWidget({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final TransactionHeader transaction;

  @override
  Widget build(BuildContext context) {
    PsValueHolder? valueHolder;
  valueHolder = Provider.of<PsValueHolder>(context, listen: false);
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
      top: PsDimens.space8,
    );

    final Widget _totalAmountTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'transaction_list__total_amount'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.balanceAmount!,valueHolder)}',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: PsColors.mainColor, fontWeight: FontWeight.normal),
        )
      ],
    );

    final Widget _statusTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'transaction_detail__status'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
              top: PsDimens.space4,
              bottom: PsDimens.space4,
              right: PsDimens.space12,
              left: PsDimens.space12),
          decoration: BoxDecoration(
              color: PsColors.mainColor,
              // border: Border.all(color: PsColors.mainLightShadowColor),
              borderRadius:
                  const BorderRadius.all(Radius.circular(PsDimens.space8))),
          child: Text(
            transaction.transStatus!.title ?? '-',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: PsColors.black),
          ),
        )
      ],
    );

    final Widget _viewDetailTextWidget = Text(
      Utils.getString(context, 'transaction_detail__view_details'),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
          ),
    );
    if ( transaction.transCode != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: PsDimens.space16, right: PsDimens.space16,),
            child: Divider(
              height: 2,
              thickness: 2,
              color: PsColors.mainColor,
            ),
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Order Status :',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  transaction.transStatus!.title!,
                    style: Theme.of(context).textTheme.titleMedium!
                        .copyWith(
                        color: Utils.hexToColor(transaction.transStatus!.colorValue!)
                    )
                )
              ],
            ),
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'transaction_list__total_amount') + ' :',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  '${transaction.currencySymbol}${Utils.getPriceFormat(transaction.balanceAmount!,valueHolder)}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith( fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Time :',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                    DateFormat("hh:mm a").format(
                    DateTime.parse(transaction.addedDate!)),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith( fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Date :',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                      DateFormat("dd-MM-yyyy").format(
                      DateTime.parse(transaction.addedDate!)),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith( fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: PsDimens.space16,
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
