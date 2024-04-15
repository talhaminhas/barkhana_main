import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/provider/common/ps_provider.dart';
import 'package:flutterrestaurant/repository/postal_address_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/api_status.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';

import '../../viewobject/address.dart';

class PostalAddressProvider extends PsProvider {
  PostalAddressProvider(
      {required PostalAddressRepository repo,
      required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    //isDispose = false;
    print('Postal Address Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
    addressListStream =
    StreamController<PsResource<List<Address>>>.broadcast();
    subscription = addressListStream.stream
        .listen((PsResource<List<Address>> resource) {
      updateOffset(resource.data!.length);

      _addressList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }
      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  late  StreamController<PsResource<List<Address>>> addressListStream;
  PostalAddressRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<List<Address>> _addressList =
  PsResource<List<Address>>(PsStatus.NOACTION, '', <Address>[]);
  PsResource<List<Address>> get addressList => _addressList;
  late  StreamSubscription<PsResource<List<Address>>> subscription;

  final PsResource<ApiStatus> _apiStatus =
  PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get user => _apiStatus;

  @override
  void dispose() {
    isDispose = true;
    subscription.cancel();
    print('Postal Address Provider Dispose: $hashCode');
    super.dispose();
  }
  Future<dynamic> loadPostalAddressesList(
      Map<String, dynamic> jsonMap,
      ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    return await _repo!.getPostalAddressList(
        addressListStream, jsonMap,
        isConnectedToInternet,
        PsStatus.PROGRESS_LOADING);

  }
}
