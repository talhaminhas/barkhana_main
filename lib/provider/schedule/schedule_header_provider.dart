import 'dart:async';
import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../constant/ps_constants.dart';
import '../../repository/schedule_header_repository.dart';
import '../../utils/utils.dart';
import '../../viewobject/api_status.dart';
import '../../viewobject/basket.dart';
import '../../viewobject/basket_selected_add_on.dart';
import '../../viewobject/basket_selected_attribute.dart';
import '../../viewobject/common/ps_value_holder.dart';
import '../../viewobject/schedule_header.dart';
import '../../viewobject/user.dart';
import '../common/ps_provider.dart';
import '../transaction/transaction_header_provider.dart';

class ScheduleHeaderProvider extends PsProvider {
  ScheduleHeaderProvider(
      {required ScheduleHeaderRepository repo,
      required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    Utils.checkInternetConnectivity()
        .then((bool value) => isConnectedToInternet = value);

    _scheduleStream =
        StreamController<PsResource<List<ScheduleHeader>>>.broadcast();
    _subscription = _scheduleStream.stream
        .listen((PsResource<List<ScheduleHeader>> resource) {
      updateOffset(resource.data!.length);
      _scheduleList = resource;
      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  PsValueHolder? psValueHolder;
  ScheduleHeaderRepository? _repo;
  PsResource<List<ScheduleHeader>> _scheduleList =
      PsResource<List<ScheduleHeader>>(PsStatus.NOACTION, '', null);

  PsResource<List<ScheduleHeader>> get scheduleList => _scheduleList;
  late StreamController<PsResource<List<ScheduleHeader>>> _scheduleStream;
  late StreamSubscription<PsResource<List<ScheduleHeader>>> _subscription;
  PsResource<ApiStatus> _apiStatus =
      PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get apiStatus => _apiStatus;

  Future<PsResource<List<ScheduleHeader>>> postScheduleSubmit(
    User user,
    List<Basket> basketList,
    String clientNonce,
    String couponDiscount,
    String taxAmount,
    String totalDiscount,
    String subTotalAmount,
    String shippingAmount,
    String balanceAmount,
    String totalItemAmount,
    String isCod,
    String isPaypal,
    String isStripe,
    String isBank,
    String isRazor,
    String isFlutterWave,
    String isPaystack,
    String razorId,
    String flutterWaveId,
    String isPickUp,
    String pickAtShop,
    String deliveryPickupDate,
    String deliveryPickupTime,
    String shippingMethodPrice,
    String shippingMethodName,
    String? memoText,
    PsValueHolder valueHolder,
    String scheduleDay,
    String scheduleTime,
    String scheduleStatus,
  ) async {
    psValueHolder = valueHolder;

    final List<String> attributeIdStr = <String>[];
    List<String> attributeNameStr = <String>[];
    final List<String> attributePriceStr = <String>[];
    final List<String> addOnIdStr = <String>[];
    final List<String> addOnNameStr = <String>[];
    final List<String> addOnPriceStr = <String>[];
    double totalItemCount = 0.0;
    for (Basket basket in basketList) {
      totalItemCount += double.parse(basket.qty!);
    }

    final List<Map<String, dynamic>> detailJson = <Map<String, dynamic>>[];
    for (int i = 0; i < basketList.length; i++) {
      attributeIdStr.clear();
      attributeNameStr.clear();
      attributePriceStr.clear();
      addOnIdStr.clear();
      addOnNameStr.clear();
      addOnPriceStr.clear();
      for (BasketSelectedAttribute basketSelectedAttribute
          in basketList[i].basketSelectedAttributeList!) {
        attributeIdStr.add(basketSelectedAttribute.headerId!);
        attributeNameStr.add(basketSelectedAttribute.name!);
        attributePriceStr.add(basketSelectedAttribute.price!);
      }

      for (BasketSelectedAddOn basketSelectedAddOn
          in basketList[i].basketSelectedAddOnList!) {
        addOnIdStr.add(basketSelectedAddOn.id!);
        addOnNameStr.add(basketSelectedAddOn.name!);
        addOnPriceStr.add(basketSelectedAddOn.price!);
      }

      final DetailMap carJson = DetailMap(
        basketList[i].productId!,
        basketList[i].product!.name!,
        attributeIdStr.join('#').toString(),
        attributeNameStr.join('#').toString(),
        attributePriceStr.join('#').toString(),
        addOnIdStr.join('#').toString(),
        addOnNameStr.join('#').toString(),
        addOnPriceStr.join('#').toString(),
        basketList[i].selectedColorId ?? '',
        basketList[i].selectedColorValue ?? '',
        basketList[i].product!.unitPrice!,
        basketList[i].basketOriginalPrice!,
        basketList[i].product!.discountValue!,
        basketList[i].product!.discountAmount!,
        basketList[i].qty!,
        basketList[i].product!.discountValue!,
        basketList[i].product!.discountPercent!,
        basketList[i].product!.currencyShortForm!,
        basketList[i].product!.currencySymbol!,
        basketList[i].product!.productUnit!,
        basketList[i].product?.productMeasurement ?? '',
      );
      attributeNameStr = <String>[];
      detailJson.add(carJson.tojsonData());
    }

    final ScheduleSubmitMap newPost = ScheduleSubmitMap(
      userId: user.userId!,
      shopId: basketList[0].shopId!,
      subTotalAmount: Utils.getPriceTwoDecimal(subTotalAmount),
      discountAmount: Utils.getPriceTwoDecimal(totalDiscount),
      couponDiscountAmount: Utils.getPriceTwoDecimal(couponDiscount) ,
      taxAmount: Utils.getPriceTwoDecimal(taxAmount),
      shippingAmount: Utils.getPriceTwoDecimal(shippingAmount),
      balanceAmount: Utils.getPriceTwoDecimal(balanceAmount),
      totalItemAmount: Utils.getPriceTwoDecimal(totalItemAmount),
      contactName: user.userName!,
      contactPhone: user.userPhone!,
      contactEmail: user.userEmail!,
      contactAddress: user.address!,
      contactAreaId: user.area!.id!,
      transLat: user.userLat!,
      transLng: user.userLng!,
      isCod: isCod == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isPickUp: isPickUp == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isPaypal: isPaypal == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isStripe: isStripe == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isBank: isBank == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isRazor: isRazor == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isFlutterWave: isFlutterWave == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      isPaystack: isPaystack == PsConst.ONE ? PsConst.ONE : PsConst.ZERO,
      razorId: razorId,
      flutterWaveId: flutterWaveId,
      pickAtShop: pickAtShop,
      deliveryPickupDate: deliveryPickupDate,
      deliveryPickupTime: deliveryPickupTime,
      paymentMethodNonce: clientNonce,
      transStatusId: PsConst.THREE, // 3 = completed
      currencySymbol: basketList[0].product!.currencySymbol!,
      currencyShortForm: basketList[0].product!.currencyShortForm!,
      shippingTaxPercent: psValueHolder!.shippingTaxLabel!,
      taxPercent: psValueHolder!.overAllTaxLabel!,
      memo: memoText ?? '',
      totalItemCount: totalItemCount.toString(),
      details: detailJson,
      scheduleDay: scheduleDay,
      scheduleTime: scheduleTime,
      scheduleStatus: scheduleStatus,
    );
    isLoading = true;
    PsResource<List<ScheduleHeader>>? scheduleHeader;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    if (isConnectedToInternet) {
      scheduleHeader = await _repo!.postScheduleSubmit(
          _scheduleStream, newPost.toMap(), PsStatus.PROGRESS_LOADING);
    }
    return scheduleHeader!;
  }

  Future<PsResource<List<ScheduleHeader>>> updateScheduleOrder(
    String scheduleHeaderId,
    String scheduleStatus,
  ) async {
    final ScheduleUpdateMap newPost = ScheduleUpdateMap(
      scheduleHeaderId: scheduleHeaderId,
      scheduleStatus: scheduleStatus,
    );
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    return await _repo!.updateScheduleOrderStatus(
        newPost.toMap(), isConnectedToInternet);
  }

  Future<dynamic> getAllScheduleHeaderList(String userId) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllScheduleHeaderList(_scheduleStream, userId,
        isConnectedToInternet, limit, offset, PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> resetScheduleHeaderList(String userId) async {
    isLoading = true;
    updateOffset(0);
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllScheduleHeaderList(_scheduleStream, userId,
        isConnectedToInternet, limit, offset, PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> loadMoreScheduleHeaderList(String userId) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllScheduleHeaderList(_scheduleStream, userId,
        isConnectedToInternet, limit, offset, PsStatus.PROGRESS_LOADING);
  }

  Future<PsResource<ApiStatus>> deleteScheduleOrder(
      Map<String, dynamic> json) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();
    if (isConnectedToInternet) {
      return _apiStatus = await _repo!.deleteScheduleOrder(json);
    }
    return _apiStatus;
  }

  @override
  void dispose() {
    _subscription.cancel();
    isDispose = true;
    super.dispose();
  }
}

class ScheduleHeaderMap {
  ScheduleHeaderMap({this.scheduleHeadId});

  final String? scheduleHeadId;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['id'] = scheduleHeadId;

    return map;
  }
}

class ScheduleSubmitMap {
  ScheduleSubmitMap({
    this.userId,
    this.shopId,
    this.subTotalAmount,
    this.discountAmount,
    this.couponDiscountAmount,
    this.taxAmount,
    this.shippingAmount,
    this.balanceAmount,
    this.totalItemAmount,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.contactAddress,
    this.contactAreaId,
    this.transLat,
    this.transLng,
    this.isCod,
    this.pickAtShop,
    this.deliveryPickupDate,
    this.deliveryPickupTime,
    this.isPaypal,
    this.isStripe,
    this.isBank,
    this.isPickUp,
    this.isRazor,
    this.isFlutterWave,
    this.isPaystack,
    this.razorId,
    this.flutterWaveId,
    this.paymentMethodNonce,
    this.transStatusId,
    this.currencySymbol,
    this.currencyShortForm,
    this.shippingTaxPercent,
    this.taxPercent,
    this.memo,
    this.totalItemCount,
    this.details,
    this.scheduleDay,
    this.scheduleStatus,
    this.scheduleTime,
  });

  String? userId;
  String? shopId;
  String? subTotalAmount;
  String? discountAmount;
  String? couponDiscountAmount;
  String? taxAmount;
  String? shippingAmount;
  String? balanceAmount;
  String? totalItemAmount;
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  String? contactAddress;
  String? contactAreaId;
  String? transLat;
  String? transLng;
  String? isPickUp;
  String? isCod;
  String? pickAtShop;
  String? deliveryPickupDate;
  String? deliveryPickupTime;
  String? isPaypal;
  String? isStripe;
  String? isBank;
  String? isRazor;
  String? isFlutterWave;
  String? isPaystack;
  String? razorId;
  String? flutterWaveId;
  String? paymentMethodNonce;
  String? transStatusId;
  String? currencySymbol;
  String? currencyShortForm;
  String? shippingTaxPercent;
  String? taxPercent;
  String? memo;
  String? totalItemCount;
  List<Map<String, dynamic>>? details;
  String? scheduleDay;
  String? scheduleTime;
  String? scheduleStatus;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['user_id'] = userId;
    map['shop_id'] = shopId;
    map['sub_total_amount'] = subTotalAmount;
    map['discount_amount'] = discountAmount;
    map['coupon_discount_amount'] = couponDiscountAmount;
    map['tax_amount'] = taxAmount;
    map['shipping_amount'] = shippingAmount;
    map['balance_amount'] = balanceAmount;
    map['total_item_amount'] = totalItemAmount;
    map['contact_name'] = contactName;
    map['contact_phone'] = contactPhone;
    map['contact_email'] = contactEmail;
    map['contact_address'] = contactAddress;
    map['contact_area_id'] = contactAreaId;
    map['trans_lat'] = transLat;
    map['trans_lng'] = transLng;
    map['is_cod'] = isCod;
    map['pick_at_shop'] = pickAtShop;
    map['delivery_pickup_date'] = deliveryPickupDate;
    map['delivery_pickup_time'] = deliveryPickupTime;
    map['is_paypal'] = isPaypal;
    map['is_stripe'] = isStripe;
    map['is_bank'] = isBank;
    map['is_pickup'] = isPickUp;
    map['is_razor'] = isRazor;
    map['is_flutter_wave'] = isFlutterWave;
    map['is_paystack'] = isPaystack;
    map['razor_id'] = razorId;
    map['flutter_wave_id'] = flutterWaveId;
    map['payment_method_nonce'] = paymentMethodNonce;
    map['trans_status_id'] = transStatusId;
    map['currency_symbol'] = currencySymbol;
    map['currency_short_form'] = currencyShortForm;
    map['shipping_tax_percent'] = shippingTaxPercent;
    map['tax_percent'] = taxPercent;
    map['memo'] = memo;
    map['total_item_count'] = totalItemCount;
    map['details'] = details;
    map['schedule_day'] = scheduleDay;
    map['schedule_time'] = scheduleTime;
    map['schedule_status'] = scheduleStatus;

    return map;
  }
}

class ScheduleUpdateMap {
  ScheduleUpdateMap({
    this.scheduleHeaderId,
    this.scheduleStatus,
  });

  String? scheduleStatus;
  String? scheduleHeaderId;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = scheduleHeaderId;
    map['schedule_status'] = scheduleStatus;
    return map;
  }
}
