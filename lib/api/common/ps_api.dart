import 'dart:convert';
import 'dart:io';

import 'package:flutterrestaurant/api/common/ps_api_reponse.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/db/common/ps_shared_preferences.dart';
import 'package:flutterrestaurant/main.dart';
import 'package:flutterrestaurant/viewobject/common/ps_object.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart';

import '../ps_url.dart';

abstract class PsApi {
  PsResource<T> psObjectConvert<T>(dynamic dataList, T data) {
    return PsResource<T>(dataList.status, dataList.message, data);
  }

  Future<List<dynamic>> getList(String url) async {
    print('getList');
    if (PSApp.apiTokenRefresher.isExpired) {

      await PSApp.apiTokenRefresher.updateToken();
    }
    final Client client = http.Client();
    try {
      final Map<String, String> headers = <String, String>{
        'content-type': 'application/json',
        'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
      };
      final Response response =
          await client.get(Uri.parse('${PsConfig.ps_app_url}$url'),
            headers: headers
          );

      if (response.statusCode == 200 &&
         // response.body != null &&
          response.body != '') {
        // parse into List
        final List<dynamic> parsed = json.decode(response.body);

        return parsed;
      } else {
        throw Exception('Error in loading...');
      }
    } finally {
      client.close();
    }
  }

  Future<PsResource<R>> getSpecificServerCall<T extends PsObject<dynamic>, R>(
      T obj, String url) async {
    print('getSpecificServerCall');
    if (PSApp.apiTokenRefresher.isExpired) {

      await PSApp.apiTokenRefresher.updateToken();
    }
    final Client client = http.Client();
    try {
      final Map<String, String> headers = <String, String>{
        'content-type': 'application/json',
        'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
      };
      final Response response = await client.get(Uri.parse('$url'),
          headers: headers);
      print('${PsConfig.ps_app_url}$url');
      final PsApiResponse psApiResponse = PsApiResponse(response);

      // return psApiResponse;
      if (psApiResponse.isSuccessful()) {
        final dynamic hashMap = json.decode(response.body);
        //print(response.body);
        if (!(hashMap is Map)) {
          final List<T> tList = <T>[];
          hashMap.forEach((dynamic data) {
            tList.add(obj.fromMap(data as dynamic));
          });
          return PsResource<R>(PsStatus.SUCCESS, '', tList as R? ?? R as R?);
        } else {
          return PsResource<R>(PsStatus.SUCCESS, '', obj.fromMap(hashMap));
        }
      } else {
        if(psApiResponse.isUnauthorized())
          PSApp.apiTokenRefresher.isExpired = true;
        return PsResource<R>(PsStatus.ERROR, psApiResponse.errorMessage, null);
      }
    }  catch (e) {
      print(e.toString());
      return PsResource<R>(PsStatus.ERROR, e.toString(), null); //e.message ??
    } finally {
      client.close();
    }
  }

  Future<PsResource<R>> getServerCall<T extends PsObject<dynamic>, R>(
      T obj, String url) async {
    print('getServerCall');
    if (PSApp.apiTokenRefresher.isExpired) {

      await PSApp.apiTokenRefresher.updateToken();
    }
    final Client client = http.Client();
    try {
      final Map<String, String> headers = <String, String>{
        'content-type': 'application/json',
        'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
      };
      final Response response =
          await client.get(Uri.parse('${PsConfig.ps_app_url}$url'),
            headers: headers
          );
      print('${PsConfig.ps_app_url}$url');
      final PsApiResponse psApiResponse = PsApiResponse(response);

      if (psApiResponse.isSuccessful()) {
        //print(response.body);
        final dynamic hashMap = json.decode(response.body);
        if (!(hashMap is Map)) {
          final List<T> tList = <T>[];
          hashMap.forEach((dynamic data) {
            tList.add(obj.fromMap(data as dynamic));
          });
          return PsResource<R>(PsStatus.SUCCESS, '', tList as R? ?? R as R?);
        } else {
          return PsResource<R>(PsStatus.SUCCESS, '', obj.fromMap(hashMap));
        }
      } else {
        if(psApiResponse.isUnauthorized())
          PSApp.apiTokenRefresher.isExpired = true;
        return PsResource<R>(PsStatus.ERROR, psApiResponse.errorMessage, null);
      }
    } catch (e) {
      print(e.toString());
      return PsResource<R>(PsStatus.ERROR, e.toString(), null); //e.message ??
    } finally {
      client.close();
    }
  }


  Future<PsResource<R>> postData<T extends PsObject<dynamic>, R>(
      T obj, String url, Map<dynamic, dynamic> jsonMap) async {
    print('postData');

    if (PSApp.apiTokenRefresher.isExpired
        && url != PsUrl.ps_api_request_token_post_url
        && url != PsUrl.ps_api_update_token_post_url) {

      await PSApp.apiTokenRefresher.updateToken();
    }
    print(jsonMap);
    print('post url: ${PsConfig.ps_app_url}$url');
    final Client client = http.Client();
    try {
      final Map<String, String> headers = <String, String>{
        'content-type': 'application/json',
        'authorization': PsSharedPreferences.instance.getApiToken() ?? '',
      };
      final Response response = await client
          .post(Uri.parse('${PsConfig.ps_app_url}$url'),
          headers: headers,
          body: const JsonEncoder().convert(jsonMap))
          .catchError((dynamic e) {
        print('** Error Post Data');
        print(e.error);
      });

      final PsApiResponse psApiResponse = PsApiResponse(response);

      if (psApiResponse.isSuccessful()) {
        //print(response.body);
        final dynamic hashMap = json.decode(response.body);
        //print(response.body);
        if (!(hashMap is Map)) {
          final List<T> tList = <T>[];
          hashMap.forEach((dynamic data) {
            tList.add(obj.fromMap(data));
          });
          return PsResource<R>(PsStatus.SUCCESS, '',tList as R? ?? R as R?);
        } else {
          return PsResource<R>(PsStatus.SUCCESS, '', obj.fromMap(hashMap));
        }
      }
      else {
        if(psApiResponse.isUnauthorized())
          print('401');
          PSApp.apiTokenRefresher.isExpired = true;
        return PsResource<R>(PsStatus.ERROR, psApiResponse.errorMessage, null);
      }
    } catch (e) {
      print(e.toString());

      return PsResource<R>(PsStatus.ERROR, e.toString(), null); //e.message ??
    } finally {
      client.close();
    }
  }


  Future<PsResource<R>> postUploadImage<T extends PsObject<dynamic>, R>(
      T obj, String url, String userId, String platformName, File imageFile) async {
    print('postUploadImage');
    if (PSApp.apiTokenRefresher.isExpired) {
      await PSApp.apiTokenRefresher.updateToken();
    }
    final Client client = http.Client();
    try {
      final Uri uri = Uri.parse('${PsConfig.ps_app_url}$url');

      final MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers['authorization'] = PsSharedPreferences.instance.getApiToken() ?? ''; // Adding the authorization token

      final ByteStream stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
      final int length = await imageFile.length();

      final MultipartFile multipartFile = http.MultipartFile(
        'file', stream, length,
        filename: basename(imageFile.path),
      );

      request.fields['user_id'] = userId;
      request.fields['platform_name'] = platformName;
      request.files.add(multipartFile);

      final StreamedResponse response = await request.send();

      final PsApiResponse psApiResponse = PsApiResponse(await http.Response.fromStream(response));

      if (psApiResponse.isSuccessful()) {
        final dynamic hashMap = json.decode(psApiResponse.body!);

        if (!(hashMap is Map)) {
          final List<T> tList = <T>[];
          hashMap.forEach((dynamic data) {
            tList.add(obj.fromMap(data));
          });
          return PsResource<R>(PsStatus.SUCCESS, '', tList as R? ?? R as R?);
        } else {
          return PsResource<R>(PsStatus.SUCCESS, '', obj.fromMap(hashMap));
        }
      }
      else {
        if(psApiResponse.isUnauthorized())
          PSApp.apiTokenRefresher.isExpired = true;
        return PsResource<R>(PsStatus.ERROR, psApiResponse.errorMessage, null);
      }
    } finally {
      client.close();
    }
  }

}
