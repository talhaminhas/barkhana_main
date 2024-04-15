
import 'common/ps_object.dart';

class UserLocation extends PsObject<UserLocation> {
  UserLocation(
      {
    this.userId,this.userLat,this.userLng
      });
  String? userId;
  String? userLat;
  String? userLng;

  @override
  String? getPrimaryKey() {
    return userId;
  }

  @override
  UserLocation? fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return UserLocation(
        userId: dynamicData['user_id'],
        userLat: dynamicData['user_lat'],
        userLng: dynamicData['user_lng'],
      );
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['user_id'] = object.userId;
      data['user_lat'] = object.userLat;
      data['user_lng'] = object.expired;
      return data;
    } else {
      return null;
    }
  }

  @override
  List<UserLocation> fromMapList(List<dynamic>? dynamicDataList) {
    final List<UserLocation> subCategoryList = <UserLocation>[];

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
