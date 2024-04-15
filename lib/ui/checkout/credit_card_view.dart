import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar_with_no_provider.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:provider/provider.dart';

import '../../config/ps_colors.dart';

class CreditCardView extends StatefulWidget {
  const CreditCardView(
      {Key? key,
      required this.basketList,
      required this.couponDiscount,
      required this.psValueHolder,
      required this.transactionSubmitProvider,
      required this.userLoginProvider,
      required this.basketProvider,
      required this.memoText,
      required this.publishKey,
      required this.isClickPickUpButton,
      required this.deliveryPickUpDate,
      required this.deliveryPickUpTime})
      : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final TransactionHeaderProvider transactionSubmitProvider;
  final UserProvider userLoginProvider;
  final BasketProvider basketProvider;
  final String memoText;
  final String publishKey;
  final bool isClickPickUpButton;
  final String deliveryPickUpDate;
  final String deliveryPickUpTime;

  @override
  State<StatefulWidget> createState() {
    return CreditCardViewState();
  }
}

dynamic callTransactionSubmitApi(
    BuildContext context,
    BasketProvider basketProvider,
    UserProvider userLoginProvider,
    TransactionHeaderProvider transactionSubmitProvider,
    List<Basket> basketList,
    String token,
    String couponDiscount,
    String memoText,
    bool isClickPickUpButton,
    String deliveryPickUpDate,
    String deliveryPickUpTime) async {
  if (await Utils.checkInternetConnectivity()) {
    if (userLoginProvider.user.data != null) {
      final PsValueHolder valueHolder =
          Provider.of<PsValueHolder>(context, listen: false);
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userLoginProvider.user.data!,
              basketList,
              Platform.isIOS ? token : token,
              couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              '',
              '',
              PsConst.ZERO,
              isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
              deliveryPickUpDate,
              deliveryPickUpTime,
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              userLoginProvider.user.data!.area!.areaName!,
              memoText,
              valueHolder);
      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider.deleteWholeBasketList();

          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data!,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: _apiStatus.message,
                );
              });
        }
      } else {
        PsProgressDialog.dismissDialog();

        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
      }
    }
  } else {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        });
  }
}

class CreditCardViewState extends State<CreditCardView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
 //CardFieldInputDetails? cardData;

  @override
  void initState() {
   //Stripe.publishableKey = widget.publishKey;
    super.initState();
  }

  void setError(dynamic error) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, error.toString()),
          );
        });
  }

  dynamic callWarningDialog(BuildContext context, String text) {
    showDialog<dynamic>(
        context: context,
        barrierColor: PsColors.transparent,
        builder: (BuildContext context) {
          return WarningDialog(
            message: Utils.getString(context, text),
            onPressed: () {},
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dynamic stripeNow(String token) async {
      widget.basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: widget.couponDiscount,
          psValueHolder: widget.psValueHolder,
          shippingPriceStringFormatting:
              widget.userLoginProvider.user.data!.area!.price!);

      callTransactionSubmitApi(
          context,
          widget.basketProvider,
          widget.userLoginProvider,
          widget.transactionSubmitProvider,
          widget.basketList,
          token,
          widget.couponDiscount,
          widget.memoText,
          widget.isClickPickUpButton,
          widget.deliveryPickUpDate,
          widget.deliveryPickUpTime);
    }

    return const PsWidgetWithAppBarWithNoProvider(
      appBarTitle: 'Credit Card',
      child: Column(
        children: <Widget>[
         /* Container(
            padding: const EdgeInsets.all(PsDimens.space16),
            child: CardField(
              autofocus: true,
              onCardChanged: (CardFieldInputDetails? card) async {
                setState(() {
                  cardData = card;
                });
              },
            ),
          ),*/
         /* Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12, right: PsDimens.space12),
            child: PSButtonWidget(
              hasShadow: true,
              width: double.infinity,
              titleText: Utils.getString(context, 'credit_card__pay'),
              onPressed: () async {
                if (cardData != null && cardData!.complete) {
                  await PsProgressDialog.showDialog(context);
                  const PaymentMethodParams paymentMethodParams =
                      PaymentMethodParams.card(
                          paymentMethodData: PaymentMethodData(
                              billingDetails: BillingDetails()));
                  final PaymentMethod paymentMethod = await Stripe.instance
                      .createPaymentMethod(params: paymentMethodParams);
                  Utils.psPrint(paymentMethod.id);
                  await stripeNow(paymentMethod.id);
                } else {
                  callWarningDialog(
                      context, Utils.getString(context, 'contact_us__fail'));
                }
              },
            ),
          ),*/
        ],
      ),
    );
  }

  // void onCreditCardModelChange(CreditCardModel creditCardModel) {
  //   setState(() {
  //     cardNumber = creditCardModel.cardNumber;
  //     expiryDate = creditCardModel.expiryDate;
  //     cardHolderName = creditCardModel.cardHolderName;
  //     cvvCode = creditCardModel.cvvCode;
  //     isCvvFocused = creditCardModel.isCvvFocused;
  //   });
  // }
}
