import 'dart:async';
import 'package:flutterrestaurant/repository/Common/ps_repository.dart';
import 'package:sembast/sembast.dart';

import '../api/common/ps_resource.dart';
import '../api/common/ps_status.dart';
import '../api/ps_api_service.dart';
import '../constant/ps_constants.dart';
import '../db/schedule_detail_dao.dart';
import '../viewobject/schedule_detail.dart';
import '../viewobject/schedule_header.dart';

class ScheduleDetailRepository extends PsRepository {
  ScheduleDetailRepository({
    required PsApiService apiService,
    required ScheduleDetailDao scheduleDetailDao,
  }) {
    _psApiService = apiService;
    _scheduleDetailDao = scheduleDetailDao;
  }

  String primaryKey = 'id';
  PsApiService? _psApiService;
  ScheduleDetailDao? _scheduleDetailDao;

  Future<dynamic> getAllScheduleDetailList(
    StreamController<PsResource<List<ScheduleDetail>>> scheduleDetailStream,
    bool isConnectedToInternet,
    ScheduleHeader scheduleHeader,
    int limit,
    int offset,
    PsStatus status,
  ) async {
    final Finder finder =
        Finder(filter: Filter.equals('schedule_header_id', scheduleHeader.id));

    scheduleDetailStream.sink
        .add(await _scheduleDetailDao!.getAll(finder: finder, status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ScheduleDetail>> resource = await _psApiService!
          .getScheduleDetail(scheduleHeader.id!, limit, offset);

      if (resource.status == PsStatus.SUCCESS) {
        await _scheduleDetailDao!.deleteWithFinder(finder);
        await _scheduleDetailDao!.insertAll(primaryKey, resource.data!);
      } else {
        if (resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _scheduleDetailDao!.deleteWithFinder(finder);
        }
      }
      scheduleDetailStream.sink
          .add(await _scheduleDetailDao!.getAll(finder: finder));
    }
  }

  Future<dynamic> getNextPageScheduleDetailList(
    StreamController<PsResource<List<ScheduleDetail>>> scheduleDetailStream,
    bool isConnectedToInternet,
    ScheduleHeader scheduleHeader,
    int limit,
    int offset,
    PsStatus status,
  ) async {
    final Finder finder =
        Finder(filter: Filter.equals('schedule_header_id', scheduleHeader.id));

    scheduleDetailStream.sink
        .add(await _scheduleDetailDao!.getAll(finder: finder, status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ScheduleDetail>> resource = await _psApiService!
          .getScheduleDetail(scheduleHeader.id!, limit, offset);

      if (resource.status == PsStatus.SUCCESS) {
        await _scheduleDetailDao!.deleteWithFinder(finder);
        await _scheduleDetailDao!.insertAll(primaryKey, resource.data!);
      } else {
        if (resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _scheduleDetailDao!.deleteWithFinder(finder);
        }
      }
      scheduleDetailStream.sink
          .add(await _scheduleDetailDao!.getAll(finder: finder));
    }
  }
}
