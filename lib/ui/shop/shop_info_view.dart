import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/shop_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopInfoView extends StatefulWidget {
  const ShopInfoView({Key? key, this.animationController, this.animation})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  _ShopInfoViewState createState() => _ShopInfoViewState();
}

class _ShopInfoViewState extends State<ShopInfoView> {
  @override
  Widget build(BuildContext context) {
    final ShopInfoProvider provider =
        Provider.of<ShopInfoProvider>(context, listen: false);
    widget.animationController!.forward();
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: widget.animationController!,
        child: provider.shopInfo.data != null
            ? _ShopInfoViewWidget(widget: widget, provider: provider)
            : Container(),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: widget.animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - widget.animation!.value), 0.0),
                child: child,
              ));
        },
      ),
    );
  }
}

class _ShopInfoViewWidget extends StatefulWidget {
  const _ShopInfoViewWidget({
    Key? key,
    required this.widget,
    required this.provider,
  }) : super(key: key);

  final ShopInfoView widget;
  final ShopInfoProvider provider;

  @override
  __ShopInfoViewWidgetState createState() => __ShopInfoViewWidgetState();
}

class __ShopInfoViewWidgetState extends State<_ShopInfoViewWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
   
    return Container(
      color: PsColors.coreBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ImageAndTextWidget(
            data: widget.provider.shopInfo.data!,
          ),
          _DescriptionWidget(
            data: widget.provider.shopInfo.data,
          ),
          _SourceAddressWidget(
            data: widget.provider.shopInfo.data!,
          ),
          _ShopBranchWidget(
            shopInfo: widget.provider.shopInfo.data!,
          ),
          _PhoneAndContactWidget(
            phone: widget.provider.shopInfo.data!,
          ),
          if(widget.provider.shopInfo.data!.aboutWebsite!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.wordpress,
              title: Utils.getString(context, 'shop_info__visit_our_website'),
              link: widget.provider.shopInfo.data!.aboutWebsite!),
          if(widget.provider.shopInfo.data!.facebook!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.facebook,
              title: Utils.getString(context, 'shop_info__facebook'),
              link: widget.provider.shopInfo.data!.facebook!),
          if(widget.provider.shopInfo.data!.googlePlus!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.google_plus_circle,
              title: Utils.getString(context, 'shop_info__google_plus'),
              link: widget.provider.shopInfo.data!.googlePlus!),
          if(widget.provider.shopInfo.data!.twitter!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.twitter_squared,
              title: Utils.getString(context, 'shop_info__twitter'),
              link: widget.provider.shopInfo.data!.twitter!),
          if(widget.provider.shopInfo.data!.instagram!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.instagram,
              title: Utils.getString(context, 'shop_info__instagram'),
              link: widget.provider.shopInfo.data!.instagram!),
          if(widget.provider.shopInfo.data!.youtube!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.youtube,
              title: Utils.getString(context, 'shop_info__youtube'),
              link: widget.provider.shopInfo.data!.youtube!),
          if(widget.provider.shopInfo.data!.pinterest!.isNotEmpty)
          _LinkAndTitle(
              icon: FontAwesome.pinterest,
              title: Utils.getString(context, 'shop_info__pinterest'),
              link: widget.provider.shopInfo.data!.pinterest!),
        ],
      ),
    );
  }
}

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
    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: PsDimens.space20),
                const SizedBox(width: PsDimens.space12),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsDimens.space8),
            Row(
              children: <Widget>[
                const SizedBox(width: PsDimens.space32),
                Flexible(
                  child: GestureDetector(
                    child: Text(
                      link.isEmpty
                          ? Utils.getString(context, 'shop_info__dash')
                          : link,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      if (await canLaunch(link)) {
                        await launch(link);
                      } else {
                        throw 'Could not launch URL: $link';
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        )


    );
  }
}

class ImageAndTextWidget extends StatelessWidget {
  const ImageAndTextWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ShopInfo data;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space4,
    );

    final Widget _imageWidget = PsNetworkImage(
      photoKey: '',
      defaultPhoto: data.defaultPhoto!,
      width: 60,
      height: 60,
      boxfit: BoxFit.cover,
      onTap: () {},
    );

    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space16,
            right: PsDimens.space16,
            top: PsDimens.space16),
        child: Row(
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
                    data.name!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: PsColors.mainColor,
                        ),
                  ),
                  _spacingWidget,
                  GestureDetector(
                    child: Text(
                      data.aboutPhone1!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                    ),
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse('tel://${data.aboutPhone1}'))) {
                        await launchUrl(Uri.parse('tel://${data.aboutPhone1}'));
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
                      GestureDetector(
                        child: Text(data.email!,
                            style: Theme.of(context).textTheme.bodyMedium),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse('mailto:${data.email}'))) {
                            await launchUrl(Uri.parse('mailto:${data.email}'));
                          } else {
                            throw 'Could not launchUrl ${data.email}';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class _PhoneAndContactWidget extends StatelessWidget {
  const _PhoneAndContactWidget({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final ShopInfo phone;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space16,
    );
    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(Utils.getString(context, 'shop_info__contact'),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            _spacingWidget,
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
                    GestureDetector(
                      child: Text(
                        phone.aboutPhone1!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse('tel://${phone.aboutPhone1}'))) {
                          await launchUrl(Uri.parse('tel://${phone.aboutPhone1}'));
                        } else {
                          throw 'Could not Call Phone Number 1';
                        }
                      },
                    ),
                    _spacingWidget,
                    GestureDetector(
                      child: Text(
                        phone.aboutPhone2!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse('tel://${phone.aboutPhone2}'))) {
                          await launchUrl(Uri.parse('tel://${phone.aboutPhone2}'));
                        } else {
                          throw 'Could not Call Phone Number 2';
                        }
                      },
                    ),
                    _spacingWidget,
                    GestureDetector(
                      child: Text(
                        phone.aboutPhone3!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse('tel://${phone.aboutPhone3}'))) {
                          await launchUrl(Uri.parse('tel://${phone.aboutPhone3}'));
                        } else {
                          throw 'Could not Call Phone Number 3';
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            _spacingWidget,
          ],
        ));
  }
}

class _ShopBranchWidget extends StatelessWidget {
  const _ShopBranchWidget({
    Key? key,
    required this.shopInfo,
  }) : super(key: key);

  final ShopInfo shopInfo;
  @override
  Widget build(BuildContext context) {
    if (shopInfo.branch!.isNotEmpty && shopInfo.branch![0].id != '') {
      final ShopInfoProvider shopInfoProvider =
          Provider.of<ShopInfoProvider>(context, listen: false);
      return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(Utils.getString(context, 'shop_info__branch'),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(
              height: PsDimens.space8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                ),
                PSButtonWidget(
                    titleText: Utils.getString(context, 'shop_branch_view_all'),
                    colorData: PsColors.mainColor,
                    textColor: PsColors.white,
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RoutePaths.shopbranchContainer,
                          arguments: shopInfoProvider.shopInfo.data);
                    }),
                // SizedBox(
                //   width: double.infinity,
                //   child: RaisedButton(
                //       child: Text(
                //           Utils.getString(context, 'shop_branch_view_all'),
                //           style: Theme.of(context)
                //               .textTheme
                //               .titleMedium
                //               .copyWith(color: PsColors.mainColor)),
                //       color: PsColors.backgroundColor,
                //       onPressed: () {
                //         Navigator.pushNamed(
                //             context, RoutePaths.shopbranchContainer,
                //             arguments: shopInfoProvider.shopInfo.data);
                //       }),
                // ),
                const SizedBox(
                  height: PsDimens.space12,
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

class _SourceAddressWidget extends StatelessWidget {
  const _SourceAddressWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ShopInfo data;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PsColors.backgroundColor,
      margin: const EdgeInsets.only(top: PsDimens.space8),
      padding: const EdgeInsets.all(PsDimens.space16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(Utils.getString(context, 'shop_info__source_address'),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(
            height: PsDimens.space8,
          ),
          Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
              ),
              _AddressWidget(icon: Icons.location_on, title: data.address1!),
              _AddressWidget(icon: Icons.location_on, title: data.address2!),
              _AddressWidget(icon: Icons.location_on, title: data.address3!),
              const SizedBox(
                height: PsDimens.space12,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AddressWidget extends StatelessWidget {
  const _AddressWidget({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space16,
        ),
        Row(
          children: <Widget>[
            Container(
              width: PsDimens.space20,
              height: PsDimens.space20,
              child: Icon(
                icon,
              ),
            ),
            const SizedBox(
              width: PsDimens.space8,
            ),
            Flexible( // Wrap the Text with Flexible
              child: Wrap( // Use Wrap to handle text overflow
                children: <Widget>[
                  Text(
                    title != '' ? title : '-',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );


  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({Key? key, this.data}) : super(key: key);

  final ShopInfo? data;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space16,
            ),
            if (data!.shopSchedules != null)
              getOpenTime(context)
            else
              Container(),
            if (data!.shopSchedules != null)
              Column(
                children: <Widget>[
                  getCloseTime(context),
                const SizedBox(
                  height: PsDimens.space16,
                ),
              ],
            )
            else
              Container(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data!.description!,
                style:
                    Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.3),
              ),
            )
          ],
        )
      );
  }

  dynamic getOpenTime (BuildContext context) {
    final String dateAndTime = DateFormat.yMMMMEEEEd('en_US').format(DateTime.now());
    final String days = dateAndTime.split(',').first;
    if (days == 'Monday') {
      if (data!.shopSchedules!.mondayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                  data!.shopSchedules!.mondayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
            );
        }
    } else if (days == 'Tuesday') {
        if (data!.shopSchedules!.tuesdayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                  data!.shopSchedules!.tuesdayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
          );
        }
    } else if (days == 'Wednesday') {
        if (data!.shopSchedules!.wednesdayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                 data!.shopSchedules!.wednesdayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Thursday') {
        if (data!.shopSchedules!.thursdayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                 data!.shopSchedules!.thursdayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Friday') {
        if (data!.shopSchedules!.fridayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                 data!.shopSchedules!.fridayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Saturday') {
        if (data!.shopSchedules!.saturdayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                 data!.shopSchedules!.saturdayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Sunday') {
        if (data!.shopSchedules!.sundayOpenHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__opening_hour') +
                 data!.shopSchedules!.sundayOpenHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    }
  }

  dynamic getCloseTime (BuildContext context) {
    final String dateAndTime = DateFormat.yMMMMEEEEd('en_US').format(DateTime.now());
    final String days = dateAndTime.split(',').first;
    if (days == 'Monday') {
      if (data!.shopSchedules!.mondayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.mondayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
            );
        }
    } else if (days == 'Tuesday') {
        if (data!.shopSchedules!.tuesdayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.tuesdayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
          );
        }
    } else if (days == 'Wednesday') {
        if (data!.shopSchedules!.wednesdayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.wednesdayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Thursday') {
        if (data!.shopSchedules!.thursdayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.thursdayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Friday') {
        if (data!.shopSchedules!.fridayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.fridayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Saturday') {
        if (data!.shopSchedules!.saturdayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.saturdayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    } else if (days == 'Sunday') {
        if (data!.shopSchedules!.sundayCloseHour != null) {
        return Text(
            Utils.getString(context, 'shop_info__closing_hour') +
                 data!.shopSchedules!.sundayCloseHour!,
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
        );
      }
    }
  }
}
