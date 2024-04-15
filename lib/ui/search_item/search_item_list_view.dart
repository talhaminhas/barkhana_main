import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/product/search_product_provider.dart';
import 'package:flutterrestaurant/provider/search_history/search_history_provider.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/repository/search_history_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/dashboard/core/drawer_view.dart';
import 'package:flutterrestaurant/ui/search_item/search_item_list_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/search_result_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/common/ps_status.dart';
import '../../provider/basket/basket_provider.dart';
import '../../provider/product/search_result_provider.dart';
import '../../repository/basket_repository.dart';
import '../../repository/search_result_repository.dart';
import '../../viewobject/basket.dart';
import '../../viewobject/basket_selected_add_on.dart';
import '../../viewobject/basket_selected_attribute.dart';
import '../../viewobject/category.dart';
import '../../viewobject/holder/intent_holder/product_list_intent_holder.dart';
import '../../viewobject/sub_category.dart';
import '../common/ps_frame_loading_widget.dart';
import '../common/ps_search_textfield_widget.dart';
import '../product/item/product_vertical_list_item.dart';

class SearchItemListView extends StatefulWidget {
  const SearchItemListView({
    Key? key,
    required this.productParameterHolder,
  }) : super(key: key);

  final ProductParameterHolder productParameterHolder;
  @override
  _SearchHistoryListViewState createState() => _SearchHistoryListViewState();
}
final GlobalKey _searchTextFieldKey = GlobalKey();
class _SearchHistoryListViewState extends State<SearchItemListView>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  // final ScrollController _scrollController = ScrollController();
  late Animation<double> fadeAnimation;

  final TextEditingController userInputItemNameTextEditingController = TextEditingController();

  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);

    super.initState();

  }

  final TextEditingController inputSearchController = TextEditingController();
  PsValueHolder? psValueHolder;
  final FocusNode _searchFocusNode = FocusNode();
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  SearchHistoryProvider? searchHistoryProvider;
  SearchHistoryRepository? searchHistoryRepository;
  SearchResultRepository? searchResultRepository;
  BasketRepository? basketRepository;
  ProductRepository? repo1;
  bool isCallFirstTime = true;
  SearchHistory? searchHistory;
  SearchResultProvider? searchResultProvider ;
  List<Product>? itemList;
  final Dio dio = Dio();
  CancelToken cancelToken = CancelToken();
  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ProductRepository>(context);
    searchHistoryRepository = Provider.of<SearchHistoryRepository>(context);
    searchResultRepository = Provider.of<SearchResultRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    searchResultProvider = SearchResultProvider(searchResultRepository!);

    Future<bool> _requestPop() {
      animationController.reverse().then<dynamic>(
        (void data) {
          if (!mounted) {
            return Future<bool>.value(false);
          }
          Navigator.pop(context, true);
          return Future<bool>.value(true);
        },
      );
      return Future<bool>.value(false);
    }


    inputSearchController.text = widget.productParameterHolder.searchTerm!;
    final SearchResultParameterHolder holder = SearchResultParameterHolder(searchTerm: inputSearchController.text.trim());
    searchResultProvider!.loadSearchResult(holder.toMap());
    /*final Widget _searchTextFieldWidget = InkWell(
        key: _searchTextFieldKey,
      child: PsSearchTextFieldWidget(
            hintText:
            Utils.getString(context, 'search_history__app_bar_search'),
            textEditingController: inputSearchController,
            psValueHolder: psValueHolder,
            height: 40,
            onTextChange: (text){
              setState(() {
                    holder.setSearchTerm(text);
              });
            },
            //textInputAction: TextInputAction.search,
          )
      *//*onTap: () {
        dashboardViewKey.currentState?.onTapBack();
        //Navigator.pop(context);
        inputSearchController.clear();
      },*//*
    );*/



    return Scaffold(
      backgroundColor: PsColors.baseColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context)),
        titleSpacing: 0,
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: PsColors.mainColorWithWhite),
        title: InkWell(
            key: _searchTextFieldKey,
            child: PsSearchTextFieldWidget(
              hintText:
              Utils.getString(context, 'search_history__app_bar_search'),
              textEditingController: inputSearchController,
              psValueHolder: psValueHolder,
              height: 40,
              focusNode: _searchFocusNode,
              onTextChange: (String text){
                //setState(() {
                final SearchResultParameterHolder holder =
                SearchResultParameterHolder(
                    searchTerm: text);
                  searchResultProvider!.loadSearchResult(holder.toMap());
                widget.productParameterHolder.searchTerm = text;
                // });
              },
              //textInputAction: TextInputAction.search,
            )
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            // To disable the back button, return false.
            return false;
          },
          child: MultiProvider(
              providers: <SingleChildWidget>[
                // Use ValueListenableBuilder to listen to text changes

                ChangeNotifierProvider<SearchResultProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    final SearchResultParameterHolder holder =
                        SearchResultParameterHolder(
                            searchTerm: widget.productParameterHolder.searchTerm!);

                    searchResultProvider!.loadSearchResult(holder.toMap());
                    return searchResultProvider!;
                  },
                ),
                ChangeNotifierProvider<BasketProvider>(
                    lazy: false,
                    create: (BuildContext context) {
                      final BasketProvider basketProvider = BasketProvider(
                          repo: basketRepository!,
                          psValueHolder: psValueHolder);
                      basketProvider.loadBasketList();
                      return basketProvider;
                    }),
                ChangeNotifierProvider<SearchProductProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    final SearchProductProvider provider =
                        SearchProductProvider(
                            repo: repo1!, valueHolder: psValueHolder);
                    provider
                        .loadProductListByKey(widget.productParameterHolder);
                    //print(provider.productList.data?.first.name);
                    return provider;
                  },
                ),
                ChangeNotifierProvider<SearchHistoryProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    searchHistoryProvider =
                        SearchHistoryProvider(repo: searchHistoryRepository!);
                    return searchHistoryProvider!;
                  },
                )
              ],
              child: Consumer<SearchResultProvider>(builder:
                  (BuildContext context, SearchResultProvider searchResultProvider,
                      Widget? child) {
                //provider.loadSearchResult(holder.toMap());
                if (
                    //provider != null &&
                    // provider.productList != null &&
                searchResultProvider.searchResult.data != null) {
                  final List<Category> categoriesList =
                  searchResultProvider.searchResult.data!.categories!;
                  final List<SubCategory> subCategoriesList =
                  searchResultProvider.searchResult.data!.subCategories!;
                  itemList =
                  searchResultProvider.searchResult.data!.products!;

                  /*if (isCallFirstTime) {
                    ///
                    /// Add to Search History
                    ///
                    searchHistory =
                        SearchHistory(searchTeam: inputSearchController.text);
                    searchHistoryProvider!.addSearchHistoryList(searchHistory!);

                    isCallFirstTime = false;
                  }*/
                  if(inputSearchController.text == searchResultProvider.searchResult.data!.id)
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                  print('-----------------------------------building ui------------------------------------------');
                  return SingleChildScrollView(
                    child: Container(
                      color: PsColors.baseColor,
                      child: Column(
                        children: <Widget>[
                          /*_searchTextFieldWidget,*/

                          /*CustomResultListTileView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            viewAllPressed: () {
                              Navigator.pushNamed(
                                  context, RoutePaths.searchCategoryViewAll,
                                  arguments: <String, String>{
                                    'title': Utils.getString(
                                        context, 'search__categories'),
                                    'keyword':
                                        inputSearchController.text.trim(),
                                  });
                            },
                            title:
                                Utils.getString(context, 'search__categories'),
                            dataList: categoriesList,
                          ),
                          CustomResultListTileView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            viewAllPressed: () {
                              Navigator.pushNamed(context,
                                  RoutePaths.searchSubCategoryViewAll,
                                  arguments: <String, String>{
                                    'title': Utils.getString(
                                        context, 'search__sub_categories'),
                                    'keyword':
                                        inputSearchController.text.trim(),
                                  });
                            },
                            title: Utils.getString(
                                context, 'search__sub_categories'),
                            dataList: subCategoriesList,
                          ),*/
                          CustomItemResultListView(
                            fadeAnimation: fadeAnimation,
                            animationController: animationController,
                            productList: itemList!,
                            provider: searchResultProvider,
                            keyword: inputSearchController.text.trim(),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return PSProgressIndicator(searchResultProvider.searchResult.status);
                }
              }
              )
          )
      ),
    );
  }
}

class SearchItemListViewWidget extends StatefulWidget {
  const SearchItemListViewWidget({
    Key? key,
    required this.parameterHolder,
    required this.provider,
    required this.scrollController,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  final ProductParameterHolder parameterHolder;
  final SearchProductProvider provider;
  final ScrollController scrollController;
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  _SearchItemListViewWidgetState createState() =>
      _SearchItemListViewWidgetState();
}

class _SearchItemListViewWidgetState extends State<SearchItemListViewWidget> {
  @override
  Widget build(BuildContext context) {
    // final PsValueHolder valueHolder;   valueHolder = Provider.of<PsValueHolder>(context);

    return Stack(children: <Widget>[
      Container(
          child: RefreshIndicator(
        child: ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.provider.productList.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final int count = widget.provider.productList.data!.length;
              final Product product = widget.provider.productList.data![index];
              widget.animationController.forward();
              return FadeTransition(
                  opacity: widget.animation,
                  child: SearchItemListItem(
                    animationController: widget.animationController,
                    animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    ),
                    product: widget.provider.productList.data![index],
                    parameterHolder: widget.parameterHolder,
                    onTap: () {
                      final ProductDetailIntentHolder holder =
                          ProductDetailIntentHolder(
                        productId: product.id,
                        heroTagImage: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__IMAGE,
                        heroTagTitle: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__TITLE,
                        heroTagOriginalPrice:
                            widget.provider.hashCode.toString() +
                                product.id! +
                                PsConst.HERO_TAG__ORIGINAL_PRICE,
                        heroTagUnitPrice: widget.provider.hashCode.toString() +
                            product.id! +
                            PsConst.HERO_TAG__UNIT_PRICE,
                      );

                      Navigator.pushNamed(context, RoutePaths.productDetail,
                          arguments: holder);
                    },
                  ));
            }),
        onRefresh: () {
          return widget.provider.resetLatestProductList(
            widget.parameterHolder,
          );
        },
      )),
      PSProgressIndicator(widget.provider.productList.status)
    ]);
  }
}

class CustomResultListTileView extends StatefulWidget {
  const CustomResultListTileView({
    Key? key,
    required this.title,
    required this.dataList,
    required this.viewAllPressed,
    required this.animationController,
    required this.fadeAnimation,
  }) : super(key: key);
  final String title;
  final List<dynamic> dataList;
  final Function() viewAllPressed;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  @override
  State<CustomResultListTileView> createState() =>
      _CustomResultListTileViewState();
}

class _CustomResultListTileViewState extends State<CustomResultListTileView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.dataList.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        AnimatedBuilder(
          animation: widget.fadeAnimation,
          child: Container(
            color: PsColors.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 16,fontWeight: FontWeight.bold),
                  ),
                ),
                RawMaterialButton(
                    onPressed: widget.viewAllPressed,
                    child: Text(
                      Utils.getString(context, 'dashboard__view_all'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600,color: PsColors.mainColor),
                    )),
              ],
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: widget.fadeAnimation,
              child: child,
            );
          },
        ),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            itemCount: widget.dataList.length,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return AnimatedBuilder(
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController,
                    curve: Interval((1 / widget.dataList.length) * index, 1.0,
                        curve: Curves.fastOutSlowIn),
                  ),
                ),
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval(
                            (1 / widget.dataList.length) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    ),
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0,
                          100 *
                              (1.0 -
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
                                        CurvedAnimation(
                                          parent: widget.animationController,
                                          curve: Interval(
                                              (1 / widget.dataList.length) *
                                                  index,
                                              1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      )
                                      .value),
                          0.0),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    if (widget.dataList[index] is Category) {
                      Navigator.pushNamed(context, RoutePaths.subCategoryGrid,
                          arguments: widget.dataList[index]);
                    }

                    if (widget.dataList[index] is SubCategory) {
                      final ProductParameterHolder parameterHolder =
                          ProductParameterHolder()
                              .getSubCategoryByCatIdParameterHolder();
                      parameterHolder.subCatId = widget.dataList[index].id;
                      parameterHolder.catId = widget.dataList[index].catId;
                      final ProductListIntentHolder holder =
                          ProductListIntentHolder(
                              productParameterHolder: parameterHolder,
                              appBarTitle: widget.dataList[index].name);
                      Navigator.pushNamed(context, RoutePaths.filterProductList,
                          arguments: holder);
                    }
                  },
                  child: Container(
                    height: 45,
                    color: PsColors.baseColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(widget.dataList[index].name),
                        ),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: PsColors.mainColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
      ]);
    } else {
      return const SizedBox();
    }
  }
}

class CustomItemResultListView extends StatefulWidget {
  const CustomItemResultListView({
    Key? key,
    required this.productList,
    required this.provider,
    required this.keyword,
    required this.animationController,
    required this.fadeAnimation,
  }) : super(key: key);

  final List<Product> productList;
  final SearchResultProvider provider;
  final String keyword;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  @override
  State<CustomItemResultListView> createState() =>
      _CustomItemResultListViewState();
}

class _CustomItemResultListViewState extends State<CustomItemResultListView>
    with SingleTickerProviderStateMixin {
  String? qty;
  String colorId = '';
  //late String colorValue;
  //late bool checkAttribute;
  late Basket basket;
  late String id;
  //late double bottomSheetPrice;
  double totalOriginalPrice = 0.0;
  BasketSelectedAttribute basketSelectedAttribute = BasketSelectedAttribute();
  BasketSelectedAddOn basketSelectedAddOn = BasketSelectedAddOn();

  @override
  Widget build(BuildContext context) {
    final BasketProvider basketProvider = Provider.of<BasketProvider>(context);
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);
    if (widget.productList.isNotEmpty
        && widget.keyword != ''
    ) {
      return Column(
        children: <Widget>[
          AnimatedBuilder(
            animation: widget.fadeAnimation,
            child: Container(
              color: PsColors.backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Text(
                      Utils.getString(context, 'search__items'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ),
                  /*RawMaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RoutePaths.searchItemViewAll,
                            arguments: <String, String>{
                              'title': 'Items',
                              'keyword': widget.keyword,
                            });
                      },
                      child: Text(
                        Utils.getString(context, 'dashboard__view_all'),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 12.5, fontWeight: FontWeight.w600,color: PsColors.mainColor),
                      )),*/
                ],
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: widget.fadeAnimation,
                child: child,
              );
            },
          ),
          GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 0.84, maxCrossAxisExtent: 220),
              itemCount: widget.productList.length,
              itemBuilder: (BuildContext context, int index) {
                widget.animationController.forward();
                if (widget.provider.searchResult.status ==
                    PsStatus.BLOCK_LOADING) {
                  return Shimmer.fromColors(
                      baseColor: PsColors.grey,
                      highlightColor: PsColors.white,
                      child: const Row(children: <Widget>[
                        PsFrameUIForLoading(),
                      ]));
                } else {
                  final Product product =
                      widget.provider.searchResult.data!.products![index];
                  final Basket? basketPrd = basketProvider.basketList.data!.firstWhere((Basket item) => item.id == product.id, orElse: () => Basket());
                  return Container(
                    margin: const EdgeInsets.all(PsDimens.space4),
                      child:AnimatedBuilder(
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval(
                              (1 / widget.productList.length) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      ),
                      builder: (BuildContext context, Widget? child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: widget.animationController,
                              curve: Interval(
                                  (1 / widget.productList.length) * index, 1.0,
                                  curve: Curves.fastOutSlowIn),
                            ),
                          ),
                          child: Transform(
                            transform: Matrix4.translationValues(
                                0.0,
                                100 *
                                    (1.0 -
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(
                                          CurvedAnimation(
                                            parent:
                                            widget.animationController,
                                            curve: Interval(
                                                (1 /
                                                    widget.productList
                                                        .length) *
                                                    index,
                                                1.0,
                                                curve:
                                                Curves.fastOutSlowIn),
                                          ),
                                        )
                                            .value),
                                0.0),
                            child: child,
                          ),
                        );
                      },
                      child: ProductVerticalListItem(
                        basket: basketPrd,
                        coreTagKey: widget.provider.hashCode.toString() +
                            widget.productList[index].id!,
                        animationController: widget.animationController,
                        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: widget.animationController,
                            curve: Interval(
                                (1 / widget.productList.length) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        ),
                        product: widget.productList[index],
                        onTap: () {
                          final ProductDetailIntentHolder holder =
                              ProductDetailIntentHolder(
                            productId: product.id,
                            heroTagImage:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__IMAGE,
                            heroTagTitle:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__TITLE,
                            heroTagOriginalPrice:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__ORIGINAL_PRICE,
                            heroTagUnitPrice:
                                widget.productList.hashCode.toString() +
                                    product.id! +
                                    PsConst.HERO_TAG__UNIT_PRICE,
                          );
                          dashboardViewKey.currentState?.selectedProductDetailHolder = holder;
                          dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(
                              Utils.getString(context, 'product_detail__title'),
                              PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT);
                        },
                        onUpdateQuantityTap: (String? productQuantity) async{
                          //print(productQuantity!);

                          id =
                          '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                          basket = Basket(
                              id: id,
                              productId: product.id,
                              qty: productQuantity,
                              shopId: psValueHolder.shopId,
                              basketPrice: product.unitPrice,
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
                            basketProvider.deleteBasketByProduct(
                                basket);
                          }
                          else
                            await basketProvider.updateBasket(basket);

                          //reloadGrid();
                        },
                        onBasketTap: () async {

                              id =
                                  '${product.id}$colorId${basketSelectedAddOn.getSelectedaddOnIdByHeaderId()}${basketSelectedAttribute.getSelectedAttributeIdByHeaderId()}';
                              if (product.minimumOrder == '0') {
                                product.minimumOrder = '1';
                              }
                              basket = Basket(
                                  id: id,
                                  productId: product.id,
                                  qty: qty ?? product.minimumOrder,
                                  shopId: psValueHolder.shopId,
                                  selectedColorId: colorId,
                                  //selectedColorValue: colorValue,
                                  // ignore: unnecessary_null_comparison
                                  basketPrice:product.unitPrice,
                                  basketOriginalPrice: totalOriginalPrice == 0.0
                                      ? product.originalPrice
                                      : totalOriginalPrice.toString(),
                                  selectedAttributeTotalPrice:
                                      basketSelectedAttribute
                                          .getTotalSelectedAttributePrice()
                                          .toString(),
                                  product: product,
                                  basketSelectedAttributeList: 
                                      basketSelectedAttribute
                                      .getSelectedAttributeList(),
                                  basketSelectedAddOnList: 
                                      basketSelectedAddOn
                                      .getSelectedAddOnList());

                              await basketProvider.addBasket(basket);
                              Fluttertoast.showToast(
                                  msg: Utils.getString(context,
                                      'product_detail__success_add_to_basket'),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: PsColors.mainColor,
                                  textColor: PsColors.white);

                        },
                        valueHolder: psValueHolder,
                      )));
                }
              }),
        ],
      );
    }  else {
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: PsDimens.space32,
                ),
                Image.asset(
                  'assets/images/demo_alert.png',
                  height: 150,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: PsDimens.space32,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      PsDimens.space32, 0, PsDimens.space32, 0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        'Nothing Found',
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
  }
}
