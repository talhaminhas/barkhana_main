

import 'common/ps_object.dart';

class Address extends PsObject<Address> {
  Address({
    //this.id,
    this.line_1,
    this.line_2,
    this.line_3,
    this.line_4,
    this.townOrCity,
    this.county,
    this.district,
    this.country,
    this.latitude,
    this.longitude
  });
  //String? id;
  String? line_1;
  String? line_2;
  String? line_3;
  String? line_4;
  String? townOrCity;
  String? county;
  String? district;
  String? country;
  String? latitude;
  String? longitude;

  @override
  String? getPrimaryKey() {
    return line_1;
  }

  @override
  Address? fromMap(dynamic dynamicData) {
   if (dynamicData != null) {
      return Address(
        //id: dynamicData['id'],
        line_1: dynamicData['line_1'],
        line_2: dynamicData['line_2'],
        line_3: dynamicData['line_3'],
        line_4: dynamicData['line_4'],
        townOrCity: dynamicData['town_or_city'],
        county: dynamicData['county'],
        district: dynamicData['district'],
        country: dynamicData['country'],
        longitude: dynamicData['longitude'],
        latitude: dynamicData['latitude']
      );
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      //data['id'] = object.id;
      data['line_1'] = object.line_1;
      data['line_2'] = object.line_2;
      data['line_3'] = object.line_3;
      data['line_4'] = object.line_4;
      data['town_or_city'] = object.town_or_city;
      data['county'] = object.county;
      data['district'] = object.district;
      data['country'] = object.country;
      data['latitude'] = object.latitude;
      data['longitude'] = object.longitude;
      return data;
    } else {
      return null;
    }
  }

  @override
  List<Address> fromMapList(List<dynamic>? dynamicDataList) {
    final List<Address> addressList = <Address>[];

    if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList) {
        if (dynamicData != null) {
          addressList.add(fromMap(dynamicData)!);
        }
      }
    }
    return addressList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<dynamic>? objectList) {
    final List<Map<String, dynamic>?> dynamicList = <Map<String, dynamic>?>[];
    if (objectList != null) {
      for (dynamic data in objectList) {
        if (data != null) {
          dynamicList.add(toMap(data));
        }
      }
   }
    return dynamicList;
  }
}
