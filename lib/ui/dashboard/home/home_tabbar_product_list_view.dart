import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/ui/collection/dashboard/dashboard_collection_header_list_view.dart';
import 'package:flutterrestaurant/ui/dashboard/home/product_list_view.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/shop_info.dart';

import '../../../config/ps_config.dart';
import '../../../provider/category/category_provider.dart';
import '../../../viewobject/holder/category_parameter_holder.dart';
import '../../../viewobject/holder/intent_holder/product_list_intent_holder.dart';
import '../../../viewobject/holder/product_parameter_holder.dart';
import '../../../viewobject/holder/touch_count_parameter_holder.dart';
import '../../category/item/category_vertical_list_item.dart';
import '../core/drawer_view.dart';

class HomeTabbarProductListView extends StatefulWidget {
  const HomeTabbarProductListView({
    Key? key,
    required this.shopInfo,
    //required this.animationController,
    required this.categoryList,
    //required this.userInputItemNameTextEditingController,
    required this.valueHolder,
    required this.categoryProvider,
    required this.onTapCategory
  }) : super(key: key);

  final ShopInfo shopInfo;
  final CategoryProvider categoryProvider;
  //final AnimationController animationController;
  final List<Category> categoryList;
  //final TextEditingController userInputItemNameTextEditingController;
  final PsValueHolder valueHolder;
  final Function (Category category) onTapCategory;
  @override
  _HomeTabbarProductListViewState createState() =>
      _HomeTabbarProductListViewState();
}

class _HomeTabbarProductListViewState extends State<HomeTabbarProductListView>
    with TickerProviderStateMixin {
  // TickerProviderStateMixin allows the fade out/fade in animation when changing the active labelLarge

  // this will control the labelLarge clicks and tab changing
  TabController? _controller;

  // this will control the animation when a labelLarge changes from an off state to an on state
  //AnimationController? _animationControllerOn;

  // this will control the animation when a labelLarge changes from an on state to an off state
  //AnimationController? _animationControllerOff;

  AnimationController? _animationControllerShopInfo;
  AnimationController? animationController;

  // this will give the background color values of a labelLarge when it changes to an on state
  Animation<dynamic>? _colorTweenBackgroundOn;
  Animation<dynamic>? _colorTweenBackgroundOff;

  // when swiping, the _controller.index value only changes after the animation, therefore, we need this to trigger the animations and save the current index
  int _currentIndex = 0;

  // saves the previous active tab
  int _prevControllerIndex = 0;

  // saves the value of the tab animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  double _aniValue = 0.0;

  // saves the previous value of the tab animation. It's used to figure the direction of the animation
  double _prevAniValue = 0.0;

  // active labelLarge's background color
  final Color _backgroundOn = PsColors.mainColor;
  final Color _backgroundOff = Colors.transparent;

  // scroll controller for the TabBar
  final ScrollController _scrollController = ScrollController();

  // this will save the keys for each Tab in the Tab Bar, so we can retrieve their position and size for the scroll controller
  final List<dynamic> _keys = <dynamic>[];
  final List<dynamic> _viewkeys = <dynamic>[];

  int? monOpenHour, monCloseHour, monOpenMin, monCloseMin;
  int? tuesOpenHour, tuesCloseHour, tuesOpenMin, tuesCloseMin;
  int? wedOpenHour, wedCloseHour, wedOpenMin, wedCloseMin;
  int? thursOpenHour, thursCloseHour, thursOpenMin, thursCloseMin;
  int? friOpenHour, friCloseHour, friOpenMin, friCloseMin;
  int? satOpenHour, satCloseHour, satOpenMin, satCloseMin;
  int? sunOpenHour, sunCloseHour, sunOpenMin, sunCloseMin;

  int? hour, minute;
  String? days;

  // regist if the the labelLarge was tapped
  bool _buttonTap = false;

  Map<int, bool> callFromDBIndexList = <int, bool>{};
  Map<int, Widget> widgetList = <int, Widget>{};

  List<IconData>? icons;
  List<String>? iconsLabel;

  @override
  void initState() {
    super.initState();

    // this creates the controller with 6 tabs (in our case)
    _controller =
        TabController(vsync: this, length: 1/*widget.categoryList.length*/);
    // this will execute the function every time there's a swipe animation
    //_controller!.animation!.addListener(_handleTabAnimation);
    // this will execute the function every time the _controller.index value changes
    //_controller!.addListener(_handleTabChange);

   /* _animationControllerOff = AnimationController(
        vsync: this,
        duration:
            const Duration(microseconds: 140)); //PsConfig.animation_duration);
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff!.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: _backgroundOn, end: _backgroundOff)
            .animate(_animationControllerOff!);

    _animationControllerOn = AnimationController(
        vsync: this,
        duration:
            const Duration(microseconds: 140)); //PsConfig.animation_duration);
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOn!.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn!);*/

    _animationControllerShopInfo = AnimationController(
        vsync: this, duration: const Duration(microseconds: 140));
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
  }


  @override
  void dispose() {
    animationController!.dispose();
    _controller!.dispose();
    //_animationControllerOff!.dispose();
    //_animationControllerOn!.dispose();
    _animationControllerShopInfo!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _controller =
    //     TabController(vsync: this, length: widget.categoryList.length);
    //print('widget.categoryList.length' + widget.categoryList.length.toString());

    for (int index = 0; index < widget.categoryList.length; index++) {
      // create a GlobalKey for each Tab
      if (
        //_keys != null &&
        _keys.length <= index) {
        _keys.add(GlobalKey());
        _viewkeys.add(GlobalKey());
      }
    }

    icons = widget.valueHolder.phone == ''
        ? <IconData>[]
        : widget.valueHolder.phone == ''
            ? <IconData>[
                FontAwesome5.shopping_bag,
                /*Icons.note_add,*/
              ]
            : <IconData>[
                // MaterialCommunityIcons.facebook_messenger,
                FontAwesome5.shopping_bag,
                /*Icons.note_add,*/
              ];
    iconsLabel = widget.valueHolder.phone == ''
        ? <String>[]
        : widget.valueHolder.phone == ''
            ? <String>[]
            : <String>[
                Utils.getString(context, 'reservation_shop_info'),
               /* Utils.getString(
                    context, 'home__menu_drawer_create_reservation'),
                Utils.getString(context, 'home__menu_drawer_create_reservation')*/
              ];
    /*final List<int> fixedList =
        Iterable<int>.generate(widget.categoryList.length).toList();*/
    return Scaffold(
      backgroundColor: PsColors.baseColor,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            const SizedBox(
                height: PsDimens.space6,
              ),
              Padding(
                padding: const EdgeInsets.only(left: PsDimens.space16),
                child: Text(
                  widget.shopInfo.address1!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      height: 1.6)),
              ),
            if(widget.shopInfo.shopSchedules != null)
              getOpenAndCloseTime(),
            const Row(
              children: <Widget>[
                /*const SizedBox(
                  width: PsDimens.space4,
                ),*/
                /*Flexible(
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
                ),*/
                /*const SizedBox(
                  width: PsDimens.space16,
                  height: PsDimens.space10,
                ),*/],),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      left: PsDimens.space8,
                      right: PsDimens.space8,
                      top: PsDimens.space8,
                      ),
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
                                  maxCrossAxisExtent: 200.0,
                                  childAspectRatio: 1
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  if (widget.categoryProvider.categoryList.data != null ||
                                      widget.categoryProvider
                                          .categoryList.data!.isNotEmpty) {
                                    final int count =
                                        widget.categoryProvider.categoryList.data!.length;
                                    return CategoryVerticalListItem(
                                     /* animationController: animationController,
                                      animation: Tween<double>(
                                          begin: 0.0, end: 1.0)
                                          .animate(
                                        CurvedAnimation(
                                          parent: animationController!,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.bounceIn),
                                        ),
                                      ),*/
                                      category:
                                      widget.categoryProvider.categoryList.data![index],
                                      onTap: () {
                                        if(PsConfig.isShowSubCategory){
                                          /*Navigator.pushNamed(
                                              context, RoutePaths.subCategoryGrid,
                                              arguments: widget.categoryProvider
                                                  .categoryList
                                                  .data![index]);*/
                                          //
                                          final Category selectedCategory = widget.categoryProvider
                                              .categoryList
                                              .data![index];

                                          dashboardViewKey.currentState?.selectedCategory = selectedCategory;
                                          dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(
                                              selectedCategory.name!,
                                              PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT);
                                          //widget.onTapCategory(widget.categoryProvider.categoryList.data![index]);
                                        }else{
                                          final String loginUserId =
                                          Utils.checkUserLoginId(
                                              widget.valueHolder);
                                          final TouchCountParameterHolder
                                          touchCountParameterHolder =
                                          TouchCountParameterHolder(
                                            typeId: widget.categoryProvider
                                                .categoryList
                                                .data![index]
                                                .id!,
                                            typeName: PsConst
                                                .FILTERING_TYPE_NAME_CATEGORY,
                                            userId: loginUserId,
                                          );

                                          widget.categoryProvider.postTouchCount(
                                              touchCountParameterHolder
                                                  .toMap());


                                          final ProductParameterHolder
                                          productParameterHolder =
                                          ProductParameterHolder()
                                              .getLatestParameterHolder();
                                          productParameterHolder.catId =
                                              widget.categoryProvider.categoryList
                                                  .data![index].id;
                                          Navigator.pushNamed(context,
                                              RoutePaths.filterProductList,
                                              arguments:
                                              ProductListIntentHolder(
                                                appBarTitle: widget.categoryProvider
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
                                widget.categoryProvider.categoryList.data!.length,
                              ),
                            ),
                          ]),
                      onRefresh: () {
                        return widget.categoryProvider
                            .resetCategoryList(CategoryParameterHolder().toMap());
                      },
                    ))
                ),

                // Container(
                //   height: PsDimens.space44,
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //     color: PsColors.baseDarkColor,
                //     borderRadius: BorderRadius.circular(PsDimens.space4),
                //     border: Border.all(color: PsColors.mainDividerColor),
                //   ),
                //   child: InkWell(
                //       child: Container(
                //         height: double.infinity,
                //         width: PsDimens.space44,
                //         child: Icon(
                //           Octicons.settings,
                //           color: PsColors.iconColor,
                //           size: PsDimens.space20,
                //         ),
                //       ),
                //       onTap: () async {
                //         productParameterHolder.searchTerm =
                //             widget.userInputItemNameTextEditingController.text;
                //         Utils.psPrint(productParameterHolder.searchTerm);
                //         Navigator.pushNamed(
                //             context, RoutePaths.dashboardsearchFood,
                //             arguments: ProductListIntentHolder(
                //                 appBarTitle: Utils.getString(
                //                     context, 'home_search__app_bar_title'),
                //                 productParameterHolder:
                //                     productParameterHolder));
                //       }),
                // ),



            // this is the TabBar
            /*Container(
              height: PsDimens.space48,
              // this generates our tabs buttons
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: PsDimens.space20,
                    ),
                    Row(
                        children: fixedList.map((int index) {
                      return Padding(
                          // each labelLarge's key
                          key: _keys[index],
                          // padding for the buttons
                          padding:
                              // index == 0
                              //     ? const EdgeInsets.only(left: PsDimens.space20)
                              // :
                              const EdgeInsets.only(left: PsDimens.space1),
                          child: ButtonTheme(
                              child: AnimatedBuilder(
                            animation: _colorTweenBackgroundOn!,
                            builder: (BuildContext context, Widget? child) {
                              return Container(
                                width: 160,
                                height: 40,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  color: _getBackgroundColor(index),
                                ),
                                child: Material(
                                  color: PsColors.transparent,
                                  type: MaterialType.card,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(PsDimens.space8),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _buttonTap = true;
                                        // trigger the controller to change between Tab Views
                                        _controller!.animateTo(index);
                                        // set the current index
                                        _setCurrentIndex(index);
                                        // scroll to the tapped labelLarge (needed if we tap the active labelLarge and it's not on its position)
                                        _scrollTo(index);
                                      });
                                    },
                                    highlightColor: PsColors.mainDarkColor,
                                    child: Center(
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(
                                            left: PsDimens.space8,
                                            right: PsDimens.space8),
                                        child: Text(
                                          widget.categoryList[index].name!,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                  color: _getTextColor(index)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )));
                    }).toList()),
                  ],
                ),
              ),
            ),*/
            /*Flexible(

                // this will host our Tab Views
                child: TabBarView(
              key: const Key('_1'),
              // and it is controlled by the controller
              controller: _controller,
              children: <Widget>[
                for (int i = 0; i < widget.categoryList.length; i++)
                  getWidget(i, _currentIndex)
              ],
            )),*/
          ]),
          Container(
              margin: const EdgeInsets.only(
                  bottom: PsDimens.space12, right: PsDimens.space12),
              child: _FloatingActionButton(
                icons: icons!,
                label: iconsLabel!,
                controller: _animationControllerShopInfo!,
                psValueHolder: widget.valueHolder,
              )),
          // child: FloatingActionButton(
          //   heroTag: '',
          //   backgroundColor: PsColors.mainColor,
          //   mini: false,
          //   child: Icon(
          //     Feather.shopping_bag,
          //     color: PsColors.white,
          //   ),
          //   onPressed: () async {
          //     Navigator.pushNamed(
          //       context,
          //       RoutePaths.shop_info_container,
          //     );
          //   },
          // ),
          //),
        ],
      ),
    );
  }

  // runs during the switching tabs animation
  dynamic _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = _controller!.animation!.value;

    // if the labelLarge wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  dynamic _handleTabChange() {
    // if a labelLarge was tapped, change the current index
    if (_buttonTap) {
      _setCurrentIndex(_controller!.index);
    }

    // this resets the labelLarge tap
    if ((_controller!.index == _prevControllerIndex) ||
        (_controller!.index == _aniValue.round())) {
      _buttonTap = false;
    }

    // save the previous controller index
    _prevControllerIndex = _controller!.index;
  }

  dynamic _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      setState(() {
        // change the index
        _currentIndex = index;
        callFromDBIndexList[_currentIndex] = true;
        // if (callFromDBIndexList.containsKey(index)) {
        //   callFromDBIndexList.update(index, (bool v) {
        //     return true;
        //   });
        // } else {
        //   callFromDBIndexList[index] = false;
        // }
      });

      // trigger the labelLarge animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  dynamic _triggerAnimation() {
    // reset the animations so they're ready to go
    /*_animationControllerOn!.reset();
    _animationControllerOff!.reset();

    // run the animations!
    _animationControllerOn!.forward();
    _animationControllerOff!.forward();*/
  }

  dynamic _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the labelLarge we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the labelLarge is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the labelLarge is to the left of the middle
    if (offset < 0) {
      // get the first labelLarge
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first labelLarge of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first labelLarge away from the left side, we limit that movement so the first labelLarge is stuck to the left side
      if (position > offset) {
        offset = position;
      }
    } else {
      // if the labelLarge is to the right of the middle

      // get the last labelLarge
      renderBox = _keys[widget.categoryList.length - 1]
          .currentContext
          .findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last labelLarge doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) {
        screenWidth = position + size;
      }

      // if the offset pulls the last labelLarge away from the right side limit, we reduce that movement so the last labelLarge is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: const Duration(milliseconds: 1200), curve: Curves.easeInOut);
  }

  dynamic getOpenAndCloseTime() {
    // Open Time
    final String? mondayOpenDateAndTime = widget.shopInfo.shopSchedules!.mondayOpenHour;
    final String? tuesdayOpenDateAndTime = widget.shopInfo.shopSchedules!.tuesdayOpenHour;
    final String? wednesdayOpenDateAndTime = widget.shopInfo.shopSchedules!.wednesdayOpenHour;
    final String? thursdayOpenDateAndTime = widget.shopInfo.shopSchedules!.thursdayOpenHour;
    final String? fridayOpenDateAndTime = widget.shopInfo.shopSchedules!.fridayOpenHour;
    final String? saturdayOpenDateAndTime = widget.shopInfo.shopSchedules!.saturdayOpenHour;
    final String? sundayOpenDateAndTime = widget.shopInfo.shopSchedules!.sundayOpenHour;

    if (mondayOpenDateAndTime != null &&
        mondayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
        mondayOpenDateAndTime.split(' ');
        // print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String> ?openHourArray =
          openDateAndTimeArray[0].split(':');

          if (openHourArray != null &&
              openHourArray.isNotEmpty) {
            monOpenHour = int.parse(openHourArray[0]);
            // print(monOpenHour);
            monOpenMin = int.parse(openHourArray[1]);
            // print(monOpenMin);
          }
        }
      }
      if (tuesdayOpenDateAndTime != null &&
        tuesdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
        tuesdayOpenDateAndTime.split(' ');
        // print(openDateAndTimeArray);

        if (openDateAndTimeArray != null &&
            openDateAndTimeArray[0].contains(':')) {
          final List<String>? openHourArray =
            openDateAndTimeArray[0].split(':');

            if (openHourArray != null &&
                openHourArray.isNotEmpty) {
              tuesOpenHour = int.parse(openHourArray[0]);
              tuesOpenMin = int.parse(openHourArray[1]);
            }
          }
        }
        if (wednesdayOpenDateAndTime != null &&
            wednesdayOpenDateAndTime != '') {
          final List<String> ?openDateAndTimeArray =
            wednesdayOpenDateAndTime.split(' ');

          if (openDateAndTimeArray != null &&
              openDateAndTimeArray[0].contains(':')) {
            final List<String>? openHourArray =
              openDateAndTimeArray[0].split(':');

              if (openHourArray != null &&
                  openHourArray.isNotEmpty) {
                wedOpenHour = int.parse(openHourArray[0]);
                wedOpenMin = int.parse(openHourArray[1]);
                
              }
            }
          }
          if (thursdayOpenDateAndTime != null &&
            thursdayOpenDateAndTime != '') {
            final List<String>? openDateAndTimeArray =
              thursdayOpenDateAndTime.split(' ');

              if (openDateAndTimeArray != null &&
                  openDateAndTimeArray[0].contains(':')) {
                final List<String>? openHourArray =
                  openDateAndTimeArray[0].split(':');

                if (openHourArray != null &&
                    openHourArray.isNotEmpty ) {
                  thursOpenHour = int.parse(openHourArray[0]);
                  thursOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
          if (fridayOpenDateAndTime != null &&
              fridayOpenDateAndTime != '') {
            final List<String>? openDateAndTimeArray =
              fridayOpenDateAndTime.split(' ');
          
            if (openDateAndTimeArray != null &&
                openDateAndTimeArray[0].contains(':')) {
              final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null &&
                    openHourArray.isNotEmpty ) {
                  friOpenHour = int.parse(openHourArray[0]);
                  friOpenMin= int.parse(openHourArray[1]);
                  
                }
              }
            }
          if (saturdayOpenDateAndTime != null &&
              saturdayOpenDateAndTime != '') {
            final List<String>? openDateAndTimeArray =
              saturdayOpenDateAndTime.split(' ');
              // print(openDateAndTimeArray);

            if (openDateAndTimeArray != null &&
                openDateAndTimeArray[0].contains(':')) {
              final List<String>? openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null &&
                    openHourArray.isNotEmpty ) {
                  satOpenHour = int.parse(openHourArray[0]);
                  satOpenMin = int.parse(openHourArray[1]);
                }
              }
            }
          if (sundayOpenDateAndTime != null &&
              sundayOpenDateAndTime != '') {
            final List<String>? openDateAndTimeArray =
              sundayOpenDateAndTime.split(' ');
              // print(openDateAndTimeArray);

            if (openDateAndTimeArray != null &&
                openDateAndTimeArray[0].contains(':')) {
              final List<String> ?openHourArray =
                openDateAndTimeArray[0].split(':');

                if (openHourArray != null &&
                    openHourArray.isNotEmpty ) {
                  sunOpenHour = int.parse(openHourArray[0]);
                  sunOpenMin = int.parse(openHourArray[1]);
              }
            }
          }

    // Close Time
    final String? mondayCloseDateAndTime = widget.shopInfo.shopSchedules!.mondayCloseHour;
    final String? tuesdayCloseDateAndTime = widget.shopInfo.shopSchedules!.tuesdayCloseHour;
    final String? wednesdayCloseDateAndTime = widget.shopInfo.shopSchedules!.wednesdayCloseHour;
    final String? thursdayCloseDateAndTime = widget.shopInfo.shopSchedules!.thursdayCloseHour;
    final String? fridayCloseDateAndTime = widget.shopInfo.shopSchedules!.fridayCloseHour;
    final String? saturdayCloseDateAndTime = widget.shopInfo.shopSchedules!.saturdayCloseHour;
    final String? sundayCloseDateAndTime = widget.shopInfo.shopSchedules!.sundayCloseHour;

    if (mondayCloseDateAndTime != null &&
        mondayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
        mondayCloseDateAndTime.split(' ');
        // print(closeDateAndTimeArray);

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray =
          closeDateAndTimeArray[0].split(':');

          if (closeHourArray != null &&
              closeHourArray.isNotEmpty) {
            monCloseHour = int.parse(closeHourArray[0]);
            // print(monCloseHour);
            monCloseMin = int.parse(closeHourArray[1]);
            // print(monCloseMin);
            }
          }
        } 
      if (tuesdayCloseDateAndTime != null &&
          tuesdayCloseDateAndTime != '') {
        final List<String>? closeDateAndTimeArray =
          tuesdayCloseDateAndTime.split(' ');
          // print(closeDateAndTimeArray);

        if (closeDateAndTimeArray != null &&
            closeDateAndTimeArray[0].contains(':')) {
          final List<String>? closeHourArray =
            closeDateAndTimeArray[0].split(':');

            if (closeHourArray != null &&
                closeHourArray.isNotEmpty) {
              tuesCloseHour = int.parse(closeHourArray[0]);
              tuesCloseMin = int.parse(closeHourArray[1]);
              }
            }
          } 
        if (wednesdayCloseDateAndTime != null &&
            wednesdayCloseDateAndTime != '') {
          final List<String>? closeDateAndTimeArray =
            wednesdayCloseDateAndTime.split(' ');

          if (closeDateAndTimeArray != null &&
              closeDateAndTimeArray[0].contains(':')) {
            final List<String>? closeHourArray =
              closeDateAndTimeArray[0].split(':');

              if (closeHourArray != null &&
                  closeHourArray.isNotEmpty) {
                wedCloseHour = int.parse(closeHourArray[0]);
                wedCloseMin = int.parse(closeHourArray[1]);
                }
              }
            } 
          if (thursdayCloseDateAndTime != null &&
              thursdayCloseDateAndTime != '') {
            final List<String>? closeDateAndTimeArray =
              thursdayCloseDateAndTime.split(' ');

            if (closeDateAndTimeArray != null &&
                closeDateAndTimeArray[0].contains(':')) {
              final List<String> ?closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null &&
                    closeHourArray.isNotEmpty) {
                  thursCloseHour = int.parse(closeHourArray[0]);
                  thursCloseMin = int.parse(closeHourArray[1]);
                }
              }
            } 
          if (fridayCloseDateAndTime != null &&
              fridayCloseDateAndTime != '') {
            final List<String> ?closeDateAndTimeArray =
              fridayCloseDateAndTime.split(' ');
              
            if (closeDateAndTimeArray != null &&
                closeDateAndTimeArray[0].contains(':')) {
              final List<String> ?closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null &&
                    closeHourArray.isNotEmpty) {
                  friCloseHour = int.parse(closeHourArray[0]);
                  friCloseMin = int.parse(closeHourArray[1]);
                }
              }
            }
          if (saturdayCloseDateAndTime != null &&
              saturdayCloseDateAndTime != '') {
            final List<String>? closeDateAndTimeArray =
              saturdayCloseDateAndTime.split(' ');

            if (closeDateAndTimeArray != null &&
                closeDateAndTimeArray[0].contains(':')) {
              final List<String>? closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null &&
                    closeHourArray.isNotEmpty) {
                  satCloseHour = int.parse(closeHourArray[0]);
                  satCloseMin = int.parse(closeHourArray[1]);
                }
              }
            } 
          if (sundayCloseDateAndTime != null &&
              sundayCloseDateAndTime != '') {
            final List<String> ?closeDateAndTimeArray =
              sundayCloseDateAndTime.split(' ');

            if (closeDateAndTimeArray != null &&
                closeDateAndTimeArray.length > 1) {
              final List<String>? closeHourArray =
                closeDateAndTimeArray[0].split(':');

                if (closeHourArray != null &&
                    closeHourArray.isNotEmpty) {
                  sunCloseHour = int.parse(closeHourArray[0]);
                  sunCloseMin = int.parse(closeHourArray[1]);
                }
              }
            } 

          final String dateAndTime = DateFormat.yMMMMEEEEd('en_US').format(DateTime.now());
           hour = int.parse(DateFormat.Hm().format(DateTime.now()).toString().split(':').first);
           minute = int.parse(DateFormat.Hm().format(DateTime.now()).toString().split(':').last);
           days = dateAndTime.split(',').first;
  
          if (days == 'Monday') {
            if(widget.shopInfo.shopSchedules!.isMondayOpen == PsConst.ONE) {
              if (((hour! > monOpenHour!) || (hour == monOpenHour && minute! >= monOpenMin!)) &&
                ((hour! < monCloseHour!) || (hour == monCloseHour && minute! <= monCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,  
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.mondayOpenHour} - ${widget.shopInfo.shopSchedules!.mondayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,    
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.mondayOpenHour} - ${widget.shopInfo.shopSchedules!.mondayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,    
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.mondayOpenHour} - ${widget.shopInfo.shopSchedules!.mondayCloseHour}'
                );
            }
          } 
          else if (days == 'Tuesday') {
            if(widget.shopInfo.shopSchedules!.isTuesdayOpen == PsConst.ONE) {
              if (((hour! > tuesOpenHour!) || (hour == tuesOpenHour && minute! >= tuesOpenMin!)) &&
                ((hour! < tuesCloseHour!) || (hour == tuesCloseHour && minute! <= tuesCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,  
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.tuesdayOpenHour} - ${widget.shopInfo.shopSchedules!.tuesdayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.tuesdayOpenHour} - ${widget.shopInfo.shopSchedules!.tuesdayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.tuesdayOpenHour} - ${widget.shopInfo.shopSchedules!.tuesdayCloseHour}'
                );
            }
          } else if (days == 'Wednesday') {
            if(widget.shopInfo.shopSchedules!.isWednesdayOpen == PsConst.ONE) {
              if (((hour! > wedOpenHour!) || (hour == wedOpenHour && minute! >= wedOpenMin!)) &&
                ((hour! < wedCloseHour!) || (hour == wedCloseHour && minute! <= wedCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,       
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.wednesdayOpenHour} - ${widget.shopInfo.shopSchedules!.wednesdayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,          
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.wednesdayOpenHour} - ${widget.shopInfo.shopSchedules!.wednesdayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,          
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.wednesdayOpenHour} - ${widget.shopInfo.shopSchedules!.wednesdayCloseHour}'
              );
            }
          } else if (days == 'Thursday') {
            if(widget.shopInfo.shopSchedules!.isThursdayOpen == PsConst.ONE) {
              if (((hour! > thursOpenHour!) || (hour == thursOpenHour && minute! >= thursOpenMin!)) &&
                ((hour! < thursCloseHour!) || (hour == thursCloseHour && minute! <= thursCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green, 
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.thursdayOpenHour} - ${widget.shopInfo.shopSchedules!.thursdayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.thursdayOpenHour} - ${widget.shopInfo.shopSchedules!.thursdayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.thursdayOpenHour} - ${widget.shopInfo.shopSchedules!.thursdayCloseHour}'
                );
            }
          } else if (days == 'Friday') {
            if(widget.shopInfo.shopSchedules!.isFridayOpen == PsConst.ONE) {
              if (((hour! > friOpenHour!) || (hour == friOpenHour && minute! >= friOpenMin!)) &&
                ((hour! < friCloseHour!) || (hour == friCloseHour && minute! <= friCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.fridayOpenHour} - ${widget.shopInfo.shopSchedules!.fridayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.fridayOpenHour} - ${widget.shopInfo.shopSchedules!.fridayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.fridayOpenHour} - ${widget.shopInfo.shopSchedules!.fridayCloseHour}'
                );
            }
          } else if (days == 'Saturday') {
            if(widget.shopInfo.shopSchedules!.isSaturdayOpen == PsConst.ONE) {
              if (((hour! > satOpenHour!) || (hour == satOpenHour && minute! >= satOpenMin!)) &&
                ((hour! < satCloseHour!) || (hour == satCloseHour && minute! <= satCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.saturdayOpenHour} - ${widget.shopInfo.shopSchedules!.saturdayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.saturdayOpenHour} - ${widget.shopInfo.shopSchedules!.saturdayCloseHour}'
                );
              }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.saturdayOpenHour} - ${widget.shopInfo.shopSchedules!.saturdayCloseHour}'
                );
            }
          } else if (days == 'Sunday') {
            if(widget.shopInfo.shopSchedules!.isSaturdayOpen == PsConst.ONE) {
              if (((hour! > sunOpenHour!) || (hour == sunOpenHour && minute! >= sunOpenMin!)) &&
                ((hour! < sunCloseHour!) || (hour == sunCloseHour && minute! <= sunCloseMin!))) {   
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__open_now'),
                  textColor: Colors.green,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.sundayOpenHour} - ${widget.shopInfo.shopSchedules!.sundayCloseHour}'
                );
              } else {
                return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.sundayOpenHour} - ${widget.shopInfo.shopSchedules!.sundayCloseHour}'
                );
             }
            } else {
              return _OpenAndTimeWidget(
                  text: Utils.getString(context, 'shop_info__close_now'),
                  textColor: Colors.red,
                  time: Utils.getString(context, 'shop_info__open_time') +
                          '${widget.shopInfo.shopSchedules!.sundayOpenHour} - ${widget.shopInfo.shopSchedules!.sundayCloseHour}'
              );
            }
          } 
      }    

  dynamic _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      // if it's active labelLarge
      return _colorTweenBackgroundOn!.value;
    } else if (index == _prevControllerIndex) {
      // if it's the previous active labelLarge
      return _colorTweenBackgroundOff!.value;
    } else {
      // if the labelLarge is inactive
      return _backgroundOff;
    }
  }

  dynamic _getTextColor(int index) {
    if (index == _currentIndex) {
      // if it's active labelLarge
      return PsColors.white;
    } else {
      return PsColors.textPrimaryColor;
    }
  }

  Widget getWidget(int i, int currentIndex) {
    // If widget is inside cache, just return from cache.
    if (widgetList[i] != null) {
      return widgetList[i]!;
    }

    final int widgetIndex = i;
    // Prepare only 3 indexs
    // int widgetIndex = 0;
    // if (i == currentIndex - 1) {
    //   widgetIndex = i;
    // } else if (i == currentIndex + 1) {
    //   widgetIndex = i;
    // } else if (i == currentIndex) {
    //   widgetIndex = currentIndex;
    // } else {
    //   return Container();
    // }

    // Check Category Id
    final String? _catId = widget.categoryList[widgetIndex].id;
    if (_catId == null || _catId == '') {
      return Container();
    }

    // Check Which UI Widget to return
    Utils.psPrint('index $widgetIndex');
    Utils.psPrint(_catId);

    if (_catId == PsConst.specialCollection) {
      // Collection View Widget
      widgetList[widgetIndex] = const DashboardCollectionHeaderListView();
      return widgetList[widgetIndex]!;
    } else if (_catId == PsConst.featuredItem) {
      // Featured Item List View Widget
      widgetList[widgetIndex] = ProductListView(
        key: _viewkeys[widgetIndex],
        catId: widget.categoryList[widgetIndex].id!,
        flag: callFromDBIndexList[widgetIndex] ?? false,
        isFeaturedItem: true,
      );

      return widgetList[widgetIndex]!;
    } else {
      // Normal Project List View Widget
      widgetList[widgetIndex] = ProductListView(
          key: _viewkeys[widgetIndex],
          catId: widget.categoryList[widgetIndex].id!,
          flag: callFromDBIndexList[widgetIndex] ?? false,
          isFeaturedItem: false);

      return widgetList[widgetIndex]!;
    }
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
class _OpenAndTimeWidget extends StatefulWidget {
  const _OpenAndTimeWidget(
      {Key? key,
      required this.text,
      required this.time,
      required this.textColor,
      })
      : super(key: key);

  final String text;
  final String time;
  final Color textColor;

  @override
  __OpenAndTimeWidgetState createState() => __OpenAndTimeWidgetState();
}

class __OpenAndTimeWidgetState extends State<_OpenAndTimeWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: PsDimens.space16),
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.textColor,
                height: 1.7)),
        ),
        Text(
            widget.time,
            style:
                Theme.of(context).textTheme.titleSmall!.copyWith(height: 1.5),
          ),
        ],
      );
  }
}
