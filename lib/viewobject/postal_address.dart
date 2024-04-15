
import 'address.dart';
import 'common/ps_object.dart';

class PostalAddress extends PsObject<PostalAddress> {
  PostalAddress(
      {this.postcode,
      this.latitude,
      this.longitude,
      this.shopId,
      //this.shop,
      this.addresses
      });
  String? postcode;
  String? latitude;
  String? longitude;
  String? shopId;
  //ShopBranch? shop;
  List<Address>? addresses;
  

  @override
  String? getPrimaryKey() {
    return postcode;
  }

  @override
  PostalAddress? fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return PostalAddress(
          postcode: dynamicData['postcode'],
          latitude: dynamicData['latitude'],
          shopId: dynamicData['shop_id'],
          longitude: dynamicData['longitude'],
          //shop: dynamicData['shop'],
          addresses: Address().fromMapList(dynamicData['addresses']),
          );
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = object.postcode;
      data['latitude'] = object.latitude;
      data['shop_id'] = object.shop_id;
      data['longitude'] = object.longitude;
      data['shop'] = object.shop;
      data['highlighted_info'] = object.highlightedInfo;
      data['addresses'] = Address().toMapList(object.addresses);
      return data;
    } else {
      return null;
    }
  }

  @override
  List<PostalAddress> fromMapList(List<dynamic>? dynamicDataList) {
    final List<PostalAddress> subCategoryList = <PostalAddress>[];

    if (dynamicDataList != null) {
      for (dynamic json in dynamicDataList) {
        if (json != null) {
          subCategoryList.add(fromMap(json)!);
        }
      }
    }
    return subCategoryList;
  }

  @override
  List<Map<String, dynamic>> toMapList(List<dynamic>? objectList) {
    final List<Map<String, dynamic>> mapList = <Map<String, dynamic>>[];
    if (objectList != null) {
      for (dynamic data in objectList) {
        if (data != null) {
          mapList.add(toMap(data)!);
        }
      }
    }

    return mapList;
  }
}
