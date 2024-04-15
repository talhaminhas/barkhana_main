import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/provider/category/category_provider.dart';
import 'package:flutterrestaurant/repository/category_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/category_parameter_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'filter_expantion_tile_view.dart';

class FilterListView extends StatefulWidget {
  const FilterListView({this.selectedData});

  final dynamic selectedData;

  @override
  State<StatefulWidget> createState() => _FilterListViewState();
}

class _FilterListViewState extends State<FilterListView> {
  final ScrollController _scrollController = ScrollController();

  final CategoryParameterHolder categoryIconList = CategoryParameterHolder();
  CategoryRepository? categoryRepository;
  PsValueHolder? psValueHolder;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onSubCategoryClick(Map<String, String> subCategory) {
    Navigator.pop(context, subCategory);
  }

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
   
    categoryRepository = Provider.of<CategoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    return PsWidgetWithAppBar<CategoryProvider>(
        appBarTitle: Utils.getString(context, 'search__category'),
        initProvider: () {
          return CategoryProvider(
              repo: categoryRepository!, psValueHolder: psValueHolder);
        },
        onProviderReady: (CategoryProvider provider) {
          provider.loadAllCategoryList(categoryIconList.toMap());
        },
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.abc_sharp,
                color: PsColors.mainColor),
            onPressed: () {
              final Map<String, String> dataHolder = <String, String>{};
              dataHolder[PsConst.CATEGORY_ID] = '';
              dataHolder[PsConst.SUB_CATEGORY_ID] = '';
              onSubCategoryClick(dataHolder);
            },
          )
        ],
        builder:
            (BuildContext context, CategoryProvider provider, Widget? child) {
          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  /*const PsAdMobBannerWidget(admobSize: AdSize.banner),*/
                  Container(
                    child: RefreshIndicator(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: provider.categoryList.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (provider.categoryList.data != null ||
                                provider.categoryList.data!.isEmpty) {
                              return FilterExpantionTileView(
                                  selectedData: widget.selectedData,
                                  category: provider.categoryList.data![index],
                                  onSubCategoryClick: onSubCategoryClick);
                            } else {
                              return Container();
                            }
                          }),
                      onRefresh: () {
                        return provider
                            .resetCategoryList(categoryIconList.toMap());
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
