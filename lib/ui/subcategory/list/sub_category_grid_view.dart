
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/subcategory/sub_category_provider.dart';
import 'package:flutterrestaurant/repository/sub_category_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/subcategory/item/sub_cateagory_grid_item.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constant/ps_constants.dart';
import '../../dashboard/core/drawer_view.dart';


class SubCategoryGridView extends StatefulWidget {
  const SubCategoryGridView({this.category});
  final Category ?category;
  @override
  _ModelGridViewState createState() {
    return _ModelGridViewState();
  }
}

class _ModelGridViewState extends State<SubCategoryGridView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  SubCategoryProvider? _subCategoryProvider;
  PsValueHolder? valueHolder;

  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final String categoryId = widget.category!.id!;
        Utils.psPrint('CategoryId number is $categoryId');

        _subCategoryProvider!.nextSubCategoryList(widget.category!.id!,
       );
      }
    });
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  SubCategoryRepository? repo1;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
  
    timeDilation = 1.0;
    repo1 = Provider.of<SubCategoryRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    // final dynamic data = EasyLocalizationProvider.of(context).data;

    // return EasyLocalizationProvider(
    //     data: data,
    //     child:
    return Scaffold(
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
            child: AppBar(
          backgroundColor: PsColors.mainColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ), 
          title: Text(
            widget.category!.name!,
            // style: TextStyle(color: PsColors.white),
          ),
          iconTheme: IconThemeData(
            color: PsColors.white,
          ),
        )),

        body: ChangeNotifierProvider<SubCategoryProvider>(
            lazy: false,
            create: (BuildContext context) {
              _subCategoryProvider = SubCategoryProvider(repo: repo1!,
              psValueHolder: valueHolder);
              _subCategoryProvider!.loadAllSubCategoryList(widget.category!.id!,
              );
              return _subCategoryProvider!;
            },
            child: Consumer<SubCategoryProvider>(builder:
                (BuildContext context, SubCategoryProvider provider, Widget? child) {
              return Column(
                children: <Widget>[
                  /*const PsAdMobBannerWidget(
                    admobSize: AdSize.banner
                  ),*/
                  Expanded(
                    child: Stack(children: <Widget>[
                      Container(
                          child: RefreshIndicator(
                        onRefresh: () {
                          return _subCategoryProvider!
                              .resetSubCategoryList(widget.category!.id!, 
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
                                        childAspectRatio: 1.2),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    if (provider.subCategoryList.status ==
                                        PsStatus.BLOCK_LOADING) {
                                      return Shimmer.fromColors(
                                          baseColor: PsColors.grey,
                                          highlightColor: PsColors.white,
                                          child:
                                              const Column(children: <Widget>[
                                            FrameUIForLoading(),
                                            FrameUIForLoading(),
                                            FrameUIForLoading(),
                                            FrameUIForLoading(),
                                            FrameUIForLoading(),
                                            FrameUIForLoading(),
                                          ]));
                                    } else {
                                      final int count =
                                          provider.subCategoryList.data!.length;
                                      return SubCategoryGridItem(
                                        subCategory: provider.subCategoryList.data![index],
                                        onTap: () {
                                          provider.subCategoryByCatIdParamenterHolder
                                                  .catId =
                                              provider.subCategoryList.data![index]
                                                  .catId;
                                          provider.subCategoryByCatIdParamenterHolder
                                                  .subCatId =
                                              provider.subCategoryList.data![index].id;
                                          dashboardViewKey.currentState?.selectedProductParameterHolder =
                                              provider
                                                  .subCategoryByCatIdParamenterHolder;
                                              dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(
                                                  provider.subCategoryList.data![index].name!,
                                              PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_PRODUCTS_FRAGMENT);
                                          /*Navigator.pushNamed(context,
                                              RoutePaths.filterProductList,
                                              arguments: ProductListIntentHolder(
                                                  appBarTitle: provider
                                                      .subCategoryList
                                                      .data![index]
                                                      .name!,
                                                  productParameterHolder: provider
                                                      .subCategoryByCatIdParamenterHolder));*/
                                        },
                                        animationController:
                                            animationController,
                                        animation:
                                            Tween<double>(begin: 0.0, end: 1.0)
                                                .animate(CurvedAnimation(
                                          parent: animationController!,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.fastOutSlowIn),
                                        )),
                                      );
                                    }
                                  },
                                  childCount: provider.subCategoryList.data!.length,
                                ),
                              ),
                            ]),
                      )),
                      PSProgressIndicator(provider.subCategoryList.status,
                      message: provider.subCategoryList.message,)
                    ]),
                  )
                ],
              );
            }))
        // )
        );
  }
}

class FrameUIForLoading extends StatelessWidget {
  const FrameUIForLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            height: 70,
            width: 70,
            margin: const EdgeInsets.all(PsDimens.space16),
            decoration: BoxDecoration(color: PsColors.grey)),
        Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
              height: 15,
              margin: const EdgeInsets.all(PsDimens.space8),
              decoration: BoxDecoration(color: Colors.grey[300])),
          Container(
              height: 15,
              margin: const EdgeInsets.all(PsDimens.space8),
              decoration: const BoxDecoration(color: Colors.grey)),
        ]))
      ],
    );
  }
}
