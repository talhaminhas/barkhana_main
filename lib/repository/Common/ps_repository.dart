import 'package:flutterrestaurant/db/common/ps_shared_preferences.dart';

class PsRepository {
  Future<dynamic> loadValueHolder() async {
    await PsSharedPreferences.instance.loadValueHolder();
  }

  Future<dynamic> replaceLoginUserId(String loginUserId) async {
    await PsSharedPreferences.instance.replaceLoginUserId(
      loginUserId,
    );
  }

  Future<dynamic> replaceLoginUserName(String loginUserName) async {
    await PsSharedPreferences.instance.replaceLoginUserName(
      loginUserName,
    );
  }

  Future<dynamic> replaceNotiToken(String notiToken) async {
    await PsSharedPreferences.instance.replaceNotiToken(
      notiToken,
    );
  }

  Future<dynamic> replaceNotiMessage(String message) async {
    await PsSharedPreferences.instance.replaceNotiMessage(
      message,
    );
  }

  Future<dynamic> replaceNotiSetting(bool notiSetting) async {
    await PsSharedPreferences.instance.replaceNotiSetting(
      notiSetting,
    );
  }

  Future<dynamic> replaceIsToShowIntroSlider(bool doNotShowAgain) async {
    await PsSharedPreferences.instance.replaceIsToShowIntroSlider(
      doNotShowAgain,
    );
  }
  Future<dynamic> replaceIsUserAlreadyChoose(bool isUserAlreadyChoose) async {
    await PsSharedPreferences.instance.replaceIsUserAlreadyChoose(
      isUserAlreadyChoose,
    );
  }

  Future<dynamic> replaceDate(String startDate, String endDate) async {
    await PsSharedPreferences.instance.replaceDate(startDate, endDate);

  }

  Future<dynamic> replaceMobileSettingData(
    String lat,
    String lng,
    String googlePlayStoreUrl, 
    String appleAppStoreUrl,
    String defaultLanguageCode,
    String defaultLanguageCountryCode,
    String defaultLanguageName,
    String priceForamat,
    String dateFormat,
    String defaultOrderTime,
    String iOSAppStoreId,
    String isUseThumbnailAsPlaceholder,
    String isShowTokenId,
    String isShowSubCategory,
    String fbKey,
    String isShowAdmob,
    String defaultLoadingLimit,
    String categoryLoadingLimit,
    String collectionProductLoadingLimit,
    String discountProductLoadingLimit,
    String featureProductLoadingLimit,
    String latestProductLoadingLimit,
    String trendingProductLoadingLimit,
    String shopLoadingLimit,
    String showFacebookLogin,
    String showGoogleLogin,
    String showPhoneLogin,
    String showMainMenu,
    String showSpecialCollections,
    String showFeaturedItems,
    String isRazorSupportMultiCurrency,
    String defaultRazorCurrency,
    String defaultFlutterWaveCurrency
   ) async {
    await PsSharedPreferences.instance.replaceMobileSettingData(
      lat,
      lng,
      googlePlayStoreUrl, 
      appleAppStoreUrl,
      defaultLanguageCode,
      defaultLanguageCountryCode,
      defaultLanguageName,
      priceForamat,
      dateFormat,
      defaultOrderTime,
      iOSAppStoreId,
      isUseThumbnailAsPlaceholder,
      isShowTokenId,
      isShowSubCategory,
      fbKey,
      isShowAdmob,
      defaultLoadingLimit,
      categoryLoadingLimit,
      collectionProductLoadingLimit,
      discountProductLoadingLimit,
      featureProductLoadingLimit,
      latestProductLoadingLimit,
      trendingProductLoadingLimit,
      shopLoadingLimit,
      showFacebookLogin,
      showGoogleLogin,
      showPhoneLogin,
      showMainMenu,
      showSpecialCollections,
      showFeaturedItems,
      isRazorSupportMultiCurrency,
      defaultRazorCurrency,
      defaultFlutterWaveCurrency
      );
  }


  Future<dynamic> replaceVerifyUserData(
      String userIdToVerify,
      String userNameToVerify,
      String userEmailToVerify,
      String userPasswordToVerify) async {
    await PsSharedPreferences.instance.replaceVerifyUserData(userIdToVerify,
        userNameToVerify, userEmailToVerify, userPasswordToVerify);
  }

  Future<dynamic> replaceVersionForceUpdateData(bool appInfoForceUpdate) async {
    await PsSharedPreferences.instance.replaceVersionForceUpdateData(
      appInfoForceUpdate,
    );
  }

  Future<dynamic> replaceAppInfoData(
      String appInfoVersionNo,
      bool appInfoForceUpdate,
      String appInfoForceUpdateTitle,
      String appInfoForceUpdateMsg) async {
    await PsSharedPreferences.instance.replaceAppInfoData(appInfoVersionNo,
        appInfoForceUpdate, appInfoForceUpdateTitle, appInfoForceUpdateMsg);
  }

  Future<dynamic> replaceShopInfoValueHolderData(
      String overAllTaxLabel,
      String overAllTaxValue,
      String shippingTaxLabel,
      String shippingTaxValue,
      String shippingId,
      String shopId,
      String messenger,
      String whatsApp,
      String phone,
      String minimumOrderAmount) async {
    await PsSharedPreferences.instance.replaceShopInfoValueHolderData(
        overAllTaxLabel,
        overAllTaxValue,
        shippingTaxLabel,
        shippingTaxValue,
        shippingId,
        shopId,
        messenger,
        whatsApp,
        phone,
        minimumOrderAmount);
  }

  Future<dynamic> replaceCheckoutEnable(
      String paypalEnabled,
      String stripeEnabled,
      String paystackEnabled,
      String codEnabled,
      String bankEnabled,
      String standardShippingEnable,
      String zoneShippingEnable,
      String noShippingEnable) async {
    await PsSharedPreferences.instance.replaceCheckoutEnable(
        paypalEnabled,
        stripeEnabled,
        paystackEnabled,
        codEnabled,
        bankEnabled,
        standardShippingEnable,
        zoneShippingEnable,
        noShippingEnable);
  }

  Future<dynamic> replacePublishKey(String pubKey) async {
    await PsSharedPreferences.instance.replacePublishKey(pubKey);
  }

  Future<dynamic> replacePayStackKey(String payStackKey) async {
    await PsSharedPreferences.instance.replacePayStackKey(payStackKey);
  }
}
