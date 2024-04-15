import 'package:flutterrestaurant/viewobject/common/ps_object.dart';
import 'package:quiver/core.dart';

class PostcodeStatus extends PsObject<PostcodeStatus> {
  PostcodeStatus(
      {this.status});

  int?  status;

  @override
  bool operator ==(dynamic other) => other is PostcodeStatus && status == other.status;

  @override
  int get hashCode => hash2(status.hashCode, status.hashCode);

  @override
  String?  getPrimaryKey() {
    return status.toString();
  }
  bool  isValid() {
    return status != 404;
  }
  @override
  PostcodeStatus? fromMap(dynamic dynamicData) {
   if (dynamicData != null) {
      return PostcodeStatus(
          status: dynamicData['status']);
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic>?  toMap(PostcodeStatus?  object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['status'] = object.status;
      return data;
    } else {
      return null;
    }
  }

  @override
  List<PostcodeStatus> fromMapList(List<dynamic>? dynamicDataList) {
    final List<PostcodeStatus> colorList = <PostcodeStatus>[];

    if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList) {
        if (dynamicData != null) {
          colorList.add(fromMap(dynamicData)!);
        }
      }
    }
    return colorList;
  }

  @override
  List<Map<String, dynamic>? > toMapList(List<PostcodeStatus>? objectList) {
    final List<Map<String, dynamic>? > mapList = <Map<String, dynamic>? >[];
    if (objectList != null) {
      for (PostcodeStatus?  data in objectList) {
        if (data != null) {
          mapList.add(toMap(data));
        }
      }
   }
    return mapList;
  }
}
