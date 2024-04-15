import 'dart:convert';
import 'dart:io';

import 'package:flutterrestaurant/api/ps_url.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/viewobject/about_app.dart';
import 'package:flutterrestaurant/viewobject/api_status.dart';
import 'package:flutterrestaurant/viewobject/api_token.dart';
import 'package:flutterrestaurant/viewobject/blog.dart';
import 'package:flutterrestaurant/viewobject/category.dart';
import 'package:flutterrestaurant/viewobject/comment_detail.dart';
import 'package:flutterrestaurant/viewobject/comment_header.dart';
import 'package:flutterrestaurant/viewobject/coupon_discount.dart';
import 'package:flutterrestaurant/viewobject/default_photo.dart';
import 'package:flutterrestaurant/viewobject/delivery_boy_rating.dart';
import 'package:flutterrestaurant/viewobject/delivery_cost.dart';
import 'package:flutterrestaurant/viewobject/download_product.dart';
import 'package:flutterrestaurant/viewobject/global_token_header.dart';
import 'package:flutterrestaurant/viewobject/noti.dart';
import 'package:flutterrestaurant/viewobject/postal_address.dart';
import 'package:flutterrestaurant/viewobject/product.dart';
import 'package:flutterrestaurant/viewobject/product_collection_header.dart';
import 'package:flutterrestaurant/viewobject/ps_app_info.dart';
import 'package:flutterrestaurant/viewobject/rating.dart';
import 'package:flutterrestaurant/viewobject/reservation.dart';
import 'package:flutterrestaurant/viewobject/shipping_area.dart';
import 'package:flutterrestaurant/viewobject/shop_info.dart';
import 'package:flutterrestaurant/viewobject/sub_category.dart';
import 'package:flutterrestaurant/viewobject/transaction_detail.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:flutterrestaurant/viewobject/transaction_status.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:flutterrestaurant/viewobject/user_location.dart';
import 'package:http/http.dart' as http;

import '../db/common/ps_shared_preferences.dart';
import '../viewobject/holder/globalTokenPost.dart';
import '../viewobject/main_point.dart';
import '../viewobject/schedule_detail.dart';
import '../viewobject/schedule_header.dart';
import '../viewobject/search_result.dart';
import 'common/ps_api.dart';
import 'common/ps_resource.dart';

class PsApiService extends PsApi {
  ///
  /// App Info
  ///
  Future<PsResource<PSAppInfo>> postPsAppInfo(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_app_info_url}';
    return await postData<PSAppInfo, PSAppInfo>(PSAppInfo(), url, jsonMap);
  }

  ///
  /// Apple Login
  ///
  Future<PsResource<User>> postAppleLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_apple_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  Future<PsResource<MainPoint>> getAllPoints(
      String deliveryBoyLat,
      String deliveryBoyLng,
      String orderLat,
      String orderLng,
      ) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$deliveryBoyLng%2C$deliveryBoyLat%3B$orderLng%2C$orderLat?alternatives=false&geometries=polyline&language=en&overview=full&steps=true&access_token=pk.eyJ1IjoidGFsaGFtaW5oYXMiLCJhIjoiY2x0bzlrenBjMGM5NTJpbzY2aHNlaGhudCJ9.AyfJIRGElx_Iv7LagZwTKg';

    //'http://router.project-osrm.org/trip/v1/driving/$deliveryBoyLng,$deliveryBoyLat;$orderLng,$orderLat?overview=simplified&steps=true';

    return await getSpecificServerCall<MainPoint, MainPoint>(MainPoint(), url);
  }

  ///
  /// User Register
  ///
  Future<PsResource<User>> postUserRegister(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_register_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Verify Email
  ///
  Future<PsResource<User>> postUserEmailVerify(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_email_verify_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Login
  ///
  Future<PsResource<User>> postUserLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// FB Login
  ///
  Future<PsResource<User>> postFBLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_fb_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// Google Login
  ///
  Future<PsResource<User>> postGoogleLogin(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_google_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Forgot Password
  ///
  Future<PsResource<ApiStatus>> postForgotPassword(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_forgot_password_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Change Password
  ///
  Future<PsResource<ApiStatus>> postChangePassword(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_change_password_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// User Profile Update
  ///
  Future<PsResource<User>> postProfileUpdate(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_user_update_profile_url}';
    print(PsUrl.ps_post_ps_user_update_profile_url);
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// User Phone Login
  ///
  Future<PsResource<User>> postPhoneLogin(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_phone_login_url}';
    return await postData<User, User>(User(), url, jsonMap);
  }

  ///
  /// Food Delivery Fee
  ///
  Future<PsResource<DeliveryCost>> postDeliveryCheckingAndCalculating(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_delivery_calculating_url}';
    return await postData<DeliveryCost, DeliveryCost>(
        DeliveryCost(), url, jsonMap);
  }

  ///
  /// User Resend Code
  ///
  Future<PsResource<ApiStatus>> postResendCode(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_resend_code_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Touch Count
  ///
  Future<PsResource<ApiStatus>> postTouchCount(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_post_ps_touch_count_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// Get User
  ///
  Future<PsResource<List<User>>> getUser(String userId) async {
    final String url =
        '${PsUrl.ps_user_url}/api_key/${PsConfig.ps_api_key}/user_id/$userId';
  print('${PsUrl.ps_user_url}/api_key/${PsConfig.ps_api_key}/user_id/$userId');
    return await getServerCall<User, List<User>>(User(), url);
  }

  Future<PsResource<User>> postImageUpload(
      String userId, String platformName, File imageFile) async {
    const String url = '${PsUrl.ps_image_upload_url}';

    return postUploadImage<User, User>(
        User(), url, userId, platformName, imageFile);
  }

  ///
  /// About App
  ///
  Future<PsResource<List<AboutApp>>> getAboutAppDataList() async {
    const String url =
        '${PsUrl.ps_about_app_url}/api_key/${PsConfig.ps_api_key}/';
    return await getServerCall<AboutApp, List<AboutApp>>(AboutApp(), url);
  }

  ///
  /// Get Shipping Area
  ///
  Future<PsResource<List<ShippingArea>>> getShippingArea() async {
    const String url =
        '${PsUrl.ps_shipping_area_url}/api_key/${PsConfig.ps_api_key}';

    return await getServerCall<ShippingArea, List<ShippingArea>>(
        ShippingArea(), url);
  }

  ///
  /// Get Shipping Area By Id
  ///
  Future<PsResource<ShippingArea>> getShippingAreaById(
      String shippingId) async {
    final String url =
        '${PsUrl.ps_shipping_area_url}/api_key/${PsConfig.ps_api_key}/id/$shippingId';

    return await getServerCall<ShippingArea, ShippingArea>(ShippingArea(), url);
  }

  static Future<bool> getPostcodeStatus (
      String postcode) async {
    final String url =
        '${PsUrl.ps_validate_postcode_url}$postcode';
    final http.Response response = await http.get(Uri.parse(url));
    return response.statusCode == 200;
  }
  ///
  /// Category
  ///
  Future<PsResource<List<Category>>> getCategoryList(
      int limit, int offset, Map<dynamic, dynamic> jsonMap) async {
    final String url =
        '${PsUrl.ps_category_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<Category, List<Category>>(Category(), url, jsonMap);
  }

  Future<PsResource<List<Category>>> getAllCategoryList(
      Map<dynamic, dynamic> jsonMap) async {
    const String url =
        '${PsUrl.ps_category_url}/api_key/${PsConfig.ps_api_key}';

    return await postData<Category, List<Category>>(Category(), url, jsonMap);
  }

  Future<PsResource<List<Category>>> getCategoryListByKey(
      int limit, int offset, Map<dynamic, dynamic> jsonMap) async {
    final String url =
        '${PsUrl.ps_category_search_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';
    return await postData<Category, List<Category>>(Category(), url, jsonMap);
  }

  ///
  /// Sub Category
  ///
  Future<PsResource<List<SubCategory>>> getSubCategoryList(
      int limit, int offset, String categoryId) async {
    final String url =
        '${PsUrl.ps_subCategory_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset/cat_id/$categoryId';

    return await getServerCall<SubCategory, List<SubCategory>>(
        SubCategory(), url);
  }

  Future<PsResource<List<SubCategory>>> getSubCategoryListByKey(
      int limit, int offset, Map<String, dynamic> json) async {
    final String url =
        '${PsUrl.ps_subCategory_search_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';
    return await postData<SubCategory, List<SubCategory>>(
        SubCategory(), url, json);
  }

  Future<PsResource<List<SubCategory>>> getAllSubCategoryList(
      String categoryId) async {
    final String url =
        '${PsUrl.ps_subCategory_url}/api_key/${PsConfig.ps_api_key}/cat_id/$categoryId';

    return await getServerCall<SubCategory, List<SubCategory>>(
        SubCategory(), url);
  }

  //noti
  Future<PsResource<List<Noti>>> getNotificationList(
      Map<dynamic, dynamic> paramMap, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_noti_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<Noti, List<Noti>>(Noti(), url, paramMap);
  }

  //
  /// Product
  ///
    Future<PsResource<List<Product>>> getProductList(
      Map<dynamic, dynamic> paramMap, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_product_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await postData<Product, List<Product>>(Product(), url, paramMap);
  }

  Future<PsResource<Product>> getProductDetail(
      String productId, String loginUserId) async {
    final String url =
        '${PsUrl.ps_product_detail_url}/api_key/${PsConfig.ps_api_key}/id/$productId/login_user_id/$loginUserId';
    return await getServerCall<Product, Product>(Product(), url);
  }

  Future<PsResource<List<Product>>> getRelatedProductList(
      String productId, String categoryId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_relatedProduct_url}/api_key/${PsConfig.ps_api_key}/id/$productId/cat_id/$categoryId/limit/$limit/offset/$offset';
    print(url);
    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  //
  /// Product Collection
  ///
  Future<PsResource<List<ProductCollectionHeader>>> getProductCollectionList(
      int limit, int offset) async {
    final String url =
        '${PsUrl.ps_collection_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<ProductCollectionHeader,
        List<ProductCollectionHeader>>(ProductCollectionHeader(), url);
  }

  ///Setting
  ///

  Future<PsResource<ShopInfo>> getShopInfo() async {
    const String url =
        '${PsUrl.ps_shop_info_url}/api_key/${PsConfig.ps_api_key}';
    return await getServerCall<ShopInfo, ShopInfo>(ShopInfo(), url);
  }

  ///Blog
  ///

  Future<PsResource<List<Blog>>> getBlogList(int limit, int offset) async {
    final String url =
        '${PsUrl.ps_bloglist_url}/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<Blog, List<Blog>>(Blog(), url);
  }

  ///Transaction
  ///

  Future<PsResource<List<TransactionHeader>>> getTransactionList(
      String userId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_transactionList_url}/api_key/${PsConfig.ps_api_key}/user_id/$userId/limit/$limit/offset/$offset';
    print (url);

    return await getServerCall<TransactionHeader, List<TransactionHeader>>(
        TransactionHeader(), url);
  }

  Future<PsResource<List<TransactionDetail>>> getTransactionDetail(
      String id, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_transactionDetail_url}/api_key/${PsConfig.ps_api_key}/transactions_header_id/$id/limit/$limit/offset/$offset';
    print(url);
    return await getServerCall<TransactionDetail, List<TransactionDetail>>(
        TransactionDetail(), url);
  }

  Future<PsResource<TransactionHeader>> postTransactionSubmit(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_transaction_submit_url}';
    return await postData<TransactionHeader, TransactionHeader>(
        TransactionHeader(), url, jsonMap);
  }
  Future<PsResource<GlobalTokenHeader>> postGlobalTokenSubmit(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_global_token_submit_url}';
    return await postData<GlobalTokenHeader, GlobalTokenHeader>(
        GlobalTokenHeader(), url, jsonMap);
  }
  ///
  /// Token
  ///
  Future<PsResource<ApiStatus>> getToken() async {
    const String url = '${PsUrl.ps_token_url}/api_key/${PsConfig.ps_api_key}';
    return await getServerCall<ApiStatus, ApiStatus>(ApiStatus(), url);
  }
  Future<PsResource<List<TransactionStatus>>> getTransactionStatusList() async {
    const String url =
        '${PsUrl.ps_transactionStatus_url}/api_key/${PsConfig.ps_api_key}';

    return await getServerCall<TransactionStatus, List<TransactionStatus>>(
        TransactionStatus(), url);
  }

  ///
  /// Comments
  ///
  Future<PsResource<List<CommentHeader>>> getCommentList(
      String productId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_commentList_url}/api_key/${PsConfig.ps_api_key}/product_id/$productId/limit/$limit/offset/$offset';

    return await getServerCall<CommentHeader, List<CommentHeader>>(
        CommentHeader(), url);
  }

  Future<PsResource<List<CommentDetail>>> getCommentDetail(
      String headerId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_commentDetail_url}/api_key/${PsConfig.ps_api_key}/header_id/$headerId/limit/$limit/offset/$offset';

    return await getServerCall<CommentDetail, List<CommentDetail>>(
        CommentDetail(), url);
  }

  Future<PsResource<CommentHeader>> getCommentHeaderById(
      String commentId) async {
    final String url =
        '${PsUrl.ps_commentList_url}/api_key/${PsConfig.ps_api_key}/id/$commentId';

    return await getServerCall<CommentHeader, CommentHeader>(
        CommentHeader(), url);
  }

  ///
  /// Favourites
  ///
  Future<PsResource<List<Product>>> getFavouritesList(
      String loginUserId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_favouriteList_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId/limit/$limit/offset/$offset';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  ///
  /// Product List By Collection Id
  ///
  Future<PsResource<List<Product>>> getProductListByCollectionId(
      String collectionId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_all_collection_url}/api_key/${PsConfig.ps_api_key}/id/$collectionId/limit/$limit/offset/$offset';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  Future<PsResource<List<CommentHeader>>> postCommentHeader(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_commentHeaderPost_url}';
    return await postData<CommentHeader, List<CommentHeader>>(
        CommentHeader(), url, jsonMap);
  }

  Future<PsResource<List<CommentDetail>>> postCommentDetail(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_commentDetailPost_url}';
    return await postData<CommentDetail, List<CommentDetail>>(
        CommentDetail(), url, jsonMap);
  }

  Future<PsResource<List<DownloadProduct>>> postDownloadProductList(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_downloadProductPost_url}';
    return await postData<DownloadProduct, List<DownloadProduct>>(
        DownloadProduct(), url, jsonMap);
  }

  Future<PsResource<ApiStatus>> rawRegisterNotiToken(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_register_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<ApiStatus>> rawUnRegisterNotiToken(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_unregister_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<Noti>> postNoti(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_noti_post_url}';
    return await postData<Noti, Noti>(Noti(), url, jsonMap);
  }

  ///
  /// Rating
  ///
  Future<PsResource<Rating>> postRating(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_ratingPost_url}';
    return await postData<Rating, Rating>(Rating(), url, jsonMap);
  }


  Future<PsResource<List<Rating>>> getRatingList(
      String productId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_ratingList_url}/api_key/${PsConfig.ps_api_key}/product_id/$productId/limit/$limit/offset/$offset';

    return await getServerCall<Rating, List<Rating>>(Rating(), url);
  }
  ///
  /// get postal addresses
  ///
  Future<PsResource<PostalAddress>> postalAddressList(
      Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_postalAddressList_url}';
    return await postData<PostalAddress, PostalAddress>(
        PostalAddress(), url, jsonMap);
  }
  ///
  /// get barer token
  ///
  Future<PsResource<ApiToken>> getApiToken(
      Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_api_request_token_post_url}';
    return await postData<ApiToken, ApiToken>(
        ApiToken(), url, jsonMap);
  }
  ///
  /// get user location
  ///
  Future<PsResource<UserLocation>> getUserLocation(
      String userId) async {
    final String url =
        '${PsUrl.ps_userLocation_url}/api_key/${PsConfig.ps_api_key}?user_id=$userId';

    return await getServerCall<UserLocation, UserLocation>(
        UserLocation(), url);
  }
  ///
  /// update token
  ///
  Future<PsResource<ApiToken>> updateApiToken(
      Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_api_update_token_post_url}';
    return await postData<ApiToken, ApiToken>(
        ApiToken(), url, jsonMap);
  }
  ///
  /// Delivery Boy Rating
  ///
  Future<PsResource<DeliveryBoyRating>> postDeliveryBoyRating(Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_delivery_boy_ratingPost_url}';
    return await postData<DeliveryBoyRating, DeliveryBoyRating>(DeliveryBoyRating(), url, jsonMap);
  }

  // Schedule Header

  Future<PsResource<List<ScheduleHeader>>> postScheduleSubmit(
      Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_schedule_order_submit_url}';
    return await postData<ScheduleHeader, List<ScheduleHeader>>(
        ScheduleHeader(), url, jsonMap);
  }

  Future<PsResource<List<ScheduleHeader>>> updateScheduleOrder(
      Map<String, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_schedule_order_status_update_url}';
    return await postData<ScheduleHeader, List<ScheduleHeader>>(
        ScheduleHeader(), url, jsonMap);
  }
  Future<PsResource<List<ScheduleDetail>>> getScheduleDetail(
      String id, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_schedule_detail_url}/api_key/${PsConfig.ps_api_key}/schedule_header_id/$id/limit/$limit/offset/$offset';
    print(url);
    return await getServerCall<ScheduleDetail, List<ScheduleDetail>>(
        ScheduleDetail(), url);
  }

  Future<PsResource<List<ScheduleHeader>>> getAllScheduleHeaderByUserId(
    String id,
    int limit,
    int offset,
  ) async {
    final String url =
        '${PsUrl.ps_schedule_header_list_url}/api_key/${PsConfig.ps_api_key}/user_id/$id/limit/$limit/offset/$offset';

    return await getServerCall<ScheduleHeader, List<ScheduleHeader>>(
        ScheduleHeader(), url);
  }

  Future<PsResource<ApiStatus>> deleteSchedule(
      Map<String, dynamic> json) async {
    const String url =
        '${PsUrl.ps_delete_schedule_url}/api_key/${PsConfig.ps_api_key}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, json);
  }


  ///
  ///Favourite
  ///
  Future<PsResource<List<Product>>> getFavouriteList(
      String loginUserId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_ratingList_url}/api_key/${PsConfig.ps_api_key}/login_user_id/$loginUserId/limit/$limit/offset/$offset';

    return await getServerCall<Product, List<Product>>(Product(), url);
  }

  Future<PsResource<Product>> postFavourite(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_favouritePost_url}';
    return await postData<Product, Product>(Product(), url, jsonMap);
  }

  ///
  /// Gallery
  ///
  Future<PsResource<List<DefaultPhoto>>> getImageList(
      String parentImgId,
      // String imageType,
      int limit,
      int offset) async {
    final String url =
        '${PsUrl.ps_gallery_url}/api_key/${PsConfig.ps_api_key}/img_parent_id/$parentImgId/limit/$limit/offset/$offset';

    return await getServerCall<DefaultPhoto, List<DefaultPhoto>>(
        DefaultPhoto(), url);
  }


  ///
  /// Contact
  ///
  Future<PsResource<ApiStatus>> postContactUs(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_contact_us_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  ///
  /// CouponDiscount
  ///
  Future<PsResource<CouponDiscount>> postCouponDiscount(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_couponDiscount_url}';
    return await postData<CouponDiscount, CouponDiscount>(
        CouponDiscount(), url, jsonMap);
  }

  Future<Map<String, dynamic>?> getGlobalTransactionStatus(GlobalTokenPost dataToSend) async {

    const String url = '${PsConfig.ps_app_url}${PsUrl.ps_global_token_submit_url}';
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
        },
        body: jsonEncode(dataToSend.toJson()),
      );

      if (response.statusCode != 500) {
        return json.decode(response.body);
      } else {
        print('Failed to post data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  Future<String?> postGlobalTokenData(GlobalTokenPost dataToSend) async {

    const String url = '${PsConfig.ps_app_url}${PsUrl.ps_global_token_submit_url}';
      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
          },
          body: jsonEncode(dataToSend.toJson()),
        );

        if (response.statusCode == 200) {
          return response.body;
        } else {
          print('Failed to post data: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Error: $e');
        return null;
      }
  }
  ///
  /// Reservation
  ///
  Future<PsResource<ApiStatus>> postReservation(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_create_reservation_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }

  Future<PsResource<List<Reservation>>> getReservationList(
      String userId, int limit, int offset) async {
    final String url =
        '${PsUrl.ps_reservationList_url}/user_id/$userId/api_key/${PsConfig.ps_api_key}/limit/$limit/offset/$offset';

    return await getServerCall<Reservation, List<Reservation>>(
        Reservation(), url);
  }

  Future<PsResource<Reservation>> postReservationStatus(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_create_reservation_status_url}';
    return await postData<Reservation, Reservation>(
        Reservation(), url, jsonMap);
  }

  Future<PsResource<SearchResult>> getSearchResult(
      Map<String, dynamic> json) async {
    const String url =
        '${PsUrl.ps_search_result_url}/api_key/${PsConfig.ps_api_key}/limit/1/offset/0/';
    return await postData(SearchResult(), url, json);
  }

  ///
  /// Refund
  ///
  Future<PsResource<TransactionHeader>> postRefund(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_cancel_order_refund_url}';
    return await postData<TransactionHeader, TransactionHeader>(
        TransactionHeader(), url, jsonMap);
  }

  ///
  /// Delete User
  ///
  Future<PsResource<ApiStatus>> postDeleteUser(
      Map<dynamic, dynamic> jsonMap) async {
    const String url = '${PsUrl.ps_delete_user_url}';
    return await postData<ApiStatus, ApiStatus>(ApiStatus(), url, jsonMap);
  }
}
