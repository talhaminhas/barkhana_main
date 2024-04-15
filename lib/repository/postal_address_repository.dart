import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/db/postal_address_dao.dart';
import 'package:flutterrestaurant/viewobject/postal_address.dart';

import '../viewobject/address.dart';
import 'Common/ps_repository.dart';

class PostalAddressRepository extends PsRepository {
  PostalAddressRepository(
      {required PsApiService psApiService,
        required PostalAddressDao postalAddressDao
      }) {
    _psApiService = psApiService;
    _postalAddressDao = postalAddressDao;
  }
  String primaryKey = 'id';
 late PsApiService _psApiService;
  late  PostalAddressDao _postalAddressDao;

  Future<dynamic> getPostalAddressList(
      StreamController<PsResource<List<Address>>> addressListStream,
      Map<String, dynamic> jsonMap,
      bool isConnectedToInternet,
      PsStatus status,{
        bool isNeedDelete = true,
        bool isLoadFromServer = true}) async {
    if (isConnectedToInternet) {
      final PsResource<PostalAddress> postalAddressResource = await _psApiService.postalAddressList(jsonMap);
      final PsResource<List<Address>> _resource =
      PsResource<List<Address>>(PsStatus.NOACTION, '', postalAddressResource.data?.addresses);
      addressListStream.sink.add(_resource);
      return postalAddressResource.data;
    }

   /* if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<PostalAddress>> completer =
      Completer<PsResource<PostalAddress>>();
      completer.complete(_resource);
      return completer.future;
    }*/
  }

}
