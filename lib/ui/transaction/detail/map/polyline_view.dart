import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/user_location.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../api/common/ps_resource.dart';
import '../../../../api/ps_api_service.dart';
import '../../../../config/ps_colors.dart';
import '../../../../provider/point/point_provider.dart';
import '../../../../repository/point_repository.dart';
import '../../../../utils/utils.dart';
import '../../../../viewobject/intersection.dart';
import '../../../../viewobject/main_point.dart';
import '../../../common/ps_toast.dart';

class PolylinePage extends StatefulWidget {
  PolylinePage
      ({
    required this.customerLatLng,
    required this.deliveryBoyLatLng,
    required this.deliveryBoyId,
    required this.valueHolder
  });

  final PsValueHolder valueHolder;
  final LatLng customerLatLng;
  late LatLng deliveryBoyLatLng;
  final String deliveryBoyId;
  @override
  _PolylinePageState createState() => _PolylinePageState();
}

List<MapLatLng> points = <MapLatLng>[];
LatLng? firstPointStringFormat;
LatLng? secPointStringFormat;
LatLng? thirdPointStringFormat;
LatLng? centerPointStringFormat;

class _PolylinePageState extends State<PolylinePage> {

  MapController mapController = MapController();
  //late Socket socket;
  PointProvider? pointProvider;
  PointRepository? pointRepository;
  late List<Model> _markers;
  late MapTileLayerController _controller;
  late MapZoomPanBehavior _zoomPanBehavior;
  late MapShapeSource dataSource;
  late List<List<MapLatLng>> polylines;
  
  @override
  void initState() {
    super.initState();
    //_updateDeliveryBoyLocation();
    _zoomPanBehavior = MapZoomPanBehavior();
    _markers = <Model>[
      Model(widget.customerLatLng.latitude, widget.customerLatLng.longitude,
          const Icon(
            Icons.home_filled,
            color: Colors.red,
          )
      ),
      Model(widget.deliveryBoyLatLng.latitude, widget.deliveryBoyLatLng.longitude,
          const Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.red,
          )
      ),
    ];
    polylines = <List<MapLatLng>>[points];
    _controller = MapTileLayerController();
    _zoomPanBehavior.zoomLevel = 15;
    _zoomPanBehavior.focalLatLng =   MapLatLng(widget.deliveryBoyLatLng.latitude, widget.deliveryBoyLatLng.longitude);

  }

  @override
  void dispose() {
    print('pilyline dispose called');
    super.dispose();
  }

  Future<dynamic> _updateDeliveryBoyLocation() async {


    if (await Utils.checkInternetConnectivity()) {

      final PsResource<UserLocation> userLocation = await PsApiService()
          .getUserLocation(widget.deliveryBoyId);
      widget.deliveryBoyLatLng = LatLng(
          double.parse(userLocation.data!.userLat!),
          double.parse(userLocation.data!.userLng!)
      );
      final PsResource<MainPoint> mainPoint = await PsApiService()
      .getAllPoints(
          widget.customerLatLng!.latitude.toString(),
          widget.customerLatLng!.longitude.toString(),
          widget.deliveryBoyLatLng!.latitude.toString(),
          widget.deliveryBoyLatLng!.longitude.toString()
      );

      final int length = _markers.length;
      if (length > 0) {
        _markers[length - 1].latitude = widget.deliveryBoyLatLng.latitude;
        _markers[length - 1].longitude = widget.deliveryBoyLatLng.longitude;
        _controller.updateMarkers([length - 1]);
        _zoomPanBehavior.focalLatLng =   MapLatLng(widget.deliveryBoyLatLng.latitude, widget.deliveryBoyLatLng.longitude);

      }
      _updatePolylines(mainPoint);

      print('updated delivery boy location: lat = ${userLocation.data!.userLat!} lng = ${userLocation.data!.userLng!}');


      return points;
    }

    PsToast().showToast(Utils.getString(context!, 'error_dialog__no_internet'));
    return null;
  }

  void _updatePolylines (PsResource<MainPoint> mainPoint) {
    if ( mainPoint.data != null) {
      points = <MapLatLng>[];
      if (mainPoint.data!.trips!.isNotEmpty) {
        for (int c = 0;
        c <
            mainPoint.data!.trips![0].legList![0]
                .stepList!.length;
        c++) {

          if (mainPoint.data?.trips != null &&
              mainPoint.data!.trips![0].legList != null &&
              mainPoint.data!.trips![0].legList![0].stepList != null) {
            for (Intersection intersection in
            mainPoint.data!.trips![0].legList![0].stepList![c].intersectionList!) {
              points.add(MapLatLng(
                  intersection.locationList![1],
                  intersection.locationList![0]
              )
              );

              //print(intersection.locationList);
            }

          }
        }
        print('poly: ${points[0].latitude}, ${points[points.length - 1].latitude}');
      }

    } else {
      points = <MapLatLng>[];
      points.add(MapLatLng(widget.customerLatLng.longitude, widget.customerLatLng.longitude));
      centerPointStringFormat = widget.customerLatLng;
    }
  }


  @override
  Widget build(BuildContext context) {

    pointRepository = Provider.of<PointRepository?>(context);

    return FutureBuilder<dynamic>(
      future: _updateDeliveryBoyLocation(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapdata)
      {
        if(snapdata.hasData) {
          final List<MapLatLng> polylinePoints =
          snapdata.data as List<MapLatLng>;
          polylines = <List<MapLatLng>>[polylinePoints];
          return MultiProvider(
              providers: <SingleChildWidget>[
                ChangeNotifierProvider<PointProvider>(
                  lazy: false,
                  create: (BuildContext context) {
                    pointProvider = PointProvider(repo: pointRepository!,
                        psValueHolder: widget.valueHolder);

                    return pointProvider!;
                  },
                ),
              ],
              child: Consumer<PointProvider>(
                  builder: (BuildContext context, PointProvider provider,
                      Widget? child) {
                    _updateDeliveryBoyLocation();
                    // Calculate the bounding box of the markers and polylines
                    List<LatLng> bounds = [];
                    /*for (LatLng point in points) {
                    bounds.add(point);
                  }*/
                    bounds.add(widget.customerLatLng);
                    bounds.add(widget.deliveryBoyLatLng);

                    const double paddingPixels = 50;
                    double paddingDegreesX = paddingPixels *
                        (360 / (256 * (1 << 15)));
                    double paddingDegreesY = paddingPixels *
                        (180 / (256 * (1 << 15)));
                    LatLngBounds paddedBounds = LatLngBounds.fromPoints(bounds);
                    paddedBounds.extend(LatLng(
                        paddedBounds.north + paddingDegreesY,
                        paddedBounds.east + paddingDegreesX));
                    paddedBounds.extend(LatLng(
                        paddedBounds.south - paddingDegreesY,
                        paddedBounds.west - paddingDegreesX));

                    return Scaffold(
                      body: Stack(
                        children: <Widget>[
                          Positioned(
                            right: 0,
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child:
                            SfMaps(
                              layers: <MapLayer>[
                                MapTileLayer(
                                  zoomPanBehavior: _zoomPanBehavior,
                                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  initialMarkersCount: _markers.length,

                                  markerBuilder: (BuildContext context,
                                      int index) {
                                    return MapMarker(
                                      latitude: _markers[index].latitude,
                                      longitude: _markers[index].longitude,
                                      child: _markers[index].icon,
                                    );
                                  },
                                  controller: _controller,
                                  sublayers: [
                                    if(polylines.isNotEmpty)
                                      MapPolylineLayer(
                                        polylines: List<MapPolyline>.generate(
                                          polylines.length,
                                              (int index) {
                                            return MapPolyline(
                                              points: polylines[index],
                                              color: Colors.blue,
                                              width: 6,
                                              strokeCap: StrokeCap.round,
                                            );
                                          },
                                        ).toSet(),
                                      ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          /*Positioned(
                            top: 10, right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: PsColors.mainColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: PsColors.discountColor,
                                ),
                                iconSize: 25,
                                onPressed: () {
                                  setState(() {
                                    _updateDeliveryBoyLocation();
                                  });
                                },
                              ),
                            ),
                          ),*/
                          Positioned(
                            bottom: 10, right: 10,
                            child:
                            Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: PsColors.mainColor.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: PsColors.discountColor,
                                    ),
                                    iconSize: 25,
                                    onPressed: () {
                                      _zoomPanBehavior.zoomLevel += 1;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: PsColors.mainColor.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      color: PsColors.discountColor,
                                    ),
                                    iconSize: 25,
                                    onPressed: () {
                                      _zoomPanBehavior.zoomLevel -= 1;
                                    },
                                  ),
                                ),
                              ],
                            ),

                          )
                        ],
                      ),
                    );
                  }));
        }
        else
          return const Center(
            child: Text('...Loading!'),
          );
      },
    );

    /**/
  }
}
class Model {
  Model(this.latitude, this.longitude, this.icon);

  double latitude;
  double longitude;
  Icon icon;
}