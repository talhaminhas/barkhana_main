import 'package:flutterrestaurant/db/common/ps_dao.dart' show PsDao;
import 'package:flutterrestaurant/viewobject/postal_address.dart';
import 'package:sembast/sembast.dart';

class PostalAddressDao extends PsDao<PostalAddress> {
  PostalAddressDao._() {
    init(PostalAddress());
  }
  static const String STORE_NAME = 'Postal Address';

  // Singleton instance
  static final PostalAddressDao _singleton = PostalAddressDao._();

  // Singleton accessor
  static PostalAddressDao get instance => _singleton;

  @override
  String getStoreName() {
    return STORE_NAME;
  }

  @override
  String ?getPrimaryKey(PostalAddress object) {
    return object.postcode;
  }

  @override
  Filter getFilter(PostalAddress object) {
    // TODO: implement getFilter
    throw UnimplementedError();
  }


}
