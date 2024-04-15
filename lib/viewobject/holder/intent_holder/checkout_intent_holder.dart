import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';

class CheckoutIntentHolder {
  const CheckoutIntentHolder({
    required this.basketList,
    this.shopInfoProvider,
  });
  final List<Basket> basketList;
  final ShopInfoProvider? shopInfoProvider;
}
