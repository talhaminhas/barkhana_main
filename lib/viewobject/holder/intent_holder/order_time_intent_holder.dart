import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../provider/user/user_provider.dart';

class OrderTimeIntentHolder {
  const OrderTimeIntentHolder({
    required this.userProvider,
    required this.shopInfoProvider,
  });
  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
}