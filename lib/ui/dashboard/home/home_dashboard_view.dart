import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/category/category_provider.dart';
import 'package:flutterrestaurant/provider/product/search_product_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/category_repository.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/choose_attribute_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/dialog/rating_dialog/core.dart';
import 'package:flutterrestaurant/ui/common/dialog/rating_dialog/style.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/dashboard/home/home_tabbar_product_list_view.dart';
import 'package:flutterrestaurant/ui/product/item/product_vertical_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_add_on.dart';
import 'package:flutterrestaurant/viewobject/basket_selected_attribute.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class HomeDashboardViewWidget extends StatefulWidget {
  const HomeDashboardViewWidget(
      this.animationController,
      this.context,
      this.onTapCategory);

  final AnimationController animationController;
  final BuildContext context;
  final Function (Category category) onTapCategory;
  @override
  _HomeDashboardViewWidgetState createState() =>
      _HomeDashboardViewWidgetState();
}

class _HomeDashboardViewWidgetState extends State<HomeDashboardViewWidget> {
  PsValueHolder? valueHolder;
  CategoryRepository? repo1;
  //ProductRepository? repo2;
  //ProductCollectionRepository? repo3;
  ShopInfoRepository? shopInfoRepository;
  static int t = 1;
  static ShopInfoProvider? shopInfoProvider;
  CategoryProvider? _categoryProvider;
  //TrendingCategoryProvider? _trendingCategoryProvider;
  BasketRepository? basketRepository;
  BasketProvider? basketProvider;
  final int count = 8;
  //final CategoryParameterHolder trendingCategory = CategoryParameterHolder();
  //final CategoryParameterHolder categoryIconList = CategoryParameterHolder();
  //final TextEditingController userInputItemNameTextEditingController = TextEditingController();

  final RateMyApp _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 1,
      remindDays: 5,
      remindLaunches: 1);
  @override
  void initState() {
    super.initState();
    if (_categoryProvider != null) {
      _categoryProvider!.loadCategoryList(/*categoryIconList.toMap()*/);
    }

    if (!foundation.kIsWeb)
    if (Platform.isAndroid) {
      _rateMyApp.init().then((_) {
        /*if (_rateMyApp.shouldOpenDialog) {
          _rateMyApp.showStarRateDialog(
            context,
            title: Utils.getString(context, 'home__menu_drawer_rate_this_app'),
            message: Utils.getString(context, 'rating_popup_dialog_message'),
            ignoreNativeDialog: true,
            actionsBuilder: (BuildContext context, double? stars) {
              return <Widget>[
                TextButton(
                  child: Text(
                    Utils.getString(context, 'dialog__ok'),
                  ),
                  onPressed: () async {
                    if (stars != null) {
                      // _rateMyApp.save().then((void v) => Navigator.pop(context));
                      Navigator.pop(context);
                      if (stars < 1) {
                      } else if (stars >= 1 && stars <= 3) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.laterButtonPressed);
                        await showDialog<dynamic>(
                            context: context,
                            barrierColor: PsColors.transparent,
                            builder: (BuildContext context) {
                              return ConfirmDialogView(
                                description: Utils.getString(
                                    context, 'rating_confirm_message'),
                                leftButtonText:
                                    Utils.getString(context, 'dialog__cancel'),
                                rightButtonText: Utils.getString(
                                    context, 'home__menu_drawer_contact_us'),
                                onAgreeTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    RoutePaths.contactUs,
                                  );
                                },
                              );
                            });
                      } else if (stars >= 4) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        if (Platform.isIOS) {
                          Utils.launchAppStoreURL(
                              iOSAppId: valueHolder!.iOSAppStoreId,
                              writeReview: true);
                        } else {
                          Utils.launchURL();
                        }
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                )
              ];
            },
            onDismissed: () =>
                _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
            dialogStyle: const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 16.0),
            ),
            starRatingOptions: const StarRatingOptions(),
          );
        }*/
      });
    }
  }

  SearchProductProvider? searchProductProvider;

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<CategoryRepository>(context);
    //repo2 = Provider.of<ProductRepository>(context);
    //repo3 = Provider.of<ProductCollectionRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ShopInfoProvider>(
              lazy: false,
              create: (BuildContext context) {
                shopInfoProvider = ShopInfoProvider(
                    repo: shopInfoRepository!,
                    psValueHolder: valueHolder,
                    ownerCode: 'HomeDashboardViewWidget');
                shopInfoProvider!.loadShopInfo();
                return shopInfoProvider!;
              }),
          ChangeNotifierProvider<CategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                _categoryProvider ??= CategoryProvider(
                    repo: repo1!,
                    psValueHolder: valueHolder,
                    limit: int.parse(valueHolder!.categoryLoadingLimit ?? '5'));
                _categoryProvider!.loadCategoryList(/*categoryIconList.toMap()*/);
                return _categoryProvider!;
              }),
          /*ChangeNotifierProvider<TrendingCategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                final TrendingCategoryProvider provider =
                    TrendingCategoryProvider(
                        repo: repo1!,
                        psValueHolder: valueHolder,
                        limit: int.parse(valueHolder!.categoryLoadingLimit!));
                provider
                    .loadTrendingCategoryList(trendingCategory.toMap())
                    .then((dynamic value) {
                  // Utils.psPrint("Is Has Internet " + value);
                  final bool isConnectedToIntenet = value ?? bool;
                  if (!isConnectedToIntenet) {
                    Fluttertoast.showToast(
                        msg: 'No Internet Connection. Please try again !',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white);
                  }
                });
                return provider;
              }),
              ChangeNotifierProvider<ProductCollectionProvider>(
              lazy: false,
              create: (BuildContext context) {
                final ProductCollectionProvider provider =
                    ProductCollectionProvider(
                        repo: repo3!,
                        limit: int.parse(valueHolder!.collectionProductLoadingLimit!));
                provider.loadProductCollectionList();
                return provider;
              }),
          ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                basketProvider = BasketProvider(
                    repo: basketRepository!, psValueHolder: valueHolder);
                basketProvider!.loadBasketList();
                return basketProvider!;
              }),*/
        ],
        child: Container(
          // color: PsColors.white,
          /*child:
              ///
              /// category List Widget
              ///
              RefreshIndicator(
            onRefresh: () {
              return _trendingCategoryProvider!
                  .resetTrendingCategoryList(trendingCategory.toMap())
                  .then((dynamic value) {
                // Utils.psPrint("Is Has Internet " + value);
                final bool isConnectedToIntenet = value ?? bool;
                if (!isConnectedToIntenet) {
                  Fluttertoast.showToast(
                      msg: 'No Internet Connectiion. Please try again !',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white);
                }
              });
            },*/
            child: _HomeCategoryHorizontalListWidget(
              categoryProvider: _categoryProvider,
              shopInfoProvider: shopInfoProvider,
              psValueHolder: valueHolder!,
              //animationController: widget.animationController,
              //userInputItemNameTextEditingController: userInputItemNameTextEditingController,
              /*animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController,
                      curve: Interval((1 / count) * 2, 1.0,
                          curve: Curves.bounceIn))),*/
              onTapCategory: (Category category) {
                  widget.onTapCategory(category);
              },
            //),
          ),
        ));
  }
}

class _HomeLatestProductHorizontalListWidget extends StatefulWidget {
  const _HomeLatestProductHorizontalListWidget(
      {Key? key,
      required this.animationController,
      required this.animation,
      required this.productProvider,
      required this.basketProvider,
      required this.bottomSheetPrice,
      required this.totalOriginalPrice,
      required this.basketSelectedAddOn,
      required this.basketSelectedAttribute})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final SearchProductProvider productProvider;
  final BasketProvider basketProvider;
  final double? bottomSheetPrice;
  final double? totalOriginalPrice;
  final BasketSelectedAddOn basketSelectedAddOn;
  final BasketSelectedAttribute basketSelectedAttribute;

  @override
  __HomeLatestProductHorizontalListWidgetState createState() =>
      __HomeLatestProductHorizontalListWidgetState();
}

class __HomeLatestProductHorizontalListWidgetState
    extends State<_HomeLatestProductHorizontalListWidget> {
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // _offset = 0;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.productProvider.nextProductListByKey(
          widget.productProvider.productParameterHolder,
        );
      }
      // setState(() {
      //   final double offset = _scrollController.offset;
      //   _delta = offset - _oldOffset!;
      //   if (_delta! > _containerMaxHeight)
      //     _delta = _containerMaxHeight;
      //   else if (_delta! < 0) {
      //     _delta = 0;
      //   }
      //   _oldOffset = offset;
      //   _offset = -_delta!;
      // });

      // print(' Offset $_offset');
    });
  }

  // final double _containerMaxHeight = 60;
  // double? _offset, _delta = 0, _oldOffset = 0;
  Basket? basket;
  String? id;
  String? colorId = '';
  String? qty;
  String? colorValue;
  bool? checkAttribute;
  double? bottomSheetPrice;
  double totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();
  PsValueHolder? valueHolder;
  @override
  Widget build(BuildContext context) {
    valueHolder = Provider.of<PsValueHolder>(context);

    return Consumer<SearchProductProvider>(
      builder: (BuildContext context, SearchProductProvider productProvider,
          Widget? child) {
        return AnimatedBuilder(
            animation: widget.animationController,
            builder: (BuildContext context, Widget? child) {
              return Column(children: <Widget>[
                Expanded(
                  child: Container(
                    color: PsColors.coreBackgroundColor,
                    child: Stack(children: <Widget>[
                      if (productProvider.productList.data!.isNotEmpty &&
                          productProvider.productList.data != null)
                        Container(
                            color: PsColors.coreBackgroundColor,
                            margin: const EdgeInsets.only(
                                left: PsDimens.space8,
                                right: PsDimens.space8,
                                top: PsDimens.space4,
                                bottom: PsDimens.space4),
                            child: RefreshIndicator(
                              child: CustomScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  slivers: <Widget>[
                                    SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 220,
                                              childAspectRatio: 0.6),
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          if (productProvider
                                                      .productList.data !=
                                                  null ||
                                              productProvider.productList.data!
                                                  .isNotEmpty) {
                                            final int count = productProvider
                                                .productList.data!.length;
                                            final Product product =
                                                productProvider
                                                    .productList.data![index];
                                            return ProductVerticalListItem(
                                              coreTagKey: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  productProvider.productList
                                                      .data![index].id!,
                                              animationController:
                                                  widget.animationController,
                                              animation: Tween<double>(
                                                      begin: 0.0, end: 1.0)
                                                  .animate(
                                                CurvedAnimation(
                                                  parent: widget
                                                      .animationController,
                                                  curve: Interval(
                                                      (1 / count) * index, 1.0,
                                                      curve:
                                                          Curves.fastOutSlowIn),
                                                ),
                                              ),
                                              product: productProvider
                                                  .productList.data![index],
                                              onTap: () {
                                                final ProductDetailIntentHolder
                                                    holder =
                                                    ProductDetailIntentHolder(
                                                  productId: product.id,
                                                  heroTagImage: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__IMAGE,
                                                  heroTagTitle: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst.HERO_TAG__TITLE,
                                                  heroTagOriginalPrice:
                                                      productProvider.hashCode
                                                              .toString() +
                                                          product.id! +
                                                          PsConst
                                                              .HERO_TAG__ORIGINAL_PRICE,
                                                  heroTagUnitPrice: productProvider
                                                          .hashCode
                                                          .toString() +
                                                      product.id! +
                                                      PsConst
                                                          .HERO_TAG__UNIT_PRICE,
                                                );

                                                Navigator.pushNamed(context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                              },
                                              onBasketTap: () async {
                                                if (product.isAvailable ==
                                                    '1') {
                                                  if (product.addOnList!
                                                              .isNotEmpty &&
                                                          product.addOnList![0]
                                                                  .id !=
                                                              '' ||
                                                      product.customizedHeaderList!
                                                              .isNotEmpty &&
                                                          product
                                                                  .customizedHeaderList![
                                                                      0]
                                                                  .id !=
                                                              '' &&
                                                          product
                                                                  .customizedHeaderList![
                                                                      0]
                                                                  .customizedDetail !=
                                                              null) {
                                                    showDialog<dynamic>(
                                                        context: context,
                                                        barrierColor: PsColors.transparent,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ChooseAttributeDialog(
                                                              product: productProvider
                                                                  .productList
                                                                  .data![index]);
                                                        });
                                                  } else {
                                                    id =
                                                        '${product.id}$colorId${widget.basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${widget.basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                                                    if (product.minimumOrder ==
                                                        '0') {
                                                      product.minimumOrder =
                                                          '1';
                                                    }
                                                    basket = Basket(
                                                        id: id,
                                                        productId: product.id,
                                                        qty: qty ??
                                                            product
                                                                .minimumOrder,
                                                        shopId: valueHolder!
                                                            .shopId,
                                                        selectedColorId:
                                                            colorId,
                                                        selectedColorValue:
                                                            colorValue,
                                                        basketPrice: widget
                                                                    .bottomSheetPrice ==
                                                                null
                                                            ? product.unitPrice
                                                            : widget
                                                                .bottomSheetPrice
                                                                .toString(),
                                                        basketOriginalPrice: widget
                                                                    .totalOriginalPrice ==
                                                                0.0
                                                            ? product
                                                                .originalPrice
                                                            : widget
                                                                .totalOriginalPrice
                                                                .toString(),
                                                        selectedAttributeTotalPrice:
                                                            widget.basketSelectedAttribute
                                                                .getTotalSelectedAttributePrice()
                                                                .toString(),
                                                        product: product,
                                                        basketSelectedAttributeList: widget
                                                            .basketSelectedAttribute
                                                            .getSelectedAttributeList(),
                                                        basketSelectedAddOnList: widget
                                                            .basketSelectedAddOn
                                                            .getSelectedAddOnList());

                                                    await widget.basketProvider
                                                        .addBasket(basket!);

                                                    Fluttertoast.showToast(
                                                        msg: Utils.getString(
                                                            context,
                                                            'product_detail__success_add_to_basket'),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            PsColors.mainColor,
                                                        textColor:
                                                            PsColors.white);

                                                    await Navigator.pushNamed(
                                                      context,
                                                      RoutePaths.basketList,
                                                    );
                                                  }
                                                } else {
                                                  showDialog<dynamic>(
                                                      context: context,
                                                      barrierColor: PsColors.transparent,
                                                      builder: (BuildContext
                                                          context) {
                                                        return WarningDialog(
                                                          message: Utils.getString(
                                                              context,
                                                              'product_detail__is_not_available'),
                                                          onPressed: () {},
                                                        );
                                                      });
                                                }
                                              },
                                              valueHolder: valueHolder!,
                                            );
                                          } else {
                                            return null;
                                          }
                                        },
                                        childCount: productProvider
                                            .productList.data!.length,
                                      ),
                                    ),
                                  ]),
                              onRefresh: () {
                                return productProvider.resetLatestProductList(
                                    productProvider.productParameterHolder);
                              },
                            ))
                      else if (productProvider.productList.status !=
                              PsStatus.PROGRESS_LOADING &&
                          productProvider.productList.status !=
                              PsStatus.BLOCK_LOADING &&
                          productProvider.productList.status !=
                              PsStatus.NOACTION)
                        Align(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/baseline_empty_item_grey_24.png',
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                  height: PsDimens.space32,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: PsDimens.space20,
                                      right: PsDimens.space20),
                                  child: Text(
                                    Utils.getString(context,
                                        'procuct_list__no_result_data'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(),
                                  ),
                                ),
                                const SizedBox(
                                  height: PsDimens.space20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      PSProgressIndicator(productProvider.productList.status),
                    ]),
                  ),
                ),
              ]);
            });
      },
    );
  }
}

class _HomeCategoryHorizontalListWidget extends StatefulWidget {
  const _HomeCategoryHorizontalListWidget(
      {Key? key,
      required this.shopInfoProvider,
      //required this.animationController,
      //required this.animation,
      required this.psValueHolder,
        required this.categoryProvider,
      //required this.userInputItemNameTextEditingController,
      required this.onTapCategory})
      : super(key: key);

  final CategoryProvider? categoryProvider;
  final ShopInfoProvider? shopInfoProvider;
  //final AnimationController animationController;
  //final Animation<double> animation;
  final PsValueHolder psValueHolder;
  //final TextEditingController userInputItemNameTextEditingController;
  final Function (Category category) onTapCategory;
  @override
  __HomeCategoryHorizontalListWidgetState createState() =>
      __HomeCategoryHorizontalListWidgetState();
}

bool showMainMenu = false;
bool showSpecialCollections = false;
bool showFeatureItems = false;

class __HomeCategoryHorizontalListWidgetState
    extends State<_HomeCategoryHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    /*if (widget.psValueHolder.showMainMenu != null &&
        widget.psValueHolder.showMainMenu == PsConst.ONE) {
      showMainMenu = true;
    } else {
      showMainMenu = false;
    }
    if (widget.psValueHolder.showSpecialCollections != null &&
        widget.psValueHolder.showSpecialCollections == PsConst.ONE) {
      showSpecialCollections = true;
    } else {
      showSpecialCollections = false;
    }
    if (widget.psValueHolder.showFeaturedItems != null &&
        widget.psValueHolder.showFeaturedItems == PsConst.ONE) {
      showFeatureItems = true;
    } else {
      showFeatureItems = false;
    }*/
    return Consumer<CategoryProvider>(
      builder: (BuildContext context, CategoryProvider categoryProvider,
          Widget? child) {
        if (categoryProvider.categoryList.data == null ||
            categoryProvider.categoryList.data!.isEmpty ||
            widget.shopInfoProvider == null ||
            widget.shopInfoProvider!.shopInfo.data == null) {
          return Container();
        }
        final List<Category> _tmpList =
            List<Category>.from(categoryProvider.categoryList.data!);
        const int i = 0;

        /*if (showMainMenu) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.mainMenu,
                  name: Utils.getString(context, 'dashboard__main_menu')));
          i++;
        }

        if (showFeatureItems) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.featuredItem,
                  name: Utils.getString(context, 'dashboard__featured_items')));
        }

        if (showSpecialCollections) {
          _tmpList.insert(
              i,
              Category(
                  id: PsConst.specialCollection,
                  name: Utils.getString(
                      context, 'dashboard__special_collection')));
        }*/

        return Container(

            //animation: widget.animationController,
            child: HomeTabbarProductListView(categoryProvider: categoryProvider,
                shopInfo: widget.shopInfoProvider!.shopInfo.data!,
                //animationController: widget.animationController,
                categoryList: _tmpList,
              //categoryProvider.categoryList.data,
                //userInputItemNameTextEditingController: widget.userInputItemNameTextEditingController,
                valueHolder: widget.psValueHolder,
                key: Key('${_tmpList.length}'),
              onTapCategory: (Category category) {
                widget.onTapCategory(category);
              },),
            /*builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 30 * (1.0 - widget.animation.value), 0.0),
                      child: child));
            }*/);
      },
    );
  }
}

class _MyHeaderWidget extends StatefulWidget {
  const _MyHeaderWidget({
    Key? key,
    required this.headerName,
    // this.productCollectionHeader,
    required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function? viewAllClicked;
  // final ProductCollectionHeader? productCollectionHeader;

  @override
  __MyHeaderWidgetState createState() => __MyHeaderWidgetState();
}

class __MyHeaderWidgetState extends State<_MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.viewAllClicked as void Function()?,
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
            Text(
              Utils.getString(context, 'dashboard__view_all'),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: PsColors.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
