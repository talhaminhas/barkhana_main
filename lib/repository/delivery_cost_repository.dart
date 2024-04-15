import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/viewobject/delivery_cost.dart';

import 'Common/ps_repository.dart';

class DeliveryCostRepository extends PsRepository {
  DeliveryCostRepository({
    required PsApiService psApiService,
  }) {
    _psApiService = psApiService;
  }
  String primaryKey = 'id';
late  PsApiService _psApiService;

  Future<PsResource<DeliveryCost>> postDeliveryCheckingAndCalculating(
      Map<dynamic, dynamic> jsonMap,
      
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<DeliveryCost> _resource =
        await _psApiService.postDeliveryCheckingAndCalculating(jsonMap);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<DeliveryCost>> completer =
          Completer<PsResource<DeliveryCost>>();
      completer.complete(_resource);
      return completer.future;
    }
  }
}

