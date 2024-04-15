import 'package:flutter/material.dart';
import 'package:flutterrestaurant/provider/gallery/gallery_provider.dart';
import 'package:flutterrestaurant/provider/product/product_provider.dart';
import 'package:flutterrestaurant/repository/gallery_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:provider/provider.dart';

import '../../product/detail/views/detail_info_tile_view.dart';

class GalleryGridView extends StatefulWidget {
  const GalleryGridView({
    Key? key,
    required this.provider,
    this.onImageTap,
  }) : super(key: key);

  final ProductDetailProvider provider;
  final Function? onImageTap;
  @override
  _GalleryGridViewState createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final GalleryRepository productRepo =
        Provider.of<GalleryRepository>(context);
    print(
        '............................Build UI Again ............................');
    return PsWidgetWithAppBar<GalleryProvider>(

        appBarTitle: ''/*Utils.getString(context, 'ingredients__title')*/ ,
        initProvider: () {
          return GalleryProvider(repo: productRepo);
        },
        onProviderReady: (GalleryProvider provider) {
          provider.loadImageList(
            widget.provider.productDetail.data!.defaultPhoto!.imgParentId!,
          );
        },
        builder:
            (BuildContext context, GalleryProvider provider, Widget? child) {

          if (
            //provider.galleryList != null &&
              provider.galleryList.data!.isNotEmpty) {
            return /*Stack(
              children: <Widget>[*/
                Column (
                  children: <Widget>[
                    DetailInfoTileView(
                      productDetail: widget.provider,
                    ),
                    /*Container(
                      color: Theme.of(context).cardColor,
                      height: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: RefreshIndicator(
                            child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                slivers: <Widget>[
                                  SliverGrid(
                                    gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 150,
                                        childAspectRatio: 1.0),
                                    delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        return GalleryGridItem(
                                            image: provider.galleryList.data![index],
                                            onImageTap: () {
                                              Navigator.pushNamed(
                                                  context, RoutePaths.galleryDetail,
                                                  arguments: provider
                                                      .galleryList.data![index]);
                                            });
                                      },
                                      childCount: provider.galleryList.data!.length,
                                    ),
                                  ),
                                ]),
                            onRefresh: () {
                              return provider.resetGalleryList(
                                  widget.provider.productDetail.data!.defaultPhoto!.imgParentId!);
                            },
                          )),
                    ),*/
                  ],
                )/*,
                PSProgressIndicator(provider.galleryList.status)
              ],
            )*/;
          } else {
            return Stack(
              children: <Widget>[
                Container(),
                PSProgressIndicator(provider.galleryList.status)
              ],
            );
          }
        });
  }
}
