import 'package:flutter/material.dart';
import 'package:flutterrestaurant/provider/subcategory/search_sub_category_provider.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../api/common/ps_status.dart';
import '../../../config/ps_colors.dart';
import '../../../config/ps_config.dart';
import '../../../constant/route_paths.dart';
import '../../../repository/sub_category_repository.dart';
import '../../../viewobject/holder/intent_holder/product_list_intent_holder.dart';
import '../../../viewobject/holder/product_parameter_holder.dart';
import '../../../viewobject/holder/sub_category_parameter_holder.dart';
import '../../../viewobject/sub_category.dart';
import '../../common/ps_ui_widget.dart';
import '../../subcategory/item/sub_cateagory_grid_item.dart';
import '../../subcategory/list/sub_category_grid_view.dart';

class SearchSubCategoryViewAll extends StatefulWidget {
  const SearchSubCategoryViewAll({
    required this.keyword,
  });
  final String keyword;
  @override
  _SearchSubCategoryViewAllState createState() =>
      _SearchSubCategoryViewAllState();
}

final ScrollController _scrollController = ScrollController();
late AnimationController animationController;
late Animation<double> animation;
SubCategoryRepository? subCategoryRepository;
late SearchSubCategoryProvider provider;
late SubCategoryParameterHolder holder;

class _SearchSubCategoryViewAllState extends State<SearchSubCategoryViewAll>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        holder.searchTerm = widget.keyword;
        provider.loadNextSubCategoryList(holder);
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  bool isConnectedToInternet = false;


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

  @override
  Widget build(BuildContext context) {
    subCategoryRepository = Provider.of<SubCategoryRepository>(context);
    final PsValueHolder valueHolder = Provider.of<PsValueHolder>(context);
 

    return WillPopScope(
        onWillPop: _requestPop,
        child: ChangeNotifierProvider<SearchSubCategoryProvider>(
            create: (BuildContext context) {
          provider = SearchSubCategoryProvider(
              repo: subCategoryRepository!, valueHolder: valueHolder);
          holder = SubCategoryParameterHolder();
          holder.searchTerm = widget.keyword;
          provider.loadSubCategoryListByKey(holder);
          return provider;
        }, child: Consumer<SearchSubCategoryProvider>(builder:
                (_, SearchSubCategoryProvider searchSubCategoryProvider, __) {
          if (searchSubCategoryProvider.subCategoryList.data != null) {
            return Column(
              children: <Widget>[
                /*const PsAdMobBannerWidget(admobSize: AdSize.banner),*/
                Expanded(
                  child: Stack(children: <Widget>[
                    Container(
                        child: RefreshIndicator(
                      onRefresh: () {
                        return provider.resetSubCategoryList(
                          holder,
                        );
                      },
                      child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 240,
                                      childAspectRatio: 1.4),
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  final List<SubCategory> subCategoryList =
                                      searchSubCategoryProvider
                                          .subCategoryList.data!;
                                  if (searchSubCategoryProvider
                                          .subCategoryList.status ==
                                      PsStatus.BLOCK_LOADING) {
                                    return Shimmer.fromColors(
                                        baseColor: PsColors.grey,
                                        highlightColor: PsColors.white,
                                        child: const Column(children: <Widget>[
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                          FrameUIForLoading(),
                                        ]));
                                  } else {
                                    final int count = subCategoryList.length;
                                    return SubCategoryGridItem(
                                      subCategory: subCategoryList[index],
                                      onTap: () {
                                        final ProductParameterHolder
                                            productParameterHolder =
                                            ProductParameterHolder()
                                                .getSubCategoryByCatIdParameterHolder();
                                        productParameterHolder.subCatId =
                                            searchSubCategoryProvider
                                                .subCategoryList
                                                .data![index]
                                                .id;
                                        productParameterHolder.catId =
                                            searchSubCategoryProvider
                                                .subCategoryList
                                                .data![index]
                                                .catId;
                                        Navigator.pushNamed(context,
                                            RoutePaths.filterProductList,
                                            arguments: ProductListIntentHolder(
                                                appBarTitle:
                                                    subCategoryList[index]
                                                        .name!,
                                                productParameterHolder:
                                                    productParameterHolder));
                                      },
                                      animationController: animationController,
                                      animation:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(CurvedAnimation(
                                        parent: animationController,
                                        curve: Interval(
                                            (1 / count) * index, 1.0,
                                            curve: Curves.fastOutSlowIn),
                                      )),
                                    );
                                  }
                                },
                                childCount: searchSubCategoryProvider
                                    .subCategoryList.data!.length,
                              ),
                            ),
                          ]),
                    )),
                    PSProgressIndicator(
                      searchSubCategoryProvider.subCategoryList.status,
                      message:
                          searchSubCategoryProvider.subCategoryList.message,
                    )
                  ]),
                )
              ],
            );
          } else {
            return Container();
          }
        })));
  }
}
