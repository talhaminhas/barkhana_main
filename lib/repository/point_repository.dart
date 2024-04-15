
import 'dart:async';

import '../api/common/ps_resource.dart';
import '../api/common/ps_status.dart';
import '../api/ps_api_service.dart';
import '../db/point_dao.dart';
import '../viewobject/main_point.dart';
import 'Common/ps_repository.dart';

class PointRepository extends PsRepository {
  PointRepository(
      {required PsApiService psApiService, required PointDao pointDao}) {
    _psApiService = psApiService;
    _pointDao = pointDao;
  }

  String primaryKey = 'point_id';
 late PsApiService _psApiService;
 late PointDao _pointDao;

  Future<dynamic> insert(MainPoint mainPoint) async {
    return _pointDao.insert(primaryKey, mainPoint);
  }

  Future<dynamic> update(MainPoint mainPoint) async {
    return _pointDao.update(mainPoint);
  }

  Future<dynamic> delete(MainPoint mainPoint) async {
    return _pointDao.delete(mainPoint);
  }

  Future<dynamic> getAllPoints(
      StreamController<PsResource<MainPoint>> mainPointListStream,
      String deliveryBoyLat,
      String deliveryBoyLng,
      String orderLat,
      String orderLng,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    // mainPointListStream.sink.add(await _pointDao.getOne(status: status));

    if (isConnectedToInternet) {
      final PsResource<MainPoint> _resource = await _psApiService.getAllPoints(
        deliveryBoyLat,
        deliveryBoyLng,
        orderLat,
        orderLng,
      );

      if (_resource.status == PsStatus.SUCCESS) {
        await _pointDao.deleteAll();
        await _pointDao.insert(primaryKey, _resource.data!);
      }
      mainPointListStream.sink.add(await _pointDao.getOne());
    }
  }
}
