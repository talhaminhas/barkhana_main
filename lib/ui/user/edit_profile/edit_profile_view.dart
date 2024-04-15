import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/success_dialog.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_dropdown_base_with_controller_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_textfield_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/profile_update_view_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../api/ps_api_service.dart';
import '../../../viewobject/address.dart';

class EditProfileView extends StatefulWidget {
  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  UserRepository? userRepository;
  UserProvider? userProvider;
  PsValueHolder ?psValueHolder;
  AnimationController? animationController;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController userAddressController = TextEditingController();
  final TextEditingController userCityController = TextEditingController();
  final TextEditingController userCountryController = TextEditingController();
  final TextEditingController shippingAreaController = TextEditingController();
  TextEditingController userPostcodeController = TextEditingController();

  bool bindDataFirstTime = true;

  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    aboutMeController.dispose();
    userAddressController.dispose();
    userCityController.dispose();
    userCountryController.dispose();
    shippingAreaController.dispose();
    userPostcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    Future<bool> _requestPop() {
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
    void resetAddress(String text){
      setState(() {
      });
      userAddressController.text = '';
      userCityController.text = '';
      userCountryController.text = '';
    }
    void checkFields(String text){
      setState(() {
      });
    }
    return WillPopScope(
        onWillPop: _requestPop,
        child: PsWidgetWithAppBar<UserProvider>(
            appBarTitle: Utils.getString(context, 'edit_profile__title') ,
            initProvider: () {
              return UserProvider(
                  repo: userRepository!, psValueHolder: psValueHolder!);
            },
            onProviderReady: (UserProvider provider) async {
              await provider.getUser(provider.psValueHolder.loginUserId!);
              userProvider = provider;
            },
            builder:
                (BuildContext context, UserProvider provider, Widget? child) {
              if (userProvider != null &&
                  // userProvider!.user != null &&
                  userProvider!.user.data != null) {
                if (bindDataFirstTime) {
                  userNameController.text = userProvider!.user.data!.userName!;
                  emailController.text = userProvider!.user.data!.userEmail!;
                  phoneController.text = userProvider!.user.data!.userPhone!;
                  aboutMeController.text = userProvider!.user.data!.userAboutMe!;
                  userAddressController.text = userProvider!.user.data!.address!;
                  userProvider!.selectedArea = userProvider!.user.data!.area!;
                  shippingAreaController.text = userProvider!.user.data!.area!.areaName!;
                  userCityController.text = userProvider!.user.data!.userCity!;
                  userCountryController.text = userProvider!.user.data!.userCountry!;
                  userPostcodeController.text = userProvider!.user.data!.userPostcode!;
                  bindDataFirstTime = false;
                }

                return Stack(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Container(
                          color: PsColors.backgroundColor,
                          padding: const EdgeInsets.only(
                              left: PsDimens.space8, right: PsDimens.space8),
                          child: Column(
                            children: <Widget>[
                              _ImageWidget(userProvider: userProvider!),
                              _UserFirstCardWidget(
                                userNameController: userNameController,
                                emailController: emailController,
                                phoneController: phoneController,
                                aboutMeController: aboutMeController,
                              ),
                              Container(
                                margin: const EdgeInsets.all(PsDimens.space12),
                                child:  Divider(
                                  thickness: 1,
                                  height: 1,
                                  color: PsColors.mainColor,
                                ),
                              ),
                              PsTextFieldWidget(
                                titleText: Utils.getString(context, 'edit_profile__postcode'),
                                textAboutMe: false,
                                hintText: Utils.getString(context, 'edit_profile__postcode'),
                                textEditingController: userPostcodeController,
                                onChanged: resetAddress,
                                isMandatory: true,
                              ),

                              PsDropdownBaseWithControllerWidget(
                                  title: Utils.getString(context, 'edit_profile__address'),
                                  textEditingController: userAddressController,
                                  borderColor: userAddressController.text == '' ? PsColors.discountColor : PsColors.mainColor,
                                  isMandatory: true,
                                  onTap: () async {
                                    final Future<bool> isAValidPostcode = PsApiService.getPostcodeStatus(userPostcodeController.text);
                                    isAValidPostcode.whenComplete(() async {
                                      if(await isAValidPostcode) {
                                        final Object? result = await Navigator.pushNamed(
                                            context, RoutePaths.postalAddressList,
                                            arguments: userPostcodeController.text);
                                        if (result != null) {
                                          final Address selectedAddress = result as Address;
                                          setState(() {
                                            userAddressController.text = selectedAddress.line_1!;
                                            userCityController.text = selectedAddress.townOrCity!;
                                            userCountryController.text = selectedAddress.country!;
                                          });
                                          //print(selectedAddress.latitude! +' ' + selectedAddress.longitude!);
                                          final LatLng coordinates = LatLng(double.parse(selectedAddress.latitude!), double.parse(selectedAddress.longitude!));
                                          userProvider!.setUserLatLng(coordinates);

                                        }
                                      }
                                      else{
                                        Fluttertoast.showToast(
                                            msg:
                                            Utils.getString(context, 'checkout1_view__please_enter_postcode'),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: PsColors.black,
                                            textColor: PsColors.white);
                                      }
                                    });

                                  }),
                              PsTextFieldWidget(
                                  titleText: Utils.getString(context, 'edit_profile__city'),
                                  textAboutMe: false,
                                  hintText: Utils.getString(context, 'edit_profile__city'),
                                  textEditingController: userCityController,
                                  //onChanged: checkFields,
                                  isReadonly: true,
                                  isMandatory: true),
                              PsTextFieldWidget(
                                  titleText: Utils.getString(context, 'edit_profile__country'),
                                  textAboutMe: false,
                                  hintText: Utils.getString(context, 'edit_profile__country'),
                                  textEditingController: userCountryController,
                                  isReadonly: true,
                                  onChanged: checkFields,
                                  isMandatory: true),
                              const SizedBox(
                                height: 120,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child:
                          _TwoButtonWidget(
                            userProvider: userProvider!,
                            userNameController: userNameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            aboutMeController: aboutMeController,
                            userAddressController: userAddressController,
                            shippingAreaController: shippingAreaController,
                            userCityController: userCityController,
                            userCountryController: userCountryController,
                            userPostcodeController: userPostcodeController,
                          )
                      ),
                    ]);
              } else {
                return Stack(
                  children: <Widget>[
                    Container(),
                    PSProgressIndicator(provider.user.status)
                  ],
                );
              }
            }));
  }
}

class _TwoButtonWidget extends StatelessWidget {
  const _TwoButtonWidget(
      {required this.userProvider,
        required this.userNameController,
        required this.emailController,
        required this.phoneController,
        required this.aboutMeController,
        required this.userAddressController,
        required this.shippingAreaController,
        required this.userCityController,
        required this.userCountryController,
        required this.userPostcodeController});

  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aboutMeController;
  final TextEditingController userAddressController;
  final TextEditingController shippingAreaController;
  final TextEditingController userCityController;
  final TextEditingController userCountryController;
  final TextEditingController userPostcodeController;
  final UserProvider userProvider;

  bool validatePhoneNumber(String phoneNumber ){
    final RegExp phoneRegExp = RegExp(r'^[0-9]{11}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12, right: PsDimens.space12),
          child: PSButtonWidget(
            hasShadow: true,
            width: double.infinity,
            titleText: Utils.getString(context, 'edit_profile__save'),
            onPressed: () async {
              if (userNameController.text == '') {
                showDialog<dynamic>(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                        message: Utils.getString(
                            context, 'edit_profile__name_error'),
                      );
                    });
              } else if (emailController.text == '') {
                showDialog<dynamic>(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                        message: Utils.getString(
                            context, 'edit_profile__email_error'),
                      );
                    });
              }
              else if(!validatePhoneNumber(phoneController.text)){
                     showDialog<dynamic>(
                         context: context,
                         barrierColor: Colors.transparent,
                         builder: (BuildContext context) {
                           return ErrorDialog(
                             message: Utils.getString(
                                 context, 'Please Enter A Valid Phone Number'),
                           );
                         });
                }
              else {
                if (await Utils.checkInternetConnectivity()) {
                  final ProfileUpdateParameterHolder
                  profileUpdateParameterHolder =
                  ProfileUpdateParameterHolder(
                    userId: userProvider.user.data!.userId!,
                    userName: userNameController.text.toUpperCase(),
                    userEmail: emailController.text.trim(),
                    userPhone: phoneController.text,
                    userAddress: userAddressController.text,
                    userAboutMe: aboutMeController.text,
                    userAreaId: userProvider.selectedArea!.id!,
                    userLat: userProvider.user.data!.userLat!,
                    userLng: userProvider.user.data!.userLng!,
                    userCountry: userCountryController.text,
                    userCity: userCityController.text,
                    userPostcode: userPostcodeController.text.trim().toUpperCase(),
                  );
                  await PsProgressDialog.showDialog(context);
                  final PsResource<User> _apiStatus = await userProvider
                      .postProfileUpdate(profileUpdateParameterHolder.toMap());
                  if (_apiStatus.data != null) {
                    PsProgressDialog.dismissDialog();
                    Navigator.of(context).pop();
                    showDialog<dynamic>(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext contet) {
                          return SuccessDialog(
                            message: Utils.getString(
                                context, 'edit_profile__success'),
                          );
                        });
                  } else {
                    PsProgressDialog.dismissDialog();
                    showDialog<dynamic>(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            message: _apiStatus.message,
                          );
                        });
                  }
                }
                else {
                  showDialog<dynamic>(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          message: Utils.getString(
                              context, 'error_dialog__no_internet'),
                        );
                      });
                }
              }
            },
          ),
        ),
        const SizedBox(
          height: PsDimens.space12,
        ),
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12,
              right: PsDimens.space12,
              bottom: PsDimens.space20),
          child: PSButtonWidget(
            hasShadow: false,
            colorData: PsColors.grey,
            width: double.infinity,
            titleText:
            Utils.getString(context, 'edit_profile__password_change'),
            onPressed: () {
              Navigator.pushNamed(
                context,
                RoutePaths.user_update_password,
              );
            },
          ),
        )
      ],
    );
  }
}

class _ImageWidget extends StatefulWidget {
  const _ImageWidget({this.userProvider});
  final UserProvider? userProvider;

  @override
  __ImageWidgetState createState() => __ImageWidgetState();
}

class __ImageWidgetState extends State<_ImageWidget> {
  XFile? pickedImage;

  Future<bool> requestGalleryPermission() async {
    const Permission _photos = Permission.photos;
    final PermissionStatus permissionss = await _photos.request();

    if (permissionss == PermissionStatus.granted) {
      return true;
    } else {
      return openAppSettings();
      // return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImage() async {
      final ImagePicker _picker = ImagePicker();

      try {
        pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
        );
      } on Exception catch (e) {
        e.toString();
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) {
        return;
      }
      setState(() {});

      if (pickedImage!.name.contains('.webp')) {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__webp_image'),
              );
            });
      } else {
        PsProgressDialog.dismissDialog();
        final PsResource<User> _apiStatus = await widget.userProvider!
            .postImageUpload(
            widget.userProvider!.psValueHolder.loginUserId!,
            PsConst.PLATFORM,
            await Utils.getImageFileFromAssets(
                pickedImage!, PsConfig.profileImageSize));
        if (_apiStatus.data != null) {
          setState(() {
            widget.userProvider!.user.data = _apiStatus.data;
          });
        }
        PsProgressDialog.dismissDialog();
      }
    }

    final Widget _imageWidget = widget.userProvider!.user.data!.userProfilePhoto != null
        ? PsNetworkImageWithUrl(
      photoKey: '',
      imagePath: widget.userProvider!.user.data!.userProfilePhoto!,
      width: double.infinity,
      height: PsDimens.space200,
      boxfit: BoxFit.cover,
      onTap: () {},
    )
        : InkWell(
      onTap: () {},
      child: Ink(
        child: Image.file(
          File(pickedImage!.path),
          width: PsDimens.space100,
          height: PsDimens.space160,
        ),
      ),
    );

    final Widget _editWidget = Container(
      child: IconButton(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: PsDimens.space2),
        iconSize: PsDimens.space24,
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () async {
          if (await Utils.checkInternetConnectivity()) {
            requestGalleryPermission().then((bool status) async {
              if (status) {
                await _pickImage();
              }
            });
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message:
                    Utils.getString(context, 'error_dialog__no_internet'),
                  );
                });
          }
        },
      ),
      width: PsDimens.space32,
      height: PsDimens.space32,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: PsColors.mainColor),
        color: PsColors.backgroundColor,
        borderRadius: BorderRadius.circular(PsDimens.space28),
      ),
    );

    final Widget _imageInCenterWidget = Positioned(
        top: 110,
        child: Stack(
          children: <Widget>[
            Container(
                width: 90,
                height: 90,
                child: CircleAvatar(
                  child: PsNetworkCircleImageForUser(
                    photoKey: '',
                    imagePath: widget.userProvider!.user.data!.userProfilePhoto,
                    width: double.infinity,
                    height: PsDimens.space200,
                    boxfit: BoxFit.cover,
                    onTap: () async {
                      if (await Utils.checkInternetConnectivity()) {
                        requestGalleryPermission().then((bool status) async {
                          if (status) {
                            await _pickImage();
                          }
                        });
                      } else {
                        showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                message: Utils.getString(
                                    context, 'error_dialog__no_internet'),
                              );
                            });
                      }
                    },
                  ),
                )),
            Positioned(
              top: 1,
              right: 1,
              child: _editWidget,
            ),
          ],
        ));
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: PsDimens.space160,
          child: _imageWidget,
        ),
        Container(
          color: PsColors.white.withAlpha(100),
          width: double.infinity,
          height: PsDimens.space160,
        ),
        Container(
          width: double.infinity,
          height: PsDimens.space220,
        ),
        _imageInCenterWidget,
      ],
    );
  }
}

class _UserFirstCardWidget extends StatelessWidget {
  const _UserFirstCardWidget(
      {required this.userNameController,
        required this.emailController,
        required this.phoneController,
        required this.aboutMeController});
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aboutMeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space16,
          ),
          PsTextFieldWidget(
            isMandatory: true,
              titleText: Utils.getString(context, 'edit_profile__user_name'),
              hintText: Utils.getString(context, 'edit_profile__user_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: userNameController),
          /*PsTextFieldWidget(
              isMandatory: true,
              titleText: Utils.getString(context, 'edit_profile__email'),
              hintText: Utils.getString(context, 'edit_profile__email'),
              textAboutMe: false,
              isEmail: true,
              isPhoneNumber: false,
              textEditingController: emailController),*/
          PsTextFieldWidget(
              isMandatory: true,
              titleText: Utils.getString(context, 'edit_profile__phone'),
              textAboutMe: false,
              isPhoneNumber: true,
              hintText: Utils.getString(context, 'edit_profile__phone'),
              textEditingController: phoneController),
          /* PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__about_me'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              phoneInputType: false,
              hintText: Utils.getString(context, 'edit_profile__about_me'),
              textEditingController: aboutMeController),*/
        ],
      ),
    );
  }
}

class _ShippingAddressCardWidget extends StatefulWidget {
  const _ShippingAddressCardWidget({
    required this.userProvider,
    required this.shippingfirstNameController,
    required this.shippingLastNameController,
    required this.shippingEmailController,
    required this.shippingPhoneController,
    required this.shippingCompanyNameController,
    required this.userAddressController,
    required this.shippingAddress2Controller,
    required this.shippingStateController,
    required this.shippingCountryController,
    required this.shippingCityController,
    required this.shippingPostalCodeController,
  });
  final UserProvider userProvider;
  final TextEditingController shippingfirstNameController;
  final TextEditingController shippingLastNameController;
  final TextEditingController shippingEmailController;
  final TextEditingController shippingPhoneController;
  final TextEditingController shippingCompanyNameController;
  final TextEditingController userAddressController;
  final TextEditingController shippingAddress2Controller;
  final TextEditingController shippingStateController;
  final TextEditingController shippingCountryController;
  final TextEditingController shippingCityController;
  final TextEditingController shippingPostalCodeController;

  @override
  __ShippingAddressCardWidgetState createState() =>
      __ShippingAddressCardWidgetState();
}

class __ShippingAddressCardWidgetState
    extends State<_ShippingAddressCardWidget> {
  String? countryId;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PsColors.backgroundColor,
      padding: const EdgeInsets.only(
          left: PsDimens.space8, right: PsDimens.space8, top: PsDimens.space12),
      margin: const EdgeInsets.only(top: PsDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
                top: PsDimens.space16),
            child: Text(
              Utils.getString(context, 'checkout1__shipping_address'),
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__first_name'),
              hintText: Utils.getString(context, 'edit_profile__first_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingfirstNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__last_name'),
              hintText: Utils.getString(context, 'edit_profile__last_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingLastNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__email'),
              hintText: Utils.getString(context, 'edit_profile__email'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingEmailController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__phone'),
              textAboutMe: false,
              isPhoneNumber: true,
              hintText: Utils.getString(context, 'edit_profile__phone'),
              textEditingController: widget.shippingPhoneController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__company_name'),
              hintText: Utils.getString(context, 'edit_profile__company_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingCompanyNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__address1'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              isPhoneNumber: false,
              hintText: Utils.getString(context, 'edit_profile__address1'),
              textEditingController: widget.userAddressController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__address2'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              isPhoneNumber: false,
              hintText: Utils.getString(context, 'edit_profile__address2'),
              textEditingController: widget.shippingAddress2Controller),
          // PsDropdownBaseWithControllerWidget(
          //     title: Utils.getString(context, 'edit_profile__country_name'),
          //     textEditingController: widget.shippingCountryController,
          //     isStar: true,
          //     onTap: () async {
          //       final dynamic result = await Navigator.pushNamed(context, RoutePaths.countryList);

          //       if (result != null && result is ShippingCountry) {
          //         setState(() {
          //           countryId = result.id;
          //           widget.shippingCountryController.text = result.name;
          //           widget.shippingCityController.text = '';
          //           widget.userProvider.selectedCountry = result;
          //           widget.userProvider.selectedCity = null;
          //         });
          //       }
          //     }),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__state_name'),
              hintText: Utils.getString(context, 'edit_profile__state_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingStateController),
          // PsDropdownBaseWithControllerWidget(
          //     title: Utils.getString(context, 'edit_profile__city_name'),
          //     textEditingController: widget.shippingCityController,
          //     isStar: true,
          //     onTap: () async {
          //       if (widget.shippingCountryController.text.isEmpty) {
          //         showDialog<dynamic>(
          //             context: context,
          //             builder: (BuildContext context) {
          //               return WarningDialog(
          //                 message: Utils.getString(context, 'edit_profile__selected_country'),
          //               );
          //             });
          //       } else {
          //         final dynamic result = await Navigator.pushNamed(context, RoutePaths.cityList,
          //             arguments: countryId ?? widget.userProvider.user.data.country.id);

          //         if (result != null && result is ShippingCity) {
          //           setState(() {
          //             widget.shippingCityController.text = result.name;
          //             widget.userProvider.selectedCity = result;
          //           });
          //         }
          //       }
          //     }),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__postal_code'),
              hintText: Utils.getString(context, 'edit_profile__postal_code'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingPostalCodeController),
          const SizedBox(
            height: PsDimens.space12,
          )
        ],
      ),
    );
  }
}

class _BillingAddressCardWidget extends StatefulWidget {
  const _BillingAddressCardWidget({
    required this.billingfirstNameController,
    required this.billingLastNameController,
    required this.billingEmailController,
    required this.billingPhoneController,
    required this.billingCompanyNameController,
    required this.billingAddress1Controller,
    required this.billingAddress2Controller,
    required this.billingStateController,
    required this.shippingAreaController,
    required this.billingCityNameController,
    required this.userProvider,
  });
  final TextEditingController billingfirstNameController;
  final TextEditingController billingLastNameController;
  final TextEditingController billingEmailController;
  final TextEditingController billingPhoneController;
  final TextEditingController billingCompanyNameController;
  final TextEditingController billingAddress1Controller;
  final TextEditingController billingAddress2Controller;
  final TextEditingController billingStateController;
  final TextEditingController shippingAreaController;
  final TextEditingController billingCityNameController;
  final UserProvider userProvider;

  @override
  __BillingAddressCardWidgetState createState() =>
      __BillingAddressCardWidgetState();
}

class __BillingAddressCardWidgetState extends State<_BillingAddressCardWidget> {
  String? countryId;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PsColors.backgroundColor,
      margin: const EdgeInsets.only(top: PsDimens.space12),
      padding: const EdgeInsets.only(
        left: PsDimens.space8,
        right: PsDimens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
                top: PsDimens.space16),
            child: Text(
              Utils.getString(context, 'checkout1__billing_address'),
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__first_name'),
              hintText: Utils.getString(context, 'edit_profile__first_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.billingfirstNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__last_name'),
              hintText: Utils.getString(context, 'edit_profile__last_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.billingLastNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__email'),
              hintText: Utils.getString(context, 'edit_profile__email'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.billingEmailController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__phone'),
              textAboutMe: false,
              isPhoneNumber: true,
              hintText: Utils.getString(context, 'edit_profile__phone'),
              textEditingController: widget.billingPhoneController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__company_name'),
              hintText: Utils.getString(context, 'edit_profile__company_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.billingCompanyNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__address1'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              isPhoneNumber: false,
              hintText: Utils.getString(context, 'edit_profile__address1'),
              textEditingController: widget.billingAddress1Controller),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__address2'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              isPhoneNumber: false,
              hintText: Utils.getString(context, 'edit_profile__address2'),
              textEditingController: widget.billingAddress2Controller),
          // PsDropdownBaseWidget(
          //     title: Utils.getString(context, 'edit_profile__country_name'),
          //     selectedText: widget.userProvider.user.data.billingCountry,
          //     onTap: () async {
          //       final dynamic result = await Navigator.pushNamed(context, RoutePaths.countryList);

          //       if (result != null && result is ShippingCountry) {
          //         setState(() {
          //           countryId = result.id;
          //           widget.userProvider.user.data.billingCountry = result.name;
          //           widget.userProvider.user.data.billingCity = '';
          //         });
          //       }
          //     }),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__state_name'),
              hintText: Utils.getString(context, 'edit_profile__state_name'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.billingStateController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__postal_code'),
              hintText: Utils.getString(context, 'edit_profile__postal_code'),
              textAboutMe: false,
              isPhoneNumber: false,
              textEditingController: widget.shippingAreaController),
        ],
      ),
    );
  }
}
