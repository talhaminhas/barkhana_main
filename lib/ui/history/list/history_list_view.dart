import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/history/history_provider.dart';
import 'package:flutterrestaurant/repository/history_repsitory.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../provider/basket/basket_provider.dart';
import '../../../repository/basket_repository.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/basket.dart';
import '../../../viewobject/common/ps_value_holder.dart';
import '../../common/dialog/confirm_dialog_view.dart';
import '../../dashboard/core/drawer_view.dart';
import '../../product/item/product_vertical_list_item.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView>
    with SingleTickerProviderStateMixin {
  HistoryRepository? historyRepo;
  dynamic data;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }
  PsValueHolder? psValueHolder;

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;
  String? id;
  Basket? basket;
  BasketRepository? basketRepository;
  BasketProvider? basketProvider;

  @override
  Widget build(BuildContext context) {
    // data = EasyLocalizationProvider.of(context).data;
    historyRepo = Provider.of<HistoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    return MultiProvider(
        providers: <SingleChildWidget>[

          ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                basketProvider = BasketProvider(repo: basketRepository!);
                basketProvider!.loadBasketList();
                return basketProvider!;
              }),
          ChangeNotifierProvider<HistoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                final HistoryProvider provider = HistoryProvider(
                  repo: historyRepo!,
                );
                provider.loadHistoryList();
                return provider;
              }),
        ],
        child: Consumer<HistoryProvider>(
          builder:
              (BuildContext context, HistoryProvider provider, Widget? child) {
                if (
                provider.historyList.data != null &&
                provider.historyList.data!.isNotEmpty
                ) {
                  return Stack(children: <Widget>[
                          Container(
                              margin: const EdgeInsets.only(
                                  left: PsDimens.space4,
                                  right: PsDimens.space4,
                                  top: PsDimens.space4,
                                  bottom: PsDimens.space4),
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
                                            if (provider.historyList.data !=
                                                null ||
                                                provider.historyList.data!
                                                    .isNotEmpty) {
                                              final int count = provider.historyList.data!.length;
                                              final Product product = provider.historyList.data![index];
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
                                                    provider.historyList.data![index].id!,
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
                                                product: provider.historyList.data![index],
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

                                                },
                                                onUpdateQuantityTap: (String? productQuantity) async{
                                                  id ='${product.id}';
                                                  basket = Basket(
                                                      id: id,
                                                      productId: product.id,
                                                      qty: productQuantity,
                                                      shopId: psValueHolder!.shopId,
                                                      basketPrice: product.unitPrice,
                                                      basketOriginalPrice:  product.originalPrice,
                                                      product: product,);

                                                  if(productQuantity == '0')
                                                  {
                                                    basketProvider!.deleteBasketByProduct(
                                                        basket!);
                                                  }
                                                  else
                                                    await basketProvider!.updateBasket(basket!);

                                                },
                                                onBasketTap: () async {
                                                    id =
                                                    '${product.id}';
                                                    if (product.minimumOrder == '0') {
                                                      product.minimumOrder = '1' ;
                                                    }
                                                    basket = Basket(
                                                        id: id,
                                                        productId: product.id,
                                                        qty: product.minimumOrder,
                                                        shopId: psValueHolder!.shopId,
                                                        basketPrice: product.unitPrice,
                                                        basketOriginalPrice: product.originalPrice,
                                                        product: product,);

                                                    await basketProvider!.addBasket(basket!);

                                                    Fluttertoast.showToast(
                                                        msg:
                                                        Utils.getString(context, 'product_detail__success_add_to_basket'),
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: PsColors.mainColor,
                                                        textColor: PsColors.white);
                                                },
                                                valueHolder: psValueHolder!,
                                              )
                                              );
                                            } else {
                                              return null;
                                            }
                                          },
                                          childCount: provider.historyList.data!.length,
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: PsDimens.space80), // Add extra space after the last item
                                      ),
                                    ]),
                          ),
                          Positioned(
                            bottom: PsDimens.space16, // Margin from the bottom
                            right: PsDimens.space16, // Margin from the right
                            child: FloatingActionButton(
                              onPressed: () {
                                showDialog<dynamic>(
                                    context: context,
                                    barrierColor: PsColors.transparent,
                                    builder: (BuildContext context) {
                                      return ConfirmDialogView(
                                          description: Utils.getString(context,
                                              'basket_list__empty_recent_dialog_description'),
                                          leftButtonText: Utils.getString(
                                              context,
                                              'basket_list__comfirm_dialog_cancel_button'),
                                          rightButtonText: Utils.getString(
                                              context,
                                              'basket_list__comfirm_dialog_ok_button'),
                                          onAgreeTap: () async {
                                            Navigator.of(context).pop();
                                            provider.deleteHistoryList();
                                          });
                                    }
                                );
                              },
                              child: Icon(
                                Icons.delete,
                                color: PsColors.discountColor, // Change the icon color to white
                              ),
                              backgroundColor: PsColors.discountColor.withOpacity(0.4), // Background color of the button

                              // Remove the shadow and add a border
                              elevation: 0, // Set elevation to 0 to remove the shadow
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: PsColors.discountColor, // Border color
                                  width: 2.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(50.0), // Rounded border
                              ),
                            )

                          ),
                        ]);
                }
            /*if (
              //provider.historyList != null &&
                provider.historyList.data != null) {
              return Column(
                children: <Widget>[
                  *//*const PsAdMobBannerWidget(
                    admobSize: AdSize.banner
                  ),*//*
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: PsDimens.space10),
                      child: RefreshIndicator(
                        child: CustomScrollView(
                            controller: _scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final int count =
                                        provider.historyList.data!.length;
                                    return HistoryListItem(
                                      animationController:
                                          widget.animationController,
                                      animation:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: widget.animationController,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      ),
                                      history: provider
                                          .historyList.data!.reversed
                                          .toList()[index],
                                      onTap: () {
                                        final Product product = provider
                                            .historyList.data!.reversed
                                            .toList()[index];
                                        final ProductDetailIntentHolder holder =
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
                                              PsConst.HERO_TAG__ORIGINAL_PRICE,
                                          heroTagUnitPrice:
                                              provider.hashCode.toString() +
                                                  product.id! +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                        );

                                        Navigator.pushNamed(
                                            context, RoutePaths.productDetail,
                                            arguments: holder);
                                      },
                                    );
                                  },
                                  childCount: provider.historyList.data!.length,
                                ),
                              )
                            ]),
                        onRefresh: () {
                          return provider.resetHistoryList();
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }*/
                else {
                  widget.animationController.forward();
                  final Animation<double> animation =
                  Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: widget.animationController,
                      curve: const Interval(0.5 * 1, 1.0,
                          curve: Curves.fastOutSlowIn)));
                  return Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child:
                      AnimatedBuilder(
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
                              'assets/images/baseline_empty_item_grey_24.png',
                              height: 200,
                              width: 200,
                              fit: BoxFit.scaleDown,
                            ),
                            const SizedBox(
                              height: PsDimens.space32,
                            ),
                            Text(
                              Utils.getString(context, 'rcnt_prd_list__empty_title'),
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
                                    Utils.getString(context, 'rcnt_prd_list__empty_desc'),
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
                  )
                      )
                  );
                }
          },

        )
    );
  }
}
