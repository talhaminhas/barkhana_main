import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/main.dart';
import 'package:flutterrestaurant/provider/common/notification_provider.dart';
import 'package:flutterrestaurant/provider/delete_task/delete_task_provider.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/Common/notification_repository.dart';
import 'package:flutterrestaurant/repository/app_info_repository.dart';
import 'package:flutterrestaurant/repository/basket_repository.dart';
import 'package:flutterrestaurant/repository/delete_task_repository.dart';
import 'package:flutterrestaurant/repository/product_repository.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/basket/list/basket_list_view.dart';
import 'package:flutterrestaurant/ui/collection/header_list/collection_header_list_view.dart';
import 'package:flutterrestaurant/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/contact/contact_us_view.dart';
import 'package:flutterrestaurant/ui/create_reservation/entry/create_reservation_view.dart';
import 'package:flutterrestaurant/ui/create_reservation/list/reservation_list_view.dart';
import 'package:flutterrestaurant/ui/dashboard/home/home_dashboard_view.dart';
import 'package:flutterrestaurant/ui/history/list/history_list_view.dart';
import 'package:flutterrestaurant/ui/language/setting/language_setting_view.dart';
import 'package:flutterrestaurant/ui/privacy_policy/privacy_policy_view.dart';
import 'package:flutterrestaurant/ui/product/favourite/favourite_product_list_view.dart';
import 'package:flutterrestaurant/ui/product/list_with_filter/product_list_with_filter_view.dart';
import 'package:flutterrestaurant/ui/search/home_item_search_view.dart';
import 'package:flutterrestaurant/ui/search_item/search_item_list_view.dart';
import 'package:flutterrestaurant/ui/setting/setting_view.dart';
import 'package:flutterrestaurant/ui/subcategory/list/sub_category_grid_view.dart';
import 'package:flutterrestaurant/ui/transaction/detail/transaction_item_list_view.dart';
import 'package:flutterrestaurant/ui/transaction/list/transaction_list_view.dart';
import 'package:flutterrestaurant/ui/user/forgot_password/forgot_password_view.dart';
import 'package:flutterrestaurant/ui/user/login/login_view.dart';
import 'package:flutterrestaurant/ui/user/phone/sign_in/phone_sign_in_view.dart';
import 'package:flutterrestaurant/ui/user/phone/verify_phone/verify_phone_view.dart';
import 'package:flutterrestaurant/ui/user/profile/profile_view.dart';
import 'package:flutterrestaurant/ui/user/register/register_view.dart';
import 'package:flutterrestaurant/ui/user/verify/verify_email_view.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/category.dart' as restaurant;
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../provider/basket/basket_provider.dart';
import '../../../provider/product/product_provider.dart';
import '../../../viewobject/transaction_header.dart';
import '../../gallery/grid/gallery_grid_view.dart';
import '../../product/detail/product_detail_view.dart';
import '../../product/list_with_filter/product_list_with_filter_container.dart';
import '../../search_history/search_history_list_view.dart';

final GlobalKey<_HomeViewState> dashboardViewKey = GlobalKey<_HomeViewState>();
class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();


}

class _HomeViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
 late AnimationController animationController;

 Animation<double>? animation;
  BasketRepository? basketRepository;
 //late DashboardStateController dashboardStateController;
  String appBarTitle = 'Home';
  int _currentIndex = PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT;
  String _userId = '';
  bool isLogout = false;
  bool isFirstTime = true;
  String phoneUserName = '';
  String phoneNumber = '';
  String phoneId = '';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ShopInfoProvider? shopInfoProvider;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool isResumed = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isResumed = true;
      initDynamicLinks(context);

    }
  }

  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    initDynamicLinks(context);
    //dashboardStateController = Provider.of<DashboardStateController>(context);
    PSApp.apiTokenRefresher.context = context;
    super.initState();

  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> initDynamicLinks(BuildContext context) async {
    Future<dynamic>.delayed(const Duration(seconds: 3));
    String itemId = '';
    /*if (!isResumed) {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();

      // ignore: unnecessary_null_comparison
      if (data != null && data.link != null) {
        final Uri? deepLink = data.link;
        if (deepLink != null) {
          final String path = deepLink.path;
          final List<String> pathList = path.split('=');
          itemId = pathList[1];
          final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
            productId: itemId,
            heroTagImage: '-1' + pathList[1] + PsConst.HERO_TAG__IMAGE,
            heroTagTitle: '-1' + pathList[1] + PsConst.HERO_TAG__TITLE,
            heroTagOriginalPrice:
                '-1' + pathList[1] + PsConst.HERO_TAG__ORIGINAL_PRICE,
            heroTagUnitPrice: '-1' + pathList[1] + PsConst.HERO_TAG__UNIT_PRICE,
          );
          Navigator.pushNamed(context, RoutePaths.productDetail,
              arguments: holder);
        }
      }
    }

    FirebaseDynamicLinks.instance.onLink;*/

    // FirebaseDynamicLinks.instance.onLink(
    //     onSuccess: (PendingDynamicLinkData? dynamicLink) async {
    //   final Uri? deepLink = dynamicLink?.link;
    //   if (deepLink != null) {
    //     final String path = deepLink.path;
    //     final List<String> pathList = path.split('=');
    //     if (itemId == '') {
    //       final ProductDetailIntentHolder holder = ProductDetailIntentHolder(
    //           productId: pathList[1],
    //           heroTagImage: '-1' + pathList[1] + PsConst.HERO_TAG__IMAGE,
    //           heroTagTitle: '-1' + pathList[1] + PsConst.HERO_TAG__TITLE);
    //       Navigator.pushNamed(context, RoutePaths.productDetail,
    //           arguments: holder);
    //     }
    //   }
    //   debugPrint('DynamicLinks onLink $deepLink');
    // }, onError: (OnLinkErrorException e) async {
    //   debugPrint('DynamicLinks onError $e');
    // });
  }

  int getBottomNavigationIndex(int param) {
    int index = 0;
    switch (param) {
      case PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT:
        index = 0;
        break;
      case PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT:
        index = 0;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT:
        index = 0;
        break;
      case PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT:
        index = 0;
        break;
      case PsConst.REQUEST_CODE__MENU_CATEGORY_FRAGMENT:
        index = 1;
        break;
      case PsConst.REQUEST_CODE__MENU_SHOPS_FRAGMENT:
        index = 5;
        break;
      // case PsConst.REQUEST_CODE__MENU_SHOPS_FRAGMENT:
      //   index = 1;
        //break;
      case PsConst.REQUEST_CODE__MENU_USER_HISTORY_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__MENU_ORDER_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__MENU_TRANSACTION_DETAIL_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT:
        index = 1;
        break;
      /*case PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT:
        if(previousControllerProductDetail == Utils.getString(context, 'home__bottom_app_bar_search'))
          index = 1;
        else
          index = 2;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_INGREDIENTS_FRAGMENT:
        if(previousControllerProductDetail == Utils.getString(context, 'home__bottom_app_bar_search'))
          index = 1;
        else
          index = 2;
        break;*/
      case PsConst.REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT:
        index = 3;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT:
        index = 2;
        break;
      default:
        index = 0;
        break;
    }
    return index;
  }

  dynamic getIndexFromBottomNavigationIndex(int param) {
    int index = PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT;
    String title;
    final PsValueHolder psValueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    switch (param) {
      case 0:
        index = PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT;
        title = Utils.getString(context, 'home__drawer_menu_menu');
        break;
      case 1:
        index = PsConst.REQUEST_CODE__MENU_CATEGORY_FRAGMENT;
        title = Utils.getString(context, 'home__bottom_app_bar_search');
        break;
      case 5:
        index = PsConst.REQUEST_CODE__MENU_SHOPS_FRAGMENT;
        title = Utils.getString(context, 'home__drawer_menu_menu');
        break;
      case 4:
        index = PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT;
        title = (
                psValueHolder.userIdToVerify == null ||
                psValueHolder.userIdToVerify == '')
            ? Utils.getString(context, 'home__bottom_app_bar_login')
            : Utils.getString(context, 'home__bottom_app_bar_verify_email');
        break;
      case 3:
        index = PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT;
        title = Utils.getString(context, 'home__menu_drawer_favourite');
        break;
      case 2:
        index = PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT;
        title = Utils.getString(context, 'home__bottom_app_bar_basket_list');
        break;
      default:
        index = 0;
        title = 'default';//Utils.getString(context, 'app_name');
        break;
    }
    return <dynamic>[title, index];
  }

  ShopInfoRepository? shopInfoRepository;
  UserRepository? userRepository;
  AppInfoRepository? appInfoRepository;
  ProductRepository? productRepository;
  PsValueHolder? valueHolder;
  NotificationRepository? notificationRepository;
  DeleteTaskRepository? deleteTaskRepository;
  DeleteTaskProvider? deleteTaskProvider;
  UserProvider? userProvider;

 Future<void> updateSelectedIndexWithAnimationUserId(
     String title, int index, String? userId) async {
   await animationController.reverse().then<dynamic>((void data) {
     if (!mounted) {
       return;
     }
     if (userId != null) {
       _userId = userId;
     }
     setState(() {
       appBarTitle = title;
       _currentIndex = index;
     });
   });
 }

 Future<void> updateSelectedIndexWithAnimation(
     String title, int index) async {
   await animationController.reverse().then<dynamic>((void data) {
     if (!mounted) {
       return;
     }
     //print(dashboardViewKey.currentState);
     if(controllersStack.last[title] != index)
       controllersStack.add(<String, int>{title: index});
     print('Navigator Stack: $controllersStack');
     //print(controllers);
     setState(() {
       appBarTitle = title;
       _currentIndex = index;
     });
   });
 }
 List<Map<String, int>> controllersStack = <Map<String, int>>[<String, int>{'Menu': PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT}];// to keep track of controller before basket page.
 restaurant.Category? selectedCategory;
 //List<Widget> controllers = [];
 ProductParameterHolder? selectedProductParameterHolder;
 ProductDetailIntentHolder? selectedProductDetailHolder;
 ProductDetailProvider? selectedProductDetailProvider;
 TransactionHeader? selectedTransactionHeader;
 void onTapBack(){
   controllersStack.removeLast();
   //controllers.removeLast();
   final Map<String, int>? lastRemovedController = controllersStack.last;
   //final Widget lastController = controllers.last;
   //print(lastRemovedController);
   //print(lastController) ;
   if (lastRemovedController != null) {
     final String key = lastRemovedController.keys.first;
     updateSelectedIndexWithAnimation(key, lastRemovedController[key]!);
     // Do something with the key and value...
   }
   else{
     updateSelectedIndexWithAnimation(
         Utils.getString(context, 'home__drawer_menu_menu'),
         PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
   }
 }
  @override
  Widget build(BuildContext context) {
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    userRepository = Provider.of<UserRepository>(context);
    appInfoRepository = Provider.of<AppInfoRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    notificationRepository = Provider.of<NotificationRepository>(context);
    productRepository = Provider.of<ProductRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    deleteTaskRepository = Provider.of<DeleteTaskRepository>(context);
    timeDilation = 1.0;

    if (isFirstTime) {
      appBarTitle = Utils.getString(context, 'app_name');

      Utils.subscribeToTopic(valueHolder!.notiSetting ?? true);

      Utils.fcmConfigure(context, _fcm, valueHolder!.loginUserId);
      isFirstTime = false;
    }



    Future<void> updateSelectedIndex(int index) async {
      setState(() {
        _currentIndex = index;
      });
    }

    dynamic callLogout(UserProvider provider,
        DeleteTaskProvider deleteTaskProvider, int index) async {
      appBarTitle = Utils.getString(context, 'app_name');
      updateSelectedIndex(index);
      updateSelectedIndexWithAnimation(
        Utils.getString(context, 'app_name'),
        index);
      await provider.replaceLoginUserId('');
      await provider.replaceLoginUserName('');
      await deleteTaskProvider.deleteTask();
      //await FacebookAuth.instance.logOut();
      await GoogleSignIn().signOut();
      await fb_auth.FirebaseAuth.instance.signOut();
    }
    String _truncateLabel(String label, int maxLength) {
      if (label.length <= maxLength) {
        return label;
      } else {
        return label.substring(0, maxLength) + '...';
      }
    }

    Future<bool> _onWillPop() {
      if(_currentIndex == PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT) {
        return showDialog<dynamic>(
                context: context,
            barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'home__quit_dialog_description'),
                      leftButtonText: Utils.getString(
                          context, 'app_info__cancel_button_name'),
                      rightButtonText: Utils.getString(context, 'dialog__ok'),
                      onAgreeTap: () {
                        SystemNavigator.pop();
                      });
                }) .then((dynamic value) => value as bool);

       } else {
        onTapBack();
          return Future<bool>.value(false);
      }
    }
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          child: MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<UserProvider?>(
                  lazy: false,
                  create: (BuildContext context) {
                    userProvider = UserProvider(
                        repo: userRepository!, psValueHolder: valueHolder!);
                    userProvider!.getUserFromDB(userProvider!.psValueHolder.loginUserId!);

                    return userProvider!;
                  }
                  /*lazy: false,
                  create: (BuildContext context) {
                    return UserProvider(
                        repo: userRepository!,
                        psValueHolder: valueHolder!
                    );
                  }*/),
              /*ChangeNotifierProvider<DeleteTaskProvider?>(
                  lazy: false,
                  create: (BuildContext context) {
                    deleteTaskProvider = DeleteTaskProvider(
                        repo: deleteTaskRepository,
                        psValueHolder: valueHolder);
                    return deleteTaskProvider;
              }),*/
          /*ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                final BasketProvider provider =
                BasketProvider(repo: basketRepository!);
                provider.loadBasketList();
                return provider;
              }),*/
            ],
            child: Consumer<UserProvider>(
              builder:
                  (BuildContext context, UserProvider provider, Widget? child) {
                print(provider.psValueHolder.loginUserId);
                return ListView(padding: EdgeInsets.zero, children: <Widget>[
                  if (provider.user.data == null ||
                      provider.user.data!.userProfilePhoto == '')
                    _DrawerHeaderWidget()
                  else
                    _DrawerHeaderWidgetWithUserProfile(
                      provider: provider,
                      deleteTaskProvider: deleteTaskProvider!),
                  ListTile(
                    title: Text(
                        Utils.getString(context, 'home__drawer_menu_home')),
                  ),
                  /*_DrawerMenuWidget(
                      icon: Icons.store,
                      title: Utils.getString(context, 'home__drawer_menu_home'),
                      index: PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(
                            Utils.getString(context, 'app_name'), index);
                      }),*/

                  /*_DrawerMenuWidget(
                      icon: Icons.folder_open,
                      title: Utils.getString(
                          context, 'home__menu_drawer_shops'),
                      index: PsConst.REQUEST_CODE__MENU_COLLECTION_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),*/
                  /*_DrawerMenuWidget(
                      icon: Icons.category,
                      title: Utils.getString(
                          context, 'home__drawer_menu_menu'),
                      index: PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),*/
                  _DrawerMenuWidget(
                      icon: Icons.category,
                      title: Utils.getString(
                          context, 'home__drawer_menu_menu'),
                      index: PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  /*_DrawerMenuWidget(
                      icon: Icons.schedule,
                      title: Utils.getString(
                          context, 'home__drawer_menu_latest_product'),
                      index: PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),*/
                  _DrawerMenuWidget(
                      icon: FontAwesome5.percent,
                      title: Utils.getString(
                          context, 'home__drawer_menu_discount_product'),
                      index:
                          PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(title, index);
                      }),
                  _DrawerMenuWidget(
                      icon: FontAwesome5.gem,
                      title: Utils.getString(
                          context, 'home__menu_drawer_featured_product'),
                      index:
                          PsConst.REQUEST_CODE__MENU_FEATURED_PRODUCT_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  /*_DrawerMenuWidget(
                      icon: Icons.trending_up,
                      title: Utils.getString(
                          context, 'home__drawer_menu_trending_product'),
                      index:
                          PsConst.REQUEST_CODE__MENU_TRENDING_PRODUCT_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),*/
                  /*_DrawerMenuWidget(
                      icon: Icons.folder_open,
                      title: Utils.getString(
                          context, 'home__menu_drawer_collection'),
                      index: PsConst.REQUEST_CODE__MENU_COLLECTION_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),*/
                  const Divider(
                    height: PsDimens.space1,
                  ),
                  ListTile(
                    title: Text(Utils.getString(
                        context, 'home__menu_drawer_user_info')),
                  ),
                  _DrawerMenuWidget(
                      icon: Icons.person,
                      title:
                          Utils.getString(context, 'home__menu_drawer_profile'),
                      index:
                          PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        title = (valueHolder == null ||
                                valueHolder!.userIdToVerify == null ||
                                valueHolder!.userIdToVerify == '')
                            ? Utils.getString(
                                context, 'home__menu_drawer_profile')
                            : Utils.getString(
                                context, 'home__bottom_app_bar_verify_email');
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  // ignore: unnecessary_null_comparison
                  if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: _DrawerMenuWidget(
                            icon: Icons.favorite_border,
                            title: Utils.getString(
                                context, 'home__menu_drawer_favourite'),
                            index:
                                PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT,
                            onTap: (String title, int index) {
                              Navigator.pop(context);
                              updateSelectedIndexWithAnimation(title, index);
                            }),
                      ),
                  // ignore: unnecessary_null_comparison
                  if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: _DrawerMenuWidget(
                          icon: Icons.swap_horiz,
                          title: Utils.getString(
                              context, 'profile__order'),
                          index:
                              PsConst.REQUEST_CODE__MENU_ORDER_FRAGMENT,
                          onTap: (String title, int index) {
                            Navigator.pop(context);
                            updateSelectedIndexWithAnimation(title, index);
                          },
                        ),
                      ),
                    //? Remove comment for ( Schedule Order )
                   /* if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: _DrawerMenuWidget(
                          icon: AntDesign.calendar,
                          title: Utils.getString(
                              context, 'order_time__my_schedule'),
                          index: PsConst.REQUEST_CODE__MENU_VIEW_MY_SCHEDULE,
                          onTap: (String title, int index) {
                            Navigator.pop(context);
                            updateSelectedIndexWithAnimation(title, index);
                          },
                        ),
                      ),
                      */
                  // ignore: unnecessary_null_comparison
                  if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: false,
                        child: _DrawerMenuWidget(
                            icon: Icons.book,
                            title: Utils.getString(
                                context, 'home__menu_drawer_recent_products'),
                            index: PsConst
                                .REQUEST_CODE__MENU_USER_HISTORY_FRAGMENT,
                            onTap: (String title, int index) {
                              Navigator.pop(context);
                              updateSelectedIndexWithAnimation(title, index);
                            }),
                      ),
                  // ignore: unnecessary_null_comparison
                  /*if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: _DrawerMenuWidget(
                            icon: Icons.note_add,
                            title: Utils.getString(context,
                                'home__menu_drawer_create_reservation'),
                            index: PsConst
                                .REQUEST_CODE__MENU_USER_CREATE_RESERVATION_FRAGMENT,
                            onTap: (String title, int index) {
                              Navigator.pop(context);
                              updateSelectedIndexWithAnimation(title, index);
                            }),
                      ),*/
                  // ignore: unnecessary_null_comparison
                 /* if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: _DrawerMenuWidget(
                            icon: FontAwesome.book,
                            title: Utils.getString(
                                context, 'home__menu_drawer_reservation_list'),
                            index: PsConst
                                .REQUEST_CODE__MENU_USER_RESERVATION_LIST_FRAGMENT,
                            onTap: (String title, int index) {
                              Navigator.pop(context);
                              updateSelectedIndexWithAnimation(title, index);
                            }),
                      ),*/
                  // ignore: unnecessary_null_comparison
                  if (provider != null)
                    if (provider.psValueHolder.loginUserId != null &&
                        provider.psValueHolder.loginUserId != '')
                      Visibility(
                        visible: true,
                        child: ListTile(
                          leading: Icon(
                            Icons.power_settings_new,
                            color: PsColors.mainColorWithWhite,
                          ),
                          title: Text(
                            Utils.getString(
                                context, 'home__menu_drawer_logout'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            showDialog<dynamic>(
                                context: context,
                                barrierColor: PsColors.transparent,
                                builder: (BuildContext context) {
                                  return ConfirmDialogView(
                                      description: Utils.getString(context,
                                          'home__logout_dialog_description'),
                                      leftButtonText: Utils.getString(context,
                                          'home__logout_dialog_cancel_button'),
                                      rightButtonText: Utils.getString(context,
                                          'home__logout_dialog_ok_button'),
                                      onAgreeTap: () async {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _currentIndex = PsConst
                                              .REQUEST_CODE__MENU_HOME_FRAGMENT;
                                        });
                                        await provider.replaceLoginUserId('');
                                        await deleteTaskProvider!.deleteTask();
                                        //await FacebookAuth.instance.logOut();
                                        await GoogleSignIn().signOut();
                                        await fb_auth.FirebaseAuth.instance
                                            .signOut();
                                      });
                                });
                          },
                        ),
                      ),
                  const Divider(
                    height: PsDimens.space1,
                  ),
                  ListTile(
                    title:
                        Text(Utils.getString(context, 'home__menu_drawer_app')),
                  ),
                  /*_DrawerMenuWidget(
                      icon: Icons.g_translate,
                      title: Utils.getString(
                          context, 'home__menu_drawer_language'),
                      index: PsConst.REQUEST_CODE__MENU_LANGUAGE_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation('', index);
                      }),*/
                  _DrawerMenuWidget(
                      icon: Icons.contacts,
                      title: Utils.getString(
                          context, 'home__menu_drawer_contact_us'),
                      index: PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  _DrawerMenuWidget(
                      icon: Icons.settings,
                      title:
                          Utils.getString(context, 'home__menu_drawer_setting'),
                      index: PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  _DrawerMenuWidget(
                      icon: Icons.info_outline,
                      title: Utils.getString(
                          context, 'privacy_policy__toolbar_name'),
                      index: PsConst
                          .REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT,
                      onTap: (String title, int index) {
                        Navigator.pop(context);
                        updateSelectedIndexWithAnimation(title, index);
                      }),
                  /*ListTile(
                    leading: Icon(
                      Icons.share,
                      color: PsColors.mainColorWithWhite,
                    ),
                    title: Text(
                      Utils.getString(
                          context, 'home__menu_drawer_share_this_app'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog<dynamic>(
                          context: context,
                          barrierColor: PsColors.transparent,
                          builder: (BuildContext context) {
                            return ShareAppDialog(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                            );
                          });
                    },
                  ),*/
                  /*ListTile(
                    leading: Icon(
                      Icons.star_border,
                      color: PsColors.mainColorWithWhite,
                    ),
                    title: Text(
                      Utils.getString(
                          context, 'home__menu_drawer_rate_this_app'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (Platform.isIOS) {
                        Utils.launchAppStoreURL(
                            iOSAppId: valueHolder!.iOSAppStoreId,
                            writeReview: true);
                      } else {
                        Utils.launchURL();
                      }
                    },
                  )*/
                ]);
              },
            ),
          ),
        ),
        appBar: AppBar(
            centerTitle: false,
            leading: _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_PRODUCTS_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_INGREDIENTS_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__MENU_TRANSACTION_DETAIL_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT||
                _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT

                ? IconButton(
              icon: const Icon(
                Icons.arrow_back, // Replace with your preferred icon for the back button
              ),
              onPressed: () {
                onTapBack();
              },
            )
                : null,
          backgroundColor: PsColors.backgroundColor,
          title: FittedBox(
            fit: BoxFit.scaleDown, // This makes the text shrink if space is small
            child: Text(
              appBarTitle,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: PsColors.textPrimaryColor,
              ),
            ),
          ),
          titleSpacing: 0,
          elevation: 0,
          iconTheme: IconThemeData(color: PsColors.textPrimaryColor),
          toolbarTextStyle: TextStyle(color: PsColors.textPrimaryColor),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ),
          actions: <Widget>[
        /*IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RoutePaths.notiList,
                );
              },
            ),
            IconButton(
              icon: Icon(
                FontAwesome5.book_open,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RoutePaths.blogList,
                );
              },
            ),*/
            ChangeNotifierProvider<BasketProvider>(
            lazy: false,
            create: (BuildContext context) {
              final BasketProvider provider =
                  BasketProvider(repo: basketRepository!);
              provider.loadBasketList();
              return provider;
            },
              child: Consumer<BasketProvider>(
                builder: (BuildContext context, BasketProvider basketProvider, Widget? child) {
                  int totalQuantity = 0;
                  double totalPrice = 0.0;
                  double totalOriginalPrice = 0.0;
                  String? currencySymbol;
                  for (Basket basket in basketProvider.basketList.data!) {
                    totalQuantity += int.parse(basket.qty!);
                    totalPrice += double.parse(basket.basketPrice!) * double.parse(basket.qty!);
                    totalOriginalPrice += double.parse(basket.basketOriginalPrice!) * double.parse(basket.qty!);
                    currencySymbol = basket.product!.currencySymbol!;
                  }
                  if (_currentIndex != PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT &&
                      _currentIndex != PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT &&
                      _currentIndex != PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT &&
                      _currentIndex != PsConst.REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT
                  )
                  return GestureDetector(
                      onTap: () {
                        controllersStack.add(<String, int>{appBarTitle:_currentIndex});
                        updateSelectedIndexWithAnimation(Utils.getString(
                            context,
                            Utils.getString(context, 'home__bottom_app_bar_basket_list')),
                            PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT);

                      },
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(width: PsDimens.space10),
                            if (basketProvider
                                .basketList.data!.isNotEmpty)
                              FittedBox(
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      FittedBox(
                                          child:
                                          Container(
                                            child: Align(
                                              /*alignment: Alignment.center,*/
                                              child: Text(
                                                '${Utils.getString(context, 'checkout__price')} $currencySymbol ${totalPrice.toStringAsFixed(2)}',
                                                textAlign: TextAlign.left,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          )
                                      ),
                                      Container(
                                        height: PsDimens.space4,
                                      ),
                                      FittedBox(
                                          child:
                                          Container(
                                            child: Align(
                                              /*alignment: Alignment.center,*/
                                              child: Text(
                                                '${Utils.getString(context, 'checkout__savings')} '
                                                    '$currencySymbol ${(totalOriginalPrice - totalPrice).toStringAsFixed(2)}',
                                                textAlign: TextAlign.left,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: PsColors.discountColor),
                                              ),
                                            ),
                                          )
                                      ),
                                    ],
                                  )
                              ),

                            Stack(
                              children: <Widget>[
                                Container(
                                  width: PsDimens.space40,
                                  height: PsDimens.space40,
                                  margin: const EdgeInsets.only(
                                      top: PsDimens.space8,
                                      left: PsDimens.space8,
                                      right: PsDimens.space8),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.shopping_basket,
                                      color: PsColors.mainColor,
                                    ),
                                  ),
                                ),
                                if (basketProvider
                                    .basketList.data!.isNotEmpty)
                                  Positioned(
                                    right: PsDimens.space4,
                                    top: PsDimens.space1,
                                    child: Container(
                                      width: PsDimens.space28,
                                      height: PsDimens.space28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PsColors.black.withAlpha(200),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          totalQuantity > 99 ? '99+' : totalQuantity.toString(),
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: PsColors.white),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ]
                      )
                  );
                  else if( totalQuantity > 0 &&
                      _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT)
                    return Container(
                      margin: const EdgeInsets.all(PsDimens.space8),
                      decoration: BoxDecoration(
                          border: Border.all(color: PsColors.discountColor, width: 2),
                          borderRadius: BorderRadius.circular(PsDimens.space8)
                      ),
                      child: TextButton(
                        onPressed: () {
                          showDialog<dynamic>(
                            context: context,
                              barrierColor: PsColors.transparent,
                            builder: (BuildContext context) {
                              return ConfirmDialogView(
                                  description: Utils.getString(context,
                                      'basket_list__empty_basket_dialog_description'),
                                  leftButtonText: Utils.getString(
                                      context,
                                      'basket_list__comfirm_dialog_cancel_button'),
                                  rightButtonText: Utils.getString(
                                      context,
                                      'basket_list__comfirm_dialog_ok_button'),
                                  onAgreeTap: () async {
                                    /*Navigator.of(context).pop();
                                    provider.deleteBasketByProduct(
                                        provider
                                            .basketList.data![index]);*/
                                    Navigator.of(context).pop();
                                    basketProvider.deleteWholeBasketList();
                                  });
                            }
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PsColors.discountColor.withAlpha(29),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PsDimens.space8), // Set the border radius for rounded corners
                          ),
                        ),
                        child: Text(
                          Utils.getString(context, 'basket__empty'),
                          style: TextStyle(
                              color: PsColors.discountColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  return Container();
                },
              ),
            ),
        ]
        ),

      bottomNavigationBar: _currentIndex ==
                    PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT ||
                _currentIndex == PsConst.REQUEST_CODE__MENU_CATEGORY_FRAGMENT ||
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT ||
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT || //go to profile
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT || //go to forgot password
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT || //go to register
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT || //go to email verify
                _currentIndex ==
                    PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT||
            _currentIndex ==
                PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT||
            _currentIndex ==
                PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT||
            _currentIndex == PsConst.REQUEST_CODE__MENU_FEATURED_PRODUCT_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__MENU_ORDER_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__MENU_USER_HISTORY_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_PRODUCTS_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_INGREDIENTS_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__MENU_TRANSACTION_DETAIL_FRAGMENT||
          _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT


            ? Visibility(
                visible: true,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: getBottomNavigationIndex(_currentIndex),
                  showUnselectedLabels: true,
                  backgroundColor: PsColors.backgroundColor,
                  selectedItemColor: PsColors.mainColor,
                  elevation: 10,
                  showSelectedLabels: true,
                  onTap: (int index) {
                    final dynamic _returnValue =
                        getIndexFromBottomNavigationIndex(index);
                      controllersStack = <Map<String, int>>[<String, int>{'Menu': PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT}];
                    updateSelectedIndexWithAnimation(
                        _returnValue[0], _returnValue[1]);
                  },
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: const Icon(
                        Icons.restaurant,
                        size: 20,
                      ),
                      label: Utils.getString(context, 'home__drawer_menu_menu'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.search),
                      label: Utils.getString(
                          context, 'home__bottom_app_bar_search'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.shopping_cart),
                      label: Utils.getString(context, 'home__bottom_app_bar_basket_list'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.favorite),
                      label: Utils.getString(
                          context, 'home__bottom_app_bar_favorites'),
                    ),

                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: Utils.getString(
                          context, 'home__bottom_app_bar_login'),
                    ),
                  ],
                ),
              )
            : null,
        floatingActionButton: _currentIndex ==
                    PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_SHOP_INFO_FRAGMENT ||
                _currentIndex ==
                    PsConst
                        .REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT ||
                _currentIndex ==
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT||
            _currentIndex ==
                PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT||
            _currentIndex ==
                PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT ||
        _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT||
            _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_PRODUCTS_FRAGMENT||
            _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT||
            _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_INGREDIENTS_FRAGMENT||
            _currentIndex == PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT
            ? Container(
                height: 65.0,
                width: 65.0,
                child: FittedBox(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: PsColors.mainColor.withOpacity(0.3),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Container()),
                ),
              )
            : null,
        body: ChangeNotifierProvider<NotificationProvider>(
          lazy: false,
          create: (BuildContext context) {
            final NotificationProvider provider = NotificationProvider(
                repo: notificationRepository!, psValueHolder: valueHolder);

            if (provider.psValueHolder!.deviceToken == null ||
                provider.psValueHolder!.deviceToken == '') {
              final FirebaseMessaging _fcm = FirebaseMessaging.instance;
              Utils.saveDeviceToken(_fcm, provider);
            } else {
              print(
                  'Notification Token is already registered. Notification Setting : true.');
            }

            return provider;
          },
          child: Builder(
            builder: (BuildContext context) {
              if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SHOP_INFO_FRAGMENT) {
                // 1 Way
                //
                // return MultiProvider(
                //     providers: <SingleChildCloneableWidget>[
                //       ChangeNotifierProvider<ShopInfoProvider>(
                //           builder: (BuildContext context) {
                //         provider = ShopInfoProvider(repo: repo1);
                //         provider.loadShopInfo();
                //         return provider;
                //       }),
                //       ChangeNotifierProvider<UserInfo
                //     ],
                //     child: CustomScrollView(
                //       scrollDirection: Axis.vertical,
                //       slivers: <Widget>[
                //         _SliverAppbar(
                //           title: 'Shop Info',
                //           scaffoldKey: scaffoldKey,
                //         ),
                //         ShopInfoView(
                //             shopInfoProvider: provider,
                //             animationController: animationController,
                //             animation: Tween<double>(begin: 0.0, end: 1.0)
                //                 .animate(CurvedAnimation(
                //                     parent: animationController,
                //                     curve: Interval((1 / 2) * 1, 1.0,
                //                         curve: Curves.fastOutSlowIn))))
                //       ],
                //     ));
                // 2nd Way
                // return ChangeNotifierProvider<ShopInfoProvider>(
                //     lazy: false,
                //     create: (BuildContext context) {
                //       final ShopInfoProvider shopInfoProvider =
                //           ShopInfoProvider(
                //               repo: shopInfoRepository,
                //               psValueHolder: valueHolder,
                //               ownerCode: 'DashboardView');
                //       shopInfoProvider.loadShopInfo();
                //       return shopInfoProvider;
                //     },
                //     child: CustomScrollView(
                //       scrollDirection: Axis.vertical,
                //       slivers: <Widget>[
                //         ShopInfoView(
                //             animationController: animationController,
                //             animation: Tween<double>(begin: 0.0, end: 1.0)
                //                 .animate(CurvedAnimation(
                //                     parent: animationController,
                //                     curve: const Interval((1 / 2) * 1, 1.0,
                //                         curve: Curves.fastOutSlowIn))))
                //       ],
                //     ));
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT) {
                return MultiProvider(
                    providers: <SingleChildWidget>[
                      ChangeNotifierProvider<UserProvider?>(
                          lazy: false,
                          create: (BuildContext context) {
                            return UserProvider(
                                repo: userRepository!,
                                psValueHolder: valueHolder!);
                          }),
                      ChangeNotifierProvider<DeleteTaskProvider?>(
                          lazy: false,
                          create: (BuildContext context) {
                            deleteTaskProvider = DeleteTaskProvider(
                                repo: deleteTaskRepository,
                                psValueHolder: valueHolder);
                            return deleteTaskProvider;
                          }),
                      ],
                    child: Consumer<UserProvider>(builder:
                        (BuildContext context, UserProvider provider,
                            Widget? child) {
                      if (
                        //provider == null ||
                          provider.psValueHolder.userIdToVerify == null ||
                          provider.psValueHolder.userIdToVerify == '') {
                        if (
                          //provider == null ||
                           // provider.psValueHolder == null ||
                            provider.psValueHolder.loginUserId == null ||
                            provider.psValueHolder.loginUserId == '') {
                          return _CallLoginWidget(
                              currentIndex: _currentIndex,
                              animationController: animationController,
                              animation: animation,
                              updateCurrentIndex: (String title, int? index) {
                                if (index != null) {
                                  updateSelectedIndexWithAnimation(
                                      title, index);
                                }
                              },
                              updateUserCurrentIndex:
                                  (String title, int? index, String ?userId) {
                                if (index != null) {
                                  updateSelectedIndexWithAnimation(
                                      title, index);
                                }
                                if (userId != null) {
                                  _userId = userId;
                                  provider.psValueHolder.loginUserId = userId;
                                }
                              });
                        } else {
                          return ProfileView(
                            scaffoldKey: scaffoldKey,
                            animationController: animationController,
                            flag: _currentIndex,
                            callLogoutCallBack: (String userId) {
                              callLogout(provider, deleteTaskProvider!,
                                  PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);

                            },
                          );
                        }
                      } else {
                        return _CallVerifyEmailWidget(
                            animationController: animationController,
                            animation: animation,
                            currentIndex: _currentIndex,
                            userId: _userId,
                            updateCurrentIndex: (String title, int index) {
                              updateSelectedIndexWithAnimation(title, index);
                            },
                            updateUserCurrentIndex:
                                (String title, int index, String? userId) async {
                              if (userId != null) {
                                _userId = userId;
                                provider.psValueHolder.loginUserId = userId;
                              }
                              setState(() {
                                appBarTitle = title;
                                _currentIndex = index;
                              });
                            });
                      }
                    }
                    )
                );
              }
              if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT) {
                // 2nd Way
                //SearchProductProvider searchProductProvider;

                return CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: <Widget>[
                    HomeItemSearchView(
                        animationController: animationController,
                        animation: animation,
                        productParameterHolder:
                            ProductParameterHolder().getLatestParameterHolder())
                  ],
                );
              }
              else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT) {
                return Stack(children: <Widget>[
                  Container(
                    color: PsColors.mainLightColorWithBlack,
                    width: double.infinity,
                    height: double.maxFinite,
                  ),
                  CustomScrollView(scrollDirection: Axis.vertical, slivers: <
                      Widget>[
                    PhoneSignInView(
                        animationController: animationController,
                        goToLoginSelected: () {
                          animationController
                              .reverse()
                              .then<dynamic>((void data) {
                            if (!mounted) {
                              return;
                            }
                            if (_currentIndex ==
                                PsConst
                                    .REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(context, 'home_login'),
                                  PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT);
                            }
                            if (_currentIndex ==
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(context, 'home_login'),
                                  PsConst
                                      .REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT);
                            }
                          });
                        },
                        phoneSignInSelected:
                            (String name, String phoneNo, String verifyId) {
                          phoneUserName = name;
                          phoneNumber = phoneNo;
                          phoneId = verifyId;
                          if (_currentIndex ==
                              PsConst
                                  .REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT) {
                            updateSelectedIndexWithAnimation(
                                Utils.getString(context, 'home_verify_phone'),
                                PsConst
                                    .REQUEST_CODE__MENU_PHONE_VERIFY_FRAGMENT);
                          } else if (_currentIndex ==
                              PsConst
                                  .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT) {
                            updateSelectedIndexWithAnimation(
                                Utils.getString(context, 'home_verify_phone'),
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT);
                          } else {
                            updateSelectedIndexWithAnimation(
                                Utils.getString(context, 'home_verify_phone'),
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT);
                          }
                        })
                  ])
                ]);
              } else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_PHONE_VERIFY_FRAGMENT) {
                return _CallVerifyPhoneWidget(
                    userName: phoneUserName,
                    phoneNumber: phoneNumber,
                    phoneId: phoneId,
                    animationController: animationController,
                    animation: animation,
                    currentIndex: _currentIndex,
                    updateCurrentIndex: (String title, int index) {
                      updateSelectedIndexWithAnimation(title, index);
                    },
                    updateUserCurrentIndex:
                        (String title, int index, String ?userId) async {
                      if (userId != null) {
                        _userId = userId;
                      }
                      setState(() {
                        appBarTitle = title;
                        _currentIndex = index;
                      });
                    });
              } else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT) {
                return ProfileView(
                  scaffoldKey: scaffoldKey,
                  animationController: animationController,
                  flag: _currentIndex,
                  userId: _userId,
                  callLogoutCallBack: (String userId) {
                    callLogout(userProvider!, deleteTaskProvider!,
                        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                  },
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_CATEGORY_FRAGMENT) {
                return SearchHistoryListView();

              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_FRAGMENT) {
                return SubCategoryGridView(category: selectedCategory);
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT) {
                return SearchItemListView(
                    productParameterHolder: selectedProductParameterHolder!);
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SUBCATEGORY_PRODUCTS_FRAGMENT) {
                return ProductListWithFilterContainerView(
                    productParameterHolder: selectedProductParameterHolder!,
                    appBarTitle: '');
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_DETAIL_FRAGMENT) {

                return ProductDetailView(
                  productId: selectedProductDetailHolder!.productId,
                  heroTagImage: selectedProductDetailHolder!.heroTagImage,
                  heroTagTitle: selectedProductDetailHolder!.heroTagTitle,
                  heroTagOriginalPrice: selectedProductDetailHolder!.heroTagOriginalPrice,
                  heroTagUnitPrice: selectedProductDetailHolder!.heroTagUnitPrice,
                  intentId: selectedProductDetailHolder!.id,
                  intentQty: selectedProductDetailHolder!.qty,
                  intentSelectedColorId: selectedProductDetailHolder!.selectedColorId,
                  intentSelectedColorValue: selectedProductDetailHolder!.selectedColorValue,
                  intentBasketPrice: selectedProductDetailHolder!.basketPrice,
                  intentBasketSelectedAttributeList: selectedProductDetailHolder!.basketSelectedAttributeList,
                  intentBasketSelectedAddOnList: selectedProductDetailHolder!.basketSelectedAddOnList,
                );
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_PRODUCT_INGREDIENTS_FRAGMENT) {
                return GalleryGridView( provider: selectedProductDetailProvider!);
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_TRANSACTION_DETAIL_FRAGMENT) {
                return TransactionItemListView(transaction: selectedTransactionHeader!);
              }
              else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT) {
                return ProductListWithFilterView(
                  key: const Key('1'),
                  animationController: animationController,
                  productParameterHolder:
                      ProductParameterHolder().getLatestParameterHolder(),
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT) {
                return ProductListWithFilterView(
                  key: const Key('2'),
                  animationController: animationController,
                  productParameterHolder:
                      ProductParameterHolder().getDiscountParameterHolder(),
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_TRENDING_PRODUCT_FRAGMENT) {
                return ProductListWithFilterView(
                  key: const Key('3'),
                  animationController: animationController,
                  productParameterHolder:
                      ProductParameterHolder().getTrendingParameterHolder(),
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_FEATURED_PRODUCT_FRAGMENT) {
                return ProductListWithFilterView(
                  key: const Key('4'),
                  animationController: animationController,
                  productParameterHolder:
                      ProductParameterHolder().getFeaturedParameterHolder(),
                );
              } else if (_currentIndex ==
                      PsConst
                          .REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_FORGOT_PASSWORD_FRAGMENT) {
                return Stack(children: <Widget>[
                  Container(
                    color: PsColors.mainLightColorWithBlack,
                    width: double.infinity,
                    height: double.maxFinite,
                  ),
                  CustomScrollView(
                      scrollDirection: Axis.vertical,
                      slivers: <Widget>[
                        ForgotPasswordView(
                          animationController: animationController,
                          goToLoginSelected: () {
                            animationController
                                .reverse()
                                .then<dynamic>((void data) {
                              if (!mounted) {
                                return;
                              }
                              if (_currentIndex ==
                                  PsConst
                                      .REQUEST_CODE__MENU_FORGOT_PASSWORD_FRAGMENT) {
                                updateSelectedIndexWithAnimation(
                                    Utils.getString(context, 'home_login'),
                                    PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT);
                              }
                              if (_currentIndex ==
                                  PsConst
                                      .REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT) {
                                updateSelectedIndexWithAnimation(
                                    Utils.getString(context, 'home_login'),
                                    PsConst
                                        .REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT);
                              }
                            });
                          },
                        )
                      ])
                ]);
              } else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT) {
                return Stack(children: <Widget>[
                  Container(
                    color: PsColors.mainLightColorWithBlack,
                    width: double.infinity,
                    height: double.maxFinite,
                  ),
                  CustomScrollView(scrollDirection: Axis.vertical, slivers: <
                      Widget>[
                    RegisterView(
                        animationController: animationController,
                        onRegisterSelected: (User user) {
                          _userId = user.userId!;
                          // widget.provider.psValueHolder.loginUserId = userId;
                          if (user.status == PsConst.ONE) {
                            updateSelectedIndexWithAnimationUserId(
                                Utils.getString(
                                    context, 'home__menu_drawer_profile'),
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                                user.userId);
                          } else {
                            if (_currentIndex ==
                                PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(
                                      context, 'home__verify_email'),
                                  PsConst
                                      .REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT);
                            } else if (_currentIndex ==
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(
                                      context, 'home__verify_email'),
                                  PsConst
                                      .REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT);
                            } else {
                              updateSelectedIndexWithAnimationUserId(
                                  Utils.getString(
                                      context, 'home__menu_drawer_profile'),
                                  PsConst
                                      .REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                                  user.userId);
                            }
                          }
                          // if (_currentIndex ==
                          //     PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT) {
                          //   updateSelectedIndexWithAnimation(
                          //       Utils.getString(context, 'home__verify_email'),
                          //       PsConst
                          //           .REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT);
                          // } else if (_currentIndex ==
                          //     PsConst
                          //         .REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT) {
                          //   updateSelectedIndexWithAnimation(
                          //       Utils.getString(context, 'home__verify_email'),
                          //       PsConst
                          //           .REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT);
                          // } else {
                          //   updateSelectedIndexWithAnimationUserId(
                          //       Utils.getString(
                          //           context, 'home__menu_drawer_profile'),
                          //       PsConst
                          //           .REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                          //       userId);
                          // }
                        },
                        goToLoginSelected: () {
                          animationController
                              .reverse()
                              .then<dynamic>((void data) {
                            if (!mounted) {
                              return;
                            }
                            if (_currentIndex ==
                                PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(context, 'home_login'),
                                  PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT);
                            }
                            if (_currentIndex ==
                                PsConst
                                    .REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT) {
                              updateSelectedIndexWithAnimation(
                                  Utils.getString(context, 'home_login'),
                                  PsConst
                                      .REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT);
                            }
                          });
                        })
                  ])
                ]);
              } else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT ||
                  _currentIndex ==
                      PsConst.REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT) {
                return _CallVerifyEmailWidget(
                    animationController: animationController,
                    animation: animation,
                    currentIndex: _currentIndex,
                    userId: _userId,
                    updateCurrentIndex: (String title, int index) {
                      updateSelectedIndexWithAnimation(title, index);
                    },
                    updateUserCurrentIndex:
                        (String title, int index, String? userId) async {
                      if (userId != null) {
                        _userId = userId;
                      }
                      setState(() {
                        appBarTitle = title;
                        _currentIndex = index;
                      });
                    });
              } else if (_currentIndex ==
                      PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT ||
                  _currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                return _CallLoginWidget(
                    currentIndex: _currentIndex,
                    animationController: animationController,
                    animation: animation,
                    updateCurrentIndex: (String title, int index) {
                      updateSelectedIndexWithAnimation(title, index);
                    },
                    updateUserCurrentIndex:
                        (String title, int? index, String? userId) {
                      setState(() {
                        if (index != null) {
                          appBarTitle = title;
                          _currentIndex = index;
                        }
                      });
                      if (userId != null) {
                        _userId = userId;
                      }
                    });
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT) {
                return ChangeNotifierProvider<UserProvider?>(
                    lazy: false,
                    create: (BuildContext context) {
                      userProvider = UserProvider(
                          repo: userRepository!, psValueHolder: valueHolder!);
                      return userProvider;
                    },
                    child: Consumer<UserProvider>(builder:
                        (BuildContext context, UserProvider provider,
                            Widget? child) {
                      if (
                          provider.psValueHolder.userIdToVerify == null ||
                          provider.psValueHolder.userIdToVerify == '') {
                        if (
                            provider.psValueHolder.loginUserId == null ||
                            provider.psValueHolder.loginUserId == '') {
                          return Stack(
                            children: <Widget>[
                              Container(
                                color: PsColors.mainLightColorWithBlack,
                                width: double.infinity,
                                height: double.maxFinite,
                              ),
                              CustomScrollView(
                                  scrollDirection: Axis.vertical,
                                  slivers: <Widget>[
                                    LoginView(
                                      animationController: animationController,
                                      animation: animation,
                                      onGoogleSignInSelected: (String userId) {
                                        setState(() {
                                          _currentIndex = PsConst
                                              .REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT;
                                        });
                                        _userId = userId;
                                        provider.psValueHolder.loginUserId =
                                            userId;
                                      },
                                      onFbSignInSelected: (String userId) {
                                        setState(() {
                                          _currentIndex = PsConst
                                              .REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT;
                                        });
                                        _userId = userId;
                                        provider.psValueHolder.loginUserId =
                                            userId;
                                      },
                                      onPhoneSignInSelected: () {
                                        if (_currentIndex ==
                                            PsConst
                                                .REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT) {
                                          updateSelectedIndexWithAnimation(
                                              Utils.getString(
                                                  context, 'home_phone_signin'),
                                              PsConst
                                                  .REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT);
                                        } else if (_currentIndex ==
                                            PsConst
                                                .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT) {
                                          updateSelectedIndexWithAnimation(
                                              Utils.getString(
                                                  context, 'home_phone_signin'),
                                              PsConst
                                                  .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
                                        } else if (_currentIndex ==
                                            PsConst
                                                .REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT) {
                                          updateSelectedIndexWithAnimation(
                                              Utils.getString(
                                                  context, 'home_phone_signin'),
                                              PsConst
                                                  .REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT);
                                        } else if (_currentIndex ==
                                            PsConst
                                                .REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT) {
                                          updateSelectedIndexWithAnimation(
                                              Utils.getString(
                                                  context, 'home_phone_signin'),
                                              PsConst
                                                  .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
                                        } else {
                                          updateSelectedIndexWithAnimation(
                                              Utils.getString(
                                                  context, 'home_phone_signin'),
                                              PsConst
                                                  .REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
                                        }
                                      },
                                      onProfileSelected: (String userId) {
                                        setState(() {
                                          _currentIndex = PsConst
                                              .REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT;
                                          _userId = userId;
                                          provider.psValueHolder.loginUserId =
                                              userId;
                                        });
                                      },
                                      onForgotPasswordSelected: () {
                                        setState(() {
                                          _currentIndex = PsConst
                                              .REQUEST_CODE__MENU_FORGOT_PASSWORD_FRAGMENT;
                                          appBarTitle = Utils.getString(
                                              context, 'home__forgot_password');
                                        });
                                      },
                                      onSignInSelected: () {
                                        updateSelectedIndexWithAnimation(
                                            Utils.getString(
                                                context, 'home__register'),
                                            PsConst
                                                .REQUEST_CODE__MENU_REGISTER_FRAGMENT);
                                      },
                                    ),
                                  ])
                            ],
                          );
                        } else {
                          return ProfileView(
                            scaffoldKey: scaffoldKey,
                            animationController: animationController,
                            flag: _currentIndex,
                            callLogoutCallBack: (String userId) {
                              callLogout(provider, deleteTaskProvider!,
                                  PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                            },
                          );
                        }
                      } else {
                        return _CallVerifyEmailWidget(
                            animationController: animationController,
                            animation: animation,
                            currentIndex: _currentIndex,
                            userId: _userId,
                            updateCurrentIndex: (String title, int index) {
                              updateSelectedIndexWithAnimation(title, index);
                            },
                            updateUserCurrentIndex:
                                (String title, int index, String? userId) async {
                              if (userId != null) {
                                _userId = userId;
                                provider.psValueHolder.loginUserId = userId;
                              }
                              setState(() {
                                appBarTitle = title;
                                _currentIndex = index;
                              });
                            });
                      }
                    }));
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT) {
                return FavouriteProductListView(
                    animationController: animationController);
              }
                else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_ORDER_FRAGMENT) {
                return TransactionListView(
                    scaffoldKey: scaffoldKey,
                    animationController: animationController);
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_USER_HISTORY_FRAGMENT) {
                return HistoryListView(
                    animationController: animationController);
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_USER_CREATE_RESERVATION_FRAGMENT) {
                return CreateReservationView(
                    animationController: animationController);
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_USER_RESERVATION_LIST_FRAGMENT) {
                return ReservationListView(
                    scaffoldKey: scaffoldKey,
                    animationController: animationController);
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_COLLECTION_FRAGMENT) {
                return CollectionHeaderListView(
                    animationController: animationController);
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_LANGUAGE_FRAGMENT) {
                return LanguageSettingView(
                    animationController: animationController,
                    languageIsChanged: () {});
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT) {
                return ContactUsView(
                    animationController: animationController,
                  userProvider: userProvider,
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT) {
                return Container(
                  color: PsColors.coreBackgroundColor,
                  height: double.infinity,
                  child: SettingView(
                    animationController: animationController,
                  ),
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT) {
                return PrivacyPolicyView(
                  animationController: animationController,
                );
              } else if (_currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_BASKET_FRAGMENT) {
                return BasketListView(
                  animationController: animationController,
                );
              // }else if (_currentIndex ==
              //     PsConst.REQUEST_CODE__MENU_VIEW_MY_SCHEDULE) {
              //   return ScheduleOrderListView(
              //     user: userProvider!.user.data!,
              //     isHideAppBar: true,
              //   );
              } else {
                animationController.forward();
                /*if(controllers.isEmpty)
                  controllers.add(HomeDashboardViewWidget(animationController, context,
                          (restaurant.Category category){
                        Navigator.pushNamed(
                            context, RoutePaths.subCategoryGrid,
                            arguments: category);
                      })
                  );
                return controllers.last;*/
                return HomeDashboardViewWidget(animationController, context,
                        (restaurant.Category category){
                      Navigator.pushNamed(
                          context, RoutePaths.subCategoryGrid,
                          arguments: category);
                    });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _CallLoginWidget extends StatelessWidget {
  const _CallLoginWidget(
      {required this.animationController,
      required this.animation,
      required this.updateCurrentIndex,
      required this.updateUserCurrentIndex,
      required this.currentIndex});
  final Function updateCurrentIndex;
  final Function updateUserCurrentIndex;
  final AnimationController animationController;
  final Animation<double> animation;
  final int currentIndex;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: PsColors
              .mainLightColorWithBlack, //ps_wtheme_core_background_color,
          width: double.infinity,
          height: double.maxFinite,
        ),
        CustomScrollView(scrollDirection: Axis.vertical, slivers: <Widget>[
          LoginView(
            animationController: animationController,
            animation: animation,
            onGoogleSignInSelected: (String userId) {
              if (currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT,
                    userId);
              } else {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                    userId);
              }
            },
            onFbSignInSelected: (String userId) {
              if (currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT,
                    userId);
              } else {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                    userId);
              }
            },
            onPhoneSignInSelected: () {
              if (currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateCurrentIndex(
                    Utils.getString(context, 'home_phone_signin'),
                    PsConst.REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT);
              } else if (currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT) {
                updateCurrentIndex(
                    Utils.getString(context, 'home_phone_signin'),
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
              } else if (currentIndex ==
                  PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT) {
                updateCurrentIndex(
                    Utils.getString(context, 'home_phone_signin'),
                    PsConst.REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT);
              } else if (currentIndex ==
                  PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT) {
                updateCurrentIndex(
                    Utils.getString(context, 'home_phone_signin'),
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
              } else {
                updateCurrentIndex(
                    Utils.getString(context, 'home_phone_signin'),
                    PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
              }
            },
            onProfileSelected: (String userId) {
              if (currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT,
                    userId);
              } else {
                updateUserCurrentIndex(
                    Utils.getString(context, 'home__menu_drawer_profile'),
                    PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                    userId);
              }
            },
            onForgotPasswordSelected: () {
              if(currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateCurrentIndex(
                    Utils.getString(context, 'home__forgot_password'),
                    PsConst.REQUEST_CODE__MENU_FORGOT_PASSWORD_FRAGMENT);
              } else {
                updateCurrentIndex(
                    Utils.getString(context, 'home__forgot_password'),
                    PsConst.REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT);
              }
            },
            onSignInSelected: () {
              if (currentIndex == PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                updateCurrentIndex(Utils.getString(context, 'home__register'),
                    PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT);
              } else {
                updateCurrentIndex(Utils.getString(context, 'home__register'),
                    PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT);
              }
            },
          ),
        ])
      ],
    );
  }
}

class _CallVerifyPhoneWidget extends StatelessWidget {
  const _CallVerifyPhoneWidget(
      {this.userName,
      this.phoneNumber,
      this.phoneId,
      required this.updateCurrentIndex,
      required this.updateUserCurrentIndex,
      required this.animationController,
      required this.animation,
      required this.currentIndex});

  final String? userName;
  final String? phoneNumber;
  final String? phoneId;
  final Function updateCurrentIndex;
  final Function updateUserCurrentIndex;
  final int currentIndex;
  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    animationController.forward();
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: VerifyPhoneView(
          userName: userName!,
          phoneNumber: phoneNumber!,
          phoneId: phoneId!,
          animationController: animationController,
          onProfileSelected: (String userId) {
            if (currentIndex ==
                PsConst.REQUEST_CODE__MENU_PHONE_VERIFY_FRAGMENT) {
              updateUserCurrentIndex(
                  Utils.getString(context, 'home__menu_drawer_profile'),
                  PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT,
                  userId);
            } else
            // if (currentIndex ==
            //     PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT)
            {
              updateUserCurrentIndex(
                  Utils.getString(context, 'home__menu_drawer_profile'),
                  PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                  userId);
            }
          },
          onSignInSelected: () {
            if (currentIndex ==
                PsConst.REQUEST_CODE__MENU_PHONE_VERIFY_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home_phone_signin'),
                  PsConst.REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT);
            } else if (currentIndex ==
                PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home_phone_signin'),
                  PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT);
            }
          },
        ));
  }
}

class _CallVerifyEmailWidget extends StatelessWidget {
  const _CallVerifyEmailWidget(
      {required this.updateCurrentIndex,
      required this.updateUserCurrentIndex,
      required this.animationController,
      required this.animation,
      required this.currentIndex,
      required this.userId});
  final Function updateCurrentIndex;
  final Function updateUserCurrentIndex;
  final int currentIndex;
  final AnimationController animationController;
  final Animation<double> animation;
  final String userId;

  @override
  Widget build(BuildContext context) {
    animationController.forward();
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: VerifyEmailView(
          animationController: animationController,
          userId: userId,
          onProfileSelected: (String userId) {
            if (currentIndex ==
                PsConst.REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT) {
              updateUserCurrentIndex(
                  Utils.getString(context, 'home__menu_drawer_profile'),
                  PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT,
                  userId);
            } else
            // (currentIndex ==
            //     PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT)
            {
              updateUserCurrentIndex(
                  Utils.getString(context, 'home__menu_drawer_profile'),
                  PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT,
                  userId);
              // updateCurrentIndex(PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT);
            }
          },
          onSignInSelected: () {
            if (currentIndex ==
                PsConst.REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home__register'),
                  PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT);
            } else if (currentIndex ==
                PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home__register'),
                  PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT);
            } else if (currentIndex ==
                PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home__register'),
                  PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT);
            } else if (currentIndex ==
                PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT) {
              updateCurrentIndex(Utils.getString(context, 'home__register'),
                  PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT);
            }
          },
        ));
  }
}

class _DrawerMenuWidget extends StatefulWidget {
  const _DrawerMenuWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final Function onTap;
  final int index;

  @override
  __DrawerMenuWidgetState createState() => __DrawerMenuWidgetState();
}

class __DrawerMenuWidgetState extends State<_DrawerMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(widget.icon, color: PsColors.mainColorWithWhite),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: () {
          widget.onTap(widget.title, widget.index);
        });
  }
}

class _DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/fs_android_3x.png',
            width: PsDimens.space100,
            height: PsDimens.space72,
          ),
          const SizedBox(
            height: PsDimens.space8,
          ),
          Text(
            Utils.getString(context, 'app_name'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: PsColors.white),
          ),
        ],
      ),
      decoration: BoxDecoration(color: PsColors.mainColor),
    );
  }
}

class _DrawerHeaderWidgetWithUserProfile extends StatefulWidget {
  const _DrawerHeaderWidgetWithUserProfile({
    Key? key, 
    required this.provider,
    required this.deleteTaskProvider
    }): super(key: key);

  final UserProvider provider;
  final DeleteTaskProvider deleteTaskProvider;

  @override
  __DrawerHeaderWidgetWithUserProfileState createState() => 
    __DrawerHeaderWidgetWithUserProfileState();
}

class __DrawerHeaderWidgetWithUserProfileState extends State<_DrawerHeaderWidgetWithUserProfile> {

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsDimens.space20), // Rounded corners
            border: Border.all(
              color: PsColors.white,
              width: 2.0,
            ),
          ),
        //color: Colors.green,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex:30,
        child:
            Container(
              padding: const EdgeInsets.all(PsDimens.space8),
              //color: Colors.blue,
              child: PsNetworkCircleImageForUser(
                width: 100,
                  height: 100,
                  photoKey: '',
                  imagePath:
                      widget.provider.user.data!.userProfilePhoto,
                  boxfit: BoxFit.cover,
                ),
              )
            ),
              Expanded(
                flex: 40,
                  child:
                  Container(
                    //color: Colors.red,
                      child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: PsDimens.space8,),
                       child: Text(
                          widget.provider.user.data!.userName!.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge!
                            .copyWith(color: PsColors.white,),
                        )

                  ),
                  /*if(widget.provider.user.data!.userPhone != '')
                  Padding(
                    padding: const EdgeInsets.only(
                        top: PsDimens.space4,
                        left: PsDimens.space8
                    ),
                    child: Text(
                      '${widget.provider.user.data!.userPhone!}',
                      style: Theme.of(context).textTheme.bodySmall!
                          .copyWith(color: PsColors.white),
                    ),
                  ),*/
                  if(widget.provider.user.data!.address != '')
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /*Padding(
                          padding: const EdgeInsets.only(
                              left: PsDimens.space6,
                              top: PsDimens.space4),
                          child: Icon(
                            Icons.location_on,
                            color: PsColors.white,
                            size: 14,
                          ),
                        ),*/
                        Expanded(
                          child:
                        Padding(
                          padding: const EdgeInsets.only(
                              top: PsDimens.space4,
                              left: PsDimens.space6
                          ),
                          child: Text(
                            '${widget.provider.user.data!.address!}'
                                ', ${widget.provider.user.data!.userCity}'
                                ', ${widget.provider.user.data!.userCountry}.',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: PsColors.white),
                            maxLines: 3,
                          ),
                        ),
                        ),
                      ],
                    ),
                        ]
                    )
                  )
                  ),
                ],
              )),
        decoration: BoxDecoration(color: PsColors.mainColor),
    );
  }
}
