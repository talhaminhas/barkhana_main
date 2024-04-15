/*
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../provider/shop_info/shop_info_provider.dart';
import '../../../../utils/ps_progress_dialog.dart';

class CurrentLocationWidget extends StatefulWidget {
  const CurrentLocationWidget(
      {Key? key,

      /// If set, enable the FusedLocationProvider on Android
      required this.androidFusedLocation,
      required this.isShowAddress,
      this.textEditingController,
      required this.shopInfoProvider})
      : super(key: key);

  final bool androidFusedLocation;
  final bool isShowAddress;
  final TextEditingController? textEditingController;
  final ShopInfoProvider? shopInfoProvider;

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<CurrentLocationWidget> {
  Position? _currentPosition;
  String address = '';
  bool bindDataFirstTime = true;
  final MapController mapController = MapController();
  MainDashboardProvider? _mainDashboardProvider;
  @override
  void initState() {
    super.initState();
    _initCurrentLocation();

    _mainDashboardProvider =
        Provider.of<MainDashboardProvider>(context, listen: false);

    if (_mainDashboardProvider!.currentUserLocation != null) {
      _currentPosition = _mainDashboardProvider!.currentUserLocation;

      loadAddress(false);
    }
  }

 // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  // }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return WarningDialog(
            message: Utils.getString(context, 'map_pin__open_gps'),
            onPressed: () {},
          );
        });
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future<bool>.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future<bool>.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final bool hasPermission = await _handleLocationPermission();
    // await PsProgressDialog.showDialog(context);

    if (!hasPermission) {
      return;
    }
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            forceAndroidLocationManager: !widget.androidFusedLocation)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      loadAddress(true);
    }).catchError((dynamic e) {
      debugPrint(e);
    });
    PsProgressDialog.dismissDialog();
  }

  dynamic loadAddress(bool isReload) async {
    if (_currentPosition != null) {
      _mainDashboardProvider!.updateUserLocation(_currentPosition!, mounted);
      // ignore: unnecessary_null_comparison
      if (widget.shopInfoProvider != null) {
        widget.shopInfoProvider!.currentLatlng ??=
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      }
      if (widget.textEditingController!.text == '') {
        await placemarkFromCoordinates(
                  _currentPosition!.latitude, _currentPosition!.longitude)
              .then((List<Placemark> placemarks) {
            final Placemark place = placemarks[0];
            setState(() {
              address =
                '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
              widget.textEditingController!.text = address;
            });
          }).catchError((dynamic e) {
            debugPrint(e);
          });
        } else {
          address = widget.textEditingController!.text;
        }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  dynamic _initCurrentLocation() {
    Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
         forceAndroidLocationManager : !widget.androidFusedLocation
      ).then((Position position) {
        if (mounted) {
          if (position != _currentPosition) {
            _currentPosition = position;
            loadAddress(true);
          }
        }
      }).catchError((Object e) {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShowAddress) {
      return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space8,
            right: PsDimens.space8,
            bottom: PsDimens.space8),
        child: Card(
          elevation: 0.0,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          color: PsColors.baseLightColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      (widget.textEditingController!.text == '')
                          ? Utils.getString(context, 'dashboard__open_gps')
                          : widget.textEditingController!.text,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          letterSpacing: 0.8, fontSize: 16, height: 1.3),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    height: PsDimens.space44,
                    width: PsDimens.space44,
                    child: Icon(
                      Icons.gps_fixed,
                      color: PsColors.iconColor,
                      size: PsDimens.space20,
                    ),
                  ),
                  onTap: () async {
                    await _getCurrentPosition();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
*/
