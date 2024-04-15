import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/coupon_discount/coupon_discount_provider.dart';
import 'package:flutterrestaurant/provider/delivery_cost/delivery_cost_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/coupon_discount_repository.dart';
import 'package:flutterrestaurant/repository/transaction_header_repository.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/success_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_textfield_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/coupon_discount.dart';
import 'package:flutterrestaurant/viewobject/holder/coupon_discount_holder.dart';
import 'package:provider/provider.dart';

import '../../constant/route_paths.dart';
import '../../provider/transaction/transaction_header_provider.dart';
import '../../repository/token_repository.dart';
import '../../utils/ps_progress_dialog.dart';
import '../../viewobject/holder/globalTokenPost.dart';
import '../../viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import '../../viewobject/holder/intent_holder/privacy_policy_intent_holder.dart';
import '../../viewobject/transaction_header.dart';

class Checkout2View extends StatefulWidget {
  const Checkout2View({
    Key? key,
    required this.updateCheckout2ViewState,
    required this.basketList,
    required this.shopInfoProvider,
    required this.publishKey,
    required this.deliveryPickUpDate,
    required this.deliveryPickUpTime,
    required this.customerMessageController
  }) : super(key: key);

  final String deliveryPickUpDate;
  final String deliveryPickUpTime;
  final Function updateCheckout2ViewState;
  final List<Basket> basketList;
  final ShopInfoProvider shopInfoProvider;
  final String publishKey;
  final TextEditingController customerMessageController;
  @override
  _Checkout2ViewState createState() {
    final _Checkout2ViewState _state = _Checkout2ViewState();
    updateCheckout2ViewState(_state);
    return _state;
  }
}

class _Checkout2ViewState extends State<Checkout2View> {
  final TextEditingController couponController = TextEditingController();

  CouponDiscountRepository? couponDiscountRepo;
  TransactionHeaderRepository? transactionHeaderRepo;
  BasketRepository ?basketRepository;
  UserRepository? userRepository;
  PsValueHolder? valueHolder;
  CouponDiscountProvider? couponDiscountProvider;
  UserProvider? userProvider;
  DeliveryCostProvider? provider;
  ShopInfoProvider? shopInfoProvider;
  bool isCheckBoxSelect = false;
  void updateCheckBox() {
    if (isCheckBoxSelect) {
      isCheckBoxSelect = false;
    } else {
      isCheckBoxSelect = true;
    }
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


        print(basketProvider.checkoutCalculationHelper.tax.toString());
        final PsResource<TransactionHeader> _apiStatus =
        await transactionSubmitProvider.postTransactionSubmit(
            userLoginProvider.user.data!,
            widget.basketList,
            '',
            couponDiscountProvider!.couponDiscount.toString(),
            '',//basketProvider.checkoutCalculationHelper.tax.toString(),
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
            PsConst.ZERO,//isClickPickUpButton == true ? PsConst.ONE : PsConst.ZERO,
            widget.deliveryPickUpDate,
            widget.deliveryPickUpTime,
            basketProvider.checkoutCalculationHelper.shippingCost
                .toString(),
            userLoginProvider.user.data!.area!.areaName!,
            ''/*memoController.text*/,
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

  @override
  Widget build(BuildContext context) {
    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);

    valueHolder = Provider.of<PsValueHolder>(context);
    userRepository = Provider.of<UserRepository>(context);
    shopInfoProvider = Provider.of<ShopInfoProvider>(context, listen: false);

    return Consumer<UserProvider>(builder:
        (BuildContext context, UserProvider userProvider, Widget? child) {
      couponDiscountProvider = Provider.of<CouponDiscountProvider>(context,
          listen: false); // Listen : False is important.
      userProvider = Provider.of<UserProvider>(context,
          listen: false);// Listen : False is important.
      provider = Provider.of<DeliveryCostProvider>(context, listen: false); 
      couponController.text = couponDiscountProvider!.couponCode;
      final BasketProvider basketProvider =
          Provider.of<BasketProvider>(context);
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              padding: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: PsDimens.space10,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: PsTextFieldWidget(
                        hintText:
                            Utils.getString(context, 'checkout__coupon_code'),
                        textEditingController: couponController,
                        isReadonly: couponDiscountProvider!.couponDiscount != '0.0',
                        showTitle: false,
                      )),
                      Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: PsDimens.space8),
                        child: PSButtonWidget(
                          titleText: couponDiscountProvider!.couponDiscount == '0.0' ?
                          Utils.getString(
                              context, 'checkout__claim_button_name') :
                          'Remove',
                          colorData: couponDiscountProvider!.couponDiscount == '0.0' ?
                              PsColors.mainColor : PsColors.discountColor
                          ,
                          onPressed: () async {
                            if (couponController.text.isNotEmpty) {
                              if(couponDiscountProvider!.couponDiscount != '0.0')
                                {
                                  setState(() {
                                    couponDiscountProvider!.couponDiscount = '0.0';
                                    couponDiscountProvider!.couponCode = '';
                                  });
                                  showDialog<dynamic>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const SuccessDialog(
                                          message: 'Coupon removed successfully.',
                                        );
                                      });
                                  return;
                                }
                              final CouponDiscountParameterHolder
                                  couponDiscountParameterHolder =
                                  CouponDiscountParameterHolder(
                                couponCode: couponController.text,
                              );
                              couponDiscountProvider!.couponCode = couponController.text;
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

                                if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data!.couponAmount!,
                                          psValueHolder: valueHolder!,
                                          shippingPriceStringFormatting:
                                              userProvider.selectedArea!.price!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .deliFeeByDistance == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
                                      shippingPriceStringFormatting:
                                          provider!.deliveryCost.data!.totalCost!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .fixedDelivery == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
                                      shippingPriceStringFormatting:
                                          provider!.deliveryCost.data!.totalCost!);
                                } else if (shopInfoProvider!.shopInfo.data!
                                        .isArea == PsConst.ZERO && 
                                      shopInfoProvider!.shopInfo.data!
                                        .freeDelivery == PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                      basketList: widget.basketList,
                                      couponDiscountString:
                                          _apiStatus.data!.couponAmount!,
                                      psValueHolder: valueHolder!,
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

                                //couponController.clear();
                                setState(() {
                                  couponDiscountProvider!.couponDiscount =
                                      _apiStatus.data!.couponAmount!;
                                });
                              } else {
                                showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        message: _apiStatus.message != '' ? _apiStatus.message
                                        : 'Please Enter A Valid Coupon.',
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
                  Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space16, right: PsDimens.space16),
                    child: Text(
                        'If you have any redeemable code, please use it here.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(
                    height: PsDimens.space10,
                  ),

                ],
              ),
            ),

            _OrderSummaryWidget(
              psValueHolder: valueHolder!,
              basketList: widget.basketList,
              couponDiscount: couponDiscountProvider!.couponDiscount ,
              basketProvider: basketProvider,
              userProvider: userProvider,
              shopInfoProvider: widget.shopInfoProvider,
            ),
            Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              padding: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
              ),
              child: PsTextFieldWidget(
                titleText: 'Kitchen Instructions',
                textAboutMe: false,
                height: PsDimens.space140,
                hintText: 'For Example: Remove Salad, Extra Sauce, etc.',
                //onChanged: checkFields,
                textEditingController: widget.customerMessageController
              ),
            ),
        Container(
          color: PsColors.backgroundColor,
          margin: const EdgeInsets.only(top: PsDimens.space8),
          padding: const EdgeInsets.only(
            left: PsDimens.space12,
            right: PsDimens.space12,
          ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Text.rich(
                      TextSpan(
                        text: Utils.getString(context, 'checkout2__agree_policy'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'terms/conditions', // The word you want to make tappable
                            style: const TextStyle(
                              color: Colors.blue, // Customize the link text color
                              decoration: TextDecoration.underline, // Add underline for the link
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Add your navigation logic here
                                Navigator.pushNamed(context, RoutePaths.termsAndRefund,
                                    arguments: PrivacyPolicyIntentHolder(
                                        title: Utils.getString(context, 'terms_and_condition__toolbar_name'),
                                        description: PsConst.TERMS_FLAG
                                    ));
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'refund policy.', // The word you want to make tappable
                            style: const TextStyle(
                              color: Colors.blue, // Customize the link text color
                              decoration: TextDecoration.underline, // Add underline for the link
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Add your navigation logic here
                                Navigator.pushNamed(context, RoutePaths.termsAndRefund,
                                    arguments: PrivacyPolicyIntentHolder(
                                        title: Utils.getString(context, 'refund_policy__toolbar_name'),
                                        description: PsConst.REFUND_FLAG
                                    ));
                              },
                          ),
                        ],
                      ),
                      maxLines: 2,
                    ),/*
                    onTap: () {
                      setState(() {
                        updateCheckBox();
                      });
                    },*/
                  ),
                ),
              ],
            ),
        ),
          ],
        ),
      );
    });
  }
}

class _OrderSummaryWidget extends StatelessWidget {
  const _OrderSummaryWidget({
    Key? key,
    required this.basketList,
    required this.couponDiscount,
    required this.psValueHolder,
    required this.basketProvider,
    required this.userProvider,
    required this.shopInfoProvider,
  }) : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final BasketProvider basketProvider;
  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  @override
  Widget build(BuildContext context) {
     final DeliveryCostProvider provider = Provider.of<DeliveryCostProvider>(
            context, listen: false);
    String? currencySymbol;

    if (basketList.isNotEmpty) {
      currencySymbol = basketList[0].product!.currencySymbol!;
    }
    if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ONE) {
       basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: userProvider.selectedArea!.price == ''
            ? '0.0'
            : userProvider.selectedArea!.price!);
    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .deliFeeByDistance == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: provider.deliveryCost.data!.totalCost!);
    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .fixedDelivery == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: provider.deliveryCost.data!.totalCost!);

    } else if (shopInfoProvider.shopInfo.data!
          .isArea == PsConst.ZERO &&
        shopInfoProvider.shopInfo.data!
          .freeDelivery == PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
        basketList: basketList,
        couponDiscountString: couponDiscount,
        psValueHolder: psValueHolder,
        shippingPriceStringFormatting: '0.0');
    }

    const Widget _dividerWidget = Divider(
      height: PsDimens.space2,
    );

    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space12,
    );

    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Utils.getString(context, 'checkout__order_summary'),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText: basketProvider
                  .checkoutCalculationHelper.totalItemCount
                  .toString(),
              title:
                  '${Utils.getString(context, 'checkout__total_item_count')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '${basketList[0].product!.currencySymbol}${basketProvider.checkoutCalculationHelper.totalOriginalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__total_item_price')} :',
            ),
            if(basketProvider.checkoutCalculationHelper.totalDiscountFormattedString != '0.00')
            _OrderSummeryTextWidget(
              transationInfoText:
                  '- $currencySymbol${basketProvider.checkoutCalculationHelper.totalDiscountFormattedString}',
              title: '${Utils.getString(context, 'checkout__discount')} :',
            ),
            if(couponDiscount != '0.0')
            _OrderSummeryTextWidget(
              transationInfoText:
              '- $currencySymbol${basketProvider.checkoutCalculationHelper.couponDiscountFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__coupon_discount')} :',
            ),
            if (provider.deliveryCost.data != null &&
                provider.deliveryCost.data!.totalCost != '0.0' /*||
                shopInfoProvider.shopInfo.data!.isArea == PsConst.ONE*/)
            Column(children: [
              _spacingWidget,
              _dividerWidget,
              _OrderSummeryTextWidget(
                transationInfoText: '£' + basketProvider
                    .checkoutCalculationHelper.subTotalPriceFormattedString
                    .toString(),
                title: '${Utils.getString(context, 'checkout__sub_total')} :',
              ),
              if (provider.deliveryCost.data == null ||
                  provider.deliveryCost.data!.totalCost == '0.0' /*||
                shopInfoProvider.shopInfo.data!.isArea == PsConst.ONE*/)
                _OrderSummeryTextWidget(
                  transationInfoText:
                  '+ $currencySymbol${double.parse(userProvider.selectedArea!.price! == '' ? '0.0' : userProvider.selectedArea!.price!)}',
                  title: '${Utils.getString(context, 'checkout__delivery_cost')} :',
                )
              else
                _OrderSummeryTextWidget(
                  transationInfoText:
                  '+ $currencySymbol${double.parse(provider.deliveryCost.data!.totalCost!)}',
                  title: '${Utils.getString(context, 'checkout__delivery_cost')} :',
                ),
            ],),

            _spacingWidget,
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol${basketProvider.checkoutCalculationHelper.totalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'transaction_detail__total')} :',
              textColor: PsColors.discountColor,
            ),
            _spacingWidget,
            _dividerWidget,
          ],
        ));
  }
}

class _OrderSummeryTextWidget extends StatelessWidget {
  const _OrderSummeryTextWidget({
    Key? key,
    required this.transationInfoText,
    this.title,
    this.textColor
  }) : super(key: key);

  final String transationInfoText;
  final String? title;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
          top: PsDimens.space12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(
                color: textColor,
                fontWeight: FontWeight.normal
            ),
          ),
          Text(
            transationInfoText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(
                color: textColor,
                fontWeight: FontWeight.normal
            ),
          )
        ],
      ),
    );
  }
}
