import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/viewobject/api_status.dart';
import '../ui/common/dialog/error_dialog.dart';
import '../utils/utils.dart';
import '../viewobject/holder/globalTokenPost.dart';
import 'Common/ps_repository.dart';

class TokenRepository extends PsRepository {
  TokenRepository({
    required PsApiService psApiService,
  }) {
    _psApiService = psApiService;
  }
  String primaryKey = '';
 late PsApiService _psApiService;

  Future<PsResource<ApiStatus>> getToken(
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<ApiStatus> _resource = await _psApiService.getToken();
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else {
      final Completer<PsResource<ApiStatus>> completer =
          Completer<PsResource<ApiStatus>>();
      completer.complete(_resource);
      return completer.future;
    }
  }
  Future<Map<String, dynamic>?> getGlobalTransactionStatus(
      GlobalTokenPost globalTokenPost,
      BuildContext context) async {

    final bool isConnectedToInternet = await Utils.checkInternetConnectivity();
    if( isConnectedToInternet) {
      return _psApiService.getGlobalTransactionStatus(globalTokenPost);
    }
    else
    {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
    return null;
  }
  Future<String?> postGlobalToken(
       GlobalTokenPost globalTokenPost,
        BuildContext context) async {

      final bool isConnectedToInternet = await Utils.checkInternetConnectivity();
      if( isConnectedToInternet) {
        return _psApiService.postGlobalTokenData(globalTokenPost);
      }
      else
      {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__no_internet'),
              );
            });
      }
      return null;
  }
}
