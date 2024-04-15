import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/coupon_discount/coupon_discount_provider.dart';
import 'package:flutterrestaurant/provider/delivery_cost/delivery_cost_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/provider/token/token_provider.dart';
import 'package:flutterrestaurant/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/coupon_discount_repository.dart';
import 'package:flutterrestaurant/repository/delivery_cost_repository.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/repository/token_repository.dart';
import 'package:flutterrestaurant/repository/transaction_header_repository.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../ui/checkout/checkout1_view.dart';
import '../../ui/checkout/checkout2_view.dart';
import '../../ui/checkout/checkout3_view.dart';
import '../../viewobject/holder/globalTokenPost.dart';

class CheckoutContainerView extends StatefulWidget {
  const CheckoutContainerView({Key? key, required this.basketList})
      : super(key: key);

  final List<Basket> basketList;

  @override
  _CheckoutContainerViewState createState() => _CheckoutContainerViewState();
}

class _CheckoutContainerViewState extends State<CheckoutContainerView> {
  int viewNo = 1;
  int maxViewNo = 5;
  UserRepository? userRepository;
  UserProvider? userProvider;
  TokenProvider? tokenProvider;
  PsValueHolder? valueHolder;
  ShopInfoProvider? shopInfoProvider;
  DeliveryCostProvider? provider;
  CouponDiscountRepository? couponDiscountRepo;
  TransactionHeaderRepository? transactionHeaderRepo;
  late BasketRepository basketRepository;
  ShopInfoRepository? shopInfoRepository;
  DeliveryCostRepository? deliveryCostRepository;
  String? couponDiscount;
  CouponDiscountProvider? couponDiscountProvider;
  BasketProvider? basketProvider;
  TransactionHeaderProvider? transactionSubmitProvider;
  PsApiService? psApiService;
  TokenRepository? tokenRepository;
  GlobalTokenPost tokenPostRequest = GlobalTokenPost();
  int? hour, minute;
  int? monOpenHour, monCloseHour, monOpenMin, monCloseMin;
  int? tuesOpenHour, tuesCloseHour, tuesOpenMin, tuesCloseMin;
  int? wedOpenHour, wedCloseHour, wedOpenMin, wedCloseMin;
  int? thursOpenHour, thursCloseHour, thursOpenMin, thursCloseMin;
  int? friOpenHour, friCloseHour, friOpenMin, friCloseMin;
  int? satOpenHour, satCloseHour, satOpenMin, satCloseMin;
  int? sunOpenHour, sunCloseHour, sunOpenMin, sunCloseMin;
  String? days;
  String weekDays = '';
  String selectedTimes = '';
  final TextEditingController customerMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void _closeCheckoutContainer() {
      Navigator.pop(context);
    }

    userRepository = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    deliveryCostRepository = Provider.of<DeliveryCostRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psApiService = Provider.of<PsApiService>(context);
    tokenRepository = Provider.of<TokenRepository>(context);
    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<CouponDiscountProvider>(
              lazy: false,
              create: (BuildContext context) {
                couponDiscountProvider = CouponDiscountProvider(
                    repo: couponDiscountRepo!, psValueHolder: valueHolder!);

                return couponDiscountProvider!;
              }),
          ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                basketProvider = BasketProvider(repo: basketRepository);

                return basketProvider!;
              }),
          ChangeNotifierProvider<UserProvider>(
              lazy: false,
              create: (BuildContext context) {
                userProvider = UserProvider(
                    repo: userRepository!, psValueHolder: valueHolder!);
                userProvider!
                    .getUserFromDB(userProvider!.psValueHolder.loginUserId!);

                return userProvider!;
              }),
          ChangeNotifierProvider<TransactionHeaderProvider>(
              lazy: false,
              create: (BuildContext context) {
                transactionSubmitProvider = TransactionHeaderProvider(
                    repo: transactionHeaderRepo!, psValueHolder: valueHolder!);

                return transactionSubmitProvider!;
              }),
          ChangeNotifierProvider<TokenProvider>(
              lazy: false,
              create: (BuildContext context) {
                tokenProvider = TokenProvider(
                    repo: tokenRepository!, psValueHolder: valueHolder);
                return tokenProvider!;
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
          ChangeNotifierProvider<DeliveryCostProvider>(
              lazy: false,
              create: (BuildContext context) {
                provider = DeliveryCostProvider(repo: deliveryCostRepository);
                return provider!;
              }),
        ],
        child: Scaffold(
          /*bottomNavigationBar: checkHideOrShowBackArrowBar(
              _closeCheckoutContainer, tokenProvider),*/
          body: Column(
            children: <Widget>[
              Container(
                child: _TopImageForCheckout(
                  viewNo: viewNo,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              checkHideOrShowBackArrowBar(_closeCheckoutContainer, tokenProvider),
              Expanded(
                child: checkForTopImage(),
              )
            ],
          )
        ));
  }

  Container checkForTopImage() {
    if (viewNo == 4) {
      return Container(child: checkToShowView());
    } else {
      return Container(
          //margin: const EdgeInsets.only(top: PsDimens.space220),
          child: checkToShowView());
    }
  }

  static dynamic checkout1ViewState;
  dynamic checkout2ViewState;
  static dynamic checkout3ViewState;
  bool isApiSuccess = false;

  void updateCheckout1ViewState(State state) {
    checkout1ViewState = state;
  }

  void updateCheckout2ViewState(State state) {
    checkout2ViewState = state;
  }

  void updateCheckout3ViewState(State state) {
    checkout3ViewState = state;
  }

  dynamic checkToShowView() {
    if (viewNo == 1) {
      return Checkout1View(
        updateCheckout1ViewState,
        widget.basketList,
      );
    } else if (viewNo == 2) {

      return Container(
        color: PsColors.coreBackgroundColor,
        child: Checkout2View(
          updateCheckout2ViewState: updateCheckout2ViewState,
          basketList: widget.basketList,
          shopInfoProvider: shopInfoProvider!,
          publishKey: valueHolder!.publishKey!,
          deliveryPickUpDate: checkout1ViewState.deliveryPickUpDate,
          deliveryPickUpTime: checkout1ViewState.deliveryPickUpTime,
          customerMessageController: customerMessageController,
        ),
      );

    } else if (viewNo == 3) {
      return Container(
        color: PsColors.coreBackgroundColor,
        child: Checkout3View(
          basketProvider,
          userProvider,
          transactionSubmitProvider,
          tokenRepository!,
          updateCheckout3ViewState,
          widget.basketList,
          checkout1ViewState.userProvider.isClickDeliveryButton,
          checkout1ViewState.userProvider.isClickPickUpButton,
          checkout1ViewState.deliveryPickUpDate,
          checkout1ViewState.deliveryPickUpTime,
          false,
          customerMessageController.text
        ),
      );
    }
  }

  dynamic checkHideOrShowBackArrowBar(
      Function _closeCheckoutContainer, TokenProvider? tokenProvider) {
    if (viewNo == 4) {
      return Container(
        height: 0,
      );
    } else {
      return Container(
          height: 50,
          color: PsColors.mainColor,
          //margin: const EdgeInsets.only(top: PsDimens.space160),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              checkHideOrShowBackArrow(),
              if(viewNo != 3)
              GestureDetector(
                child:
                Container(
                    height: 50,
                    margin: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: PsColors.white, // Set border color
                        width: 2, // Set border width
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child:Padding(
                        padding: const EdgeInsets.only(
                          right: PsDimens.space10,
                          left: PsDimens.space10,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              viewNo == 3
                                  ? '' /*Utils.getString(context,
                                        'basket_list__checkout_button_name')*/
                                  : Utils.getString(context, 'checkout_container__next'),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: PsColors.white),
                            ),/*
                            const SizedBox(
                              width: 3,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: PsColors.white,
                              size: PsDimens.space16,
                            ),*/
                          ],
                        ),
                      ),
                    )


                ),
                onTap: () {
                  clickToNextCheck(userProvider!.user.data!,
                      _closeCheckoutContainer, tokenProvider!);
                },
              )
            ],
          ));
    }
  }
  bool validatePhoneNumber(String phoneNumber ){
    final RegExp phoneRegExp = RegExp(r'^[0-9]{11}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
  void parseOpenCloseTime(
      String? openDateAndTime,
      String? closeDateAndTime,
      int? openHour,
      int? openMin,
      int? closeHour,
      int? closeMin,
      ) {
    if (openDateAndTime != null && openDateAndTime != '') {
      final List<String>? openDateAndTimeArray = openDateAndTime.split(' ');

      if (openDateAndTimeArray != null && openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          openHour = int.parse(openHourArray[0]);
          openMin = int.parse(openHourArray[1]);
        }
      }
    }

    if (closeDateAndTime != null && closeDateAndTime != '') {
      final List<String>? closeDateAndTimeArray = closeDateAndTime.split(' ');

      if (closeDateAndTimeArray != null && closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          closeHour = int.parse(closeHourArray[0]);
          closeMin = int.parse(closeHourArray[1]);
        }
      }
    }
  }

  dynamic clickToNextCheck(User user, Function _closeCheckoutContainer,
      TokenProvider tokenProvider) async {
    if (viewNo < maxViewNo) {
      if (viewNo == 2) {
        //checkout2ViewState.checkStatus();
        if (checkout2ViewState.isCheckBoxSelect) {
          showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
              builder: (BuildContext context) {
                return ConfirmDialogView(
                    description: Utils.getString(
                        context, 'checkout_container__confirm_order'),
                    leftButtonText: Utils.getString(
                        context, 'home__logout_dialog_cancel_button'),
                    rightButtonText: Utils.getString(
                        context, 'home__logout_dialog_ok_button'),
                    onAgreeTap: () async {
                      /*if (PsConfig.isDemo) {
                        //await callDemoWarningDialog(context);
                      }*/
                      //Navigator.pop(context);
                        tokenPostRequest = GlobalTokenPost(
                        userEmail: user.userEmail,
                        userPhone: user.userPhone,
                        userAddress1: user.address,
                        userAddress2: '',
                        userCity: user.userCity,
                        userPostcode: user.userPostcode,
                        userTotal: basketProvider?.checkoutCalculationHelper.totalPrice.toString(),
                        jsonResponse: '0',// zero means posting to get token, if it is assigned with a response then server will return transaction result
                      );
                      final String? token = await tokenRepository?.postGlobalToken(tokenPostRequest,context);
                      if (token != null) {
                      // Handle the JSON response
                        _closeCheckoutContainer();
                        setState(() {
                          viewNo++;
                        });
                        /*final dynamic returnData = checkout2ViewState.callGlobalNow(
                            token,
                            dataToSend,
                            tokenRepository,
                            basketProvider,
                            userProvider,
                            transactionSubmitProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }*/
                        /*return Container(
                          color: PsColors.coreBackgroundColor,
                          child: Checkout3View(
                              token,
                              updateCheckout3ViewState,
                              widget.basketList,
                              checkout1ViewState.userProvider.isClickDeliveryButton,
                              checkout1ViewState.userProvider.isClickPickUpButton,
                              checkout1ViewState.deliveryPickUpDate,
                              checkout1ViewState.deliveryPickUpTime,
                              false,
                                (String hppResponse) async {
                                  dataToSend.jsonResponse = '{' + hppResponse + '}';
                            final Map<String, dynamic>? jsonResponse = await tokenRepository!.getGlobalTransactionStatus(dataToSend, context);
                            print('''payment response from server${jsonResponse!['status']},${jsonResponse!['error']}''');
                            if(jsonResponse!['status'] == true)//payment successfully
                                {
                              checkout2ViewState.callCardNow(basketProvider, userProvider, transactionSubmitProvider);
                            }
                            //payment unsuccessfully
                            else{
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ErrorDialog(
                                      message: Utils.getString(context, 'error_dialog__payment_unsuccessful'
                                      ),
                                    );
                                  });
                            }

                          },
                          ),
                        );*/
                      } else {
                      // Handle the failure case
                      print('Failed to post data.');
                      }

                      
                    });
              });
          /*if (checkout3ViewState.isPaypalClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        if (PsConfig.isDemo) {
                          await callDemoWarningDialog(context);
                        }
                        Navigator.pop(context);
                        final PsResource<ApiStatus> tokenResource =
                            await tokenProvider.loadToken();
                        
                        final dynamic returnData =
                            await checkout3ViewState.payNow(
                                tokenResource.data!.message,
                                userProvider,
                                transactionSubmitProvider,
                                couponDiscountProvider,
                                valueHolder,
                                basketProvider);
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isStripeClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        if (PsConfig.isDemo) {
                          await callDemoWarningDialog(context);
                        }
                        Navigator.pop(context);
                        final dynamic returnData = await Navigator.pushNamed(
                            context, RoutePaths.creditCard,
                            arguments: CreditCardIntentHolder(
                                basketList: widget.basketList,
                                couponDiscount:
                                    couponDiscountProvider!.couponDiscount,
                                transactionSubmitProvider:
                                    transactionSubmitProvider!,
                                userProvider: userProvider!,
                                basketProvider: basketProvider!,
                                psValueHolder: valueHolder!,
                                memoText:
                                    checkout3ViewState.memoController.text,
                                publishKey: valueHolder!.publishKey!,
                                isClickPickUpButton: checkout1ViewState
                                    .userProvider.isClickPickUpButton,
                                deliveryPickUpDate:
                                    checkout1ViewState.deliveryPickUpDate,
                                deliveryPickUpTime:
                                    checkout1ViewState.deliveryPickUpTime));

                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isPayStackClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        if (PsConfig.isDemo) {
                          await callDemoWarningDialog(context);
                        }
                        Navigator.pop(context);
                        final dynamic returnData = await Navigator.pushNamed(
                            context, RoutePaths.paystack,
                            arguments: PayStackInterntHolder(
                                basketList: widget.basketList,
                                couponDiscount:
                                    couponDiscountProvider!.couponDiscount,
                                transactionSubmitProvider:
                                    transactionSubmitProvider!,
                                userLoginProvider: userProvider!,
                                basketProvider: basketProvider!,
                                psValueHolder: valueHolder!,
                                memoText:
                                    checkout3ViewState.memoController.text,
                                paystackKey: shopInfoProvider!
                                    .shopInfo.data!.paystackKey!,
                                publishKey: valueHolder!.publishKey!,
                                isClickPickUpButton: checkout1ViewState
                                    .userProvider.isClickPickUpButton,
                                deliveryPickUpDate:
                                    checkout1ViewState.deliveryPickUpDate,
                                deliveryPickUpTime:
                                    checkout1ViewState.deliveryPickUpTime,
                                basketTotalPrice: 0));

                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isCashClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.callCardNow(
                          basketProvider,
                          userProvider,
                          transactionSubmitProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isPickUpClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.callPickUpNow(
                          basketProvider,
                          userProvider,
                          transactionSubmitProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isBankClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.callBankNow(
                          basketProvider,
                          userProvider,
                          transactionSubmitProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isRazorClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        if (PsConfig.isDemo) {
                          await callDemoWarningDialog(context);
                        }
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.payRazorNow(
                                userProvider,
                                transactionSubmitProvider,
                                couponDiscountProvider,
                                valueHolder,
                                basketProvider);
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isFlutterWaveClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        if (PsConfig.isDemo) {
                          await callDemoWarningDialog(context);
                        }
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.payFlutterWave(
                                userProvider,
                                transactionSubmitProvider,
                                couponDiscountProvider,
                                valueHolder,
                                basketProvider);
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: Utils.getString(
                        context, 'checkout_container__choose_payment'),
                  );
                });
          }*/
        } else {
          showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
              builder: (BuildContext context) {
                return WarningDialog(
                  message: Utils.getString(
                      context, 'checkout_container__agree_term_and_con'),
                  onPressed: () {},
                );
              });
        }
      } else if (viewNo == 1) {
        if (checkout1ViewState.userEmailController.text.isEmpty ||
            (!checkout1ViewState.userProvider.hasLatLng(valueHolder) &&
                checkout1ViewState.addressController.text == '' &&
                checkout1ViewState.userProvider.isClickDeliveryButton) ||
            (checkout1ViewState.addressController.text.isEmpty &&
                checkout1ViewState.userProvider.isClickDeliveryButton) ||
            (checkout1ViewState.userPostcodeController.text.isEmpty &&
                checkout1ViewState.userProvider.isClickDeliveryButton) ||
            (checkout1ViewState.userCityController.text.isEmpty &&
                checkout1ViewState.userProvider.isClickDeliveryButton) ||
            (checkout1ViewState.userCountryController.text.isEmpty &&
                checkout1ViewState.userProvider.isClickDeliveryButton) ||
            checkout1ViewState.userPhoneController.text.isEmpty

        ) {
          print('field check failed');
          checkout1ViewState.checkFields('');
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                  Utils.getString(context, 'warning_dialog__input_fields'),
                );
              });
        } else
        if (!validatePhoneNumber(checkout1ViewState.userPhoneController.text)) {
          showDialog<dynamic>(
              context: context,
              barrierColor: Colors.transparent,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'Please Enter A Valid Phone Number'),
                );
              });
        }
        /*else if (!checkout1ViewState.userProvider.hasLatLng(valueHolder) &&
            checkout1ViewState.addressController.text == '' &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__no_pin_location'),
                );
              });
        } else if (checkout1ViewState.addressController.text.isEmpty &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'warning_dialog__address'),
                );
              });

        } else if (checkout1ViewState.userPostcodeController.text.isEmpty &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'warning_dialog__postcode'),
                );
              });

        }else if (checkout1ViewState.userCityController.text.isEmpty &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'warning_dialog__city'),
                );
              });

        }else if (checkout1ViewState.userCountryController.text.isEmpty &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'warning_dialog__country'),
                );
              });

        }else if (checkout1ViewState.userPhoneController.text.isEmpty) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                      Utils.getString(context, 'warning_dialog__input_phone'),
                );
              });
        } */ else if (shopInfoProvider!.shopInfo.data!.isArea == PsConst.ONE &&
            (checkout1ViewState.userProvider.selectedArea == null ||
                checkout1ViewState.userProvider.selectedArea.id == null ||
                checkout1ViewState.userProvider.selectedArea.id == '') &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                  Utils.getString(context, 'warning_dialog__select_area'),
                );
              });
        } else if (shopInfoProvider!.shopInfo.data!.isArea == PsConst.ZERO &&
            checkout1ViewState.costPerChargesController.text == '0' &&
            checkout1ViewState.userProvider.isClickDeliveryButton) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'error_dialog__order'),
                );
              });
        }
        else if (!checkout1ViewState
            .orderTimeTextEditingController.text.isEmpty &&
            shopInfoProvider!.shopInfo.data!.shopSchedules != null) {
          String? orderDateAndTime;

          orderDateAndTime =checkout1ViewState.orderTime;
          final DateTime currentDateTime = DateTime.now();
            final DateTime shopAcceptDate = DateTime.parse(shopInfoProvider!.shopInfo.data!.acceptOrdersDate!);

            if (shopAcceptDate.isAfter(currentDateTime)) {
              showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: Utils.getString(
                        context, 'Shop Is Not Accepting Orders'),
                  );
                },
              );
            }
          else {


            // Open Time
            final String? mondayOpenDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.mondayOpenHour;
            final String? tuesdayOpenDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.tuesdayOpenHour;
            final String? wednesdayOpenDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.wednesdayOpenHour;
            final String? thursdayOpenDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.thursdayOpenHour;
            final String? fridayOpenDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.fridayOpenHour;
            final String? saturdayOpenDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.saturdayOpenHour;
            final String? sundayOpenDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.sundayOpenHour;

            if (mondayOpenDateAndTime != null && mondayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              mondayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  monOpenHour = int.parse(openHourArray[0]);

                  monOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
            if (tuesdayOpenDateAndTime != null &&
                tuesdayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              tuesdayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  tuesOpenHour = int.parse(openHourArray[0]);
                  tuesOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
            if (wednesdayOpenDateAndTime != null &&
                wednesdayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              wednesdayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  wedOpenHour = int.parse(openHourArray[0]);
                  wedOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
            if (thursdayOpenDateAndTime != null &&
                thursdayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              thursdayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

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
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  friOpenHour = int.parse(openHourArray[0]);
                  friOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
            if (saturdayOpenDateAndTime != null &&
                saturdayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              saturdayOpenDateAndTime.split(' ');


              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  satOpenHour = int.parse(openHourArray[0]);
                  satOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
            if (sundayOpenDateAndTime != null && sundayOpenDateAndTime != '') {
              final List<String>? openDateAndTimeArray =
              sundayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null && openHourArray.isNotEmpty) {
                  sunOpenHour = int.parse(openHourArray[0]);
                  sunOpenMin = int.parse(openHourArray[1]);
                }
              }
            }

            // Close Time
            final String? mondayCloseDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.mondayCloseHour;
            final String? tuesdayCloseDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.tuesdayCloseHour;
            final String? wednesdayCloseDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.wednesdayCloseHour;
            final String? thursdayCloseDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.thursdayCloseHour;
            final String? fridayCloseDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.fridayCloseHour;
            final String? saturdayCloseDateAndTime = shopInfoProvider!
                .shopInfo.data!.shopSchedules!.saturdayCloseHour;
            final String? sundayCloseDateAndTime =
                shopInfoProvider!.shopInfo.data!.shopSchedules!.sundayCloseHour;

            if (mondayCloseDateAndTime != null &&
                mondayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              mondayCloseDateAndTime.split(' ');
              print(
                  'Monday => $mondayOpenDateAndTime ~ $mondayCloseDateAndTime ');


              if (closeDateAndTimeArray != null &&
                  closeDateAndTimeArray[0].contains(':')) {
                final List<String>? closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null && closeHourArray.isNotEmpty) {
                  monCloseHour = int.parse(closeHourArray[0]);

                  monCloseMin = int.parse(closeHourArray[1]);
                }
              }
            }
            if (tuesdayCloseDateAndTime != null &&
                tuesdayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              tuesdayCloseDateAndTime.split(' ');
              print(
                  'Tuesday => $thursdayOpenDateAndTime ~ $tuesdayCloseDateAndTime ');


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
            if (wednesdayCloseDateAndTime != null &&
                wednesdayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              wednesdayCloseDateAndTime.split(' ');
              print(
                  'Wednesday => $wednesdayOpenDateAndTime ~ $wednesdayCloseDateAndTime ');


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
            if (thursdayCloseDateAndTime != null &&
                thursdayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              thursdayCloseDateAndTime.split(' ');
              print(
                  'Thursday => $thursdayOpenDateAndTime ~ $thursdayCloseDateAndTime ');


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
            if (fridayCloseDateAndTime != null &&
                fridayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              fridayCloseDateAndTime.split(' ');
              print(
                  'Friday => $fridayOpenDateAndTime ~ $fridayCloseDateAndTime ');


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
            if (saturdayCloseDateAndTime != null &&
                saturdayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              saturdayCloseDateAndTime.split(' ');
              print(
                  'Saturday => $saturdayOpenDateAndTime ~ $saturdayCloseDateAndTime ');


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
            if (sundayCloseDateAndTime != null &&
                sundayCloseDateAndTime != '') {
              final List<String>? closeDateAndTimeArray =
              sundayCloseDateAndTime.split(' ');
              print(
                  'Sunday => $sundayOpenDateAndTime ~ $sundayCloseDateAndTime ');


              if (closeDateAndTimeArray != null &&
                  closeDateAndTimeArray.length > 1) {
                final List<String>? closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null && closeHourArray.isNotEmpty) {
                  sunCloseHour = int.parse(closeHourArray[0]);
                  sunCloseMin = int.parse(closeHourArray[1]);
                }
              }
            }
            //Split Date and Time
            if (orderDateAndTime != null &&
                orderDateAndTime != '' &&
                orderDateAndTime.contains(' ')) {
              final List<String>? orderDateAndTimeArray =
              orderDateAndTime.split(' ');
              final String orderDays = orderDateAndTimeArray![0];
              final List<String> ordererDayArray = orderDays.split(',');
              days = ordererDayArray[0];


              // ignore: unnecessary_null_comparison
              if (orderDateAndTimeArray != null &&
                  orderDateAndTimeArray.length > 4 &&
                  // orderDateAndTimeArray[3] != null &&
                  orderDateAndTimeArray[4] != '' &&
                  orderDateAndTimeArray[4].contains(':')) {
                final List<String>? orderTimeArray =
                orderDateAndTimeArray[4].split(':');

                if (orderTimeArray != null &&
                    orderTimeArray.isNotEmpty &&
                    // orderTimeArray[0] != null &&
                    orderTimeArray[0] != '' &&
                    // orderTimeArray[1] != null &&
                    orderTimeArray[1] != '') {
                  hour = int.parse(orderTimeArray[0]);
                  minute = int.parse(orderTimeArray[1]);

                  // if (orderDateAndTimeArray[4] == 'PM'){
                  //   hour += 12;
                  // }
                  // final String pm = orderDateAndTimeArray[4];
                  // print(pm);
                }
              }
            }
            if (days == 'Mon') {
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isMondayOpen ==
                  PsConst.ONE) {
                if (((hour! > monOpenHour!) ||
                    (hour == monOpenHour && minute! >= monOpenMin!)) &&
                    ((hour! < monCloseHour!) ||
                        (hour == monCloseHour && minute! <= monCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isTuesdayOpen ==
                  PsConst.ONE) {
                if (((hour! > tuesOpenHour!) ||
                    (hour == tuesOpenHour && minute! >= tuesOpenMin!)) &&
                    ((hour! < tuesCloseHour!) ||
                        (hour == tuesCloseHour && minute! <= tuesCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isWednesdayOpen ==
                  PsConst.ONE) {
                if (((hour! > wedOpenHour!) ||
                    (hour == wedOpenHour && minute! >= wedOpenMin!)) &&
                    ((hour! < wedCloseHour!) ||
                        (hour == wedCloseHour && minute! <= wedCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isThursdayOpen ==
                  PsConst.ONE) {
                if (((hour! > thursOpenHour!) ||
                    (hour == thursOpenHour && minute! >= thursOpenMin!)) &&
                    ((hour! < thursCloseHour!) ||
                        (hour == thursCloseHour &&
                            minute! <= thursCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isFridayOpen ==
                  PsConst.ONE) {
                if (((hour! > friOpenHour!) ||
                    (hour == friOpenHour && minute! >= friOpenMin!)) &&
                    ((hour! < friCloseHour!) ||
                        (hour == friCloseHour && minute! <= friCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isSaturdayOpen ==
                  PsConst.ONE) {
                if (((hour! > satOpenHour!) ||
                    (hour == satOpenHour && minute! >= satOpenMin!)) &&
                    ((hour! < satCloseHour!) ||
                        (hour == satCloseHour && minute! <= satCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
              if (shopInfoProvider!
                  .shopInfo.data!.shopSchedules!.isSaturdayOpen ==
                  PsConst.ONE) {
                if (((hour! > satOpenHour!) ||
                    (hour == satOpenHour && minute! >= satOpenMin!)) &&
                    ((hour! < satCloseHour!) ||
                        (hour == satCloseHour && minute! <= satCloseMin!))) {
                  if (!await checkout1ViewState
                      .checkIsDataChange(userProvider)) {
                    isApiSuccess = await checkout1ViewState
                        .callUpdateUserProfile(context, userProvider, provider);
                    //chang checkout1 data
                    if (isApiSuccess) {
                      viewNo++;
                    } else {
                      //not chang checkout1 data
                      //viewNo++;
                    }
                  }
                } else {
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
        }
      }else {

          if (!await checkout1ViewState.checkIsDataChange(userProvider)) {
            isApiSuccess =
                await checkout1ViewState.callUpdateUserProfile(context, userProvider, provider);
            //chang checkout1 data
            if (isApiSuccess) {
              viewNo++;
            }
          } else {
            //not chang checkout1 data
            //viewNo++;
          }
        }
      }
    //else if
    else {
        viewNo++;
      }
      setState(() {});
      
    //? Remove comment for Schedule Order
    // }
  }

  dynamic checkHideOrShowBackArrow() {
    if (viewNo == 1) {
      return const Text('');
    } else {
      return GestureDetector(
        child:
        Container(
            height: 50,
            margin: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25), // Set border radius for rounded corners
              border: Border.all(
                color: PsColors.white, // Set border color
                width: 2, // Set border width
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.only(
                  right: PsDimens.space10,
                  left: PsDimens.space10,
                ),
                child:
                Row(
                children: <Widget>[
                  /*Icon(
                      Icons.arrow_back_ios,
                      color: PsColors.white,
                      size: PsDimens.space16,
                    ),
                  const SizedBox(
                    width: 3,
                  ),*/
                  Container(
                    child: Text(
                        Utils.getString(context, 'checkout_container__back'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: PsColors.white)),

                  ),
                ],
              )
            ),


        ),
        onTap: () {
          goToBackViewCheck();
        },
      );
    }
  }

  void goToBackViewCheck() {
    if (viewNo < maxViewNo) {
      viewNo--;

      setState(() {});
    }
  }
}

class _TopImageForCheckout extends StatelessWidget {
  const _TopImageForCheckout({Key? key, this.viewNo, this.onTap})
      : super(key: key);

  final int? viewNo;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    StatelessWidget checkSecondCircle() {
      return Icon(
        viewNo == 3 ? FontAwesome5.check_circle : Icons.circle_outlined,
        size: PsDimens.space28,
        color: viewNo != 1 ? PsColors.mainColor : PsColors.grey,
      );
    }

    StatelessWidget checkFirstCircle() {
      return Icon(
        viewNo == 1 ? Icons.circle_outlined : FontAwesome5.check_circle,
        size: PsDimens.space28,
        color: PsColors.mainColor,
      );
    }

    StatelessWidget checkThirdCircle() {
      return Icon(
        Icons.circle_outlined,
        size: PsDimens.space28,
        color: viewNo == 3 ? PsColors.mainColor : PsColors.grey,
      );
    }

    if (viewNo == 4) {
      return Container();
    } else {
      return Container(
        color: PsColors.mainColor,
        child:  Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 2),
                  alignment: Alignment.center,
                  width: double.infinity,
                  child:Text(Utils.getString(context, 'checkout_container__checkout'),
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white
                      )),
                  color: PsColors.mainColor,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: PsColors.coreBackgroundColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: viewNo! > 1 ? PsColors.mainColor : PsColors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border:  Border.all(
                                color: viewNo! >= 1 ? PsColors.mainColor : PsColors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              Utils.getString(context, 'checkout_container__address'),
                              style: viewNo! > 1
                                  ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: PsColors.white,)
                                  : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: PsColors.mainColor,
                              ),
                            ),
                          ),

                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Image.asset(
                            'assets/images/right_arrow.png',
                            height: 45,
                          ),
                        ),
                      ),

                      Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: viewNo! > 2 ? PsColors.mainColor : PsColors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border:  Border.all(
                                color: viewNo! >= 2 ? PsColors.mainColor : PsColors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              Utils.getString(context, 'checkout_container__confirm'),
                              style: viewNo! > 2
                                  ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: PsColors.white,)
                                  : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: PsColors.mainColor,
                              ),
                            ),
                          ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Image.asset(
                            'assets/images/right_arrow.png',
                            height: 45,
                          ),
                        ),
                      ),
                      Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: viewNo! > 3 ? PsColors.mainColor : PsColors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border:  Border.all(
                                  color: viewNo! >= 3 ? PsColors.mainColor : PsColors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                Utils.getString(context, 'checkout_container__payment'),
                                style: viewNo! > 3
                                    ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: PsColors.white,)
                                    : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: PsColors.mainColor,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: PsDimens.space28, left: PsDimens.space2),
             /* padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),*/
              child: IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: PsDimens.space24,
                  color: Colors.white,
                ),
                onPressed: onTap as void Function()?,
              ),
            )
            ,
          ],
        ),
      );
    }
  }
}
