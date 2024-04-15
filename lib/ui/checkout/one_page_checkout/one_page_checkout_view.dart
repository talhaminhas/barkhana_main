import 'package:flutter/material.dart';
//import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutterrestaurant/viewobject/holder/profile_update_view_holder.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
//import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../api/common/ps_resource.dart';
import '../../../api/common/ps_status.dart';
import '../../../config/ps_colors.dart';
import '../../../config/ps_config.dart';
import '../../../constant/ps_constants.dart';
import '../../../constant/ps_dimens.dart';
import '../../../constant/route_paths.dart';
import '../../../provider/basket/basket_provider.dart';
import '../../../provider/coupon_discount/coupon_discount_provider.dart';
import '../../../provider/delivery_cost/delivery_cost_provider.dart';
import '../../../provider/schedule/schedule_header_provider.dart';
import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../provider/token/token_provider.dart';
import '../../../provider/transaction/transaction_header_provider.dart';
import '../../../provider/user/user_provider.dart';
import '../../../repository/basket_repository.dart';
import '../../../repository/coupon_discount_repository.dart';
import '../../../repository/delivery_cost_repository.dart';
import '../../../repository/schedule_header_repository.dart';
import '../../../repository/shop_info_repository.dart';
import '../../../repository/token_repository.dart';
import '../../../repository/transaction_header_repository.dart';
import '../../../repository/user_repository.dart';
import '../../../utils/ps_progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/api_status.dart';
import '../../../viewobject/basket.dart';
import '../../../viewobject/common/ps_value_holder.dart';
import '../../../viewobject/coupon_discount.dart';
import '../../../viewobject/delivery_cost.dart';
import '../../../viewobject/holder/bill_to_callback_holder.dart';
import '../../../viewobject/holder/coupon_discount_holder.dart';
import '../../../viewobject/holder/delivery_cost_parameter_holder.dart';
import '../../../viewobject/holder/intent_holder/billing_to_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/credit_card_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/delivery_location_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/order_time_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/payment_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/paystack_intent_holder.dart';
import '../../../viewobject/holder/intent_holder/schedule_checkout_intent_holder.dart';
import '../../../viewobject/holder/order_location_callback_holder.dart';
import '../../../viewobject/holder/order_time_callback_holder.dart';
import '../../../viewobject/holder/payment_callback_holder.dart';
import '../../../viewobject/schedule_header.dart';
import '../../../viewobject/transaction_header.dart';
import '../../../viewobject/user.dart';
import '../../common/dialog/confirm_dialog_view.dart';
import '../../common/dialog/demo_warning_dialog.dart';
import '../../common/dialog/error_dialog.dart';
import '../../common/dialog/success_dialog.dart';
import '../../common/dialog/warning_dialog_view.dart';
import '../../common/ps_button_widget.dart';
import '../../common/ps_textfield_widget.dart';

class OnePageCheckoutView extends StatefulWidget {
  const OnePageCheckoutView({
    Key? key,
    required this.basketList,
    required this.shopInfoProvider,
  }) : super(key: key);

  final List<Basket> basketList;
  final ShopInfoProvider shopInfoProvider;

  @override
  _OnePageCheckoutViewState createState() {
    final _OnePageCheckoutViewState _state = _OnePageCheckoutViewState();
    return _state;
  }
}

class _OnePageCheckoutViewState extends State<OnePageCheckoutView> {
  AnimationController? animationController;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController userAddressController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  TextEditingController firstTimeOrderController = TextEditingController();
  TextEditingController secondTimeOrderController = TextEditingController();
  TextEditingController selectedTimesController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  TextEditingController costPerChargesController = TextEditingController();
  TextEditingController shippingCostController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  TextEditingController orderTimeTextEditingController =
      TextEditingController();
  bool isCheckBoxSelect = false;
  UserRepository? userRepository;
  UserProvider? userProvider;
  ShopInfoProvider? shopInfoProvider;
  TransactionHeaderProvider? transactionSubmitProvider;
  CouponDiscountProvider? couponDiscountProvider;
  ScheduleHeaderProvider? scheduleHeaderProvider;
  BasketProvider? basketProvider;
  TokenProvider? tokenProvider;
  TokenRepository? tokenRepository;
  DeliveryCostProvider? provider;
  ShopInfoRepository? shopInfoRepository;
  CouponDiscountRepository? couponDiscountRepo;
  ScheduleHeaderRepository? scheduleHeaderRepository;
  BasketRepository? basketRepository;
  DeliveryCostRepository? deliveryCostRepository;
  TransactionHeaderRepository? transactionHeaderRepo;
  late PsValueHolder valueHolder;
  bool bindDataFirstTime = true;
  bool isRazorSupportMultiCurrency = false;
  String? deliveryPickUpDate;
  String? deliveryPickUpTime;
  double? couponDiscount;
  double? basketTotalPrice = 0;
  String? currencySymbol;
  double? totalCost;
  int? hour, minute;
  String? days;
  int? monOpenHour, monCloseHour, monOpenMin, monCloseMin;
  int? tuesOpenHour, tuesCloseHour, tuesOpenMin, tuesCloseMin;
  int? wedOpenHour, wedCloseHour, wedOpenMin, wedCloseMin;
  int? thursOpenHour, thursCloseHour, thursOpenMin, thursCloseMin;
  int? friOpenHour, friCloseHour, friOpenMin, friCloseMin;
  int? satOpenHour, satCloseHour, satOpenMin, satCloseMin;
  int? sunOpenHour, sunCloseHour, sunOpenMin, sunCloseMin;
  bool hasErrorInShopTime = false;
  bool dateTimeUpdatedFromOrderTime = false;
  bool isApiSuccess = false;

  dynamic updatDateAndTime(String dateTime) {
    deliveryPickUpDate =
        DateFormat.yMMMEd('en_US').format(DateTime.parse(dateTime));
    deliveryPickUpTime =
        DateFormat.Hm('en_US').format(DateTime.parse(dateTime));
    orderTimeTextEditingController.text =
        deliveryPickUpDate! + ' ' + deliveryPickUpTime!;
  }

  dynamic calculateBasketTotalPrice() {
    double total = 0;
    for (Basket basket in widget.basketList) {
      total += double.parse(basket.basketPrice!) * double.parse(basket.qty!);
    }
    currencySymbol = widget.basketList[0].product!.currencySymbol;

    total += basketTotalPrice! * double.parse(valueHolder.overAllTaxValue!);
    basketTotalPrice = total;
  }

  dynamic calculateTotalDeliveryCost() {
    final double totalShippingCostWithTax =
        double.parse(shippingCostController.text) +
            (double.parse(shippingCostController.text) * .02);
    final double totalBasketCostWithTax =
        basketTotalPrice! + (basketTotalPrice! * .03);
    totalCost =
        (totalShippingCostWithTax + totalBasketCostWithTax) - couponDiscount!;
  }

  dynamic deliveryCostCalculate() async {
    // if (shippingCostController.text.isEmpty) {
    if (await Utils.checkInternetConnectivity()) {
      final DeliveryCostParameterHolder deliveryCostParameterHolder =
          DeliveryCostParameterHolder(
              userLat: userProvider!.user.data!.userLat!,
              userLng: userProvider!.user.data!.userLng!,
              productId: widget.basketList[0].product!.id!);
      await PsProgressDialog.showDialog(context);

      final PsResource<DeliveryCost> _apiStatus =
          await provider!.postDeliveryCost(deliveryCostParameterHolder.toMap());
      PsProgressDialog.dismissDialog();

      if (_apiStatus.data != null) {
        costPerChargesController.text = _apiStatus.data!.costPerCharges!;
        shippingCostController.text = _apiStatus.data!.totalCost!;
        setState(() {});
      } else {
        costPerChargesController.text = '0';
        shippingCostController.text = '0';
      }
    } else {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
      // }
    }
  }

  dynamic bankNow() async {
    if (await Utils.checkInternetConnectivity()) {
      if (userProvider?.user != null && userProvider!.user.data != null) {
        await PsProgressDialog.showDialog(context);
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider!.postTransactionSubmit(
                userProvider!.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider!.checkoutCalculationHelper.tax.toString(),
                basketProvider!.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider!.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                '0.0',
                basketTotalPrice.toString(),
                basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                    .toString(),
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ONE,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                '',
                '',
                PsConst.ZERO,
                userProvider!.isClickPickUpButton == true
                    ? PsConst.ONE
                    : PsConst.ZERO,
                deliveryPickUpDate!,
                deliveryPickUpTime!,
                userProvider!.isClickPickUpButton
                    ? '0.0'
                    : basketProvider!.checkoutCalculationHelper.shippingCost
                        .toString(),
                userProvider!.user.data!.area!.areaName!,
                memoController.text,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();

          await basketProvider?.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccess,
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

  dynamic payNow() async {
    await PsProgressDialog.showDialog(context);
    final PsResource<ApiStatus> tokenResource =
        await tokenProvider!.loadToken();
    await deliveryCostCalculate();

    if (valueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider!.checkoutCalculationHelper.calculate(
          basketList: basketProvider!.basketList.data!,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    } else if (valueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider?.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    }
    /*final BraintreeDropInRequest request = BraintreeDropInRequest(
      clientToken: tokenResource.data!.message,
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: userProvider!.isClickPickUpButton
            ? basketTotalPrice.toString()
            : basketProvider!.checkoutCalculationHelper.totalPrice.toString(),
        currencyCode: shopInfoProvider!.shopInfo.data!.currencyShortForm!,
        billingAddressRequired: false,
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: userProvider!.isClickPickUpButton
            ? basketTotalPrice.toString()
            : basketProvider!.checkoutCalculationHelper.totalPrice.toString(),
        displayName: userProvider!.user.data!.userName,
      ),
    );*/

    /*final BraintreeDropInResult? result = await BraintreeDropIn.start(request);*/
    /*if (result != null) {
      print('Nonce: ${result.paymentMethodNonce.nonce}');
    } else {
      print('Selection was canceled.');
    }*/

    /*if (await Utils.checkInternetConnectivity()) {
      if (result?.paymentMethodNonce.nonce != null) {
        await PsProgressDialog.showDialog(context);

        if (userProvider?.user != null && userProvider?.user.data != null) {
          final PsValueHolder valueHolder =
              Provider.of<PsValueHolder>(context, listen: false);
          final PsResource<TransactionHeader> _apiStatus =
              await transactionSubmitProvider!.postTransactionSubmit(
                  userProvider!.user.data!,
                  widget.basketList,
                  result!.paymentMethodNonce.nonce,
                  couponDiscountProvider!.couponDiscount.toString(),
                  basketProvider!.checkoutCalculationHelper.tax.toString(),
                  basketProvider!.checkoutCalculationHelper.totalDiscount
                      .toString(),
                  basketProvider!.checkoutCalculationHelper.subTotalPrice
                      .toString(),
                  userProvider!.isClickPickUpButton
                      ? '0.0'
                      : basketProvider!.checkoutCalculationHelper.shippingCost
                          .toString(),
                  userProvider!.isClickPickUpButton
                      ? basketTotalPrice.toString()
                      : basketProvider!.checkoutCalculationHelper.totalPrice
                          .toString(),
                  basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                      .toString(),
                  PsConst.ZERO,
                  PsConst.ONE,
                  PsConst.ZERO,
                  PsConst.ZERO,
                  PsConst.ZERO,
                  PsConst.ZERO,
                  PsConst.ZERO,
                  PsConst.ZERO,
                  '',
                  '',
                  PsConst.ZERO,
                  userProvider!.isClickPickUpButton == true
                      ? PsConst.ONE
                      : PsConst.ZERO,
                  deliveryPickUpDate!,
                  deliveryPickUpTime!,
                  userProvider!.isClickPickUpButton
                      ? '0.0'
                      : basketProvider!.checkoutCalculationHelper.shippingCost
                          .toString(),
                  userProvider!.user.data!.area!.areaName!,
                  memoController.text,
                  valueHolder);

          if (_apiStatus.data != null) {
            PsProgressDialog.dismissDialog();

            if (_apiStatus.status == PsStatus.SUCCESS) {
              await basketProvider!.deleteWholeBasketList();

              // Navigator.pop(context, true);
              await Navigator.pushReplacementNamed(
                  context, RoutePaths.checkoutSuccess,
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
      }
    } else {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }*/
  }

  dynamic payCashOnDeliveryScheduleOrder() async {
    if (await Utils.checkInternetConnectivity()) {
      if (userProvider?.user != null && userProvider?.user.data != null) {
        await PsProgressDialog.showDialog(context);
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<List<ScheduleHeader>> _apiStatus =
            await scheduleHeaderProvider!.postScheduleSubmit(
          userProvider!.user.data!,
          widget.basketList,
          '',
          couponDiscountProvider!.couponDiscount.toString(),
          basketProvider!.checkoutCalculationHelper.tax.toString(),
          basketProvider!.checkoutCalculationHelper.totalDiscount.toString(),
          basketProvider!.checkoutCalculationHelper.subTotalPrice.toString(),
          userProvider!.isClickPickUpButton
              ? '0.0'
              : basketProvider!.checkoutCalculationHelper.shippingCost
                  .toString(),
          userProvider!.isClickPickUpButton
              ? basketTotalPrice.toString()
              : basketProvider!.checkoutCalculationHelper.totalPrice.toString(),
          basketProvider!.checkoutCalculationHelper.totalOriginalPrice
              .toString(),
          PsConst.ONE,
          PsConst.ZERO,
          PsConst.ZERO,
          PsConst.ZERO,
          PsConst.ZERO,
          PsConst.ZERO,
          PsConst.ZERO,
          '',
          '',
          PsConst.ZERO,
          userProvider!.isClickPickUpButton == true
              ? PsConst.ONE
              : PsConst.ZERO,
          deliveryPickUpDate!,
          deliveryPickUpTime!,
          userProvider!.isClickPickUpButton
              ? '0.0'
              : basketProvider!.checkoutCalculationHelper.shippingCost
                  .toString(),
          userProvider!.user.data!.area!.areaName!,
          memoController.text,
          valueHolder,
          firstTimeOrderController.text,
          selectedTimesController.text,
          '1',
        );
        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider!.deleteWholeBasketList();
          Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccessSchedule,
              arguments: ScheduleCheckoutStatusIntentHolder(
                scheduleHeader: _apiStatus.data![0],
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

  dynamic payCashPickUp() async {
    if (await Utils.checkInternetConnectivity()) {
      if (userProvider?.user != null && userProvider?.user.data != null) {
        await PsProgressDialog.showDialog(context);

        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider!.postTransactionSubmit(
                userProvider!.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider!.checkoutCalculationHelper.tax.toString(),
                basketProvider!.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider!.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                '0.0',
                basketTotalPrice.toString(),
                basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                    .toString(),
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                '',
                '',
                PsConst.ONE,
                userProvider!.isClickPickUpButton == true
                    ? PsConst.ONE
                    : PsConst.ZERO,
                deliveryPickUpDate!,
                deliveryPickUpTime!,
                '0.0',
                userProvider!.user.data!.area!.areaName!,
                memoController.text,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider!.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccess,
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

  dynamic payCash() async {
    if (await Utils.checkInternetConnectivity()) {
      if (userProvider?.user != null && userProvider?.user.data != null) {
        await PsProgressDialog.showDialog(context);

        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);

        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider!.postTransactionSubmit(
                userProvider!.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider!.checkoutCalculationHelper.tax.toString(),
                basketProvider!.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider!.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                basketProvider!.checkoutCalculationHelper.shippingCost
                    .toString(),
                basketProvider!.checkoutCalculationHelper.totalPrice.toString(),
                basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                    .toString(),
                PsConst.ONE,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                '',
                '',
                PsConst.ZERO,
                userProvider!.isClickPickUpButton == true
                    ? PsConst.ONE
                    : PsConst.ZERO,
                deliveryPickUpDate!,
                deliveryPickUpTime!,
                basketProvider!.checkoutCalculationHelper.shippingCost
                    .toString(),
                userProvider!.user.data!.area!.areaName!,
                memoController.text,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider!.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccess,
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

  dynamic payPayStack() async {
    await Navigator.pushNamed(context, RoutePaths.paystack,
        arguments: PayStackInterntHolder(
          basketList: widget.basketList,
          couponDiscount: couponDiscountProvider?.couponDiscount ?? '0.0',
          transactionSubmitProvider: transactionSubmitProvider!,
          userLoginProvider: userProvider!,
          basketProvider: basketProvider!,
          psValueHolder: valueHolder,
          memoText: memoController.text,
          paystackKey: shopInfoProvider!.shopInfo.data!.paystackKey!,
          publishKey: valueHolder.publishKey!,
          isClickPickUpButton: userProvider!.isClickPickUpButton,
          deliveryPickUpDate: deliveryPickUpDate!,
          deliveryPickUpTime: deliveryPickUpTime!,
          basketTotalPrice: basketTotalPrice!,
        ));
  }

  dynamic payStripe() async {
    await Navigator.pushNamed(context, RoutePaths.creditCard,
        arguments: CreditCardIntentHolder(
            basketList: widget.basketList,
            couponDiscount: couponDiscountProvider?.couponDiscount ?? '0.0',
            transactionSubmitProvider: transactionSubmitProvider!,
            userProvider: userProvider!,
            basketProvider: basketProvider!,
            psValueHolder: valueHolder,
            memoText: memoController.text,
            publishKey: valueHolder.publishKey!,
            isClickPickUpButton: userProvider!.isClickPickUpButton,
            deliveryPickUpDate: deliveryPickUpDate!,
            deliveryPickUpTime: deliveryPickUpTime!));
  }

  Future<void> _handleWavePaymentSuccess(String transactionId) async {
    // Do something when payment succeeds
    print('success');

    print(transactionId);

    await PsProgressDialog.showDialog(context);
    if (userProvider?.user != null && userProvider?.user.data != null) {
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider!.postTransactionSubmit(
              userProvider!.user.data!,
              widget.basketList,
              '',
              couponDiscountProvider!.couponDiscount.toString(),
              basketProvider!.checkoutCalculationHelper.tax.toString(),
              basketProvider!.checkoutCalculationHelper.totalDiscount
                  .toString(),
              basketProvider!.checkoutCalculationHelper.subTotalPrice
                  .toString(),
              basketProvider!.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider!.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO, // Cod
              PsConst.ZERO, // Paypal
              PsConst.ZERO, // Stripe
              PsConst.ZERO, // Bank
              PsConst.ZERO, // Razor
              PsConst.ONE, // Wave
              PsConst.ZERO, // Paystack
              PsConst.ZERO,
              '', // Razor Id
              transactionId, // Wave Id
              PsConst.ZERO, // Pickup Or Not
              userProvider!.isClickPickUpButton == true
                  ? PsConst.ONE
                  : PsConst.ZERO,
              deliveryPickUpDate!,
              deliveryPickUpTime!,
              basketProvider!.checkoutCalculationHelper.shippingCost.toString(),
              userProvider!.user.data!.area!.areaName!,
              memoController.text,
              valueHolder);

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider!.deleteWholeBasketList();

          // Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccess,
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
  }

  dynamic payFlutterWave() async {
    if (valueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider!.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    } else if (valueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider!.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    }

    final String amount = Utils.getPriceTwoDecimal(
        userProvider!.isClickPickUpButton
            ? basketTotalPrice.toString()
            : basketProvider!.checkoutCalculationHelper.totalPrice.toString());

    // final FlutterwaveStyle style = FlutterwaveStyle(
    //     appBarText: Utils.getString(context, 'checkout3__wave'),
    //     buttonColor: PsColors.mainColor,
    //     appBarIcon: Icon(
    //       Icons.arrow_back,
    //       color: PsColors.mainColorWithWhite,
    //     ),
    //     mainBackgroundColor: PsColors.backgroundColor,
    //     buttonText: Utils.getString(context, 'flutter_wave_make_payment'),
    //     buttonTextStyle: TextStyle(
    //       color: PsColors.white,
    //       fontWeight: FontWeight.bold,
    //       fontSize: 18,
    //     ),
    //     appBarTitleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
    //           color: PsColors.mainColorWithWhite,
    //           fontWeight: FontWeight.bold,
    //         ),
    //     appBarColor: PsColors.baseColor,
    //     dialogCancelTextStyle: const TextStyle(
    //       color: Colors.redAccent,
    //       fontSize: 18,
    //     ),
    //     dialogContinueTextStyle: const TextStyle(
    //       color: Colors.blue,
    //       fontSize: 18,
    //     ));

    final Customer customer = Customer(
        name: userProvider!.user.data!.userName!,
        phoneNumber: userProvider!.user.data!.userPhone!,
        email: userProvider!.user.data!.userEmail!);

    final Flutterwave flutterwave = Flutterwave(
      context: context,
     // style: style,
      publicKey: shopInfoProvider!.shopInfo.data!.flutterWavePublishableKey!,
      currency: valueHolder.defaultFlutterWaveCurrency!,
      redirectUrl: 'https://google.com',
      txRef:
          '${DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.now())}-${valueHolder.loginUserId}',
      amount: amount,
      customer: customer,
      paymentOptions: 'ussd, card, barter, payattitude',
      customization: Customization(title: 'Flutterwave Payment'),
      isTestMode: true,
    );

    try {
      if (await Utils.checkInternetConnectivity()) {
        final ChargeResponse? response = await flutterwave.charge();
        if (response != null) {
          print(response.toJson());
          if (response.success!) {
            //  Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
            PsProgressDialog.dismissDialog();
            print(response.toJson());
            _handleWavePaymentSuccess(response.transactionId!);
          } else {
            print('Transaction not successful');
          }
        } else {
          print('Transaction Cancelled');
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
    } catch (error) {
      print(error);
    }
  }

  /*Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    print('success');

    print(response);

    await PsProgressDialog.showDialog(context);
    if (userProvider?.user != null && userProvider?.user.data != null) {
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider!.postTransactionSubmit(
              userProvider!.user.data!,
              widget.basketList,
              '',
              couponDiscountProvider!.couponDiscount.toString(),
              basketProvider!.checkoutCalculationHelper.tax.toString(),
              basketProvider!.checkoutCalculationHelper.totalDiscount
                  .toString(),
              basketProvider!.checkoutCalculationHelper.subTotalPrice
                  .toString(),
              userProvider!.isClickPickUpButton
                  ? '0.0'
                  : basketProvider!.checkoutCalculationHelper.shippingCost
                      .toString(),
              userProvider!.isClickPickUpButton
                  ? basketTotalPrice.toString()
                  : basketProvider!.checkoutCalculationHelper.totalPrice
                      .toString(),
              basketProvider!.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              PsConst.ZERO,
              PsConst.ZERO,
              response.paymentId.toString(),
              '',
              PsConst.ONE,
              userProvider!.isClickPickUpButton == true
                  ? PsConst.ONE
                  : PsConst.ZERO,
              deliveryPickUpDate!,
              deliveryPickUpTime!,
              userProvider!.isClickPickUpButton
                  ? '0.0'
                  : basketProvider!.checkoutCalculationHelper.shippingCost
                      .toString(),
              userProvider!.user.data!.area!.areaName!,
              memoController.text,
              valueHolder);

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider!.deleteWholeBasketList();

          // Navigator.pop(context, true);
          await Navigator.pushReplacementNamed(
              context, RoutePaths.checkoutSuccess,
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
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print('error');
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'checkout3__payment_fail'),
          );
        });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print('external wallet');
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message:
                Utils.getString(context, 'checkout3__payment_not_supported'),
          );
        });
  }*/

  dynamic payRazorNow() async {
    if (valueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider!.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    } else if (valueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider!.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider!.couponDiscount,
          psValueHolder: valueHolder,
          shippingPriceStringFormatting: userProvider!.user.data!.area!.price!);
    }

    // Start Razor Payment
    /*final Razorpay _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);*/

    if (valueHolder.isRazorSupportMultiCurrency != null &&
        valueHolder.isRazorSupportMultiCurrency == PsConst.ONE) {
      isRazorSupportMultiCurrency = true;
    } else {
      isRazorSupportMultiCurrency = false;
    }

    final Map<String, Object> options = <String, Object>{
      'key': shopInfoProvider!.shopInfo.data!.razorKey!,
      'amount': (double.parse(Utils.getPriceTwoDecimal(
                  userProvider!.isClickPickUpButton
                      ? basketTotalPrice.toString()
                      : basketProvider!.checkoutCalculationHelper.totalPrice
                          .toString())) *
              100)
          .round(),
      'name': userProvider!.user.data!.userName!,
      'currency': isRazorSupportMultiCurrency
          ? shopInfoProvider!.shopInfo.data!.currencyShortForm!
          : valueHolder.defaultRazorCurrency!,
      'description': '',
      'prefill': <String, String>{
        'contact': userProvider!.user.data!.userPhone!,
        'email': userProvider!.user.data!.userEmail!
      }
    };

    if (await Utils.checkInternetConnectivity()) {
      //_razorpay.open(options);
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

  void payWithWeeklyScheduleCash() {
    Navigator.pop(context);
    payCashOnDeliveryScheduleOrder();
  }

  void payWithCash() {
    Navigator.pop(context);
    payCash();
  }

  void payWithCashPickUp() {
    Navigator.pop(context);
    payCashPickUp();
  }

  Future<void> payWithPaypal() async {
    if (PsConfig.isDemo) {
      await callDemoWarningDialog(context);
    }
    Navigator.pop(context);
    payNow();
  }

  void payWithBank() {
    Navigator.pop(context);
    bankNow();
  }

  void payWithPayStack() {
    Navigator.pop(context);
    payPayStack();
  }

  Future<void> payWithStripe() async {
    if (PsConfig.isDemo) {
      await callDemoWarningDialog(context);
    }
    Navigator.pop(context);
    payStripe();
  }

  Future<void> payWithRazor() async {
    if (PsConfig.isDemo) {
      await callDemoWarningDialog(context);
    }
    Navigator.pop(context);
    payRazorNow();
  }

  Future<void> payWithFlutterWave() async {
    if (PsConfig.isDemo) {
      await callDemoWarningDialog(context);
    }
    Navigator.pop(context);
    payFlutterWave();
  }

  dynamic openAndCloseTime(ShopInfoProvider shopInfoProvider) {
    // Open Time
    final String? mondayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.mondayOpenHour!;
    final String? tuesdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.tuesdayOpenHour!;
    final String? wednesdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.wednesdayOpenHour!;
    final String? thursdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.thursdayOpenHour!;
    final String? fridayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.fridayOpenHour!;
    final String? saturdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.saturdayOpenHour!;
    final String? sundayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.sundayOpenHour!;

    if (mondayOpenDateAndTime != null && mondayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          mondayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          monOpenHour = int.parse(openHourArray[0]);
          print(monOpenHour);
          monOpenMin = int.parse(openHourArray[1]);
          print(monOpenMin);
        }
      }
    }
    if (tuesdayOpenDateAndTime != null && tuesdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          tuesdayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          tuesOpenHour = int.parse(openHourArray[0]);
          tuesOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (wednesdayOpenDateAndTime != null && wednesdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          wednesdayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          wedOpenHour = int.parse(openHourArray[0]);
          wedOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (thursdayOpenDateAndTime != null && thursdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          thursdayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          thursOpenHour = int.parse(openHourArray[0]);
          thursOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (fridayOpenDateAndTime != null && fridayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          fridayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          friOpenHour = int.parse(openHourArray[0]);
          friOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (saturdayOpenDateAndTime != null && saturdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          saturdayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          satOpenHour = int.parse(openHourArray[0]);
          satOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (sundayOpenDateAndTime != null && sundayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          sundayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          sunOpenHour = int.parse(openHourArray[0]);
          sunOpenMin = int.parse(openHourArray[1]);
        }
      }
    }

    // Close Time
    final String? mondayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.mondayCloseHour;
    final String? tuesdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.tuesdayCloseHour;
    final String? wednesdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.wednesdayCloseHour;
    final String? thursdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.thursdayCloseHour;
    final String? fridayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.fridayCloseHour;
    final String? saturdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.saturdayCloseHour;
    final String? sundayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules?.sundayCloseHour;

    if (mondayCloseDateAndTime != null && mondayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          mondayCloseDateAndTime.split(' ');
      print(closeDateAndTimeArray);

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          monCloseHour = int.parse(closeHourArray[0]);
          print(monCloseHour);
          monCloseMin = int.parse(closeHourArray[1]);
          print(monCloseMin);
        }
      }
    }
    if (tuesdayCloseDateAndTime != null && tuesdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          tuesdayCloseDateAndTime.split(' ');
      print(closeDateAndTimeArray);

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          tuesCloseHour = int.parse(closeHourArray[0]);
          tuesCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (wednesdayCloseDateAndTime != null && wednesdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          wednesdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          wedCloseHour = int.parse(closeHourArray[0]);
          wedCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (thursdayCloseDateAndTime != null && thursdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          thursdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          thursCloseHour = int.parse(closeHourArray[0]);
          thursCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (fridayCloseDateAndTime != null && fridayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          fridayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          friCloseHour = int.parse(closeHourArray[0]);
          friCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (saturdayCloseDateAndTime != null && saturdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          saturdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          satCloseHour = int.parse(closeHourArray[0]);
          satCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (sundayCloseDateAndTime != null && sundayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          sundayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          sunCloseHour = int.parse(closeHourArray[0]);
          sunCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }

    final String? orderDateAndTime = orderTimeTextEditingController.text;

    //Split Date and Time
    if (orderDateAndTime != null &&
        orderDateAndTime != '' &&
        orderDateAndTime.contains(' ')) {
      final List<String>? orderDateAndTimeArray = orderDateAndTime.split(' ');
      final String orderDays = orderDateAndTimeArray![0];
      final List<String> ordererDayArray = orderDays.split(',');
      days = ordererDayArray[0];

      if (orderDateAndTimeArray.length > 4 &&
          orderDateAndTimeArray[4] != '' &&
          orderDateAndTimeArray[4].contains(':')) {
        final List<String>? orderTimeArray =
            orderDateAndTimeArray[4].split(':');

        if (orderTimeArray != null &&
            orderTimeArray.isNotEmpty &&
            orderTimeArray[0] != '' &&
            orderTimeArray[1] != '') {
          hour = int.parse(orderTimeArray[0]);
          minute = int.parse(orderTimeArray[1]);
          print(minute);
          print('\u001b[33m Hour $hour \u001b[0m');
          print('\u001b[33m Minute $minute \u001b[0m');
          print('\u001b[33m Days $days \u001b[0m');
        }
      }
    }
    if (days == 'Mon') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules?.isMondayOpen ==
          PsConst.ONE) {
        if (((hour! > monOpenHour!) ||
                (hour == monOpenHour && minute! >= monOpenMin!)) &&
            ((hour! < monCloseHour!) ||
                (hour == monCloseHour && minute! <= monCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Tue') {
      if (shopInfoProvider.shopInfo.data?.shopSchedules!.isTuesdayOpen ==
          PsConst.ONE) {
        if (((hour! > tuesOpenHour!) ||
                (hour == tuesOpenHour && minute! >= tuesOpenMin!)) &&
            ((hour! < tuesCloseHour!) ||
                (hour == tuesCloseHour && minute! <= tuesCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Wed') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules?.isWednesdayOpen ==
          PsConst.ONE) {
        if (((hour! > wedOpenHour!) ||
                (hour == wedOpenHour && minute! >= wedOpenMin!)) &&
            ((hour! < wedCloseHour!) ||
                (hour == wedCloseHour && minute! <= wedCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Thu') {
      if (shopInfoProvider.shopInfo.data?.shopSchedules!.isThursdayOpen ==
          PsConst.ONE) {
        if (((hour! > thursOpenHour!) ||
                (hour == thursOpenHour && minute! >= thursOpenMin!)) &&
            ((hour! < thursCloseHour!) ||
                (hour == thursCloseHour && minute! <= thursCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Fri') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules?.isFridayOpen ==
          PsConst.ONE) {
        if (((hour! > friOpenHour!) ||
                (hour == friOpenHour && minute! >= friOpenMin!)) &&
            ((hour! < friCloseHour!) ||
                (hour == friCloseHour && minute! <= friCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Sat') {
      if (shopInfoProvider.shopInfo.data?.shopSchedules!.isSaturdayOpen ==
          PsConst.ONE) {
        if (((hour! > satOpenHour!) ||
                (hour == satOpenHour && minute! >= satOpenMin!)) &&
            ((hour! < satCloseHour!) ||
                (hour == satCloseHour && minute! <= satCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Sun') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules?.isSundayOpen ==
          PsConst.ONE) {
        if (((hour! > satOpenHour!) ||
                (hour == satOpenHour && minute! >= satOpenMin!)) &&
            ((hour! < satCloseHour!) ||
                (hour == satCloseHour && minute! <= satCloseMin!))) {
        } else {
          hasErrorInShopTime = true;
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        hasErrorInShopTime = true;
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    }
  }

  dynamic validate() async {
    if (userProvider!.isClickOneTimeButton &&
        dateTimeUpdatedFromOrderTime == false) {
      openAndCloseTime(shopInfoProvider!);
    }

    if (shopInfoProvider!.shopInfo.data!.isArea == PsConst.ZERO &&
        costPerChargesController.text == '0' &&
        userProvider!.isClickDeliveryButton) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__order'),
            );
          });
    } else if (userEmailController.text.isEmpty) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'warning_dialog__input_email'),
            );
          });
    } else if (!userProvider!.hasLatLng(valueHolder) &&
        userAddressController.text == '' &&
        userProvider!.isClickDeliveryButton) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message:
                  Utils.getString(context, 'warning_dialog__no_pin_location'),
            );
          });
    } else if (userAddressController.text.isEmpty &&
        userProvider!.isClickDeliveryButton) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'warning_dialog__address'),
            );
          });
    } else if (userPhoneController.text.isEmpty) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'warning_dialog__input_phone'),
            );
          });
    } else if (shopInfoProvider!.shopInfo.data!.isArea == PsConst.ONE &&
        (userProvider?.selectedArea == null ||
            userProvider?.selectedArea?.id == null ||
            userProvider?.selectedArea?.id == '') &&
        userProvider!.isClickDeliveryButton) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'warning_dialog__select_area'),
            );
          });
    } else if (!await checkIsDataChange(userProvider!)) {
        isApiSuccess = await callUpdateUserProfile(userProvider!, provider!);
        if (isApiSuccess) {
          callPayment();
        }
    } else if (!hasErrorInShopTime) {
      callPayment();
    }
  }

  dynamic checkIsDataChange(UserProvider userProvider) async {
    if (userProvider.user.data!.userEmail == userEmailController.text &&
        userProvider.user.data!.userPhone == userPhoneController.text &&
        userProvider.user.data!.address == userAddressController.text &&
        userProvider.user.data!.area!.areaName == userProvider.selectedArea!.areaName &&
        userProvider.user.data!.userLat == userProvider.originalUserLat &&
        userProvider.user.data!.userLng == userProvider.originalUserLng) {
      return true;
    } else {
      return false;
    }
  }

  dynamic callUpdateUserProfile(UserProvider userProvider, DeliveryCostProvider provider) async {
    bool isSuccess = false;

    if (userProvider.isClickPickUpButton && userProvider.selectedArea != null) {
      userProvider.selectedArea!.id = '';
      userProvider.selectedArea!.price = '0.0';
      userProvider.selectedArea!.areaName = '';
    }

    if (userProvider.isClickPickUpButton && provider.deliveryCost.data != null) {
      provider.deliveryCost.data!.totalCost = '0.0';
    }

    if (await Utils.checkInternetConnectivity()) {
      final ProfileUpdateParameterHolder profileUpdateParameterHolder =
          ProfileUpdateParameterHolder(
        userId: userProvider.psValueHolder.loginUserId ?? '',
        userName: userProvider.user.data!.userName!,
        userEmail: userEmailController.text.trim(),
        userPhone: userPhoneController.text,
        userAddress: userAddressController.text,
        userAboutMe: userProvider.user.data!.userAboutMe!,
        userAreaId: userProvider.selectedArea!.id!,
        userLat: userProvider.user.data!.userLat!,
        userLng: userProvider.user.data!.userLng!,
            userPostcode: userProvider.user.data!.userPostcode!,
            userCity: userProvider.user.data!.userCity!,
            userCountry: userProvider.user.data!.userCountry!,


      );
      await PsProgressDialog.showDialog(context);
      final PsResource<User> _apiStatus = await userProvider
          .postProfileUpdate(profileUpdateParameterHolder.toMap());
      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();
        isSuccess = true;

      } else {
        PsProgressDialog.dismissDialog();

        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
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

    return isSuccess;
  }


  void callPayment() {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialogView(
              description:
                  Utils.getString(context, 'checkout_container__confirm_order'),
              leftButtonText:
                  Utils.getString(context, 'home__logout_dialog_cancel_button'),
              rightButtonText:
                  Utils.getString(context, 'home__logout_dialog_ok_button'),
              onAgreeTap: () async {
                if (paymentController.text ==
                    Utils.getString(context, 'checkout3__paypal')) {
                  payWithPaypal();
                } else if (paymentController.text ==
                    Utils.getString(context, 'checkout3__paystack')) {
                  payWithPayStack();
                } else if (paymentController.text ==
                    Utils.getString(context, 'checkout3__stripe')) {
                  payWithStripe();
                } else if (paymentController.text ==
                    Utils.getString(context, 'checkout3__razor')) {
                  payWithRazor();
                } else if (paymentController.text ==
                    Utils.getString(context, 'checkout3__wave')) {
                  payWithFlutterWave();
                } else if (paymentController.text ==
                    Utils.getString(context, 'checkout3__bank')) {
                  payWithBank();
                } else if (paymentController.text ==
                        Utils.getString(context, 'checkout3__pick_up') &&
                    userProvider!.isCash) {
                  payWithCashPickUp();
                } else if (paymentController.text ==
                        Utils.getString(context, 'checkout3__cod') &&
                    userProvider!.isCash) {
                  payWithCash();
                }
                // else if (paymentController.text ==
                //         Utils.getString(context, 'checkout3__cod') &&
                //     userProvider!.isClickWeeklyButton) {
                //   payWithWeeklyScheduleCash();
                // }
              });
        });
  }

  void updateCheckBox() {
    if (isCheckBoxSelect) {
      isCheckBoxSelect = false;
    } else {
      isCheckBoxSelect = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    tokenRepository = Provider.of<TokenRepository>(context);
    deliveryCostRepository = Provider.of<DeliveryCostRepository>(context);

    calculateBasketTotalPrice();

    if (bindDataFirstTime) {
      paymentController.text = Utils.getString(context, 'checkout3__cod');
      final DateTime dateTime = DateTime.now()
          .add(Duration(minutes: int.parse(valueHolder.defaultOrderTime!)));
      updatDateAndTime(dateTime.toString());
    }

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserProvider>(
            lazy: false,
            create: (BuildContext context) {
              userProvider = UserProvider(
                  repo: userRepository!, psValueHolder: valueHolder);
              userProvider!
                  .getUserFromDB(userProvider!.psValueHolder.loginUserId!);
              return userProvider!;
            }),
        ChangeNotifierProvider<CouponDiscountProvider>(
            lazy: false,
            create: (BuildContext context) {
              couponDiscountProvider = CouponDiscountProvider(
                  repo: couponDiscountRepo!, psValueHolder: valueHolder);

              return couponDiscountProvider!;
            }),
        ChangeNotifierProvider<BasketProvider>(
            lazy: false,
            create: (BuildContext context) {
              basketProvider = BasketProvider(
                  repo: basketRepository!, psValueHolder: valueHolder);
              basketProvider!.loadBasketList();
              return basketProvider!;
            }),
        ChangeNotifierProvider<ShopInfoProvider>(
            lazy: false,
            create: (BuildContext context) {
              shopInfoProvider = ShopInfoProvider(
                  repo: shopInfoRepository!,
                  psValueHolder: valueHolder,
                  ownerCode: 'CheckoutContainerView');
              shopInfoProvider!.loadShopInfo();
              return shopInfoProvider!;
            }),
        // ChangeNotifierProvider<ScheduleHeaderProvider>(
        //     lazy: false,
        //     create: (BuildContext context) {
        //       scheduleHeaderProvider = ScheduleHeaderProvider(
        //           repo: scheduleHeaderRepository!, psValueHolder: valueHolder);
        //       return scheduleHeaderProvider!;
        //     }),
        ChangeNotifierProvider<TransactionHeaderProvider>(
            lazy: false,
            create: (BuildContext context) {
              transactionSubmitProvider = TransactionHeaderProvider(
                  repo: transactionHeaderRepo!, psValueHolder: valueHolder);

              return transactionSubmitProvider!;
            }),
        ChangeNotifierProvider<TokenProvider>(
            lazy: false,
            create: (BuildContext context) {
              tokenProvider = TokenProvider(
                  repo: tokenRepository!, psValueHolder: valueHolder);
              return tokenProvider!;
            }),
        ChangeNotifierProvider<DeliveryCostProvider>(
            lazy: false,
            create: (BuildContext context) {
              provider = DeliveryCostProvider(
                  repo: deliveryCostRepository, psValueHolder: valueHolder);
              return provider!;
            }),
      ],
      child: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider _, Widget? child) {
        if (userProvider?.user != null && userProvider?.user.data != null) {
          if (bindDataFirstTime) {
            userEmailController.text = userProvider!.user.data!.userEmail!;
            userPhoneController.text = userProvider!.user.data!.userPhone!;
            userAddressController.text = userProvider!.user.data!.address!;
            firstTimeOrderController.text =
                Utils.getString(context, 'checkout1__asap') +
                    ' (' +
                    valueHolder.defaultOrderTime! +
                    'mins)';
            secondTimeOrderController.text =
                Utils.getString(context, 'checkout_one_page__one_time_order');
            deliveryCostCalculate();
            userProvider!.selectedArea = userProvider!.user.data!.area!;
            bindDataFirstTime = false;
          }
          if (widget.shopInfoProvider.shopInfo.data?.isArea != null ||
              widget.shopInfoProvider.shopInfo.data!.isArea!.isNotEmpty) {
            if (widget.shopInfoProvider.shopInfo.data?.isArea == PsConst.ONE) {
              basketProvider!.checkoutCalculationHelper.calculate(
                  basketList: basketProvider!.basketList.data!,
                  couponDiscountString: couponController.text,
                  psValueHolder: valueHolder,
                  shippingPriceStringFormatting:
                      userProvider!.selectedArea!.price!);
            } else if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                    PsConst.ZERO &&
                widget.shopInfoProvider.shopInfo.data?.deliFeeByDistance ==
                    PsConst.ONE) {
              basketProvider!.checkoutCalculationHelper.calculate(
                  basketList: basketProvider!.basketList.data!,
                  couponDiscountString: couponController.text,
                  psValueHolder: valueHolder,
                  shippingPriceStringFormatting: shippingCostController.text);
            } else if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                    PsConst.ZERO &&
                widget.shopInfoProvider.shopInfo.data?.fixedDelivery ==
                    PsConst.ONE) {
              basketProvider!.checkoutCalculationHelper.calculate(
                  basketList: basketProvider!.basketList.data!,
                  couponDiscountString: couponController.text,
                  psValueHolder: valueHolder,
                  shippingPriceStringFormatting: shippingCostController.text);
            } else if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                    PsConst.ZERO &&
                widget.shopInfoProvider.shopInfo.data?.freeDelivery ==
                    PsConst.ONE) {
              basketProvider!.checkoutCalculationHelper.calculate(
                  basketList: basketProvider!.basketList.data!,
                  couponDiscountString: couponController.text,
                  psValueHolder: valueHolder,
                  shippingPriceStringFormatting: '0.0');
            }
          }

          return SingleChildScrollView(
            child: Container(
              color: PsColors.coreBackgroundColor,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _BillingWidget(
                        user: userProvider!.user.data!,
                        userEmailController: userEmailController,
                        userPhoneController: userPhoneController),
                    const SizedBox(height: PsDimens.space2),
                    _OrderTimeWidget(
                      userProvider: userProvider!,
                      shopInfoProvider: shopInfoProvider!,
                      firstTimeOrderController: firstTimeOrderController,
                      secondTimeOrderController: secondTimeOrderController,
                      selectedTimesController: selectedTimesController,
                      updateDateTime: updatDateAndTime,
                      onTap: () {
                        setState(() {
                          if (userProvider!.isClickWeeklyButton) {
                            userProvider!.isCash = true;
                          }
                          dateTimeUpdatedFromOrderTime = true;
                          hasErrorInShopTime = false;
                        });
                      },
                    ),
                    const SizedBox(height: PsDimens.space2),
                    _OrderLocationWidget(
                      user: userProvider!.user.data!,
                      basketList: widget.basketList,
                      deliveryCostProvider: provider!,
                      userProvider: userProvider!,
                      shopInfoProvider: shopInfoProvider!,
                      userAddressController: userAddressController,
                      onTap: () {
                        setState(() {
                          if (userProvider!.isClickPickUpButton) {
                            paymentController.text =
                                Utils.getString(context, 'checkout3__pick_up');
                            userProvider!.isCash = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: PsDimens.space2),
                    _OrderPaymentWidget(
                      userProvider: userProvider!,
                      paymentController: paymentController,
                    ),
                    PsTextFieldWidget(
                        titleText: Utils.getString(context, 'checkout3__memo'),
                        height: PsDimens.space80,
                        textAboutMe: true,
                        hintText: Utils.getString(context, 'checkout3__memo'),
                        keyboardType: TextInputType.multiline,
                        textEditingController: memoController),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: PsTextFieldWidget(
                          hintText:
                              Utils.getString(context, 'checkout__coupon_code'),
                          textEditingController: couponController,
                          showTitle: false,
                        )),
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: PsDimens.space8),
                          child: PSButtonWidget(
                            titleText: Utils.getString(
                                context, 'checkout__claim_button_name'),
                            onPressed: () async {
                              if (couponController.text.isNotEmpty) {
                                final CouponDiscountParameterHolder
                                    couponDiscountParameterHolder =
                                    CouponDiscountParameterHolder(
                                  couponCode: couponController.text,
                                );

                                final PsResource<CouponDiscount> _apiStatus =
                                    await couponDiscountProvider!
                                        .postCouponDiscount(
                                            couponDiscountParameterHolder
                                                .toMap());

                                if (_apiStatus.data != null &&
                                    couponController.text ==
                                        _apiStatus.data!.couponCode) {
                                  final BasketProvider basketProvider =
                                      Provider.of<BasketProvider>(context,
                                          listen: false);

                                  if (shopInfoProvider!.shopInfo.data!.isArea ==
                                      PsConst.ONE) {
                                    basketProvider.checkoutCalculationHelper
                                        .calculate(
                                            basketList: widget.basketList,
                                            couponDiscountString:
                                                _apiStatus.data!.couponAmount!,
                                            psValueHolder: valueHolder,
                                            shippingPriceStringFormatting:
                                                userProvider!
                                                    .selectedArea!.price!);
                                  } else if (shopInfoProvider!
                                              .shopInfo.data?.isArea ==
                                          PsConst.ZERO &&
                                      shopInfoProvider?.shopInfo.data
                                              ?.deliFeeByDistance ==
                                          PsConst.ONE) {
                                    basketProvider.checkoutCalculationHelper
                                        .calculate(
                                            basketList: widget.basketList,
                                            couponDiscountString:
                                                _apiStatus.data!.couponAmount!,
                                            psValueHolder: valueHolder,
                                            shippingPriceStringFormatting:
                                                provider!.deliveryCost.data!
                                                    .totalCost!);
                                  } else if (shopInfoProvider
                                              ?.shopInfo.data?.isArea ==
                                          PsConst.ZERO &&
                                      shopInfoProvider!
                                              .shopInfo.data?.fixedDelivery ==
                                          PsConst.ONE) {
                                    basketProvider.checkoutCalculationHelper
                                        .calculate(
                                            basketList: widget.basketList,
                                            couponDiscountString:
                                                _apiStatus.data!.couponAmount!,
                                            psValueHolder: valueHolder,
                                            shippingPriceStringFormatting:
                                                provider!.deliveryCost.data!
                                                    .totalCost!);
                                  } else if (shopInfoProvider
                                              ?.shopInfo.data?.isArea ==
                                          PsConst.ZERO &&
                                      shopInfoProvider
                                              ?.shopInfo.data?.freeDelivery ==
                                          PsConst.ONE) {
                                    basketProvider.checkoutCalculationHelper
                                        .calculate(
                                            basketList: widget.basketList,
                                            couponDiscountString:
                                                _apiStatus.data!.couponAmount!,
                                            psValueHolder: valueHolder,
                                            shippingPriceStringFormatting:
                                                '0.0');
                                  }

                                  showDialog<dynamic>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SuccessDialog(
                                          message: Utils.getString(context,
                                              'checkout__couponcode_add_dialog_message'),
                                        );
                                      });

                                  couponController.clear();
                                  print(_apiStatus.data!.couponAmount);
                                  setState(() {
                                    couponDiscountProvider!.couponDiscount =
                                        _apiStatus.data!.couponAmount!;
                                  });
                                } else {
                                  showDialog<dynamic>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ErrorDialog(
                                          message: _apiStatus.message,
                                        );
                                      });
                                }
                              } else {
                                showDialog<dynamic>(
                                    context: context,
                                    barrierColor: PsColors.transparent,
                                    builder: (BuildContext context) {
                                      return WarningDialog(
                                        message: Utils.getString(context,
                                            'checkout__warning_dialog_message'),
                                        onPressed: () {},
                                      );
                                    });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          activeColor: PsColors.mainColor,
                          value: isCheckBoxSelect,
                          onChanged: (bool? value) {
                            setState(() {
                              updateCheckBox();
                            });
                          },
                        ),
                        Expanded(
                          child: InkWell(
                            child: Text(
                              Utils.getString(
                                  context, 'checkout3__agree_policy'),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                            ),
                            onTap: () {
                              setState(() {
                                updateCheckBox();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PsDimens.space24),
                    _CheckoutButtonWidget(
                      basketList: widget.basketList,
                      isCheckBoxSelect: isCheckBoxSelect,
                      onTap: validate,
                      currencySymbol: currencySymbol!,
                      basketTotalPrice: basketTotalPrice!,
                      isPickup: userProvider!.isClickPickUpButton,
                      totalPrice:
                          basketProvider!.checkoutCalculationHelper.totalPrice,
                    )
                  ]),
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }
}

class _BillingWidget extends StatefulWidget {
  const _BillingWidget(
      {Key? key,
      required this.user,
      required this.userEmailController,
      required this.userPhoneController})
      : super(key: key);

  final User user;
  final TextEditingController userEmailController;
  final TextEditingController userPhoneController;

  @override
  __BillingWidgetViewState createState() => __BillingWidgetViewState();
}

class __BillingWidgetViewState extends State<_BillingWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dynamic result = await Navigator.pushNamed(
            context, RoutePaths.billingTo,
            arguments: BillingToIntentHolder(
                userEmail: widget.userEmailController.text,
                userPhoneNo: widget.userPhoneController.text));
        if (result != null && result is BillingToCallBackHolder) {
          setState(() {
            widget.userEmailController.text = result.userEmail;
            widget.userPhoneController.text = result.userPhoneNo;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Ink(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Utils.getString(context, 'checkout_one_page__billing_to'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: PsDimens.space8,
                  ),
                  Text(
                    widget.userEmailController.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: PsDimens.space4,
                  ),
                  Text(
                    widget.userPhoneController.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              Text(
                Utils.getString(context, 'checkout_one_page__edit'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: PsColors.mainColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTimeWidget extends StatefulWidget {
  const _OrderTimeWidget(
      {Key? key,
      required this.userProvider,
      required this.shopInfoProvider,
      required this.firstTimeOrderController,
      required this.secondTimeOrderController,
      required this.updateDateTime,
      required this.selectedTimesController,
      required this.onTap})
      : super(key: key);

  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  final TextEditingController firstTimeOrderController;
  final TextEditingController secondTimeOrderController;
  final Function updateDateTime;
  final TextEditingController selectedTimesController;
  final Function onTap;

  @override
  __OrderTimeWidgetViewState createState() => __OrderTimeWidgetViewState();
}

class __OrderTimeWidgetViewState extends State<_OrderTimeWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dynamic result = await Navigator.pushNamed(
            context, RoutePaths.orderTime,
            arguments: OrderTimeIntentHolder(
                userProvider: widget.userProvider,
                shopInfoProvider: widget.shopInfoProvider));
        if (result != null && result is OrderTimeCallBackHolder) {
          setState(() {
            widget.firstTimeOrderController.text = result.firstOrderTime;
            widget.secondTimeOrderController.text = result.secondOrderTime;
            // Will Update date time if order time is not weekly schedule order
            if (widget.userProvider.selectedRadioBtnName ==
                    PsConst.ORDER_TIME_WEEKLY_SCHEDULE &&
                !widget.userProvider.isClickWeeklyButton) {
              widget.updateDateTime(result.selectedDateTime);
            }
            // if (widget.userProvider.selectedRadioBtnName ==
            //         PsConst.ORDER_TIME_WEEKLY_SCHEDULE &&
            //     widget.userProvider.isClickWeeklyButton) {
            //   widget.selectedTimesController.text = result.selectedTimes!;
            // }
          });
          widget.onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Ink(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Utils.getString(context, 'checkout1__order_time'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: PsDimens.space8,
                  ),
                  Text(
                    widget.firstTimeOrderController.text,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: PsDimens.space4,
                  ),
                  Text(
                    widget.secondTimeOrderController.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: PsColors.mainColor),
                  ),
                ],
              ),
              Text(
                Utils.getString(context, 'checkout_one_page__edit'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: PsColors.mainColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderLocationWidget extends StatefulWidget {
  const _OrderLocationWidget({
    Key? key,
    required this.user,
    required this.basketList,
    required this.deliveryCostProvider,
    required this.userProvider,
    required this.shopInfoProvider,
    required this.userAddressController,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final List<Basket> basketList;
  final DeliveryCostProvider deliveryCostProvider;
  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  final TextEditingController userAddressController;
  final Function onTap;

  @override
  __OrderLocationWidgetState createState() => __OrderLocationWidgetState();
}

class __OrderLocationWidgetState extends State<_OrderLocationWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dynamic result = await Navigator.pushNamed(
            context, RoutePaths.orderLocation,
            arguments: DeliveryLocationIntentHolder(
                address: widget.userAddressController.text,
                basketList: widget.basketList,
                deliveryCostProvider: widget.deliveryCostProvider,
                userProvider: widget.userProvider,
                shopInfoProvider: widget.shopInfoProvider));
        if (result != null && result is OrderLocationCallBackHolder) {
          setState(() {
            widget.userAddressController.text = result.address;
            widget.userProvider.selectedArea = result.shippingArea;
          });
        }
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Ink(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Utils.getString(
                        context, 'checkout_one_page__location_title'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: PsDimens.space8,
                  ),
                  if (widget.userProvider.isClickPickUpButton)
                    const SizedBox()
                  else
                    Text(
                      Utils.getString(
                          context, 'checkout_one_page__delivery_to'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  const SizedBox(
                    height: PsDimens.space4,
                  ),
                  Text(
                    widget.userProvider.isClickPickUpButton
                        ? Utils.getString(context, 'checkout1__pick_up')
                        : widget.userAddressController.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              Text(
                Utils.getString(context, 'checkout_one_page__edit'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: PsColors.mainColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderPaymentWidget extends StatefulWidget {
  const _OrderPaymentWidget({
    Key? key,
    required this.userProvider,
    required this.paymentController,
  }) : super(key: key);

  final UserProvider userProvider;
  final TextEditingController paymentController;

  @override
  State<_OrderPaymentWidget> createState() => _OrderPaymentWidgetState();
}

class _OrderPaymentWidgetState extends State<_OrderPaymentWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.userProvider.isClickWeeklyButton &&
        widget.userProvider.isClickPickUpButton) {
      setState(() {
        widget.paymentController.text =
            Utils.getString(context, 'checkout3__pick_up');
        widget.userProvider.isCash = true;
      });
    } else if (widget.userProvider.isClickWeeklyButton &&
        widget.userProvider.isClickDeliveryButton) {
      setState(() {
        widget.paymentController.text =
            Utils.getString(context, 'checkout3__cod');
        widget.userProvider.isCash = true;
      });
    }
    return InkWell(
      onTap: () async {
        if (widget.userProvider.isClickPickUpButton) {
          widget.userProvider.isCash = false;
        }
        final dynamic result = await Navigator.pushNamed(
          context,
          RoutePaths.paymentMethod,
          arguments: PaymentIntentHolder(userProvider: widget.userProvider),
        );
        if (result != null && result is PaymentCallBackHolder) {
          setState(() {
            widget.userProvider.isCash = result.isCash;
            if (result.isCash && widget.userProvider.isClickPickUpButton) {
              widget.paymentController.text =
                  Utils.getString(context, 'checkout3__pick_up');
            } else if (result.isCash &&
                widget.userProvider.isClickDeliveryButton) {
              widget.paymentController.text =
                  Utils.getString(context, 'checkout3__cod');
            } else {
              widget.paymentController.text =
                  Utils.getString(context, result.payment);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Ink(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Utils.getString(
                        context, 'checkout_one_page__payment_method'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: PsDimens.space8,
                  ),
                  Text(
                    widget.paymentController.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: PsDimens.space8,
                  ),
                ],
              ),
              Text(
                Utils.getString(context, 'checkout_one_page__edit'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: PsColors.mainColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutButtonWidget extends StatelessWidget {
  const _CheckoutButtonWidget({
    Key? key,
    required this.basketList,
    required this.isCheckBoxSelect,
    required this.onTap,
    required this.basketTotalPrice,
    required this.currencySymbol,
    required this.totalPrice,
    required this.isPickup,
  }) : super(key: key);

  final List<Basket> basketList;
  final bool isCheckBoxSelect;
  final Function onTap;
  final double basketTotalPrice;
  final String currencySymbol;
  final double totalPrice;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder =
        Provider.of<PsValueHolder>(context, listen: false);

    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(PsDimens.space8),
        decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          border: Border.all(color: PsColors.mainLightShadowColor),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(PsDimens.space12),
              topRight: Radius.circular(PsDimens.space12)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: PsColors.mainShadowColor,
                offset: const Offset(1.1, 1.1),
                blurRadius: 7.0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: PsDimens.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'whatsapp__view_order'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${Utils.getString(context, 'checkout__total')} ${Utils.getPriceFormat(isPickup ? basketTotalPrice.toString() : totalPrice.toString(), psValueHolder)} $currencySymbol',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: PsDimens.space8),
            Card(
              elevation: 0,
              color: PsColors.mainColor,
              shape: const BeveledRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(PsDimens.space8))),
              child: InkWell(
                onTap: () async {
                  if (isCheckBoxSelect) {
                    onTap();
                  } else {
                    showDialog<dynamic>(
                        context: context,
                        barrierColor: PsColors.transparent,
                        builder: (BuildContext context) {
                          return WarningDialog(
                            message: Utils.getString(context,
                                'checkout_container__agree_term_and_con'),
                            onPressed: () {},
                          );
                        });
                  }
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    padding: const EdgeInsets.only(
                        left: PsDimens.space4, right: PsDimens.space4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: <Color>[
                        PsColors.mainColor,
                        PsColors.mainDarkColor,
                      ]),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(PsDimens.space12)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: PsColors.mainColorWithBlack.withOpacity(0.6),
                            offset: const Offset(0, 4),
                            blurRadius: 8.0,
                            spreadRadius: 3.0),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Utils.getString(
                              context, 'basket_list__checkout_button_name'),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: PsColors.white),
                        ),
                      ],
                    )),
              ),
            ),
            const SizedBox(height: PsDimens.space8),
          ],
        ));
  }
}
