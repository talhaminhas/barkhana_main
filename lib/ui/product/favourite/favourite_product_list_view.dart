import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/product/favourite_product_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/dashboard/core/drawer_view.dart';
import 'package:flutterrestaurant/ui/product/item/product_vertical_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


class FavouriteProductListView extends StatefulWidget {
  const FavouriteProductListView({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _FavouriteProductListView createState() => _FavouriteProductListView();
}

class _FavouriteProductListView extends State<FavouriteProductListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  FavouriteProductProvider? _favouriteProductProvider;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _favouriteProductProvider!.nextFavouriteProductList();
      }
    });

    super.initState();
  }

  ProductRepository? repo1;
  PsValueHolder? psValueHolder;
  BasketProvider? basketProvider;
  BasketRepository? basketRepository;
  dynamic data;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;
  Basket? basket;
  String? id;
  String? colorId = '';
  String? qty;
  String? colorValue;
  bool? checkAttribute;
  double? bottomSheetPrice;
  double? totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();



  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ProductRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

  
    print(
        '............................Build UI Again ............................');
    return  MultiProvider(
        providers: <SingleChildWidget>[
      ChangeNotifierProvider<FavouriteProductProvider>(
        lazy: false,
        create: (BuildContext context) {
          final FavouriteProductProvider provider =
              FavouriteProductProvider(repo: repo1, psValueHolder: psValueHolder);
          provider.loadFavouriteProductList();
          _favouriteProductProvider = provider;
          return _favouriteProductProvider!;
        },
      ),
      ChangeNotifierProvider<BasketProvider>(
          lazy: false,
          create: (BuildContext context) {
            basketProvider = BasketProvider(repo: basketRepository!);
            basketProvider!.loadBasketList();
            return basketProvider!;
        }),
      ],
      child: Consumer<FavouriteProductProvider>(
        builder: (BuildContext context, FavouriteProductProvider provider,
            Widget ?child) {
          if (
            //provider.favouriteProductList != null &&
              provider.favouriteProductList.data != null &&
              provider.favouriteProductList.data!.isNotEmpty) {
            return Column(
              children: <Widget>[
                /*const PsAdMobBannerWidget(
                  admobSize: AdSize.banner
                ),*/
                Expanded(
                  child: Stack(children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(
                            left: PsDimens.space4,
                            right: PsDimens.space4,
                            top: PsDimens.space4,
                            bottom: PsDimens.space4),
                        child: RefreshIndicator(
                          child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              slivers: <Widget>[
                                SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 220,
                                          childAspectRatio: 0.84),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (provider.favouriteProductList.data !=
                                              null ||
                                          provider.favouriteProductList.data!
                                              .isNotEmpty) {
                                        final int count = provider
                                            .favouriteProductList.data!.length;
                                        final Product product = provider
                                            .favouriteProductList.data![index];
                                        Basket? basket = basketProvider!.basketList.data!.firstWhere((Basket item) => item.id == product.id, orElse: () => Basket());

                                        return Container(
                                          margin: const EdgeInsets.only(
                                              bottom: PsDimens.space4,
                                          ),
                                            child:
                                          ProductVerticalListItem(
                                            basket: basket,
                                          coreTagKey:
                                              provider.hashCode.toString() +
                                                  provider.favouriteProductList
                                                      .data![index].id!,
                                          animationController:
                                              widget.animationController,
                                          animation: Tween<double>(
                                                  begin: 0.0, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent:
                                                  widget.animationController,
                                              curve: Interval(
                                                  (1 / count) * index, 1.0,
                                                  curve: Curves.fastOutSlowIn),
                                            ),
                                          ),
                                          product: provider
                                              .favouriteProductList.data![index],
                                          onTap: () async {
                                            final ProductDetailIntentHolder
                                                holder =
                                                ProductDetailIntentHolder(
                                              productId: product.id,
                                              heroTagImage:
                                                  provider.hashCode.toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__IMAGE,
                                              heroTagTitle:
                                                  provider.hashCode.toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__TITLE,
                                              heroTagOriginalPrice: provider
                                                      .hashCode
                                                      .toString() +
                                                  product.id! +
                                                  PsConst
                                                      .HERO_TAG__ORIGINAL_PRICE,
                                              heroTagUnitPrice: provider
                                                      .hashCode
                                                      .toString() +
                                                  product.id! +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                            );

                                            dashboardViewKey.currentState?.selectedProductDetailHolder = holder;
                                            dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(
                                                Utils.getString(context, 'product_detail__title'),
                                                PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT);

                                            /*await Navigator.pushNamed(context,
                                                RoutePaths.productDetail,
                                                arguments: holder);*/

                                            /*await provider
                                                .resetFavouriteProductList();*/
                                          },
                                          onUpdateQuantityTap: (String? productQuantity) async{
                                            //print(productQuantity!);

                                            id =
                                            '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                                            basket = Basket(
                                                id: id,
                                                productId: product.id,
                                                qty: productQuantity,
                                                shopId: psValueHolder!.shopId,
                                                selectedColorId: colorId,
                                                selectedColorValue: colorValue,
                                                basketPrice: bottomSheetPrice == null
                                                    ? product.unitPrice
                                                    : bottomSheetPrice.toString(),
                                                basketOriginalPrice: totalOriginalPrice == 0.0
                                                    ? product.originalPrice
                                                    : totalOriginalPrice.toString(),
                                                selectedAttributeTotalPrice:
                                                basketSelectedAttribute
                                                    .getTotalSelectedAttributePrice()
                                                    .toString(),
                                                product: product,
                                                basketSelectedAttributeList:
                                                basketSelectedAttribute.getSelectedAttributeList(),
                                                basketSelectedAddOnList:
                                                basketSelectedAddOn.getSelectedAddOnList());

                                            if(productQuantity == '0')
                                            {
                                              basketProvider!.deleteBasketByProduct(
                                                  basket!);
                                            }
                                            else
                                              await basketProvider!.updateBasket(basket!);

                                            //reloadGrid();
                                          },
                                          onBasketTap: () async {
                                            if (product.isAvailable == '1') {

                                                id =
                                                    '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                                                if (product.minimumOrder == '0') {
                                                  product.minimumOrder = '1' ;
                                                }
                                                basket = Basket(
                                                  id: id,
                                                  productId: product.id,
                                                  qty: qty ?? product.minimumOrder,
                                                  shopId: psValueHolder!.shopId,
                                                  selectedColorId: colorId,
                                                  selectedColorValue: colorValue,
                                                  basketPrice: bottomSheetPrice == null
                                                      ? product.unitPrice
                                                      : bottomSheetPrice.toString(),
                                                  basketOriginalPrice: totalOriginalPrice == 0.0
                                                      ? product.originalPrice
                                                      : totalOriginalPrice.toString(),
                                                  selectedAttributeTotalPrice: basketSelectedAttribute
                                                      .getTotalSelectedAttributePrice()
                                                      .toString(),
                                                  product: product,
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

                                                  /*await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.basketList,
                                                );*/
                                              //}
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
                                          }, valueHolder: psValueHolder!,
                                        )
                                        );
                                      } else {
                                        return null;
                                      }
                                    },
                                    childCount: provider
                                        .favouriteProductList.data!.length,
                                  ),
                                ),
                              ]),
                          onRefresh: () {
                            return provider.resetFavouriteProductList();
                          },
                        )),
                    PSProgressIndicator(provider.favouriteProductList.status)
                  ]),
                ),

              ],
            );
          } else {
            widget.animationController.forward();
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: widget.animationController,
                    curve: const Interval(0.5 * 1, 1.0,
                        curve: Curves.fastOutSlowIn)));
            return AnimatedBuilder(
              animation: widget.animationController,
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.only(bottom: PsDimens.space120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/empty_fav.png',
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        height: PsDimens.space32,
                      ),
                      Text(
                        Utils.getString(context, 'fav_list__empty_title'),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                      ),
                      const SizedBox(
                        height: PsDimens.space20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            PsDimens.space32, 0, PsDimens.space32, 0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              Utils.getString(context, 'fav_list__empty_desc'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                    opacity: animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: child,
                    ));
              },
            );
          }
        },
      ),
    );
  }
}
