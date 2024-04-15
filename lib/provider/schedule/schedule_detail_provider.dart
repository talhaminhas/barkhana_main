import 'dart:async';
import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../repository/schedule_detail_repository.dart';
import '../../utils/utils.dart';
import '../../viewobject/common/ps_value_holder.dart';
import '../../viewobject/schedule_detail.dart';
import '../../viewobject/schedule_header.dart';
import '../common/ps_provider.dart';

class ScheduleDetailProvider extends PsProvider {
  ScheduleDetailProvider(
      {required ScheduleDetailRepository repo,
      required this.valueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    Utils.checkInternetConnectivity()
        .then((bool value) => isConnectedToInternet = value);

    _scheduleDetailListStream =
        StreamController<PsResource<List<ScheduleDetail>>>.broadcast();

    _subscription = _scheduleDetailListStream.stream
        .listen((PsResource<List<ScheduleDetail>> resource) {
      updateOffset(resource.data!.length);
      _scheduleDetailList = resource;
      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  PsValueHolder? valueHolder;
  ScheduleDetailRepository? _repo;
  PsResource<List<ScheduleDetail>> _scheduleDetailList =
      PsResource<List<ScheduleDetail>>(
          PsStatus.NOACTION, '', <ScheduleDetail>[]);
  PsResource<List<ScheduleDetail>> get scheduleDetailList =>
      _scheduleDetailList;
  late StreamController<PsResource<List<ScheduleDetail>>> _scheduleDetailListStream;
  late StreamSubscription<PsResource<List<ScheduleDetail>>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    isDispose = true;
    super.dispose();
  }

  Future<dynamic> loadScheduleDetailList(ScheduleHeader scheduleHeader) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllScheduleDetailList(
        _scheduleDetailListStream,
        isConnectedToInternet,
        scheduleHeader,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> loadnextScheduleDetailList(
      ScheduleHeader scheduleHeader) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;
      await _repo!.getNextPageScheduleDetailList(
          _scheduleDetailListStream,
          isConnectedToInternet,
          scheduleHeader,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING);
    }
  }

  Future<void> resetScheduleDetailList(ScheduleHeader scheduleHeader) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo!.getAllScheduleDetailList(
        _scheduleDetailListStream,
        isConnectedToInternet,
        scheduleHeader,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING);

    isLoading = false;
  }
}
