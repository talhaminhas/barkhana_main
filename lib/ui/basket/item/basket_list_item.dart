
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_toast.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

class BasketListItemView extends StatelessWidget {
  const BasketListItemView({
    Key? key,
    required this.basket,
    required this.onTap,
    required this.onDeleteTap,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  final Basket basket;
  final Function? onTap;
  final Function? onDeleteTap;
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // if (basket != null) {
      return AnimatedBuilder(
          animation: animationController,
          child: _ImageAndTextWidget(
            basket: basket,
            onDeleteTap: onDeleteTap as void Function()?,
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: animation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation.value), 0.0),
                child: GestureDetector(
                  onTap: onTap as void Function()?,
                  child: child,
                ),
              ),
            );
          });
    // } else {
    //   return Container();
    // }
  }
}

class _ImageAndTextWidget extends StatelessWidget {
  const _ImageAndTextWidget({
    Key? key,
    required this.basket,
    required this.onDeleteTap,
  }) : super(key: key);

  final Basket basket;
  final Function? onDeleteTap;
  @override
  Widget build(BuildContext context) {
    double subTotalPrice = 0.0;
    subTotalPrice = double.parse(basket.basketPrice!) * double.parse(basket.qty!);

    final BasketRepository basketRepository =
        Provider.of<BasketRepository>(context);
    final PsValueHolder psValueHolder = Provider.of(context);    
    // ignore: unnecessary_null_comparison
    if (basket != null) {
      return ChangeNotifierProvider<BasketProvider>(
          lazy: false,
          create: (BuildContext context) {
            final BasketProvider provider =
                BasketProvider(repo: basketRepository);
            provider.loadBasketList();
            return provider;
          },
          child: Consumer<BasketProvider>(builder: (BuildContext context,
              BasketProvider basketProvider, Widget? child) {
            return
            IntrinsicHeight(
            child:
              Container(
              //height: PsDimens.space160,
              margin: const EdgeInsets.all(PsDimens.space8),
              decoration: BoxDecoration(
                border: Border.all(color: PsColors.mainColor, width: 2),
                borderRadius: BorderRadius.circular(PsDimens.space8),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Padding(
                        padding: const EdgeInsets.all(PsDimens.space8),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(PsDimens.space8),
                                child: PsNetworkImage(
                                  //height: double.infinity,
                                  photoKey: '',
                                  defaultPhoto: basket.product!.defaultPhoto!,
                                  boxfit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if(basket.product!.isDiscount == '1')
                            Positioned(
                              top: 10,
                              left: 0,
                              child:Container(
                                decoration: const BoxDecoration(
                                    color: Colors.red,
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
                          ],
                        )
                      // child:
                    ),
                  ),
                  Expanded(
                    flex: 6, // Adjust the flex value as needed to control the width ratio
                    child: Container(
                      //height: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: PsDimens.space8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            /*child:FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,*/
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                      basket.product!.name!,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  const Divider(
                                    height: PsDimens.space10,
                                  ),
                                  //_AttributeAndColorWidget(basket: basket),
                                  _AddOnWidget(basket: basket, psValueHolder: psValueHolder,),
                                  /*const SizedBox(
                                    height: PsDimens.space6,
                                  ),*/
                                  if(basket.product!.discountAmount! != '0')
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${Utils.getString(context, 'Discount:')} ',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const Spacer(),
                                      Text(
                                        ' ${basket.product!.currencySymbol}'
                                            '${Utils.getPriceFormat(basket.product!.discountAmount!, psValueHolder)}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${Utils.getString(context, 'basket_list__price')} ',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const Spacer(),
                                      Text(
                                            ' ${basket.product!.currencySymbol}${Utils.getPriceFormat(basket.basketPrice!, psValueHolder)}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${Utils.getString(context, 'basket_list__sub_total')}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: PsColors.discountColor
                                          ),
                                      ),
                                      const Spacer(),
                                      Text(
                                            ' ${basket.product!.currencySymbol}${Utils.getPriceFormat(subTotalPrice.toString(), psValueHolder)}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: PsColors.discountColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: PsDimens.space10,
                                  ),
                                ]),
                            //)
                          ),
                          const SizedBox(
                            height: PsDimens.space4,
                          ),
                          const Spacer(),
                          Container(
                            height: PsDimens.space52,
                            child:
                            Row(
                              children: <Widget>[
                                _IconAndTextWidget(
                                  basket: basket,
                                  basketProvider: basketProvider,
                                ),
                                const Spacer(),
                                _DeleteButtonWidget(onDeleteTap: onDeleteTap!),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: PsDimens.space8,
                  )
                ],
              ),
            )
            )
            ;

          }));
    } else {
      return Container();
    }
  }
}

class _DeleteButtonWidget extends StatelessWidget {
  const _DeleteButtonWidget({
    Key? key,
    required this.onDeleteTap,
  }) : super(key: key);

  final Function? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDeleteTap as void Function()?,
      child: Container(
        /*decoration: BoxDecoration(
            border: Border.all(color: PsColors.mainColor, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space8))
        ),*/
        decoration: BoxDecoration(
          color: PsColors.discountColor.withAlpha(29),
          borderRadius:
          const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        width: PsDimens.space52,
        height: PsDimens.space52,
        alignment: Alignment.center,
        child: Icon(
          Icons.delete,
          color: PsColors.discountColor,
        ),
      ),
    );
  }
}

class _IconAndTextWidget extends StatefulWidget {
  const _IconAndTextWidget({
    Key? key,
    required this.basket,
    required this.basketProvider,
  }) : super(key: key);

  final Basket basket;
  final BasketProvider basketProvider;

  @override
  _IconAndTextWidgetState createState() => _IconAndTextWidgetState();
}

class _IconAndTextWidgetState extends State<_IconAndTextWidget> {
  int orderQty = 0;
  Basket? basket;
  double? basketOriginalPrice, basketPrice;
  int minimumOrder = 1; // 1 is default
  int maximumOrder = 0;

  void initMinimumOrder() {
    if (widget.basket.product?.minimumOrder != '0' &&
        widget.basket.product?.minimumOrder != '' &&
        widget.basket.product?.minimumOrder != null) {
      minimumOrder = int.parse(widget.basket.product!.minimumOrder!);
    }
  }

  void initMaximumOrder() {
    if (widget.basket.product!.maximumOrder != '0' &&
        widget.basket.product!.maximumOrder != '' &&
        widget.basket.product!.maximumOrder != null) {
      maximumOrder = int.parse(widget.basket.product!.maximumOrder!);
    }
  }

  void initQty() {
    if (orderQty == 0 && widget.basket.qty != null && widget.basket.qty != '') {
      orderQty = int.parse(widget.basket.qty!);
    } else if (orderQty == 0) {
      orderQty = int.parse(widget.basket.product!.minimumOrder!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);

    initMinimumOrder();

    initMaximumOrder();

    initQty();

    Future<void> changeBasketQtyAndPrice() async {
      basket = Basket(
          id: widget.basket.id,
          productId: widget.basket.product!.id,
          qty: widget.basket.qty,
          shopId: psValueHolder.shopId,
          selectedColorId: widget.basket.selectedColorId,
          selectedColorValue: widget.basket.selectedColorValue,
          basketPrice: widget.basket.basketPrice,
          basketOriginalPrice: widget.basket.basketOriginalPrice,
          selectedAttributeTotalPrice:
              widget.basket.selectedAttributeTotalPrice,
          product: widget.basket.product,
          basketSelectedAttributeList:
              widget.basket.basketSelectedAttributeList,
          basketSelectedAddOnList: widget.basket.basketSelectedAddOnList);

      await widget.basketProvider.updateBasket(basket!);
    }

    void _increaseItemCount() {
      if (orderQty + 1 <= maximumOrder || maximumOrder == 0) {
        setState(() {
          orderQty++;
          widget.basket.qty = '$orderQty';
          changeBasketQtyAndPrice();
        });
      } else {
        PsToast().showToast(
            ' ${Utils.getString(context, 'product_detail__maximum_order')}  ${widget.basket.product!.maximumOrder}');
      }
      // widget.basket.qty ??= widget.basket.product.minimumOrder;
      //   if (int.parse(widget.basket.qty) <
      //       int.parse(widget.basket.product.maximumOrder)) {
      //     setState(() {
      //       widget.basket.qty =  (int.parse(widget.basket.qty) + 1).toString();
      //       changeBasketQtyAndPrice();
      //     });
      //   } else {
      //     Fluttertoast.showToast(
      //         msg:
      //             ' ${Utils.getString(context, 'product_detail__maximum_order')}  ${widget.basket.product.maximumOrder}',
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         timeInSecForIosWeb: 1,
      //         backgroundColor: PsColors.mainColor,
      //         textColor: PsColors.white);
      //   }
    }

    void _decreaseItemCount() {
      if (orderQty != 0 && orderQty > minimumOrder) {
        orderQty--;
        setState(() {
          widget.basket.qty = '$orderQty';
          changeBasketQtyAndPrice();
        });
      } else {
        PsToast().showToast(
            ' ${Utils.getString(context, 'product_detail__minimum_order')}  ${widget.basket.product!.minimumOrder}');
      }
      // if (int.parse(widget.basket.qty) >
      //     int.parse(widget.basket.product.minimumOrder)) {
      //   setState(() {
      //     widget.basket.qty = (int.parse(widget.basket.qty) - 1).toString();
      //     changeBasketQtyAndPrice();
      //   });
      // } else {
      //   Fluttertoast.showToast(
      //       msg:
      //           '${Utils.getString(context, 'product_detail__minimum_order')} ${widget.basket.product.minimumOrder}',
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: PsColors.mainColor,
      //       textColor: PsColors.white);
      // }
    }

    void onUpdateItemCount(int buttonType) {
      if (buttonType == 1) {
        _increaseItemCount();
      } else if (buttonType == 2) {
        _decreaseItemCount();
      }
    }

    final Widget _addIconWidget = IconButton(
        iconSize: PsDimens.space32,
        icon: Icon(Icons.add_circle, color: PsColors.mainColor),
        onPressed: () {
          onUpdateItemCount(1);
        });

    final Widget _removeIconWidget = IconButton(
        iconSize: PsDimens.space32,
        icon: Icon(Icons.remove_circle, color: PsColors.discountColor),
        onPressed: () {
          onUpdateItemCount(2);
        });
    return Container(
      /*margin: const EdgeInsets.only(
          top: PsDimens.space8, bottom: PsDimens.space8, left: PsDimens.space8),*/

          decoration: BoxDecoration( border: Border.all(color: PsColors.mainColor, width: 2,),
        borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space8))
    ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _removeIconWidget,
          Center(
            child: Container(
              //height: PsDimens.space24,
              alignment: Alignment.center,
              child: Text(
                widget.basket.qty!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          _addIconWidget,
        ],
      ),
    );
  }
}

class _AttributeAndColorWidget extends StatelessWidget {
  const _AttributeAndColorWidget({
    Key? key,
    required this.basket,
  }) : super(key: key);

  final Basket basket;
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String getSelectedAttribute() {
    final List<String> attributeName = <String>[];
    for (BasketSelectedAttribute attribute
        in basket.basketSelectedAttributeList!) {
      attributeName.add(attribute.name!);
    }

    return attributeName.join(',').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (basket.basketSelectedAttributeList!.isNotEmpty &&
            basket.selectedColorValue != null)
          Text(
            '${Utils.getString(context, 'basket_list__attributes')}',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Container(),
        if (basket.selectedColorValue != null)
          Container(
            margin: const EdgeInsets.all(PsDimens.space10),
            width: PsDimens.space20,
            height: PsDimens.space20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: hexToColor(basket.selectedColorValue!),
              border: Border.all(width: 1, color: PsColors.grey),
            ),
          )
        else
          Container(),
        if (basket.basketSelectedAttributeList!.isNotEmpty)
          Flexible(
            child: Text(
              '${getSelectedAttribute().toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          Container(),
      ],
    );
  }
}

class _AddOnWidget extends StatelessWidget {
  const _AddOnWidget({
    Key? key,
    required this.basket,
    required this.psValueHolder,
  }) : super(key: key);

  final Basket basket;
  final PsValueHolder psValueHolder;
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String getAddOnNames() {
    final List<String> addOnName = <String>[];
    for (BasketSelectedAddOn addOn in basket.basketSelectedAddOnList!) {
      addOnName.add(addOn.name! + ': ');
    }
    return addOnName.join('\n').toString();
  }
  String getAddOnPrices() {
    final List<String> addOnName = <String>[];
    for (BasketSelectedAddOn addOn in basket.basketSelectedAddOnList!) {
      addOnName.add('${basket.product!.currencySymbol}${Utils.getPriceFormat(addOn.price.toString(), psValueHolder)}');
    }
    return addOnName.join('\n').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (basket.basketSelectedAttributeList!.isNotEmpty )
          Text(
            '${Utils.getString(context, 'basket_list__attributes')}',
            style: Theme.of(context).textTheme.bodyMedium,
            //textAlign: TextAlign.center,
          )
        else
          Container(),
        /*if (basket.selectedColorValue != null)
          Container(
            margin: const EdgeInsets.all(PsDimens.space10),
            width: PsDimens.space20,
            height: PsDimens.space20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: hexToColor(basket.selectedColorValue!),
              border: Border.all(width: 1, color: PsColors.grey),
            ),
          )
        else
          Container(),*/
        if (basket.basketSelectedAddOnList!.isNotEmpty)
          Expanded(
              child: Column(
                children: <Widget>[

                  Row(
                    children: <Widget>[
                      Text(
                        '${getAddOnNames().toString()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
                      const Spacer(),
                      Text(
                        '${getAddOnPrices().toString()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                  const Divider(
                    height: PsDimens.space10,
                  ),
                ],
              )
          )
        else
          Container(),
      ],
    );
  }
}
