import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/history/history_provider.dart';
import 'package:flutterrestaurant/provider/product/product_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/history_repsitory.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/add_on.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/customized_detail.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ChooseAttributeDialog extends StatefulWidget {
  const ChooseAttributeDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  _LogoutDialogState createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<ChooseAttributeDialog> {

  @override
  Widget build(BuildContext context) {
    return NewDialog(
      widget: widget, 
      product: widget.product);
  }
}

class NewDialog extends StatefulWidget {
  const NewDialog({
    Key? key,
    required this.widget,
    required this.product,
  }) : super(key: key);

  final ChooseAttributeDialog widget;
  final Product product;

   @override
  _NewDialogState createState() => _NewDialogState();
}

class _NewDialogState extends State<NewDialog> {
  
  PsValueHolder? psValueHolder;
  ProductDetailProvider? provider;
  HistoryProvider? historyProvider;
  Map<AddOn, bool> selectedAddOnList = <AddOn, bool>{};
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  double selectedAddOnPrice = 0.0;
  double selectedAttributePrice = 0.0;
  double? totalPrice;
  double? bottomSheetPrice;
  double totalOriginalPrice = 0.0;
  ProductRepository? productRepo;
  BasketProvider? basketProvider;
  BasketRepository? basketRepository;
  HistoryRepository? historyRepo;
  bool isCallFirstTime = true;
  String? colorId = '';
  String? colorValue;
  Basket? basket;
  String? id;
  String? qty;
  List<BasketSelectedAttribute>? holderBasketSelectedAttributeList;
  List<BasketSelectedAddOn>? holderBasketSelectedAddOnList;
  Map<String, CustomizedDetail> selectedcustomizedDetail =
      <String, CustomizedDetail>{};

   Future<void> updateAttributePrice(
        BasketSelectedAttribute basketSelectedAttribute) async {
      // this.totalOriginalPrice = totalOriginalPrice;
      // Get Total Selected Attribute Price
      selectedAttributePrice =
          basketSelectedAttribute.getTotalSelectedAttributePrice();

      // Update Price
      totalPrice =
          double.parse(provider!.productDetail.data!.unitPrice!) +
              selectedAddOnPrice +
              selectedAttributePrice;
      totalOriginalPrice =
          double.parse(provider!.productDetail.data!.originalPrice!) +
              selectedAddOnPrice +
              selectedAttributePrice;
      updateBottomPrice();
    }

    dynamic updateBottomPrice() {
    setState(() {
      bottomSheetPrice = totalPrice;
    });
  }

  dynamic addAttributeAddOnFromView(
      List<BasketSelectedAddOn> holderBasketSelectedAddOnList,
      AddOn addOn,
      Map<AddOn, bool> addOrSubtractFlagList) {
    setState(() {
      if (addOrSubtractFlagList[addOn]!) {
        // add it to use sub or add price
        basketSelectedAddOn.addAddOn(BasketSelectedAddOn(
            id: addOn.id,
            name: addOn.name,
            currencySymbol:
                provider!.productDetail.data!.currencySymbol,
            price: addOn.price));
        //add addOn select data
        //holderBasketSelectedAddOnList ??= <BasketSelectedAddOn>[];
        holderBasketSelectedAddOnList.add(BasketSelectedAddOn(
            id: addOn.id,
            name: addOn.name,
            currencySymbol:
                provider!.productDetail.data!.currencySymbol,
            price: addOn.price));
      } else {
        // add it to use sub or add price
        basketSelectedAddOn.subAddOn(BasketSelectedAddOn(
            id: addOn.id,
            name: addOn.name,
            currencySymbol:
                provider!.productDetail.data!.currencySymbol,
            price: addOn.price));
        //remove addOn select data
        //holderBasketSelectedAddOnList ??= <BasketSelectedAddOn>[];
        holderBasketSelectedAddOnList.remove(BasketSelectedAddOn(
            id: addOn.id,
            name: addOn.name,
            currencySymbol:
                provider!.productDetail.data!.currencySymbol,
            price: addOn.price));
      }

      updateAddOnPrice(basketSelectedAddOn, addOrSubtractFlagList[addOn]!);
    });
  }

  Future<void> updateAddOnPrice(
      BasketSelectedAddOn basketSelectedAddOn, bool addOrSubtractFlag) async {
    // Get Total Selected AddOn Price
    selectedAddOnPrice = basketSelectedAddOn.getTotalSelectedaddOnPrice();

    // Add Price
    totalPrice =
        double.parse(provider!.productDetail.data!.unitPrice!) +
            selectedAddOnPrice +
            selectedAttributePrice;
    totalOriginalPrice =
        double.parse(provider!.productDetail.data!.originalPrice!) +
            selectedAddOnPrice +
            selectedAttributePrice;

    updateBottomPrice();
  }

  dynamic addIntentAddOnPrice(double price) {
    selectedAddOnPrice += price;
  }

  dynamic addIntentAttributePrice(double price) {
    selectedAttributePrice += price;
  }

  Future<void> addToBasketAndBuyClickEvent(bool isBuyButtonType) async {
      if (widget.product.itemColorList!.isNotEmpty &&
          widget.product.itemColorList?[0].id != '') {
        if (colorId == null || colorId == '') {
          await showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
              builder: (BuildContext context) {
                return WarningDialog(
                  message: Utils.getString(
                      context, 'product_detail__please_select_color'),
                  onPressed: () {},
                );
              });
          return;
        }
      }
      id =
          '${widget.product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
      // Check All Attribute is selected
      if (widget.product.customizedHeaderList != null) {
        if (widget.product.customizedHeaderList!.isNotEmpty &&
            widget.product.customizedHeaderList![0].id != '' &&
            widget.product.customizedHeaderList![0].customizedDetail != null &&
            // widget.product.customizedHeaderList[0].customizedDetail[0].id !=
            //     '' &&
            !basketSelectedAttribute.isAllAttributeSelected(
                widget.product.customizedHeaderList!.length)) {
          await showDialog<dynamic>(
              context: context,
              barrierColor: PsColors.transparent,
              builder: (BuildContext context) {
                return WarningDialog(
                  message: Utils.getString(
                      context, 'product_detail__please_choose_customize'),
                  onPressed: () {},
                );
              });
          return;
        }
      }

      basket = Basket(
          id: id,
          productId: widget.product.id,
          qty: qty ?? widget.product.minimumOrder,
          shopId: psValueHolder!.shopId,
          selectedColorId: colorId,
          selectedColorValue: colorValue,
          basketPrice: bottomSheetPrice == null
              ? widget.product.unitPrice
              : bottomSheetPrice.toString(),
          basketOriginalPrice: totalOriginalPrice == 0.0
              ? widget.product.originalPrice
              : totalOriginalPrice.toString(),
          selectedAttributeTotalPrice: basketSelectedAttribute
              .getTotalSelectedAttributePrice()
              .toString(),
          product: widget.product,
          basketSelectedAttributeList:
              basketSelectedAttribute.getSelectedAttributeList(),
          basketSelectedAddOnList:
              basketSelectedAddOn.getSelectedAddOnList());

      await basketProvider!.addBasket(basket!);

      Fluttertoast.showToast(
          msg:
              Utils.getString(context, 'product_detail__success_add_to_basket'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: PsColors.mainColor,
          textColor: PsColors.white);

      if (isBuyButtonType) {
        final dynamic result = await Navigator.pushNamed(
          context,
          RoutePaths.basketList,
        );
        if (result != null && result) {
         provider!
              .loadProduct(widget.product.id!, psValueHolder!.loginUserId!);
        }
      }
    }
  
    dynamic addAttributeFromRadioView(
      List<BasketSelectedAttribute> intentbasketSelectedAttributeList,
      CustomizedDetail customizedDetail) {
    setState(() {
      // Update selected attribute
      basketSelectedAttribute.addAttribute(BasketSelectedAttribute(
          id: customizedDetail.id,
          headerId: customizedDetail.headerId,
          name: customizedDetail.name,
          currencySymbol:
              provider!.productDetail.data!.currencySymbol,
          price: customizedDetail.additionalPrice));
      //add radio select data
      holderBasketSelectedAttributeList ??= <BasketSelectedAttribute>[];
      holderBasketSelectedAttributeList!.add(BasketSelectedAttribute(
          id: customizedDetail.id,
          headerId: customizedDetail.headerId,
          name: customizedDetail.name,
          currencySymbol:
              provider!.productDetail.data!.currencySymbol,
          price: customizedDetail.additionalPrice));

      updateAttributePrice(basketSelectedAttribute);
    });
  }

  @override
  Widget build(BuildContext context) {
    productRepo = Provider.of<ProductRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    historyRepo = Provider.of<HistoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

     final Widget _headerWidget = Container(
        height: PsDimens.space52,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            color: PsColors.mainColor),
        child: Row(
          children: <Widget>[
            const SizedBox(width: PsDimens.space12),
            Icon(
              Icons.add_shopping_cart,
              color: PsColors.white,
            ),
            const SizedBox(width: PsDimens.space8),
            Text(
              Utils.getString(context, 'choose_attribute_dialog__title'),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: PsColors.white,
              ),
            ),
          ],
        ));

      return MultiProvider(
          providers: <SingleChildWidget>[
        ChangeNotifierProvider<ProductDetailProvider>(
          lazy: false,
          create: (BuildContext context) {
            provider = ProductDetailProvider(
                repo: productRepo!, psValueHolder: psValueHolder);

            final String loginUserId = Utils.checkUserLoginId(psValueHolder!);
            provider!.loadProduct(widget.product.id!, loginUserId);

            return provider!;
          },
        ),
        ChangeNotifierProvider<BasketProvider>(
            lazy: false,
            create: (BuildContext context) {
              basketProvider = BasketProvider(repo: basketRepository!);
              return basketProvider!;
          }),
        ChangeNotifierProvider<HistoryProvider>(
            lazy: false,
            create: (BuildContext context) {
              historyProvider = HistoryProvider(repo: historyRepo!);
              return historyProvider!;
            },
          ),
        ],
       child: Consumer<ProductDetailProvider>(
          builder: (BuildContext context, ProductDetailProvider provider,
            Widget? child) {
          return Consumer<BasketProvider>(builder:
            (BuildContext context, BasketProvider basketProvider, Widget? child) {
              if (
                  provider.productDetail.data != null) {
                if (isCallFirstTime) {
                  ///
                  /// Add to History
                  ///
                  historyProvider!.addHistoryList(provider.productDetail.data!);

                  ///
                  /// Load Basket List
                  ///
                  ///
                  basketProvider =
                      Provider.of<BasketProvider>(context, listen: false);

                  basketProvider.loadBasketList();
                  isCallFirstTime = false;
                }
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _headerWidget,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomizeCardView(
                          productDetail: provider.productDetail.data!,
                          addAttributeFromRadioView:
                              addAttributeFromRadioView,
                          intentbasketSelectedAttributeList:
                              holderBasketSelectedAttributeList ??
                                  <BasketSelectedAttribute>[],
                          selectedcustomizedDetail:
                              selectedcustomizedDetail,
                          addIntentAttributePrice:
                              addIntentAttributePrice, psValueHolder: psValueHolder!,),
                      AddOnCardView(
                          productDetail: provider.productDetail.data!,
                          selectedAddOnList: selectedAddOnList,
                          addAttributeAddOnFromView:
                              addAttributeAddOnFromView,
                          holderBasketSelectedAddOnList:
                              holderBasketSelectedAddOnList ??
                                  <BasketSelectedAddOn>[],
                          addIntentAddOnPrice: addIntentAddOnPrice, psValueHolder: psValueHolder!,
                        ),
                      const SizedBox(height: PsDimens.space12),
                      Padding(
                        padding: const EdgeInsets.all(PsDimens.space8),
                          child: PSButtonWithIconWidget(
                            hasShadow: true,
                            colorData: PsColors.grey,
                            icon: Icons.add_shopping_cart,
                            width: double.infinity,
                            titleText: Utils.getString(
                                context, 'product_detail__add_to_basket'),
                             onPressed: () async {
                            if (widget.product.isAvailable == '1') {
                              if (widget.product.customizedHeaderList != null &&
                                  widget.product.customizedHeaderList![0].id !=
                                      '' &&
                                  widget.product.customizedHeaderList![0]
                                          .customizedDetail !=
                                      null &&
                                  widget.product.customizedHeaderList![0]
                                          .customizedDetail![0].id !=
                                      '' &&
                                  !basketSelectedAttribute
                                      .isAllAttributeSelected(widget.product
                                          .customizedHeaderList!.length)) {
                                await showDialog<dynamic>(
                                    context: context,
                                    barrierColor: PsColors.transparent,
                                    builder: (BuildContext context) {
                                      return WarningDialog(
                                        message: Utils.getString(context,
                                            'product_detail__please_choose_customize'),
                                        onPressed: () {},
                                      );
                                    });
                              } else {
                                addToBasketAndBuyClickEvent(false);
                              }
                            } else {
                              showDialog<dynamic>(
                                  context: context,
                                  barrierColor: PsColors.transparent,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                      message: Utils.getString(context,
                                          'product_detail__is_not_available'),
                                      onPressed: () {},
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: PsDimens.space4),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: PsDimens.space8,
                                right: PsDimens.space8,
                                top: PsDimens.space8,
                                bottom: PsDimens.space32),
                              child: PSButtonWithIconWidget(
                                hasShadow: true,
                                icon: Icons.shopping_cart,
                                width: double.infinity,
                                titleText:
                                    Utils.getString(context, 'product_detail__buy'),
                              onPressed: () async {
                                if (widget.product.isAvailable == '1') {
                                  if (widget.product.customizedHeaderList != null &&
                                      widget.product.customizedHeaderList![0].id !=
                                          '' &&
                                      widget.product.customizedHeaderList![0]
                                              .customizedDetail !=
                                          null &&
                                      widget.product.customizedHeaderList![0]
                                              .customizedDetail![0].id !=
                                          '' &&
                                      !basketSelectedAttribute
                                          .isAllAttributeSelected(widget.product
                                              .customizedHeaderList!.length)) {
                                    await showDialog<dynamic>(
                                        context: context,
                                        barrierColor: PsColors.transparent,
                                        builder: (BuildContext context) {
                                          return WarningDialog(
                                            message: Utils.getString(context,
                                                'product_detail__please_choose_customize'),
                                            onPressed: () {},
                                          );
                                        });
                                  } else {
                                    addToBasketAndBuyClickEvent(true);
                                  }
                                } else {
                                  showDialog<dynamic>(
                                      context: context,
                                      barrierColor: PsColors.transparent,
                                      builder: (BuildContext context) {
                                        return WarningDialog(
                                          message: Utils.getString(context,
                                              'product_detail__is_not_available'),
                                          onPressed: () {},
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ));
                 } else {
                  return Container();
                }
            });
          })
      );
  }
}

class CustomizeCardView extends StatefulWidget {
  const CustomizeCardView(
      {Key? key,
      required this.productDetail,
      required this.addAttributeFromRadioView,
      required this.intentbasketSelectedAttributeList,
      required this.selectedcustomizedDetail,
      required this.addIntentAttributePrice,
      required this.psValueHolder,
      })
      : super(key: key);

  final Product productDetail;
  final Function addAttributeFromRadioView;
  final List<BasketSelectedAttribute> intentbasketSelectedAttributeList;
  final Map<String, CustomizedDetail> selectedcustomizedDetail;
  final Function addIntentAttributePrice;
  final PsValueHolder psValueHolder;


  @override
  _CustomizeCardViewState createState() => _CustomizeCardViewState();
}

class _CustomizeCardViewState extends State<CustomizeCardView> {
  dynamic setSelectedData(CustomizedDetail customizedDetail, String headerId) {
    setState(() {
      widget.selectedcustomizedDetail[headerId] = customizedDetail;
      widget.addAttributeFromRadioView(
          widget.intentbasketSelectedAttributeList, customizedDetail);
    });
  }

  List<Widget> createRadioListWidget(
      List<CustomizedDetail> customizedDetailMapList, String headerId) {
    final List<Widget> widgets = <Widget>[];
    for (CustomizedDetail customizedDetail in customizedDetailMapList) {
      widgets.add(
        InkWell(
          onTap: () {
            setSelectedData(customizedDetail, headerId);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Radio<CustomizedDetail>(
                        value: customizedDetail,
                        groupValue: widget.selectedcustomizedDetail[headerId],
                        onChanged: (dynamic customizedDetail) {
                          setSelectedData(customizedDetail, headerId);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: PsColors.mainColor,
                      ),
                      Expanded(
                        child: Text(
                          customizedDetail.name!,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (customizedDetail.additionalPrice == null ||
                    customizedDetail.additionalPrice == '')
                  Container()
                else
                  Text(
                      '+ ${widget.productDetail.currencySymbol} ' +
                          Utils.getPriceFormat('${customizedDetail.additionalPrice}',widget.psValueHolder),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith())
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (
        widget.intentbasketSelectedAttributeList.isNotEmpty &&
        widget.selectedcustomizedDetail.isEmpty) {
      for (BasketSelectedAttribute basketSelectedAttribute
          in widget.intentbasketSelectedAttributeList) {
        widget.selectedcustomizedDetail[basketSelectedAttribute.headerId!] =
            CustomizedDetail(
                id: basketSelectedAttribute.id,
                headerId: basketSelectedAttribute.headerId,
                name: basketSelectedAttribute.name,
                additionalPrice: basketSelectedAttribute.price);
        if (basketSelectedAttribute.price != '') {
          widget.addIntentAttributePrice(
              double.parse(basketSelectedAttribute.price!));
        }
      }
    }
    if (widget.productDetail.customizedHeaderList!.isNotEmpty &&
        widget.productDetail.customizedHeaderList![0].id != '') {
      return Container(
        margin: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12),
          decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: PsDimens.space14),
            Text(Utils.getString(context, 'customize_tile__title'),
              style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: PsColors.mainColor,fontWeight: FontWeight.bold)),
            const SizedBox(height: PsDimens.space16),    
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.productDetail.customizedHeaderList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: PsDimens.space16,
                      right: PsDimens.space8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              widget.productDetail
                                  .customizedHeaderList![index].name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: PsDimens.space16),
                            child: Text(
                              Utils.getString(
                                  context, 'customize_tile__1_require'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: PsColors.mainColor),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(
                              top: PsDimens.space8,
                              bottom: PsDimens.space4),
                        child: Text(
                            Utils.getString(
                                context, 'customize_tile__select_1'),
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith()),
                      ),
                      if (widget.productDetail.customizedHeaderList![index]
                              .customizedDetail![0].id !=
                          '')
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: createRadioListWidget(
                              widget
                                  .productDetail
                                  .customizedHeaderList![index]
                                  .customizedDetail!,
                              widget.productDetail
                                  .customizedHeaderList![index].id!)),
                      
                      ],
                    ), 
                  );
                },
              ),
              const Divider(
                height: PsDimens.space1,
              ),
            ]
          ),
        );
      } else {
        return const Card();
    }
  }
}

class AddOnCardView extends StatefulWidget {
  const AddOnCardView(
      {Key? key,
      required this.productDetail,
      required this.selectedAddOnList,
      required this.addAttributeAddOnFromView,
      required this.holderBasketSelectedAddOnList,
      required this.addIntentAddOnPrice,
      required this.psValueHolder,
      })
      : super(key: key);

  final Product productDetail;
  final Map<AddOn, bool> selectedAddOnList;
  final Function addAttributeAddOnFromView;
  final List<BasketSelectedAddOn> holderBasketSelectedAddOnList;
  final Function addIntentAddOnPrice;
  final PsValueHolder psValueHolder;

  @override
  _AddOnCardViewState createState() => _AddOnCardViewState();
}

class _AddOnCardViewState extends State<AddOnCardView> {
  @override
  Widget build(BuildContext context) {
    if (
        widget.holderBasketSelectedAddOnList.isNotEmpty &&
        widget.selectedAddOnList.isEmpty) {
      for (BasketSelectedAddOn basketSelectedAddOn
          in widget.holderBasketSelectedAddOnList) {
        widget.selectedAddOnList[AddOn(
            id: basketSelectedAddOn.id,
            name: basketSelectedAddOn.name,
            price: basketSelectedAddOn.price)] = true;
        if (basketSelectedAddOn.price != '') {
          widget.addIntentAddOnPrice(double.parse(basketSelectedAddOn.price!));
        }
      }
    }
    if (widget.productDetail.addOnList!.isNotEmpty &&
        widget.productDetail.addOnList![0].id != '') {
      return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space12,
            right: PsDimens.space12),
        decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Padding(
            padding: const EdgeInsets.only(
                right: PsDimens.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: PsDimens.space8),
                Text(Utils.getString(context, 'add_on_tile__title'),
                  style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: PsColors.mainColor,fontWeight: FontWeight.bold)),
            const SizedBox(height: PsDimens.space4),   
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.productDetail.addOnList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {});
                      if (widget.selectedAddOnList[
                              widget.productDetail.addOnList![index]] ==
                          true)
                        widget.selectedAddOnList[widget
                            .productDetail.addOnList![index]] = false;
                      else
                        widget.selectedAddOnList[
                            widget.productDetail.addOnList![index]] = true;
                      Utils.psPrint('Clicked Add on');
                      widget.addAttributeAddOnFromView(
                          widget.holderBasketSelectedAddOnList,
                          widget.productDetail.addOnList![index],
                          widget.selectedAddOnList);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: PsDimens.space8, left: PsDimens.space32),
                      child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: PsDimens.space60,
                                        height: PsDimens.space60,
                                        child: PsNetworkImage(
                                          photoKey: '',
                                          defaultPhoto: widget
                                              .productDetail
                                              .addOnList![index]
                                              .defaultPhoto!,
                                          onTap: () {
                                            if (widget.selectedAddOnList[
                                                    widget.productDetail
                                                            .addOnList![
                                                        index]] ==
                                                true)
                                              widget.selectedAddOnList[
                                                  widget.productDetail
                                                          .addOnList![
                                                      index]] = false;
                                            else
                                              widget.selectedAddOnList[
                                                  widget.productDetail
                                                          .addOnList![
                                                      index]] = true;
                                            Utils.psPrint(
                                                'Clicked Add on');
                                            widget.addAttributeAddOnFromView(
                                                widget
                                                    .holderBasketSelectedAddOnList,
                                                widget.productDetail
                                                    .addOnList![index],
                                                widget.selectedAddOnList);
                                          },
                                        ),
                                      ),
                                      if (widget.selectedAddOnList
                                              .containsKey(widget
                                                  .productDetail
                                                  .addOnList![index]) ==
                                          widget.selectedAddOnList[widget
                                              .productDetail
                                              .addOnList![index]])
                                        Container(
                                          width: PsDimens.space60,
                                          height: PsDimens.space60,
                                          child: CircleAvatar(
                                            child: Icon(
                                                Icons.check_circle,
                                                size: PsDimens.space44,
                                                color:
                                                    PsColors.mainColor),
                                            backgroundColor:
                                                PsColors.transparent,
                                          ),
                                        )
                                      else
                                        Container()
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.productDetail
                                                .addOnList![index].name!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: PsColors
                                                        .textPrimaryDarkColor),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: 4.0),
                                            child: Text(
                                              widget
                                                  .productDetail
                                                  .addOnList![index]
                                                  .description!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: PsColors
                                                          .textPrimaryLightColor),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.productDetail.addOnList![index]
                                        .price ==
                                    null ||
                                widget.productDetail.addOnList![index]
                                        .price ==
                                    '')
                              Container()
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                    '+ ${widget.productDetail.currencySymbol} ' +
                                        Utils.getPriceFormat(
                                            '${widget.productDetail.addOnList![index].price}',widget.psValueHolder)),
                              ),
                          ]),
                    ),
                  );
                }),
              ]),
          ));
      } else {
      return const Card();
    }
  }
}

