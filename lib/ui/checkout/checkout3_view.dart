import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/repository/token_repository.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:webview_flutter/webview_flutter.dart';

import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../api/ps_url.dart';
import '../../config/ps_colors.dart';
import '../../constant/ps_constants.dart';
import '../../constant/ps_dimens.dart';
import '../../constant/route_paths.dart';
import '../../provider/basket/basket_provider.dart';
import '../../provider/coupon_discount/coupon_discount_provider.dart';
import '../../provider/schedule/schedule_header_provider.dart';
import '../../provider/shop_info/shop_info_provider.dart';
import '../../provider/token/token_provider.dart';
import '../../provider/transaction/transaction_header_provider.dart';
import '../../provider/user/user_provider.dart';
import '../../utils/ps_progress_dialog.dart';
import '../../utils/utils.dart';
import '../../viewobject/basket.dart';
import '../../viewobject/common/ps_value_holder.dart';
import '../../viewobject/holder/globalTokenPost.dart';
import '../../viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import '../../viewobject/holder/intent_holder/schedule_checkout_intent_holder.dart';
import '../../viewobject/schedule_header.dart';
import '../../viewobject/transaction_header.dart';
import '../common/dialog/error_dialog.dart';

class Checkout3View extends StatefulWidget {
  const Checkout3View(
      this.basketProvider,
      this.userProvider,
      this.transactionSubmitProvider,
      this.tokenRepository,
      this.updateCheckout3ViewState,
      this.basketList,
      this.isClickDeliveryButton,
      this.isClickPickUpButton,
      this.deliveryPickUpDate,
      this.deliveryPickUpTime,
      this.isWeeklyScheduleOrder,
      this.customerMessage
  );

  final BasketProvider? basketProvider;
  final TransactionHeaderProvider? transactionSubmitProvider;
  final UserProvider? userProvider;
  final Function updateCheckout3ViewState;
  final TokenRepository tokenRepository;
  final String customerMessage;
  final List<Basket> basketList;
  final bool isClickDeliveryButton;
  final bool isClickPickUpButton;
  final String deliveryPickUpDate;
  final String deliveryPickUpTime;
  final bool isWeeklyScheduleOrder;

  @override
  _Checkout3ViewState createState() {
    final _Checkout3ViewState _state = _Checkout3ViewState();
    updateCheckout3ViewState(_state);
    return _state;
  }
}

class _Checkout3ViewState extends State<Checkout3View> {
  bool isCheckBoxSelect = false;
  bool isCashClicked = false;
  bool isGlobalClicked = false;
  bool isPickUpClicked = false;
  bool isPaypalClicked = false;
  bool isStripeClicked = false;
  bool isBankClicked = false;
  bool isRazorClicked = false;
  bool isPayStackClicked = false;
  bool isFlutterWaveClicked = false;
  bool isRazorSupportMultiCurrency = false;
  String? token;
  late GlobalTokenPost tokenPostRequest;

  late PsValueHolder valueHolder;
  CouponDiscountProvider? couponDiscountProvider;
  BasketProvider? basketProvider;


  late final  WebViewController? webController;
  HttpServer? _httpServer;
  late String deviceIp;
  @override
  void initState() {
    super.initState();

    // Get the IP address of the development machine
    _getIpAddress().then((String ipAddress) {
      // Start the HTTP server
      final shelf.Handler handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(_receiveHandler);
      deviceIp = ipAddress;
      io.serve(handler, ipAddress, 8080).then((HttpServer server) {
        setState(() {
          _httpServer = server;
        });
      });
    });
    //callCardNow(widget.basketProvider!, widget.userProvider!, widget.transactionSubmitProvider!);
  }
  Future<String> _getIpAddress() async {
    // Get the IP address of the first non-loopback network interface
    for (NetworkInterface interface in await NetworkInterface.list()) {
      for (InternetAddress addr in interface.addresses) {
        if (!addr.isLoopback) {
          return addr.address;
        }
      }
    }
    // If no non-loopback address is found, fallback to localhost
    return 'localhost';
  }
  @override
  void dispose() {
    // Close the HTTP server when the widget is disposed
    _httpServer?.close();
    super.dispose();
  }



  Future<shelf.Response> _receiveHandler(shelf.Request request) async {
    if (request.method == 'POST') {
      // Handle the incoming POST data
      final String body = await request.readAsString();
      // Decode the JSON data into a Dart object
      String hppResponse = Uri.decodeFull(body);

      // Remove the "hppResponse=" prefix from the string
      hppResponse = hppResponse.replaceFirst('hppResponse=', '');
      tokenPostRequest.jsonResponse = '{' + hppResponse + '}';
      final Map<String, dynamic>? jsonResponse = await widget.tokenRepository.getGlobalTransactionStatus(tokenPostRequest, context);
      print('''payment response from server${jsonResponse!['status']},${jsonResponse['error']}''');
      if(jsonResponse['status'] == true)//payment successfully
          {
        callCardNow(widget.basketProvider!, widget.userProvider!, widget.transactionSubmitProvider!);
      }
      //payment unsuccessfully
      else{
        /*setState(() {
                viewNo--;
              });*/
        webController!.reload();
        showDialog<dynamic>(
            context: context,
            barrierColor: PsColors.transparent,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__payment_unsuccessful'
                ),
              );
            });
      }
      return shelf.Response.ok('');
    } else {
      // Respond with a method not allowed message for other request methods
      return shelf.Response(HttpStatus.methodNotAllowed);
    }
  }

  void checkStatus() {
    print('Checking Status ... $isCheckBoxSelect');
  }

  dynamic callGlobalNow(String token,
      GlobalTokenPost globalTokenPost,
      TokenRepository tokenRepository,
      BasketProvider basketProvider,
      UserProvider userProvider,
      TransactionHeaderProvider transactionHeaderProvider)
  {
    Navigator.pushNamed(context, RoutePaths.globalWebview,
        arguments:<String, Object>{
          'token': token,
          'onHppResponse': (String hppResponse) async {
            globalTokenPost.jsonResponse = '{' + hppResponse + '}';
            final Map<String, dynamic>? jsonResponse = await tokenRepository.getGlobalTransactionStatus(globalTokenPost, context);
            print('''payment response from server${jsonResponse!['status']},${jsonResponse['error']}''');
            if(jsonResponse['status'] == true)//payment successfully
              {
                callCardNow(basketProvider, userProvider, transactionHeaderProvider);
            }
            //payment unsuccessfully
            else{
              showDialog<dynamic>(
                  context: context,
                  barrierColor: PsColors.transparent,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                      message: Utils.getString(context, 'error_dialog__payment_unsuccessful'
                      ),
                    );
                  });
            }

          },
        });

  }
  dynamic callBankNow(
      BasketProvider basketProvider,
      UserProvider userLoginProvider,
      TransactionHeaderProvider transactionSubmitProvider) async {
    if (await Utils.checkInternetConnectivity()) {
      if (userLoginProvider.user.data != null) {
        await PsProgressDialog.showDialog(context);
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider.postTransactionSubmit(
                userLoginProvider.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider.checkoutCalculationHelper.tax.toString(),
                basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
                basketProvider.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                basketProvider.checkoutCalculationHelper.totalPrice.toString(),
                basketProvider.checkoutCalculationHelper.totalOriginalPrice
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
                widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
                widget.deliveryPickUpDate,
                widget.deliveryPickUpTime,
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                userLoginProvider.user.data!.area!.areaName!,
                widget.customerMessage,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();

          await basketProvider.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data!,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
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
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  dynamic callScheduleCardNow(
    BasketProvider basketProvider,
    UserProvider userLoginProvider,
    ScheduleHeaderProvider scheduleHeaderProvider,
    String weekDays,
    String selectedTimes,
  ) async {
    if (await Utils.checkInternetConnectivity()) {
      if (userLoginProvider.user.data != null) {
        await PsProgressDialog.showDialog(context);
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<List<ScheduleHeader>> _apiStatus =
            await scheduleHeaderProvider.postScheduleSubmit(
          userLoginProvider.user.data!,
          widget.basketList,
          '',
          couponDiscountProvider!.couponDiscount.toString(),
          basketProvider.checkoutCalculationHelper.tax.toString(),
          basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
          basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
          basketProvider.checkoutCalculationHelper.shippingCost.toString(),
          basketProvider.checkoutCalculationHelper.totalPrice.toString(),
          basketProvider.checkoutCalculationHelper.totalOriginalPrice
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
          widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
          widget.deliveryPickUpDate,
          widget.deliveryPickUpTime,
          basketProvider.checkoutCalculationHelper.shippingCost.toString(),
          userLoginProvider.user.data!.area!.areaName!,
              widget.customerMessage,
          valueHolder,
          weekDays,
          selectedTimes,
          '1',
        );
        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider.deleteWholeBasketList();
          Navigator.pop(context, true);
          await Navigator.pushNamed(context, RoutePaths.checkoutSuccessSchedule,
              arguments: ScheduleCheckoutStatusIntentHolder(
                scheduleHeader: _apiStatus.data![0],
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
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
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  dynamic callCardNow(
      BasketProvider basketProvider,
      UserProvider userLoginProvider,
      TransactionHeaderProvider transactionSubmitProvider) async {
    if (await Utils.checkInternetConnectivity()) {
      if (userLoginProvider.user.data != null) {
        await PsProgressDialog.showDialog(context);
        print(
            basketProvider.checkoutCalculationHelper.subTotalPrice.toString());
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);

        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider.postTransactionSubmit(
                userLoginProvider.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider.checkoutCalculationHelper.tax.toString(),
                basketProvider.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                basketProvider.checkoutCalculationHelper.totalPrice.toString(),
                basketProvider.checkoutCalculationHelper.totalOriginalPrice
                    .toString(),
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ZERO,
                PsConst.ONE,
                '',
                '',
                PsConst.ZERO,
                widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
                widget.deliveryPickUpDate,
                widget.deliveryPickUpTime,
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                userLoginProvider.user.data!.area!.areaName!,
                widget.customerMessage,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data!,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
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
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  dynamic callPickUpNow(
      BasketProvider basketProvider,
      UserProvider userLoginProvider,
      TransactionHeaderProvider transactionSubmitProvider) async {
    if (await Utils.checkInternetConnectivity()) {
      if (userLoginProvider.user.data != null) {
        await PsProgressDialog.showDialog(context);
        print(
            basketProvider.checkoutCalculationHelper.subTotalPrice.toString());
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider.postTransactionSubmit(
                userLoginProvider.user.data!,
                widget.basketList,
                '',
                couponDiscountProvider!.couponDiscount.toString(),
                basketProvider.checkoutCalculationHelper.tax.toString(),
                basketProvider.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                basketProvider.checkoutCalculationHelper.totalPrice.toString(),
                basketProvider.checkoutCalculationHelper.totalOriginalPrice
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
                widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
                widget.deliveryPickUpDate,
                widget.deliveryPickUpTime,
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                userLoginProvider.user.data!.area!.areaName!,
                widget.customerMessage,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();
          await basketProvider.deleteWholeBasketList();
          // Navigator.pop(context, true);
          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data!,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
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
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  dynamic payRazorNow(
      UserProvider userProvider,
      TransactionHeaderProvider transactionSubmitProvider,
      CouponDiscountProvider couponDiscountProvider,
      PsValueHolder psValueHolder,
      BasketProvider basketProvider) async {
    if (psValueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    } else if (psValueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    }
    final ShopInfoProvider _shopInfoProvider =
        Provider.of<ShopInfoProvider>(context, listen: false);
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
      'key': _shopInfoProvider.shopInfo.data!.razorKey!,
      'amount': (double.parse(Utils.getPriceTwoDecimal(basketProvider
                  .checkoutCalculationHelper.totalPrice
                  .toString())) *
              100)
          .round(),
      'name': userProvider.user.data!.userName!,
      'currency': isRazorSupportMultiCurrency
          ? _shopInfoProvider.shopInfo.data!.currencyShortForm!
          : valueHolder.defaultRazorCurrency!,
      'description': '',
      'prefill': <String, String>{
        'contact': userProvider.user.data!.userPhone!,
        'email': userProvider.user.data!.userEmail!
      }
    };

    if (await Utils.checkInternetConnectivity()) {
      //_razorpay.open(options);
    } else {
      showDialog<dynamic>(
          context: context,
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  /*Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds

    print(response);

    await PsProgressDialog.showDialog(context);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final TransactionHeaderProvider transactionSubmitProvider =
        Provider.of<TransactionHeaderProvider>(context, listen: false);
    final BasketProvider basketProvider =
        Provider.of<BasketProvider>(context, listen: false);
    if (userProvider.user.data != null) {
      final PsValueHolder valueHolder =
          Provider.of<PsValueHolder>(context, listen: false);
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userProvider.user.data!,
              widget.basketList,
              '',
              couponDiscountProvider!.couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
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
              widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
              widget.deliveryPickUpDate,
              widget.deliveryPickUpTime,
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              userProvider.user.data!.area!.areaName!,
              memoController.text,
              valueHolder);

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider.deleteWholeBasketList();

          // Navigator.pop(context, true);
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
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
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

  dynamic payFlutterWave(
      UserProvider userProvider,
      TransactionHeaderProvider transactionSubmitProvider,
      CouponDiscountProvider couponDiscountProvider,
      PsValueHolder psValueHolder,
      BasketProvider basketProvider) async {
    if (psValueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    } else if (psValueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    }

    final ShopInfoProvider shopInfoProvider =
        Provider.of<ShopInfoProvider>(context, listen: false);

    final String amount = Utils.getPriceTwoDecimal(
        basketProvider.checkoutCalculationHelper.totalPrice.toString());

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
        name: userProvider.user.data!.userName!,
        phoneNumber: userProvider.user.data!.userPhone!,
        email: userProvider.user.data!.userEmail!);

    final Flutterwave flutterwave = Flutterwave(
      context: context,
     // style: style,
      publicKey: shopInfoProvider.shopInfo.data!.flutterWavePublishableKey!,
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
            barrierColor: PsColors.transparent,
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

  Future<void> _handleWavePaymentSuccess(String transactionId) async {
    // Do something when payment succeeds
    print('success');

    print(transactionId);

    await PsProgressDialog.showDialog(context);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final TransactionHeaderProvider transactionSubmitProvider =
        Provider.of<TransactionHeaderProvider>(context, listen: false);
    final BasketProvider basketProvider =
        Provider.of<BasketProvider>(context, listen: false);
    if (userProvider.user.data != null) {
      final PsValueHolder valueHolder =
          Provider.of<PsValueHolder>(context, listen: false);
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userProvider.user.data!,
              widget.basketList,
              '',
              couponDiscountProvider!.couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO, // Cod
              PsConst.ZERO, // Paypal
              PsConst.ZERO, // Stripe
              PsConst.ZERO, // Bank
              PsConst.ZERO, // Razor
              PsConst.ONE, // Wave
              PsConst.ZERO, // Paystack
              PsConst.ZERO, // global
              '', // Razor Id
              transactionId, // Wave Id
              PsConst.ZERO, // Pickup Or Not
              widget.isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
              widget.deliveryPickUpDate,
              widget.deliveryPickUpTime,
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              userProvider.user.data!.area!.areaName!,
              widget.customerMessage,
              valueHolder);

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider.deleteWholeBasketList();

          // Navigator.pop(context, true);
          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data!,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
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
            barrierColor: PsColors.transparent,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
      }
    }
  }

  dynamic payNow(
      String clientNonce,
      UserProvider userProvider,
      TransactionHeaderProvider transactionSubmitProvider,
      CouponDiscountProvider couponDiscountProvider,
      PsValueHolder psValueHolder,
      BasketProvider basketProvider) async {
    final ShopInfoProvider shopInfoProvider =
        Provider.of<ShopInfoProvider>(context, listen: false);
    if (psValueHolder.standardShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    } else if (psValueHolder.zoneShippingEnable == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: couponDiscountProvider.couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: userProvider.user.data!.area!.price!);
    }

    // final BraintreePayment braintreePayment = BraintreePayment();
    // final dynamic data = await braintreePayment.showDropIn(
    //     nonce: clientNonce,
    //     amount:
    //         basketProvider.checkoutCalculationHelper.totalPriceFormattedString,
    //     enableGooglePay: true);
    // print('${Utils.getString(context, 'checkout__payment_response')} $data');
    /*final BraintreeDropInRequest request = BraintreeDropInRequest(
      clientToken: clientNonce,
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice:
            basketProvider.checkoutCalculationHelper.totalPrice.toString(),
        currencyCode: shopInfoProvider.shopInfo.data!.currencyShortForm!,
        billingAddressRequired: false,
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: basketProvider.checkoutCalculationHelper.totalPrice.toString(),
        displayName: userProvider.user.data!.userName,
      ),
    );*/
    
    /*final BraintreeDropInResult? result = await BraintreeDropIn.start(request);
    if (result != null) {
      print('Nonce: ${result.paymentMethodNonce.nonce}');
    } else {
      print('Selection was canceled.');
    }

    if (await Utils.checkInternetConnectivity()) {

      if (userProvider.user.data != null && result != null) {
      await PsProgressDialog.showDialog(context);
        final PsValueHolder valueHolder =
            Provider.of<PsValueHolder>(context, listen: false);
        final PsResource<TransactionHeader> _apiStatus =
            await transactionSubmitProvider.postTransactionSubmit(
                userProvider.user.data!,
                widget.basketList,
                result.paymentMethodNonce.nonce,
                couponDiscountProvider.couponDiscount.toString(),
                basketProvider.checkoutCalculationHelper.tax.toString(),
                basketProvider.checkoutCalculationHelper.totalDiscount
                    .toString(),
                basketProvider.checkoutCalculationHelper.subTotalPrice
                    .toString(),
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                basketProvider.checkoutCalculationHelper.totalPrice
                    .toString(),
                basketProvider.checkoutCalculationHelper.totalOriginalPrice
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
                widget.isClickPickUpButton == true
                    ? PsConst.ONE
                    : PsConst.ZERO,
                widget.deliveryPickUpDate,
                widget.deliveryPickUpTime,
                basketProvider.checkoutCalculationHelper.shippingCost
                    .toString(),
                userProvider.user.data!.area!.areaName!,
                memoController.text,
                valueHolder);

        if (_apiStatus.data != null) {
          PsProgressDialog.dismissDialog();

          if (_apiStatus.status == PsStatus.SUCCESS) {
            print(_apiStatus.data);
            *//*await basketProvider.deleteWholeBasketList();

            // Navigator.pop(context, true);
            await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
                arguments: CheckoutStatusIntentHolder(
                  transactionHeader: _apiStatus.data!,
                ));*//*
          } else {
            PsProgressDialog.dismissDialog();

            return showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
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
              barrierColor: PsColors.transparent,
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
          barrierColor: PsColors.transparent,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);
    return Consumer<TransactionHeaderProvider>(builder: (BuildContext context,
        TransactionHeaderProvider transactionHeaderProvider, Widget? child) {
      return Consumer<BasketProvider>(builder:
          (BuildContext context, BasketProvider basketProvider, Widget? child) {
        return Consumer<UserProvider>(builder:
            (BuildContext context, UserProvider userProvider, Widget? child) {
          return Consumer<TokenProvider>(builder: (BuildContext context,
              TokenProvider tokenProvider, Widget? child) {
            // if (tokenProvider.tokenData != null &&
            //     tokenProvider.tokenData.data != null &&
            //     tokenProvider.tokenData.data.message != null) {
            couponDiscountProvider = Provider.of<CouponDiscountProvider>(
                context,
                listen: false); // Listen : False is important.
            basketProvider = Provider.of<BasketProvider>(context,
                listen: false); // Listen : False is important.

            //return SingleChildScrollView(
              child:
            return Column(
                children: <Widget>[
                  Expanded(
                      child:
                      WebView(
                        initialUrl: PsUrl.ps_global_payment_hpp_url,
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
                          webController = webViewController;
                        },
                        onPageFinished: (String url) async{
                          if (webController != null) {
                            tokenPostRequest = GlobalTokenPost(
                              userEmail: userProvider.user.data!.userEmail,
                              userPhone: userProvider.user.data!.userPhone,
                              userAddress1: userProvider.user.data!.address,
                              userAddress2: '',
                              userCity: userProvider.user.data!.userCity,
                              userPostcode: userProvider.user.data!.userPostcode,
                              userTotal: basketProvider.checkoutCalculationHelper.totalPrice.toString(),
                              jsonResponse: '0',// zero means posting to get token, if it is assigned with a response then server will return transaction result
                            );
                            token = await widget.tokenRepository.postGlobalToken(tokenPostRequest,context);
                            if (token != null) {
                              print(token!);
                              webController!.runJavascript('''
                                    \$(document).ready(function() {
                                RealexHpp.setHppUrl("${PsUrl
                                  .ps_global_payment_url}");
                                var jsonObject = JSON.parse($token);
                                RealexHpp.embedded.init("payButtonId", "iframeId", "http://$deviceIp:8080/", jsonObject );
                                \$("#payButtonId").click();
                            });
                        ''');
                            }
                          }
                        },
                        onPageStarted: (String url) {
                        },
                        // ),

                        /*Container(
                color: PsColors.backgroundColor,
                padding: const EdgeInsets.only(
                  left: PsDimens.space12,
                  right: PsDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: PsDimens.space16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: PsDimens.space16, right: PsDimens.space16),
                      child: Text(
                        Utils.getString(context, 'checkout3__payment_method'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      height: PsDimens.space16,
                    ),
                    const Divider(
                      height: 2,
                    ),
                    const SizedBox(
                      height: PsDimens.space8,
                    ),
                    Consumer<ShopInfoProvider>(builder: (BuildContext context,
                        ShopInfoProvider shopInfoProvider, Widget? child) {
                      if (shopInfoProvider.shopInfo.data == null) {
                        return Container();
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.codEnabled ==
                                          '1' &&
                                      widget.isClickDeliveryButton,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isCashClicked) {
                                          isCashClicked = true;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsCashSelected(
                                          Utils.getString(
                                              context, 'checkout3__cod')),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.pickupEnabled ==
                                          '1' &&
                                      widget.isClickPickUpButton &&
                                      widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isPickUpClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = true;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsPickUpSelected(
                                          Utils.getString(
                                              context, 'checkout3__pick_up')),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.paypalEnabled ==
                                          '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isPaypalClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = true;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsPaypalSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                      .shopInfo.data!.globalEnabled ==
                                      '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                    const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isGlobalClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = true;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsGlobalSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.stripeEnabled ==
                                          '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () async {
                                        if (!isStripeClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = true;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsStripeSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider.shopInfo.data
                                              !.banktransferEnabled ==
                                          '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isBankClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = true;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsBankSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.razorEnabled ==
                                          '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isRazorClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = true;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsRazorSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider
                                              .shopInfo.data!.paystackEnabled ==
                                          PsConst.ONE &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isPayStackClicked) {
                                          isCashClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = true;
                                          isFlutterWaveClicked = false;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsPayStackSelected(),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: shopInfoProvider.shopInfo.data!
                                              .flutterWaveEnabled ==
                                          '1' &&
                                      !widget.isWeeklyScheduleOrder,
                                  child: Container(
                                    width: PsDimens.space140,
                                    height: PsDimens.space140,
                                    padding:
                                        const EdgeInsets.all(PsDimens.space8),
                                    child: InkWell(
                                      onTap: () {
                                        if (!isFlutterWaveClicked) {
                                          isCashClicked = false;
                                          isPickUpClicked = false;
                                          isPaypalClicked = false;
                                          isGlobalClicked = false;
                                          isStripeClicked = false;
                                          isBankClicked = false;
                                          isRazorClicked = false;
                                          isPayStackClicked = false;
                                          isFlutterWaveClicked = true;
                                        }

                                        setState(() {});
                                      },
                                      child: checkIsWaveSelected(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: PsDimens.space12,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: PsDimens.space16,
                                  right: PsDimens.space16),
                              child: showOrHideCashText(
                                  shopInfoProvider.shopInfo.data!.pickupMessage!),
                            ),
                            const SizedBox(
                              height: PsDimens.space8,
                            ),
                          ],
                        ),
                      );
                    }),
                    PsTextFieldWidget(
                        titleText: Utils.getString(context, 'checkout3__delivery_notes'),
                        height: PsDimens.space80,
                        textAboutMe: true,
                        hintText: Utils.getString(context, 'checkout3__delivery_notes'),
                        keyboardType: TextInputType.multiline,
                        textEditingController: memoController),
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
                  ],
                ),
              ),*/
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: TextField(
                      controller: TextEditingController(text: '4000120000001154'),
                      decoration: const InputDecoration(
                        labelText: 'Declined',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: TextField(
                      controller: TextEditingController(text: '4263970000005262'),
                      decoration: const InputDecoration(
                        labelText: 'Successful',
                      ),
                    ),
                  ),
                ]);
            // } else {
            //   return Container();
            // }
          });
        });
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

  Widget checkIsWaveSelected() {
    if (!isFlutterWaveClicked) {
      return changeWaveCardToWhite();
    } else {
      return changeWaveCardToOrange();
    }
  }

  Widget changeWaveCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space12, right: PsDimens.space12),
              child: Text(Utils.getString(context, 'checkout3__wave'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changeWaveCardToWhite() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.coreBackgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__wave'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkIsCashSelected(String title) {
    if (!isCashClicked) {
      return changeCashCardToWhite(title);
    } else {
      return changeCashCardToOrange(title);
    }
  }

  Widget checkIsPickUpSelected(String title) {
    if (!isPickUpClicked) {
      return changeCashCardToWhite(title);
    } else {
      return changeCashCardToOrange(title);
    }
  }

  Widget changeCashCardToWhite(String title) {
    return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.coreBackgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                  width: 50, height: 50, child: const Icon(Icons.delivery_dining_sharp)),
              Container(
                margin: const EdgeInsets.only(
                  left: PsDimens.space16,
                  right: PsDimens.space16,
                ),
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        !.copyWith(height: 1.3)),
              ),
            ],
          ),
        ));
  }

  Widget changeCashCardToOrange(String title) {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(
                  Icons.delivery_dining_sharp,
                  color: PsColors.white,
                )),
            Container(
              margin: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
              ),
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkIsPaypalSelected() {
    if (!isPaypalClicked) {
      return changePaypalCardToWhite();
    } else {
      return changePaypalCardToOrange();
    }
  }

  Widget changePaypalCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.paypal, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
              ),
              child: Text(Utils.getString(context, 'checkout3__paypal'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changePaypalCardToWhite() {
    return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.coreBackgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                  width: 50, height: 50, child: const Icon(FontAwesome.paypal)),
              Container(
                margin: const EdgeInsets.only(
                  left: PsDimens.space16,
                  right: PsDimens.space16,
                ),
                child: Text(Utils.getString(context, 'checkout3__paypal'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        !.copyWith(height: 1.3)),
              ),
            ],
          ),
        ));
  }
  Widget checkIsGlobalSelected() {
    if (!isGlobalClicked) {
      return changeGlobalCardToWhite();
    } else {
      return changeGlobalCardToOrange();
    }
  }
  Widget changeGlobalCardToWhite() {
    return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.coreBackgroundColor,
            borderRadius:
            const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                  width: 50, height: 50, child: const Icon(FontAwesome.paypal)),
              Container(
                margin: const EdgeInsets.only(
                  left: PsDimens.space16,
                  right: PsDimens.space16,
                ),
                child: Text(Utils.getString(context, 'checkout3__global'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                    !.copyWith(height: 1.3)),
              ),
            ],
          ),
        ));
  }
  Widget changeGlobalCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
          const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.paypal, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
              ),
              child: Text(Utils.getString(context, 'checkout3__global'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                  !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }
  Widget checkIsStripeSelected() {
    if (!isStripeClicked) {
      return changeStripeCardToWhite();
    } else {
      return changeStripeCardToOrange();
    }
  }

  Widget changeStripeCardToWhite() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.coreBackgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
              ),
              child: Text(Utils.getString(context, 'checkout3__stripe'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changeStripeCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.payment, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
              ),
              child: Text(Utils.getString(context, 'checkout3__stripe'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkIsPayStackSelected() {
    if (!isPayStackClicked) {
      return changePayStackCardToWhite();
    } else {
      return changePayStackCardToOrange();
    }
  }

  Widget changePayStackCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.payment, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__paystack'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changePayStackCardToWhite() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.coreBackgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__paystack'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkIsBankSelected() {
    if (!isBankClicked) {
      return changeBankCardToWhite();
    } else {
      return changeBankCardToOrange();
    }
  }

  Widget changeBankCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.payment, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__bank'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changeBankCardToWhite() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.coreBackgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__bank'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkIsRazorSelected() {
    if (!isRazorClicked) {
      return changeRazorCardToWhite();
    } else {
      return changeRazorCardToOrange();
    }
  }

  Widget changeRazorCardToOrange() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.mainColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(
                width: 50,
                height: 50,
                child: Icon(Icons.payment, color: PsColors.white)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__razor'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3, color: PsColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget changeRazorCardToWhite() {
    return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.coreBackgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space4,
            ),
            Container(width: 50, height: 50, child: const Icon(Icons.payment)),
            Container(
              margin: const EdgeInsets.only(
                  left: PsDimens.space16, right: PsDimens.space16),
              child: Text(Utils.getString(context, 'checkout3__razor'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      !.copyWith(height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget? showOrHideCashText(String pickUpMessage) {
    if (isCashClicked) {
      return Text(Utils.getString(context, 'checkout3__cod_message'),
          style: Theme.of(context).textTheme.bodyMedium);
    } else if (isPickUpClicked) {
      return Text(pickUpMessage, style: Theme.of(context).textTheme.bodyMedium);
    } else {
      return null;
    }
  }
}
