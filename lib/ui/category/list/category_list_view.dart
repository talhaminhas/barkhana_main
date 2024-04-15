import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/category/category_provider.dart';
import 'package:flutterrestaurant/repository/category_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/category_parameter_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../config/ps_colors.dart';
import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../repository/shop_info_repository.dart';

class CategoryListView extends StatefulWidget {
  /*const CategoryListView({
    Key? key,
    required this.valueHolder,
  }) : super(key: key);
  final PsValueHolder valueHolder;*/
  @override
  _CategoryListViewState createState() {
    return _CategoryListViewState();
  }
}

class _CategoryListViewState extends State<CategoryListView>
    with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();
  CategoryProvider? _categoryProvider;
  final CategoryParameterHolder categoryIconList = CategoryParameterHolder();
  ShopInfoRepository? shopInfoRepository;
  ShopInfoProvider? shopInfoProvider;
  PsValueHolder? valueHolder;
  AnimationController? animationController;
  Animation<double> ?animation;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }
  List<IconData>? icons;
  List<String>? iconsLabel;
  AnimationController? _animationControllerShopInfo;
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _categoryProvider!.nextCategoryList(categoryIconList.toMap());
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  CategoryRepository? repo1;
  ShopInfoRepository? repo2;
  PsValueHolder? psValueHolder;
  dynamic data;

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
    //shopInfoProvider = Provider.of<ShopInfoProvider>(context, listen: false);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    /*shopInfoProvider = ShopInfoProvider(
        repo: shopInfoRepository!,
        psValueHolder: valueHolder,
        ownerCode: 'HomeDashboardViewWidget');*/
    //shopInfoProvider!.loadShopInfo();
    valueHolder = Provider.of<PsValueHolder>(context);
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ShopInfoRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    Future<bool> _requestPop() {
      animationController!.reverse().then<dynamic>(
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

    //final shopInfo = Provider.of<ShopInfo>(context);
    print(
        '............................Build UI Again ............................');
    //print('${_HomeDashboardViewWidgetState.t}');
    return WillPopScope(
        onWillPop: _requestPop,

        child: ChangeNotifierProvider<CategoryProvider>(

            lazy: false,
            /*create: (BuildContext context) {
            shopInfoProvider = ShopInfoProvider(
            repo: repo2!,
            psValueHolder: psValueHolder,
            ownerCode: 'CategoryListView');
            shopInfoProvider!.loadShopInfo();
            return shopInfoProvider!;
            },*/
            create: (BuildContext context) {
              final CategoryProvider provider =
                  CategoryProvider(repo: repo1!, psValueHolder: psValueHolder);
              provider.loadCategoryList(/*categoryIconList.toMap()*/);
              _categoryProvider = provider;
              return _categoryProvider!;

            },

            child: Consumer<CategoryProvider>(builder: (BuildContext context,
                CategoryProvider provider, Widget? child) {
              return Stack(children: <Widget>[
                Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      const SizedBox(
                    width: PsDimens.space4,
                  ),
                  Flexible(
                    child: InkWell(
                        child: Container(
                            height: PsDimens.space44,
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                                top: PsDimens.space12,
                                left: PsDimens.space16,
                                right: PsDimens.space4,
                                bottom: PsDimens.space12),
                            decoration: BoxDecoration(
                              color: PsColors.baseDarkColor,
                              borderRadius: BorderRadius.circular(PsDimens.space4),
                              border: Border.all(color: PsColors.mainDividerColor),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(left: PsDimens.space8),
                                    child: Icon(
                                      Icons.search,
                                      color: PsColors.iconColor,
                                      size: 26,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space8),
                                    child: Text(
                                        Utils.getString(
                                            context, 'home__bottom_app_bar_search'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                    ),
                                  ),
                                ])),
                        onTap: () {
                          Navigator.pushNamed(
                              context, RoutePaths.searchHistory);
                        }),
                  ),
                  const SizedBox(
                  width: PsDimens.space16,
                  height: PsDimens.space10,
                ),],),
                  /*Container(
                      margin: const EdgeInsets.only(
                          bottom: PsDimens.space12, right: PsDimens.space12),
                      child: _FloatingActionButton(
                        icons: icons!,
                        label: iconsLabel!,
                        controller: _animationControllerShopInfo!,
                        psValueHolder: widget.valueHolder,
                      )),*/
                  /*const PsAdMobBannerWidget(
                    admobSize: AdSize.banner
                  ),*/
                  /*const SizedBox(
                    height: PsDimens.space6,
                  ),*/
                  /*Padding(
                    padding: const EdgeInsets.only(left: PsDimens.space16),
                    child: Text(
                      '',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            height: 1.6)),
                  ),*/
                    /*Row(
                    children: <Widget>[
    const SizedBox(
    width: PsDimens.space4,
    ),
    Flexible(
                  child: InkWell(
                    child: Container(
                      height: PsDimens.space44,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: PsDimens.space12,
                        left: PsDimens.space16,
                        right: PsDimens.space4,
                        bottom: PsDimens.space12),
                      decoration: BoxDecoration(
                        color: PsColors.baseDarkColor,
                        borderRadius: BorderRadius.circular(PsDimens.space4),
                        border: Border.all(color: PsColors.mainDividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(left: PsDimens.space8),
                          child: Icon(
                            Icons.search,
                            color: PsColors.iconColor,
                            size: 26,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: PsDimens.space8),
                            child: Text(
                              Utils.getString(
                                  context, 'home__bottom_app_bar_search'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                            ),
                          ),
                        ])),
                        onTap: () {
                          Navigator.pushNamed(
                            context, RoutePaths.searchHistory);
                    }),
                ),),*/
                  /*Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: PsDimens.space8,
                            right: PsDimens.space8,
                            top: PsDimens.space8,
                            bottom: PsDimens.space8),
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
                                          maxCrossAxisExtent: 100.0,
                                          childAspectRatio: 0.8),
                                  *//*const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),*//*
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (provider.categoryList.data != null ||
                                          provider
                                              .categoryList.data!.isNotEmpty) {
                                        final int count =
                                            provider.categoryList.data!.length;
                                        return CategoryVerticalListItem(
                                          animationController:
                                              animationController,
                                          animation: Tween<double>(
                                                  begin: 0.0, end: 1.0)
                                              .animate(
                                            CurvedAnimation(
                                              parent: animationController!,
                                              curve: Interval(
                                                  (1 / count) * index, 1.0,
                                                  curve: Curves.fastOutSlowIn),
                                            ),
                                          ),
                                          category:
                                              provider.categoryList.data![index],
                                          onTap: () {
                                            if(PsConfig.isShowSubCategory){
                                                Navigator.pushNamed(
                                                  context, RoutePaths.subCategoryGrid,
                                                  arguments: provider
                                                      .categoryList
                                                      .data![index]);
                                              }else{
                                                final String loginUserId =
                                                        Utils.checkUserLoginId(
                                                            psValueHolder!);
                                                    final TouchCountParameterHolder
                                                        touchCountParameterHolder =
                                                        TouchCountParameterHolder(
                                                            typeId: provider
                                                                .categoryList
                                                                .data![index]
                                                                .id!,
                                                            typeName: PsConst
                                                                .FILTERING_TYPE_NAME_CATEGORY,
                                                            userId: loginUserId,
                                                            );

                                                    provider.postTouchCount(
                                                        touchCountParameterHolder
                                                            .toMap());
                                                            
                                          
                                            final ProductParameterHolder
                                                productParameterHolder =
                                                ProductParameterHolder()
                                                    .getLatestParameterHolder();
                                            productParameterHolder.catId =
                                                provider.categoryList
                                                    .data![index].id;
                                            Navigator.pushNamed(context,
                                                RoutePaths.filterProductList,
                                                arguments:
                                                    ProductListIntentHolder(
                                                  appBarTitle: provider
                                                      .categoryList
                                                      .data![index]
                                                      .name!,
                                                  productParameterHolder:
                                                      productParameterHolder,
                                                ));
                                              }
                                          },
                                        );
                                      } else {
                                        return null;
                                      }
                                    },
                                    childCount:
                                        provider.categoryList.data!.length,
                                  ),
                                ),
                              ]),
                          onRefresh: () {
                            return provider
                                .resetCategoryList(categoryIconList.toMap());
                          },
                        )),
                  ),*/
                ]),
                PSProgressIndicator(provider.categoryList.status)
              ]);
            }))
    );
  }
}
class _FloatingActionButton extends StatefulWidget {
  const _FloatingActionButton({
    Key? key,
    required this.controller,
    required this.icons,
    required this.label,
    required this.psValueHolder,
  }) : super(key: key);

  final AnimationController controller;
  final List<IconData> icons;
  final List<String> label;
  final PsValueHolder psValueHolder;

  @override
  __FloatingActionButtonState createState() => __FloatingActionButtonState();
}

class __FloatingActionButtonState extends State<_FloatingActionButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(widget.icons.length, (int index) {
        Widget _getChip() {
          return Chip(
            backgroundColor: PsColors.mainColor,
            label: InkWell(
              onTap: () async {
                print(index);
              },
              child: Text(
                widget.label[index],
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PsColors.white,
                ),
              ),
            ),
          );
        }

        final Widget child = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: PsDimens.space8),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: widget.controller,
                  curve: Interval((index + 1) / 10, 1.0, curve: Curves.easeIn),
                ),
                child: _getChip(),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: PsDimens.space4, vertical: PsDimens.space2),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: widget.controller,
                  curve: Interval(0.0, 1.0 - index / widget.icons.length / 2.0,
                      curve: Curves.easeIn),
                ),
                child: FloatingActionButton(
                  heroTag: widget.label[index],
                  backgroundColor: PsColors.mainColor,
                  mini: true,
                  child: Icon(widget.icons[index], color: PsColors.white),
                  onPressed: () async {
                    print(index);

                    if (index == 0) {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.shop_info_container,
                      );
                    } else {
                      Utils.navigateOnUserVerificationView(context, () async {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.createreservationContainer,
                        );
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );
        return child;
      }).toList()
        ..add(
          Container(
            margin: const EdgeInsets.only(top: PsDimens.space8),
            child: FloatingActionButton(
              backgroundColor: PsColors.mainColor,
              child: AnimatedBuilder(
                animation: widget.controller,
                child: Icon(
                  widget.controller.isDismissed
                      ? Icons.restaurant_menu
                      : Icons.restaurant_menu,
                  color: PsColors.white,
                ),
                builder: (BuildContext context, Widget? child) {
                  return Transform(
                    transform:
                    Matrix4.rotationZ(widget.controller.value * 0.5 * 8),
                    alignment: FractionalOffset.center,
                    child: child,
                  );
                },
              ),
              onPressed: () {
                if (widget.controller.isDismissed) {
                  widget.controller.forward();
                } else {
                  widget.controller.reverse();
                }
              },
            ),
          ),
        ),
    );
  }
}
