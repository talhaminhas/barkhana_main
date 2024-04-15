import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/provider/address/postal_address_provider.dart';
import 'package:flutterrestaurant/repository/postal_address_repository.dart';
import 'package:flutterrestaurant/ui/checkout/postal_address_list_item.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/address.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../api/ps_api_service.dart';
import '../../config/ps_colors.dart';
import '../../viewobject/postal_address.dart';
import '../common/ps_frame_loading_widget.dart';

class PostalAddressListView extends StatefulWidget {
  const PostalAddressListView({required this.postcode});
  @override
  State<StatefulWidget> createState() {
    return _PostalAddressListViewState();
  }
  final String postcode;
}

class _PostalAddressListViewState extends State<PostalAddressListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PsApiService _psApiService = PsApiService();
  PostalAddressProvider? postalAddressProvider;
  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //postalAddressProvider!.nextShippingAreaList();
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    animation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(animationController!);
    super.initState();
  }

  PostalAddressRepository ?repo1;
  PsValueHolder? psValueHolder;

  @override
  Widget build(BuildContext context) {
    Future<bool> _requestPop() async {

      animationController!.reverse().then<dynamic>(
        (void data) {
          if (!mounted) {
            return Future<bool>.value(false);
          }
          Navigator.pop(context, true);
          return Future<bool>.value(true);
        },
      );
      return Future<bool>.value(false);
    }

    repo1 = Provider.of<PostalAddressRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    PostalAddress postalAddress = PostalAddress(postcode: '',latitude: '',longitude: '',shopId: '',addresses: <Address>[]);
    print(
        '............................Build UI Again ............................');

    return WillPopScope(
        onWillPop: _requestPop,
        child: PsWidgetWithAppBar<PostalAddressProvider>(
            appBarTitle:
                Utils.getString(context, 'postal_address_list__app_bar_name') ,
            initProvider: () {
              return PostalAddressProvider(
                  repo: repo1!, psValueHolder: psValueHolder);
            },
            onProviderReady: (PostalAddressProvider provider) async {
              final Map<String, dynamic> jsonMap = <String, dynamic>{};

              jsonMap['postcode'] = widget.postcode;
              /*setState(() async {
                postalAddress = await provider.loadPostalAddressesList(jsonMap);
                print(postalAddress.addresses![0].line_1);
              });*/
              postalAddress = await provider.loadPostalAddressesList(jsonMap);
              postalAddressProvider = provider;
              return postalAddressProvider;
            },
            builder: (BuildContext context, PostalAddressProvider provider,
                Widget? child) {
              return Stack(children: <Widget>[
                Container(
                    /*child: RefreshIndicator(*/
                  child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.addressList.data!.length,
                      itemBuilder: (BuildContext context, int index) {

                        if (/*provider.addressList.status ==
                            PsStatus.BLOCK_LOADING*/
                        provider.addressList.data!.isEmpty) {
                          PsProgressDialog.showDialog(context);
                          return Shimmer.fromColors(
                              baseColor: PsColors.grey,
                              highlightColor: PsColors.white,
                              child: const Column(children: <Widget>[
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                                PsFrameUIForLoading(),
                              ]));
                        }
                        else {
                          PsProgressDialog.dismissDialog();
                          final int count = provider.addressList.data!.length;

                          return FadeTransition(
                              opacity: animation!,
                              child: PostalAddressListItem(
                                animationController: animationController,
                                animation:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animationController!,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                                  ),
                                ),
                                address: provider.addressList.data![index].line_1! + ', ' +
                                    provider.addressList.data![index].line_2!,
                                city: provider.addressList.data![index].townOrCity! + ', ' +
                                    provider.addressList.data![index].country! + '.',
                                onTap: () {
                                  provider.addressList.data![index].longitude = postalAddress.longitude;
                                  provider.addressList.data![index].latitude = postalAddress.latitude;
                                  Navigator.pop(context,
                                      provider.addressList.data![index]);
                                },
                              ));
                          }
                      }
                      /*}*/),
                  /*onRefresh: () {
                    return provider.resetShippingAreaList();
                  },
                */),
                /*PSProgressIndicator(provider.shippingAreaList.status)*/
              ]);
            }));
  }
}
