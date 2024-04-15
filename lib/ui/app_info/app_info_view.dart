import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/about_app/about_app_provider.dart';
import 'package:flutterrestaurant/repository/about_app_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/about_app.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/default_photo.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoView extends StatefulWidget {
  @override
  _AppInfoViewState createState() {
    return _AppInfoViewState();
  }
}

class _AppInfoViewState extends State<AppInfoView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double> ?animation;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(animationController!);
  }

  AboutAppRepository? repo1;
  PsValueHolder? valueHolder;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
   
    repo1 = Provider.of<AboutAppRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    return PsWidgetWithAppBar<AboutAppProvider>(
        appBarTitle: Utils.getString(context, 'setting__app_info'),
        initProvider: () {
          return AboutAppProvider(
            repo: repo1,
            psValueHolder: valueHolder,
          );
        },
        onProviderReady: (AboutAppProvider provider) {
          provider.loadAboutAppList();
          return provider;
        },
        builder:
            (BuildContext context, AboutAppProvider provider, Widget? child) {
          if (
              provider.aboutAppList.data != null &&
              provider.aboutAppList.data!.isNotEmpty) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PsDimens.space10),
                child: Column(
                  children: <Widget>[
                    /*const PsAdMobBannerWidget(
                      admobSize: AdSize.banner
                    ),*/
                    _HeaderImageWidget(
                      photo: provider.aboutAppList.data![0].defaultPhoto!,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: PsDimens.space16,
                          right: PsDimens.space16,
                          top: PsDimens.space16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          _TitleAndDescriptionWidget(
                            data: provider.aboutAppList.data![0],
                          ),
                          _PhoneAndContactWidget(
                            phone: provider.aboutAppList.data![0],
                          ),
                          _LinkAndTitle(
                              icon: FontAwesome.wordpress,
                              title: Utils.getString(
                                  context, 'shop_info__visit_our_website'),
                              link: provider.aboutAppList.data![0].aboutWebsite!),
                          _LinkAndTitle(
                              icon: FontAwesome.facebook,
                              title: Utils.getString(
                                  context, 'shop_info__facebook'),
                              link: provider.aboutAppList.data![0].facebook!),
                          _LinkAndTitle(
                              icon: FontAwesome.google_plus_circle,
                              title: Utils.getString(
                                  context, 'shop_info__google_plus'),
                              link: provider.aboutAppList.data![0].googlePlus!),
                          _LinkAndTitle(
                              icon: FontAwesome.twitter_squared,
                              title: Utils.getString(
                                  context, 'shop_info__twitter'),
                              link: provider.aboutAppList.data![0].twitter!),
                          _LinkAndTitle(
                              icon: FontAwesome.instagram,
                              title: Utils.getString(
                                  context, 'shop_info__instagram'),
                              link: provider.aboutAppList.data![0].instagram!),
                          _LinkAndTitle(
                              icon: FontAwesome.youtube,
                              title: Utils.getString(
                                  context, 'shop_info__youtube'),
                              link: provider.aboutAppList.data![0].youtube!),
                          _LinkAndTitle(
                              icon: FontAwesome.pinterest,
                              title: Utils.getString(
                                  context, 'shop_info__pinterest'),
                              link: provider.aboutAppList.data![0].pinterest!),
                          const SizedBox(
                            height: PsDimens.space36,
                          ),
                          // _SourceAddressWidget(
                          //   data: provider.aboutAppList.data[0],
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class AboutUsRepository {}

class _LinkAndTitle extends StatelessWidget {
  const _LinkAndTitle({
    Key? key,
    required this.icon,
    required this.title,
    required this.link,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space16,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Container(
                  width: PsDimens.space20,
                  height: PsDimens.space20,
                  child: Icon(
                    icon,
                  )),
              const SizedBox(
                width: PsDimens.space12,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: PsDimens.space8,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: PsDimens.space32,
              ),
              InkWell(
                child: Text(
                    link == ''
                        ? Utils.getString(context, 'shop_info__dash')
                        : link,
                    style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(link))) {
                    await launchUrl(Uri.parse(link));
                  } else {
                    throw 'Could not launchUrl $link';
                  }
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _HeaderImageWidget extends StatelessWidget {
  const _HeaderImageWidget({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final DefaultPhoto photo;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PsNetworkImage(
          photoKey: '',
          defaultPhoto: photo,
          width: MediaQuery.of(context).size.width,
          height: 300,
          boxfit: BoxFit.cover,
          onTap: () {},
        ),
      ],
    );
  }
}

class ImageAndTextWidget extends StatelessWidget {
  const ImageAndTextWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AboutApp data;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space4,
    );

    final Widget _imageWidget = PsNetworkImage(
      photoKey: '',
      defaultPhoto: data.defaultPhoto!,
      width: 50,
      height: 50,
      boxfit: BoxFit.cover,
      onTap: () {},
    );

    return Row(
      children: <Widget>[
        _imageWidget,
        const SizedBox(
          width: PsDimens.space12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.aboutTitle!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: PsColors.mainColor,
                    ),
              ),
              _spacingWidget,
              InkWell(
                child: Text(
                  data.aboutPhone!,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                ),
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse('tel://${data.aboutPhone}'))) {
                    await launchUrl(Uri.parse('tel://${data.aboutPhone}'));
                  } else {
                    throw 'Could not Call Phone Number 1';
                  }
                },
              ),
              _spacingWidget,
              Row(
                children: <Widget>[
                  Container(
                      child: const Icon(
                    Icons.email,
                  )),
                  const SizedBox(
                    width: PsDimens.space8,
                  ),
                  InkWell(
                    child: Text(data.aboutEmail!,
                        style: Theme.of(context).textTheme.bodyLarge),
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse('mailto:teamps.is.cool@gmail.com'))) {
                        await launchUrl(Uri.parse('mailto:teamps.is.cool@gmail.com'));
                      } else {
                        throw 'Could not launchUrl teamps.is.cool@gmail.com';
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _PhoneAndContactWidget extends StatelessWidget {
  const _PhoneAndContactWidget({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final AboutApp phone;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space8,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // const SizedBox(
        //   height: PsDimens.space32,
        // ),
        // Text(Utils.getString(context, 'shop_info__contact'),
        //     style: Theme.of(context).textTheme.titleMedium),
        // _spacingWidget,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                width: PsDimens.space20,
                height: PsDimens.space20,
                child: const Icon(
                  Icons.phone_in_talk,
                )),
            const SizedBox(
              width: PsDimens.space12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'shop_info__phone'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _spacingWidget,
                InkWell(
                  child: Text(
                    phone.aboutPhone!,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                  ),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse('tel://${phone.aboutPhone}'))) {
                      await launchUrl(Uri.parse('tel://${phone.aboutPhone}'));
                    } else {
                      throw 'Could not Call Phone Number 1';
                    }
                  },
                ),
                // _spacingWidget,
                // InkWell(
                //   child: Text(
                //     phone.aboutPhone2,
                //     style: Theme.of(context).textTheme.bodyLarge.copyWith(),
                //   ),
                //   onTap: () async {
                //     if (await canLaunchUrl('tel://${phone.aboutPhone2}')) {
                //       await launchUrl('tel://${phone.aboutPhone2}');
                //     } else {
                //       throw 'Could not Call Phone Number 2';
                //     }
                //   },
                // ),
                // _spacingWidget,
                // InkWell(
                //   child: Text(
                //     phone.aboutPhone3,
                //     style: Theme.of(context).textTheme.bodyLarge.copyWith(),
                //   ),
                //   onTap: () async {
                //     if (await canLaunchUrl('tel://${phone.aboutPhone3}')) {
                //       await launchUrl('tel://${phone.aboutPhone3}');
                //     } else {
                //       throw 'Could not Call Phone Number 3';
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
        // _spacingWidget,
      ],
    );
  }
}

class _TitleAndDescriptionWidget extends StatelessWidget {
  const _TitleAndDescriptionWidget({Key? key, this.data}) : super(key: key);

  final AboutApp? data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          data!.aboutTitle!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: PsColors.mainColor,
              ),
        ),
        const SizedBox(
          height: PsDimens.space16,
        ),
        Text(
          data!.aboutDescription!,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.3),
        ),
        const SizedBox(
          height: PsDimens.space32,
        ),
      ],
    );
  }
}
