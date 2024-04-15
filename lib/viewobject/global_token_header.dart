import 'dart:core';

import 'common/ps_object.dart';

class GlobalTokenHeader extends PsObject<GlobalTokenHeader> {
  GlobalTokenHeader(
      {
        this.merchantId,/*
        this.userEmail,
      this.userPhone,
      this.userAddress1,
      this.userAddress2,
      this.userCity,
      this.userPostcode,
      this.userTotal,*/

      });
  String? merchantId;/*
  String? userEmail;
  String? userPhone;
  String? userAddress1;
  String? userAddress2;
  String? userCity;
  String? userPostcode;
  String? userTotal;*/
  

  @override
  String? getPrimaryKey() {
    return merchantId;
  }

  @override
  GlobalTokenHeader? fromMap(dynamic dynamicData) {
   if (dynamicData != null) {
      return GlobalTokenHeader(
        merchantId: dynamicData['MERCHANT_ID']
        /*userEmail: dynamicData['user_email'],
        userPhone: dynamicData['user_phone'],
        userAddress1: dynamicData['user_address1'],
        userAddress2: dynamicData['user_address2'],
        userCity: dynamicData['user_city'],
        userPostcode: dynamicData['user_postcode'],
        userTotal: dynamicData['user_total']*/
      );    
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['MERCHANT_ID'] = object.merchantId;/*
      data['user_email'] = object.userEmail;
      data['user_phone'] = object.userPhone;
      data['user_address1'] = object.userAddress1;
      data['user_address2'] = object.userAddress2;
      data['user_city'] = object.userCity;
      data['user_postcode'] = object.userPostcode;
      data['user_total'] = object.userTotal;*/
      return data;
    } else {
      return null;
    }
  }

  @override
  List<GlobalTokenHeader> fromMapList(List<dynamic>? dynamicDataList) {
    final List<GlobalTokenHeader> subCategoryList = <GlobalTokenHeader>[];

   if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList) {
        if (dynamicData != null) {
          subCategoryList.add(fromMap(dynamicData)!);
        }
      }
   }
    return subCategoryList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<GlobalTokenHeader>? objectList) {
    final List<Map<String, dynamic>?> mapList = <Map<String, dynamic>?>[];
   if (objectList != null) {
      for (GlobalTokenHeader? data in objectList) {
        if (data != null) {
          mapList.add(toMap(data));
        }
      }
    }

    return mapList;
  }
}
