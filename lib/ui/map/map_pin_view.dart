import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar_with_no_provider.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/holder/map_pin_call_back_holder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
//import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class MapPinView extends StatefulWidget {
  const MapPinView(
      {required this.flag, required this.maplat, required this.maplng});

  final String flag;
  final String maplat;
  final String maplng;

  @override
  _MapPinViewState createState() => _MapPinViewState();
}

class _MapPinViewState extends State<MapPinView> with TickerProviderStateMixin {
  LatLng? _latlng;
  double defaultRadius = 3000;
  String address = '';

  // dynamic loadAddress() async {
  //   try {
  //     final Address? locationAddress = await GeoCode().reverseGeocoding(
  //         latitude: double.parse(latlng!.latitude.toString()),
  //         longitude: double.parse(latlng!.longitude.toString()));
  //     if (locationAddress != null) {
  //       if (locationAddress.streetAddress != null &&
  //           locationAddress.countryName != null) {
  //         address =
  //             '${locationAddress.streetAddress}  \n, ${locationAddress.countryName}';
  //       } else {
  //         address = locationAddress.region!;
  //       }
  //     }
  //   } catch (e) {
  //     address = '';
  //     print(e);
  //   }
  // }

  Future<void> loadAddress() async {
      await placemarkFromCoordinates(
              double.parse(_latlng!.latitude.toString()),
              double.parse(_latlng!.longitude.toString()))
          .then((List<Placemark> placemarks) {
        final Placemark place = placemarks[0];
        setState(() {
          address =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        });
      }).catchError((dynamic e) {
        debugPrint(e);
      });
    }

  @override
  Widget build(BuildContext context) {
    _latlng ??= LatLng(double.parse(widget.maplat), double.parse(widget.maplng));

    // final double scale = defaultRadius / 200; //radius/20
    const double value = 17.0; //16 - log(scale) / log(2);
    loadAddress();

    print('value $value');

    return PsWidgetWithAppBarWithNoProvider(
        appBarTitle: Utils.getString(context, 'map_pin__title'),
        actions: widget.flag == PsConst.PIN_MAP
            ? <Widget>[
                InkWell(
                  child: Ink(
                    child: Center(
                      child: Text(
                        Utils.getString(context, 'map_pin__pick_location'),
                        textAlign: TextAlign.justify,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold)
                            .copyWith(color: PsColors.mainColorWithWhite),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context,
                        MapPinCallBackHolder(address: address, latLng: _latlng!));
                  },
                ),
                const SizedBox(
                  width: PsDimens.space16,
                ),
              ]
            : <Widget>[],
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Flexible(
                child: FlutterMap(
                  options: MapOptions(
                      center:
                          _latlng, //LatLng(51.5, -0.09), //LatLng(45.5231, -122.6765),
                      zoom: value, //10.0,
                      // onTap: widget.flag == PsConst.PIN_MAP
                      //     ? _handleTap
                      //     : _doNothingTap),
                      onTap: (TapPosition tapPosition, LatLng latlng) {
                        if (widget.flag == PsConst.PIN_MAP) {
                          setState(() {
                            _latlng = latlng;
                          });
                        }
                      }),
                  /*layers: <LayerOptions>[
                    TileLayerOptions(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayerOptions(markers: <Marker>[
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _latlng!,
                        builder: (BuildContext ctx) => Container(
                          child: IconButton(
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            iconSize: 45,
                            onPressed: () {},
                          ),
                        ),
                      )
                    ])
                  ],*/
                ),
              ),
            ],
          ),
        ));
  }

  // void _handleTap(LatLng latlng) {
  //   setState(() {
  //     this.latlng = latlng;
  //   });
  // }

  // void _doNothingTap(LatLng latlng) {}
}
