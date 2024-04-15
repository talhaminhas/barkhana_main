import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../api/common/ps_resource.dart';
import '../../../config/ps_colors.dart';
import '../../../constant/ps_constants.dart';
import '../../../constant/ps_dimens.dart';
import '../../../constant/route_paths.dart';
import '../../../provider/delivery_cost/delivery_cost_provider.dart';
import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../provider/user/user_provider.dart';
import '../../../utils/ps_progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/basket.dart';
import '../../../viewobject/common/ps_value_holder.dart';
import '../../../viewobject/delivery_cost.dart';
import '../../../viewobject/holder/delivery_cost_parameter_holder.dart';
import '../../../viewobject/holder/order_location_callback_holder.dart';
import '../../../viewobject/holder/profile_update_view_holder.dart';
import '../../../viewobject/shipping_area.dart';
import '../../../viewobject/user.dart';
import '../../common/dialog/error_dialog.dart';
import '../../common/dialog/success_dialog.dart';
import '../../common/ps_button_widget.dart';
import '../../common/ps_dropdown_base_with_controller_widget.dart';
import '../../map/current_location_view.dart';

class DeliveryLocationView extends StatefulWidget {
  const DeliveryLocationView({
    Key? key,
    required this.address,
    required this.basketList,
    required this.deliveryCostProvider,
    required this.userProvider,
    required this.shopInfoProvider,
  }) : super(key: key);

  final String address;
  final List<Basket> basketList;
  final DeliveryCostProvider deliveryCostProvider;
  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;

  @override
  @override
  __DeliveryLocationViewState createState() => __DeliveryLocationViewState();
}

class __DeliveryLocationViewState extends State<DeliveryLocationView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController addressController = TextEditingController();
  TextEditingController costPerChargesController = TextEditingController();
  TextEditingController totalCostController = TextEditingController();
  TextEditingController shippingAreaController = TextEditingController();
  PsValueHolder? psValueHolder;
  bool bindDataFirstTime = true;
  bool callDeliveryCost = true;
  LatLng? latLng;
  bool isApiSuccess = false;
  bool? isDelivery, isPickup;

  dynamic updateDeliveryClick() {
    setState(() {});
    if (widget.userProvider.isClickDeliveryButton) {
      widget.userProvider.isClickDeliveryButton = false;
      widget.userProvider.isClickPickUpButton = true;
    } else {
      widget.userProvider.isClickDeliveryButton = true;
      widget.userProvider.isClickPickUpButton = false;
    }
  }
  dynamic resetDeliveryMethod(){
    widget.userProvider.isClickDeliveryButton = isDelivery!;
    widget.userProvider.isClickPickUpButton = isPickup!;
    setState(() {});
  }

  dynamic updatePickUpClick() {
    setState(() {});
    if (widget.userProvider.isClickPickUpButton) {
      widget.userProvider.isClickPickUpButton = false;
      widget.userProvider.isClickDeliveryButton = true;
    } else {
      widget.userProvider.isClickPickUpButton = true;
      widget.userProvider.isClickDeliveryButton = false;
    }
  }

  dynamic deliveryCostCalculate(DeliveryCostProvider provider,
      List<Basket> basketList, String lat, String lng) async {
    if (await Utils.checkInternetConnectivity()) {
      final DeliveryCostParameterHolder deliveryCostParameterHolder =
          DeliveryCostParameterHolder(
              userLat: lat,
              userLng: lng,
              productId: widget.basketList[0].product!.id!);

      await PsProgressDialog.showDialog(context);

      final PsResource<DeliveryCost> _apiStatus =
          await provider.postDeliveryCost(deliveryCostParameterHolder.toMap());

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();
        costPerChargesController.text = _apiStatus.data!.costPerCharges!;
        totalCostController.text = _apiStatus.data!.totalCost!;
        setState(() {});
      } else {
        PsProgressDialog.dismissDialog();
        costPerChargesController.text = '0';
        totalCostController.text = '0';
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

  dynamic checkIsDataChange(UserProvider userProvider) async {
    if (
        // userProvider.user.data.userEmail == userEmailController.text &&
        // userProvider.user.data.userPhone == userPhoneController.text &&
        userProvider.user.data?.address == addressController.text &&
            userProvider.user.data?.area!.areaName ==
                shippingAreaController.text &&
            userProvider.user.data?.userLat == userProvider.originalUserLat &&
            userProvider.user.data?.userLng == userProvider.originalUserLng) {
      return true;
    } else {
      return false;
    }
  }

  dynamic callUpdateUserProfile(UserProvider userProvider) async {
    bool isSuccess = false;

    if (userProvider.isClickPickUpButton && userProvider.selectedArea != null) {
      userProvider.selectedArea!.id = '';
      userProvider.selectedArea!.price = '0.0';
      userProvider.selectedArea!.areaName = '';
    }

    if (await Utils.checkInternetConnectivity()) {
      final ProfileUpdateParameterHolder profileUpdateParameterHolder =
          ProfileUpdateParameterHolder(
        userId: userProvider.psValueHolder.loginUserId!,
        userName: userProvider.user.data!.userName!,
        userEmail: userProvider.user.data!.userEmail!,
        userPhone: userProvider.user.data!.userPhone!,
        userAddress: addressController.text,
        userAboutMe: userProvider.user.data!.userAboutMe!,
        userAreaId: userProvider.selectedArea!.id!,
        userLat: userProvider.user.data!.userLat!,
        userLng: userProvider.user.data!.userLng!,
            userPostcode: userProvider.user.data!.userPostcode!,
            userCountry: userProvider.user.data!.userCountry!,
            userCity: userProvider.user.data!.userCity!
      );
      await PsProgressDialog.showDialog(context);
      final PsResource<User> _apiStatus = await userProvider
          .postProfileUpdate(profileUpdateParameterHolder.toMap());
      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();
        isSuccess = true;

        showDialog<dynamic>(
            context: context,
            builder: (BuildContext contet) {
              return SuccessDialog(
                message: Utils.getString(context, 'edit_profile__success'),
              );
            });
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
  @override
  void initState() {
    super.initState();
    isDelivery = widget.userProvider.isClickDeliveryButton;
    isPickup = widget.userProvider.isClickPickUpButton;
  }

  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);

    if (callDeliveryCost) {
      if (widget.shopInfoProvider.shopInfo.data != null &&
          widget.shopInfoProvider.shopInfo.data?.isArea != null &&
          widget.userProvider.user.data != null) {
        if (widget.shopInfoProvider.shopInfo.data?.isArea == PsConst.ZERO) {
          deliveryCostCalculate(
            widget.deliveryCostProvider,
            widget.basketList,
            widget.userProvider
                .getUserLatLng(psValueHolder!)
                .latitude
                .toString(),
            widget.userProvider
                .getUserLatLng(psValueHolder!)
                .longitude
                .toString(),
          );
          callDeliveryCost = false;
        }
      } else {
        return Container();
      }
    }
    if (widget.userProvider.user.data != null) {
      if (bindDataFirstTime) {
        /// Shipping Data
        addressController.text = widget.address;
        shippingAreaController.text =
            widget.userProvider.user.data!.area!.areaName! +
                ' (' +
                widget.userProvider.user.data!.area!.currencySymbol! +
                widget.userProvider.user.data!.area!.price! +
                ')';
        widget.userProvider.selectedArea = widget.userProvider.user.data!.area;
        latLng = widget.userProvider.getUserLatLng(psValueHolder!);
        if (widget.userProvider.isClickWeeklyButton) {
          widget.userProvider.isClickDeliveryButton = true;
          widget.userProvider.isClickPickUpButton = false;
        }
        bindDataFirstTime = false;
      }
      return WillPopScope(
        onWillPop: ()async{
          resetDeliveryMethod();
          return true;
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: PsColors.coreBackgroundColor,
          appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Utils.getBrightnessForAppBar(context)),
              iconTheme: Theme.of(context).iconTheme.copyWith(),
              title: Text(
                '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              elevation: 0,
              actions: <Widget>[
                InkWell(
                  child: Ink(
                    child: Center(
                      child: Text(
                        Utils.getString(context, 'checkout_one_page__done'),
                        textAlign: TextAlign.justify,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            !.copyWith(fontWeight: FontWeight.bold)
                            .copyWith(color: PsColors.mainColor),
                      ),
                    ),
                  ),
                  onTap: () async {
                    if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                            PsConst.ONE &&
                        (widget.userProvider.selectedArea == null ||
                            widget.userProvider.selectedArea?.id == null ||
                            widget.userProvider.selectedArea?.id == '') &&
                        widget.userProvider.isClickDeliveryButton) {
                      showDialog<dynamic>(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorDialog(
                              message: Utils.getString(
                                  context, 'warning_dialog__select_area'),
                            );
                          });
                    } else if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                            PsConst.ZERO &&
                        costPerChargesController.text == '0' &&
                        widget.userProvider.isClickDeliveryButton) {
                      showDialog<dynamic>(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorDialog(
                              message:
                                  Utils.getString(context, 'error_dialog__order'),
                            );
                          });
                    } else {
                      Navigator.pop(
                          context,
                          OrderLocationCallBackHolder(
                              address: addressController.text,
                              shippingArea: widget.userProvider.selectedArea!));
                    }
                  },
                ),
                const SizedBox(
                  width: PsDimens.space16,
                ),
              ]),
          body: SingleChildScrollView(
              child: Container(
            color: PsColors.coreBackgroundColor,
            padding: const EdgeInsets.only(
                left: PsDimens.space16, right: PsDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: PsDimens.space8,
                ),
                Text(
                  'Delivery Method',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: PsDimens.space8,
                ),
                  _EditAndDeleteButtonWidget(
                      userProvider: widget.userProvider,
                      shopInfoProvider: widget.shopInfoProvider,
                      updateDeliveryClick: updateDeliveryClick,
                      updatePickUpClick: updatePickUpClick,
                      isClickDeliveryButton:
                          widget.userProvider.isClickDeliveryButton,
                      isClickPickUpButton:
                          widget.userProvider.isClickPickUpButton),
                const SizedBox(height: PsDimens.space8),
                if (widget.userProvider.isClickDeliveryButton)
                  Column(
                    children: <Widget>[
                      CurrentLocationWidget(
                          provider: widget.deliveryCostProvider,
                          shopInfoProvider: widget.shopInfoProvider,
                          userProvider: widget.userProvider,
                          basketList: widget.basketList,
                          androidFusedLocation: true,
                          textEditingController: addressController,
                          deliveryCostCalculate: deliveryCostCalculate,
                          valueHolder: psValueHolder!),
                      Container(
                          width: double.infinity,
                          height: PsDimens.space120,
                          margin: const EdgeInsets.fromLTRB(PsDimens.space8, 0,
                              PsDimens.space8, PsDimens.space16),
                          decoration: BoxDecoration(
                            color: PsColors.backgroundColor,
                            borderRadius: BorderRadius.circular(PsDimens.space4),
                            border: Border.all(color: PsColors.mainDividerColor),
                          ),
                          child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: addressController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  left: PsDimens.space12,
                                  bottom: PsDimens.space8,
                                  top: PsDimens.space10,
                                ),
                                border: InputBorder.none,
                                hintText: Utils.getString(
                                    context, 'edit_profile__address'),
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    !.copyWith(
                                        color: PsColors.textPrimaryLightColor),
                              ))),
                      if (widget.shopInfoProvider.shopInfo.data?.isArea != null &&
                          widget.shopInfoProvider.shopInfo.data?.isArea ==
                              PsConst.ONE)
                        PsDropdownBaseWithControllerWidget(
                            title: Utils.getString(context, 'checkout1__area'),
                            textEditingController: shippingAreaController,
                            isMandatory: true,
                            onTap: () async {
                              final dynamic result = await Navigator.pushNamed(
                                  context, RoutePaths.areaList);
      
                              if (result != null && result is ShippingArea) {
                                setState(() {
                                  shippingAreaController.text = result.areaName! +
                                      ' (' +
                                      result.currencySymbol! +
                                      ' ' +
                                      result.price! +
                                      ')';
                                  widget.userProvider.selectedArea = result;
                                });
                              }
                            }),
                      if (widget.shopInfoProvider.shopInfo.data?.isArea ==
                          PsConst.ZERO)
                        if (widget.deliveryCostProvider.deliveryCost.data != null)
                          _DeliveryCostWidget(
                              provider: widget.deliveryCostProvider,
                              basketList: widget.basketList)
                        else
                          _DefaultDeliveryCostWidget(),
                    ],
                  )
                else
                  Container(),
              ],
            ),
          )),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _EditAndDeleteButtonWidget extends StatefulWidget {
  const _EditAndDeleteButtonWidget(
      {Key? key,
      required this.userProvider,
      required this.shopInfoProvider,
      required this.isClickPickUpButton,
      required this.isClickDeliveryButton,
      required this.updateDeliveryClick,
      required this.updatePickUpClick})
      : super(key: key);

  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  final bool isClickDeliveryButton;
  final bool isClickPickUpButton;
  final Function updateDeliveryClick;
  final Function updatePickUpClick;
  @override
  __EditAndDeleteButtonWidgetState createState() =>
      __EditAndDeleteButtonWidgetState();
}

class __EditAndDeleteButtonWidgetState
    extends State<_EditAndDeleteButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: PsDimens.space12),
          SizedBox(
            width: double.infinity,
            height: PsDimens.space40,
            child: Container(
              decoration: BoxDecoration(
                color: PsColors.backgroundColor,
                border: Border.all(color: PsColors.backgroundColor),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(PsDimens.space12),
                    topRight: Radius.circular(PsDimens.space12)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: PsColors.backgroundColor,
                    blurRadius: 10.0, // has the effect of softening the shadow
                    spreadRadius: 0, // has the effect of extending the shadow
                    offset: const Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: PSButtonWidget(
                      hasShadow: true,
                      hasShape: false,
                      textColor: widget.isClickDeliveryButton
                          ? PsColors.white
                          : PsColors.black,
                      width: double.infinity,
                      colorData: widget.isClickDeliveryButton
                          ? PsColors.mainColor
                          : PsColors.white,
                      titleText:
                          Utils.getString(context, 'checkout1__delivery'),
                      onPressed: () async {
                        if (widget
                                .shopInfoProvider.shopInfo.data?.pickupEnabled ==
                            '1') {
                          widget.updateDeliveryClick();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: PsDimens.space10,
                  ),
                  if (widget.shopInfoProvider.shopInfo.data?.pickupEnabled ==
                      '1')
                    Expanded(
                      child: PSButtonWidget(
                        hasShadow: true,
                        hasShape: false,
                        width: double.infinity,
                        textColor: widget.isClickPickUpButton
                            ? PsColors.white
                            : PsColors.black,
                        colorData: widget.isClickPickUpButton
                            ? PsColors.mainColor
                            : PsColors.white,
                        titleText:
                            Utils.getString(context, 'checkout1__pick_up'),
                        onPressed: () async {
                          widget.updatePickUpClick();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCostWidget extends StatelessWidget {
  const _DeliveryCostWidget({
    Key? key,
    required this.provider,
    required this.basketList,
  }) : super(key: key);

  final DeliveryCostProvider provider;
  final List<Basket> basketList;

  @override
  Widget build(BuildContext context) {
    String? currencySymbol;

    if (basketList.isNotEmpty) {
      currencySymbol = basketList[0].product!.currencySymbol!;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: PsDimens.space16,
              left: PsDimens.space16,
              right: PsDimens.space16,
              bottom: PsDimens.space32),
          child: Text(
            Utils.getString(context, 'checkout__order_delivery'),
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (provider.deliveryCost.data?.distance != null &&
            provider.deliveryCost.data?.distance != '')
          _DeliveryTextWidget(
            deliveryInfoText:
                '${provider.deliveryCost.data!.distance} ${provider.deliveryCost.data!.unit}',
            title:
                '${Utils.getString(context, 'checkout__delivery_distance')} :',
          ),
        _DeliveryTextWidget(
          deliveryInfoText:
              '$currencySymbol ${provider.deliveryCost.data!.costPerCharges}',
          title:
              '${Utils.getString(context, 'checkout__delivery_cost_per_mile')} :',
        ),
        _DeliveryTextWidget(
          deliveryInfoText:
              '$currencySymbol ${provider.deliveryCost.data!.totalCost}',
          title:
              '${Utils.getString(context, 'checkout__delivery_total_cost')} :',
        )
      ],
    );
  }
}

class _DefaultDeliveryCostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: PsDimens.space16,
              left: PsDimens.space16,
              right: PsDimens.space16,
              bottom: PsDimens.space12),
          child: Text(
            Utils.getString(context, 'checkout__order_delivery'),
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _DeliveryTextWidget(
          deliveryInfoText: '0',
          title: '${Utils.getString(context, 'checkout__delivery_distance')} :',
        ),
        _DeliveryTextWidget(
          deliveryInfoText: '0',
          title:
              '${Utils.getString(context, 'checkout__delivery_cost_per_mile')} :',
        ),
        _DeliveryTextWidget(
          deliveryInfoText: '0',
          title:
              '${Utils.getString(context, 'checkout__delivery_total_cost')} :',
        )
      ],
    );
  }
}

class _DeliveryTextWidget extends StatelessWidget {
  const _DeliveryTextWidget({
    Key? key,
    this.deliveryInfoText,
    this.title,
  }) : super(key: key);

  final String? deliveryInfoText;
  final String? title;

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
                .bodyMedium
                !.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            deliveryInfoText ?? '-',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                !.copyWith(fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}
