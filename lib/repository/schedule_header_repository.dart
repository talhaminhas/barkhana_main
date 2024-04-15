import 'dart:async';
import '../api/common/ps_resource.dart';
import '../api/common/ps_status.dart';
import '../api/ps_api_service.dart';
import '../constant/ps_constants.dart';
import '../db/schedule_header_dao.dart';
import '../viewobject/api_status.dart';
import '../viewobject/schedule_header.dart';
import 'Common/ps_repository.dart';

class ScheduleHeaderRepository extends PsRepository {
  ScheduleHeaderRepository({
    required PsApiService apiService,
    required ScheduleHeaderDao scheduleHeaderDao,
  }) {
    _psApiService = apiService;
    _scheduleHeaderDao = scheduleHeaderDao;
  }

  PsApiService? _psApiService;
  ScheduleHeaderDao? _scheduleHeaderDao;
  final String _primaryKey = 'id';

  Future<dynamic> postScheduleSubmit(
      StreamController<PsResource<List<ScheduleHeader>>> scheduleListStream,
      Map<String, dynamic> jsonMap,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<List<ScheduleHeader>> _resource =
        await _psApiService!.postScheduleSubmit(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<List<ScheduleHeader>>> completer =
          Completer<PsResource<List<ScheduleHeader>>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<PsResource<List<ScheduleHeader>>> updateScheduleOrderStatus(
      Map<String, dynamic> json, bool isConnectedToInternet) async {
    final PsResource<List<ScheduleHeader>> _resource =
        await _psApiService!.updateScheduleOrder(json);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<List<ScheduleHeader>>> completer =
          Completer<PsResource<List<ScheduleHeader>>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<dynamic> getAllScheduleHeaderList(
      StreamController<PsResource<List<ScheduleHeader>>>
          scheduleHeaderListStream,
      String userId,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status) async {
    scheduleHeaderListStream.sink
        .add(await _scheduleHeaderDao!.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ScheduleHeader>> _resource = await _psApiService
          !.getAllScheduleHeaderByUserId(userId, limit, offset);
      if (_resource.status == PsStatus.SUCCESS) {
        await _scheduleHeaderDao!.deleteAll();
        await _scheduleHeaderDao!.insertAll(_primaryKey, _resource.data!);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _scheduleHeaderDao!.deleteAll();
        }
      }
    }
    scheduleHeaderListStream.sink
        .add(await _scheduleHeaderDao!.getAll(status: PsStatus.SUCCESS));
  }

  Future<PsResource<ApiStatus>> deleteScheduleOrder(
    Map<String, dynamic> json,
  ) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService!.deleteSchedule(json);

    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }

  Future<PsResource<ApiStatus>> postResendCode(Map<dynamic, dynamic> jsonMap,
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource =
        await _psApiService!.postResendCode(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }
}
