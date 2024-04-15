
import 'common/ps_object.dart';

class ApiToken extends PsObject<ApiToken> {
  ApiToken(
      {
    this.token,this.expiry,this.expired
      });
  String? token;
  String? expiry;
  String? expired;

  @override
  String? getPrimaryKey() {
    return token;
  }

  @override
  ApiToken? fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return ApiToken(
        token: dynamicData['token'],
        expiry: dynamicData['expiry'],
        expired: dynamicData['expired'],
      );
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['token'] = object.token;
      data['expiry'] = object.expiry;
      data['expired'] = object.expired;
      return data;
    } else {
      return null;
    }
  }

  @override
  List<ApiToken> fromMapList(List<dynamic>? dynamicDataList) {
    final List<ApiToken> subCategoryList = <ApiToken>[];

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
