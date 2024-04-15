import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_back_button_with_circle_bg_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/blog.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

class BlogView extends StatefulWidget {
  const BlogView({Key? key, required this.blog, required this.heroTagImage})
      : super(key: key);

  final Blog blog;
  final String heroTagImage;

  @override
  _BlogViewState createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
  bool isReadyToShowAppBarIcons = false;

  @override
  Widget build(BuildContext context) {
    if (!isReadyToShowAppBarIcons) {
      Timer(const Duration(milliseconds: 800), () {
        setState(() {
          isReadyToShowAppBarIcons = true;
        });
      });
    }

    return Scaffold(
        body: CustomScrollView(
      shrinkWrap: true,
      slivers: <Widget>[
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
          ),
          expandedHeight: PsDimens.space300,
          floating: true,
          pinned: true,
          snap: false,
          elevation: 0,
          leading: PsBackButtonWithCircleBgWidget(
              isReadyToShow: isReadyToShowAppBarIcons),
          backgroundColor: PsColors.mainColor,
          flexibleSpace: FlexibleSpaceBar(
            background: PsNetworkImage(
              photoKey: widget.heroTagImage,
              height: PsDimens.space300,
              //0width: double.infinity,
              defaultPhoto: widget.blog.defaultPhoto!,
              boxfit: BoxFit.cover,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: TextWidget(
            blog: widget.blog,
          ),
        )
      ],
    ));
  }
}

class TextWidget extends StatefulWidget {
  const TextWidget({
    Key? key,
    required this.blog,
  }) : super(key: key);

  final Blog blog;

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  @override
  Widget build(BuildContext context) {
  
    return Container(
      color: PsColors.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(PsDimens.space12),
            child: Text(
              widget.blog.name!,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
                bottom: PsDimens.space12),
            child: Text(
              widget.blog.description!,
              style:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5),
            ),
          ),
          /*const PsAdMobBannerWidget(admobSize: AdSize.banner),*/
        ],
      ),
    );
  }
}
