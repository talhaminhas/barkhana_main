
import 'package:flutterrestaurant/viewobject/intersection.dart';
import 'package:quiver/core.dart';

import 'common/ps_object.dart';
import 'maneuver.dart';

class Steps extends PsObject<Steps> {
  Steps({this.id, this.maneuver, this.intersectionList});

  String? id;
  Maneuver? maneuver;
  List<Intersection>? intersectionList;

  @override
  bool operator ==(dynamic other) => other is Steps && id == other.id;

  @override
  int get hashCode => hash2(id.hashCode, id.hashCode);

  @override
  String? getPrimaryKey() {
    return id;
  }

  @override
  List<Steps> fromMapList(List<dynamic>? dynamicDataList) {
    final List<Steps> subCategoryList = <Steps>[];

   // if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList!) {
        if (dynamicData != null) {
          subCategoryList.add(fromMap(dynamicData));
        }
      }
   // }
    return subCategoryList;
  }

  @override
  Steps fromMap(dynamic dynamicData) {
   // if (dynamicData != null) {
      return Steps(
        id: dynamicData['id'],
        maneuver: Maneuver().fromMap(dynamicData['maneuver']),
        intersectionList: Intersection().fromMapList(dynamicData['intersections']),
      );
    // } else {
    //   return null;
    // }
  }

  @override
  Map<String, dynamic>? toMap(Steps? object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = object.id;
      data['maneuver'] = Maneuver().toMap(object.maneuver);
      data['intersections'] = Intersection().toMapList(object.intersectionList!);

      return data;
    } else {
      return null;
    }
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<Steps>? objectList) {
    final List<Map<String, dynamic>?> mapList = <Map<String, dynamic>?>[];
    //if (objectList != null) {
      for (Steps? data in objectList!) {
        if (data != null) {
          mapList.add(toMap(data));
        }
      }
   // }
    return mapList;
  }
}
