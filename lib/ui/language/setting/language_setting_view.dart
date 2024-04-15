import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/language/language_provider.dart';
import 'package:flutterrestaurant/repository/language_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_dropdown_base_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/language.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class LanguageSettingView extends StatefulWidget {
  const LanguageSettingView(
      {Key? key,
      required this.animationController,
      required this.languageIsChanged})
      : super(key: key);
  final AnimationController animationController;
  final Function languageIsChanged;
  @override
  _LanguageSettingViewState createState() => _LanguageSettingViewState();
}

class _LanguageSettingViewState extends State<LanguageSettingView> {
  String currentLang = '';
  LanguageRepository? repo1;
  late PsValueHolder psValueHolder;

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    widget.animationController.forward();

    widget.animationController.forward();
    final LanguageRepository repo1 = Provider.of<LanguageRepository>(context);
    return AnimatedBuilder(
        animation: widget.animationController,
        child: ChangeNotifierProvider<LanguageProvider>(
          lazy: false,
          create: (BuildContext context) {
            final LanguageProvider provider = LanguageProvider(repo: repo1,);
            provider.getLanguageList();
            return provider;
          },
          child: Consumer<LanguageProvider>(builder:
              (BuildContext context, LanguageProvider provider, Widget? child) {
            return SingleChildScrollView(
                child: Container(
              padding: const EdgeInsets.all(PsDimens.space8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PsDropdownBaseWidget(
                      title: Utils.getString(
                          context, 'language_selection__select'),
                      selectedText: provider.getLanguage().name,
                      onTap: () async {
                        final dynamic result = await Navigator.pushNamed(
                            context, RoutePaths.languageList);
                         if (result != null && result is Language) {
                          psValueHolder.defaultLanguageCode = result.languageCode;
                          psValueHolder.defaultLanguageCountryCode = result.countryCode;
                          psValueHolder.defaultLanguageName = result.name;
                          await provider.addLanguage(result);
                              
                          EasyLocalization.of(context)!.setLocale(Locale(
                            result.languageCode!, result.countryCode));
                        }
                        Utils.psPrint(result.toString());
                      }),
                 /* const PsAdMobBannerWidget(
                    admobSize: AdSize.mediumRectangle
                  ),*/
                ],
              ),
            ));
          }),
        ),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: animation,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 100 * (1.0 - animation.value), 0.0),
              child: child,
            ),
          );
        });
  }
}
