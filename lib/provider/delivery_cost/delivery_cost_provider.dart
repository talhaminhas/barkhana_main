import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/provider/common/ps_provider.dart';
import 'package:flutterrestaurant/repository/delivery_cost_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/delivery_cost.dart';

class DeliveryCostProvider extends PsProvider {
  DeliveryCostProvider(
      {required DeliveryCostRepository? repo,
      this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    isDispose = false;

    print('DeliveryCost Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
    deliveryCostListStream =
        StreamController<PsResource<DeliveryCost>>.broadcast();
    subscription =
        deliveryCostListStream.stream.listen((PsResource<DeliveryCost> resource) {
        
      _deliveryCost = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
            resource.status != PsStatus.PROGRESS_LOADING) {
          isLoading = false;
      }

      if (!isDispose) {
          notifyListeners();
      }
    });
  }

  DeliveryCostRepository? _repo;
  PsValueHolder? psValueHolder;

 late StreamSubscription<PsResource<DeliveryCost>> subscription;
late  StreamController<PsResource<DeliveryCost>> deliveryCostListStream;

  PsResource<DeliveryCost> _deliveryCost =
      PsResource<DeliveryCost>(PsStatus.NOACTION, '', null);
  PsResource<DeliveryCost> get deliveryCost => _deliveryCost;
  @override
  void dispose() {
    subscription.cancel();
    deliveryCostListStream.close();
    isDispose = true;
    print('Delivery Cost Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> postDeliveryCost(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _deliveryCost = await _repo!.postDeliveryCheckingAndCalculating(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _deliveryCost;
  }
}
