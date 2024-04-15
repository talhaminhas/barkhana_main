
import 'dart:async';

import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../repository/point_repository.dart';
import '../../utils/utils.dart';
import '../../viewobject/common/ps_value_holder.dart';
import '../../viewobject/main_point.dart';
import '../common/ps_provider.dart';

class PointProvider extends PsProvider {
  PointProvider(
      {required PointRepository repo,
      required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    mainPointListStream = StreamController<PsResource<MainPoint>>.broadcast();
    subscription =
        mainPointListStream.stream.listen((PsResource<MainPoint> resource) {
      _mainPoint = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  PointRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<MainPoint> _mainPoint =
      PsResource<MainPoint>(PsStatus.NOACTION, '', null);

  PsResource<MainPoint> get mainPoint => _mainPoint;
 late StreamSubscription<PsResource<MainPoint>> subscription;
 late StreamController<PsResource<MainPoint>> mainPointListStream;
  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('MainPoint Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadAllPoint(
    String deliveryBoyLat,
    String deliveryBoyLng,
    String orderLat,
    String orderLng,
  ) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo!.getAllPoints(
        mainPointListStream,
        deliveryBoyLat,
        deliveryBoyLng,
        orderLat,
        orderLng,
        isConnectedToInternet,
        PsStatus.PROGRESS_LOADING);
  }
}
