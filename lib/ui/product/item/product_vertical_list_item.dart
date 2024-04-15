import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_hero.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';

import '../../../repository/basket_repository.dart';
import '../../common/ps_toast.dart';

class ProductVerticalListItem extends StatefulWidget {

  const ProductVerticalListItem(
      {Key? key,
      required this.product,
      required this.valueHolder,
      this.onTap,
      this.onBasketTap,
        this.onUpdateQuantityTap,
        this.onRemoveTap,
      this.animationController,
      this.animation,
      this.coreTagKey,
      this.qty,
      this.basket
      })
      : super(key: key);

  final OnAddTapCallback? onUpdateQuantityTap;
  final String? qty;
  final Product product;
  final Basket? basket;
  final Function? onTap;
  final Function? onBasketTap;
  //final Function? onAddTap;
  final Function? onRemoveTap;
  final String? coreTagKey;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final PsValueHolder valueHolder;

  @override
  _ProductVerticalListItemState createState() => _ProductVerticalListItemState();
}

class _ProductVerticalListItemState extends State<ProductVerticalListItem> {
  BasketRepository? basketRepository;
  @override
  Widget build(BuildContext context) {
    Future<void> updateQty(String minimumOrder) async {
      /*setState(() {
        qty = minimumOrder;
      });*/
    }
    widget.animationController!.forward();
    return AnimatedBuilder(
        animation: widget.animationController!,
        child: GestureDetector(
            onTap: widget.onTap as void Function()?,
            child: GridTile(
                child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: PsDimens.space2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: PsColors.mainColor, // Set the desired border color here
                        width: 2, // Set the border width
                      ),
                      color: PsColors.backgroundColor,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Stack(
                      /*mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,*/
                      children: <Widget>[
                        /*Expanded(
                          child:*/ Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: ClipPath(
                              child: PsNetworkImage(
                                photoKey: '$widget.coreTagKey${PsConst.HERO_TAG__IMAGE}',
                                defaultPhoto: widget.product.defaultPhoto!,
                                width: double.infinity,
                                height: double.infinity,
                                boxfit: BoxFit.cover,
                                onTap: () {
                                  Utils.psPrint(widget.product.defaultPhoto!.imgParentId!);
                                  widget.onTap!();
                                },
                              ),
                              clipper: const ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                          ),
                        //),

                        Positioned(
                          bottom: 0, // Margin from the bottom
                          right: 0,
                          left: 0,// Margin from the right

                          child:
                          Column(

                              children: <Widget>[
                                if(widget.product.isAvailable == '0')
                                  ...<Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: PsColors.discountColor.withOpacity(0.8), // Adjust the background color and opacity
                                        border: Border.all(
                                          color: PsColors.white, // Adjust the border color
                                          width: 2.0, // Adjust the border width
                                        ),
                                        borderRadius: BorderRadius.circular(5), // Adjust the border radius
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Out Of Stock!',
                                        style: TextStyle(
                                          color: PsColors.white, // Text color
                                          fontWeight: FontWeight.bold, // Text fontWeight
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: PsDimens.space10,
                                    ),
                                  ],
                                ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5)),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                      child:
                                      Column(
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              color: PsColors.black.withOpacity(0.4),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: PsHero(
                                                  tag: '$widget.coreTagKey${PsConst.HERO_TAG__TITLE}',
                                                  child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        margin: const EdgeInsets.only(left: PsDimens.space10,right: PsDimens.space10),
                                                        child: Text(
                                                          widget.product.name!,
                                                          overflow: TextOverflow.ellipsis,
                                                          textAlign: TextAlign.center,
                                                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: PsColors.white),
                                                          maxLines: 1,
                                                        ),
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                                padding: const EdgeInsets.all(PsDimens.space8),
                                                color: PsColors.backgroundColor.withOpacity(0.6),
                                                child:Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child:FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment:
                                                          widget.product.isAvailable == '0' ?
                                                          Alignment.center :
                                                          Alignment.centerLeft,
                                                          child:Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              PsHero(
                                                                tag: '$widget.coreTagKey$PsConst.HERO_TAG__UNIT_PRICE',
                                                                flightShuttleBuilder: Utils.flightShuttleBuilder,
                                                                child: Material(
                                                                  type: MaterialType.transparency,
                                                                  child:  Text(
                                                                    '${widget.product.currencySymbol}${Utils.getPriceFormat(widget.product.unitPrice!, widget.valueHolder)}',
                                                                    style: Theme.of(context).textTheme.titleLarge!.
                                                                    copyWith(),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (widget.product.isDiscount == PsConst.ONE) ...<Widget>[
                                                                PsHero(
                                                                  tag: '', // Replace with your tag
                                                                  flightShuttleBuilder: Utils.flightShuttleBuilder,
                                                                  child: Material(
                                                                    color: PsColors.transparent,
                                                                    child: Text(
                                                                      '${widget.product.currencySymbol}${Utils.getPriceFormat(widget.product.originalPrice!, widget.valueHolder)}',
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .titleSmall!
                                                                          .copyWith(color: PsColors.discountColor)
                                                                          .copyWith(decoration: TextDecoration.lineThrough),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${widget.product.discountPercent}%' + Utils.getString(context, 'product_detail__discount_off'),
                                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: PsColors.discountColor),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ],
                                                            ],
                                                          )),
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    if(widget.product.isAvailable == '1')
                                                      _IconAndTextWidget(
                                                        product: widget.product,
                                                        updateQty: updateQty,
                                                        qty: widget.qty,
                                                        onBasketTap: widget.onBasketTap,
                                                        onUpdateQuantityTap: widget.onUpdateQuantityTap,
                                                        onRemoveTap: widget.onRemoveTap,
                                                        basket: widget.basket,
                                                      ),
                                                  ],
                                                )),
                                          ]),
                                    ))
                              ]),

                        ),

                        if(widget.product.isDiscount == '1' && widget.product.isAvailable == '1')
                          Positioned(
                            top: 10,
                            left: 0,
                            child:Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red, // Adjust the background color and opacity
                                  /*border: Border.all(
                                            color: PsColors.white, // Adjust the border color
                                            width: 2.0, // Adjust the border width
                                          ),*/
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.elliptical(50, 50),
                                    topRight: Radius.elliptical(50, 50),
                                  )
                              ),
                              padding: const EdgeInsets.only(
                                right: PsDimens.space10,
                                left: PsDimens.space6,
                                top: PsDimens.space6,
                                bottom: PsDimens.space6,
                              ),
                              child: const Text(
                                'Discounted',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if(widget.product.isFeatured == '1' && widget.product.isAvailable == '1')
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              FontAwesome.diamond,
                              size: PsDimens.space20,
                              color: PsColors.discountColor,
                            )
                          ),
                      ],
                    )
                )
            )
        ),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: widget.animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - widget.animation!.value), 0.0),
                child: child,
              ));
        });
  }
}
typedef OnAddTapCallback = void Function(String? parameter);

class _IconAndTextWidget extends StatefulWidget {
   const _IconAndTextWidget({
    Key? key,
    required this.product,
    required this.updateQty,
    required this.qty,
    required this.onBasketTap,
     required this.onRemoveTap,
     required this.onUpdateQuantityTap,
     required this.basket
  }) : super(key: key);
   final OnAddTapCallback? onUpdateQuantityTap;
  final Product product;
  final Function updateQty;
  final String? qty;
  final Basket? basket;
  final Function? onBasketTap;
   //final Function? onAddTap;
   final Function? onRemoveTap;

  @override
  _IconAndTextWidgetState createState() => _IconAndTextWidgetState();
}
class _IconAndTextWidgetState extends State<_IconAndTextWidget>  {
  int orderQty = 0;
  int maximumOrder = 0;
  int minimumOrder = 1; // 1 is default
  bool showBasket = true;
  @override
  void initState(){
    super.initState();

  }
  void initMinimumOrder() {
    if (widget.product.minimumOrder != '0' &&
        widget.product.minimumOrder != '' &&
        widget.product.minimumOrder != null) {
      minimumOrder = int.parse(widget.product.minimumOrder!);
    }
  }

  void initMaximumOrder() {
    if (widget.product.maximumOrder != '0' &&
        widget.product.maximumOrder != '' &&
        widget.product.maximumOrder != null) {
      maximumOrder = int.parse(widget.product.maximumOrder!);
    }
  }

  void initQty() {
    //print('init called');
    //print(widget.basket?.qty);
    //print(orderQty);
    if (orderQty == 0 && widget.basket?.qty != null && widget.basket?.qty != '') {
      orderQty = int.parse(widget.basket!.qty!);
      setState(() {
        showBasket = false;
      });
    }
    /*else if (orderQty > 0 && orderQty < int.parse(widget.basket!.qty!) && widget.basket?.qty != null && widget.basket?.qty != '') {
      orderQty = int.parse(widget.basket!.qty!);
      setState(() {
        showBasket = false;
      });
    }*/
    else if (orderQty == 0) {
      orderQty = int.parse(widget.product.minimumOrder!);
      setState(() {
        showBasket = true;
      });
    }
  }

  void _increaseItemCount() {
    if (orderQty + 1 <= maximumOrder || maximumOrder == 0) {
      setState(() {
        orderQty++;
        widget.updateQty('$orderQty');
      });
    } else {
      PsToast().showToast(
          ' ${Utils.getString(context, 'product_detail__maximum_order')}  ${widget.product.maximumOrder}');
    }
  }

  void _decreaseItemCount() {
    /*if (orderQty != 0 && orderQty > minimumOrder) {*/
      orderQty--;
      setState(() {
        widget.updateQty('$orderQty');
      });
    //}

    if (orderQty == 0)
    {
      /*PsToast().showToast(
          ' ${Utils.getString(context, 'product_detail__minimum_order')}  ${widget.product.minimumOrder}');*/
      setState(() {
        showBasket = true;
      });
    }
  }

  void onUpdateItemCount(int buttonType) {
    if (buttonType == 1) {
      _increaseItemCount();
    } else if (buttonType == 2) {
      _decreaseItemCount();
      if (orderQty == 0)
        {
          widget.basket?.qty = null;
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    initMinimumOrder();

    initMaximumOrder();

    initQty();

    final Widget _addIconWidget = IconButton(
        iconSize: PsDimens.space32,
        icon: Icon(Icons.add_circle, color: PsColors.greenColor),
        onPressed: () {
          onUpdateItemCount(1);
          widget.onUpdateQuantityTap!.call(orderQty.toString());
          setState(() {
            showBasket = false;
          });
        });

    final Widget _removeIconWidget = IconButton(
        iconSize: PsDimens.space32,
        icon: Icon(Icons.remove_circle, color: PsColors.discountColor),
        onPressed: () {
          onUpdateItemCount(2);
          widget.onUpdateQuantityTap!.call(orderQty.toString());
        });

    return Container(
      margin: const EdgeInsets.only(top: PsDimens.space1, bottom: PsDimens.space1),
      decoration: BoxDecoration(
        border: Border.all(color: PsColors.mainColor, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space10)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double containerWidth = constraints.maxWidth;
          final bool isSmallContainer = containerWidth < PsDimens.space200;

          return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
              color: PsColors.mainColor.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    if (showBasket)
                      Center(
                        child: Container(
                            child:IconButton(
                              icon: Icon(Icons.add_shopping_cart_outlined, color: PsColors.white),
                              onPressed: () {
                                widget.onBasketTap!();
                                setState(() {
                                  showBasket = false;
                                });
                              },
                            )
                        ),
                      ),
                    if (!showBasket) ...<Widget>[
                      _removeIconWidget,
                      Center(
                        child: Container(
                          height: isSmallContainer ? PsDimens.space16 : PsDimens.space24,
                          alignment: Alignment.center,
                          child: Text(
                            '$orderQty',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: PsColors.white),
                          ),
                        ),
                      ),
                      _addIconWidget,
                    ],
                ],

              )));
        },
      ),
    );

  }
}