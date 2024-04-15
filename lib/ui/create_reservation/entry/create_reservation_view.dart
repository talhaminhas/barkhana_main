import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/reservation/create_reservation_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/create_reservation_repository.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/success_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_dropdown_base_with_controller_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_textfield_widget.dart';
import 'package:flutterrestaurant/ui/create_reservation/list/reservation_list_view.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/api_status.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/create_reservation_holder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../config/ps_colors.dart';
import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../repository/shop_info_repository.dart';

class CreateReservationView extends StatefulWidget {
  const CreateReservationView({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _CreateReservationViewState createState() => _CreateReservationViewState();
}

class _CreateReservationViewState extends State<CreateReservationView> {
  ReservationRepository? reservationRepository;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController noOfPeopleController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();
  final TextEditingController reservationDateController =
      TextEditingController();
  final TextEditingController reservationTimeController =
      TextEditingController();
  final TextEditingController userNoteController = TextEditingController();
  ShopInfoProvider? shopInfoProvider;
  ShopInfoRepository? shopInfoRepository;
  String timePeriod = '';
  TimeOfDay? timePicked;
  DateTime? todayTime;
  DateTime? dateTime;
  PsValueHolder? psValueHolder;
  bool bindDataFirstTime = true;
  UserRepository? userRepository;
  CreateReservationProvider? reservationProvider;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    widget.animationController.forward();
    reservationRepository = Provider.of<ReservationRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    userRepository = Provider.of<UserRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    const Widget _largeSpacingWidget = SizedBox(
      height: PsDimens.space40,
    );

    void bindingTime(TimeOfDay todayTime, TimeOfDay timePicked) {
      setState(() {

      });
      // Determine AM or PM
      if (timePicked.period == DayPeriod.am) {
        timePeriod = 'AM';
      } else {
        timePeriod = 'PM';
      }

      // Convert hour to 24-hour format
      int hourIn24HourFormat = timePicked.hour;

      // Format minute to always have two digits
      final String minute = timePicked.minute.toString().padLeft(2, '0');

      // Build the formatted time string in 24-hour format
      reservationTimeController.text = '$hourIn24HourFormat : $minute';
    }



    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ShopInfoProvider>(
            lazy: false,
            create: (BuildContext context) {
              shopInfoProvider = ShopInfoProvider(
                  repo: shopInfoRepository!,
                  psValueHolder: psValueHolder,
                  ownerCode: 'CheckoutContainerView');
              shopInfoProvider!.loadShopInfo();

              return shopInfoProvider!;
            }),
        ChangeNotifierProvider<CreateReservationProvider>(
          lazy: false,
          create: (BuildContext context) {
            reservationProvider = CreateReservationProvider(
                repo: reservationRepository!, psValueHolder: psValueHolder);

            return reservationProvider!;
          },
        ),
        ChangeNotifierProvider<UserProvider>(
          lazy: false,
          create: (BuildContext context) {
            final UserProvider provider = UserProvider(
                repo: userRepository!, psValueHolder: psValueHolder!);
            provider.getUser(provider.psValueHolder.loginUserId!);
            return provider;
          },
        ),
      ],
      child: Consumer<UserProvider>(builder:
          (BuildContext context, UserProvider userProvider, Widget? child) {
        if (
          // userProvider != null &&
          //   userProvider.user != null &&
            userProvider.user.data != null) {
          if (bindDataFirstTime) {
            userNameController.text = userProvider.user.data!.userName!;
            userEmailController.text = userProvider.user.data!.userEmail!;
            userPhoneController.text = userProvider.user.data!.userPhone!;
            bindDataFirstTime = false;
          }
          return AnimatedBuilder(
              animation: widget.animationController,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(PsDimens.space8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PsDropdownBaseWithControllerWidget(
                                title: Utils.getString(
                                    context, 'create_reservation__reservation_date'),
                                textEditingController: reservationDateController,
                                isMandatory: true,
                                onTap: () async {
                                  final DateTime today = DateTime.now();
                                  //Utils.psPrint('Today is ' + today.toString());
                                  dateTime = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: today,
                                      lastDate: DateTime(2025),

                                  );

                                  if (dateTime != null) {
                                    reservationProvider!.reservationDate =
                                        DateFormat('yyyy-MM-dd').format(dateTime!);

                                    //Utils.psPrint('Today Date format is ' + reservationProvider!.reservationDate!);
                                  }
                                  setState(() {
                                    reservationDateController.text =
                                    reservationProvider!.reservationDate!;
                                    reservationTimeController.text = '';
                                  });
                                }),
                            PsDropdownBaseWithControllerWidget(
                                title: Utils.getString(
                                    context, 'create_reservation__reservation_time'),
                                textEditingController: reservationTimeController,
                                isMandatory: true,
                                onTap: () async {
                                  final TimeOfDay todayTime = TimeOfDay.now();
                                  if (
                                  //reservationDateController.text == null ||
                                  reservationDateController.text == '') {
                                    showDialog<dynamic>(
                                        context: context,
                                        barrierColor: PsColors.transparent,
                                        builder: (BuildContext context) {
                                          return WarningDialog(
                                            message: Utils.getString(context,
                                                'create_reservation__warning_reservation_date'),
                                            onPressed: () {},
                                          );
                                        });
                                  } else {
                                    if (dateTime!.day == DateTime.now().day) {
                                      final TimeOfDay todayTime = TimeOfDay.now();

                                      timePicked = await
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context, Widget? child) {
                                          return MediaQuery(
                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (timePicked!.hour < TimeOfDay.now().hour ||
                                          (timePicked!.hour <= TimeOfDay.now().hour &&
                                              timePicked!.minute <
                                                  TimeOfDay.now().minute)) {
                                        setState(() {
                                          reservationTimeController.text = '';
                                        });
                                        showDialog<dynamic>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ErrorDialog(
                                                message: Utils.getString(context,
                                                    'create_reservation__error_selected_time'),
                                              );
                                            });
                                      } else {
                                        bindingTime(todayTime, timePicked!);
                                      }
                                    } else {
                                      timePicked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context, Widget? child) {
                                          return MediaQuery(
                                            data: MediaQuery.of(context)
                                                .copyWith(alwaysUse24HourFormat:false),
                                            child: child!,
                                          );
                                        },
                                      );
                                        bindingTime(todayTime, timePicked!);

                                    }
                                  }
                                }),
                            PsDropdownBaseWithControllerWidget(
                                title: 'Number Of People',
                                textEditingController: noOfPeopleController,
                                isMandatory: true,
                              onTap: () async {
                                await showDialog(
                                  barrierColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext context) {
                                    int selectedNumber = int.tryParse(noOfPeopleController.text) ?? 1;
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      content: Container(
                                        width: 150,
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: 50,
                                          itemBuilder: (BuildContext context, int index) {
                                            final int number = index + 1;
                                            return ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0), ),
                                              title: Center(child: Text('$number',
                                                style: TextStyle(
                                                  color: selectedNumber == number ? PsColors.white : PsColors.mainColor, // Set text color conditionally
                                                ),
                                              )), // Set text color to white
                                              onTap: () {
                                                setState(() {
                                                  selectedNumber = number;
                                                  noOfPeopleController.text = '$selectedNumber';
                                                  Navigator.pop(context);
                                                });
                                              },
                                              tileColor: selectedNumber == number
                                                  ? PsColors.mainColor // Highlight selected number
                                                  : PsColors.white,
                                            );
                                          },
                                        ),
                                      ),
                                    );

                                  },
                                );
                              },

                            ),
                            PsTextFieldWidget(
                                titleText: Utils.getString(
                                    context, 'create_reservation__user_name'),
                                textAboutMe: false,
                                hintText: Utils.getString(
                                    context, 'create_reservation__user_name_hint'),
                                textEditingController: userNameController,
                                isMandatory: true),
                            PsTextFieldWidget(
                                titleText: Utils.getString(
                                    context, 'create_reservation__user_email'),
                                textAboutMe: false,
                                hintText: Utils.getString(
                                    context, 'create_reservation__user_email_hint'),
                                textEditingController: userEmailController),
                            PsTextFieldWidget(
                                titleText: Utils.getString(
                                    context, 'create_reservation__user_phone'),
                                textAboutMe: false,
                                hintText: Utils.getString(
                                  context,
                                  'create_reservation__user_phone_hint',
                                ),
                                keyboardType: TextInputType.phone,
                                isPhoneNumber: true,
                                textEditingController: userPhoneController,
                                isMandatory: true),
                            PsTextFieldWidget(
                                titleText: Utils.getString(
                                    context, 'create_reservation__user_note'),
                                textAboutMe: false,
                                height: PsDimens.space160,
                                hintText: Utils.getString(
                                    context, 'create_reservation__user_note_hint'),
                                textEditingController: userNoteController),
                            _largeSpacingWidget,
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 10, right: 20, left: 20,
                      child: PsButtonWidget(
                        provider: reservationProvider!,
                        userProvider: userProvider,
                        userNameTextController: userNameController,
                        userEmailTextController: userEmailController,
                        userPhoneTextController: userPhoneController,
                        userNoteTextController: userNoteController,
                        reservationDateController: reservationDateController,
                        reservationTimeController: reservationTimeController,
                        noOfPeopleController: noOfPeopleController,
                        shopInfoProvider : shopInfoProvider,
                      ),
                  ),
                ],
              ),
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                    opacity: animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: child,
                    ));
              });
        } else {
          return Container();
        }
      }),
    );
  }
}

class PsButtonWidget extends StatelessWidget {
  const PsButtonWidget(
      {required this.userNameTextController,
      required this.userEmailTextController,
      required this.userPhoneTextController,
      required this.userNoteTextController,
      required this.reservationDateController,
      required this.reservationTimeController,
      required this.provider,
      required this.userProvider,
        required this.noOfPeopleController,
        required this.shopInfoProvider});

  final TextEditingController userNameTextController,
      userEmailTextController,
      userPhoneTextController,
      userNoteTextController,
      reservationDateController,
      reservationTimeController,
      noOfPeopleController;
  final CreateReservationProvider provider;
  final UserProvider userProvider;
  final ShopInfoProvider? shopInfoProvider;

  bool isTimeInRange(String timeString, String startTime, String endTime) {
    final DateTime time = DateFormat('HH : mm').parse(timeString);
    final DateTime start = DateFormat('HH:mm').parse(startTime);
    final DateTime end = DateFormat('HH:mm').parse(endTime);

    return time.isAfter(start) && time.isBefore(end);
  }
  bool isValidTime(String dateString, String timeString) {
    final DateTime dateTime = DateFormat('yyyy-MM-dd').parse(dateString);;
    switch (dateTime.weekday) {
      case 1:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isMondayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.mondayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.mondayCloseHour!
          );
        else {
          return false;
        }
      case 2:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isTuesdayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.tuesdayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.tuesdayCloseHour!
          );
        else {
          return false;
        }
      case 3:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isWednesdayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.wednesdayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.wednesdayCloseHour!
          );
        else {
          return false;
        }
      case 4:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isThursdayOpen! == '1')
          return isTimeInRange(
            timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.thursdayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.thursdayCloseHour!
          );
        else {
          return false;
        }
      case 5:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isFridayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.fridayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.fridayCloseHour!
          );
        else {
          return false;
        }
      case 6:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isSaturdayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.saturdayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.saturdayCloseHour!
          );
        else {
          return false;
        }
      case 7:
        if(shopInfoProvider!.shopInfo.data!.shopSchedules!.isSundayOpen! == '1')
          return isTimeInRange(
              timeString,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.sundayOpenHour!,
              shopInfoProvider!.shopInfo.data!.shopSchedules!.sundayCloseHour!
          );
        else {
          return false;
        }
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);
    return PSButtonWidget(
        hasShadow: true,
        width: double.infinity,
        titleText: Utils.getString(context, 'contact_us__submit'),
        onPressed: () async {
          if (provider.reservationDate == null) {

            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(context,
                        'create_reservation__warning_reservation_date'),
                    onPressed: () {},
                  );
                });
          } else if (
              reservationTimeController.text == '') {

            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(context,
                        'create_reservation__warning_reservation_time'),
                    onPressed: () {},
                  );
                });
          }  else if (
          noOfPeopleController.text == '') {
            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: 'Please Select Number Of People',
                    onPressed: () {},
                  );
                });
          } else if (userNameTextController.text == ''
          //||
              //userNameTextController.text == null
              ) {
            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(
                        context, 'create_reservation__warning_user_name'),
                    onPressed: () {},
                  );
                });
          } else if (userPhoneTextController.text == '' 
          //||
             // userPhoneTextController.text == null
              ) {
            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(
                        context, 'create_reservation__warning_user_phone'),
                    onPressed: () {},
                  );
                });
          }
          else if(!isValidTime(provider.reservationDate!, reservationTimeController.text)){
            showDialog<dynamic>(
                context: context,
                barrierColor: PsColors.transparent,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: 'Shop Is Closed At Selected Time.',
                    onPressed: () {},
                  );
                });
          }
          else {
            if (await Utils.checkInternetConnectivity()) {
              final ReservationParameterHolder reservationParameterHolder =
                  ReservationParameterHolder(
                      reservationDate: provider.reservationDate!,
                      reservationTime: reservationTimeController.text,
                      // reservationDate: '23/5/2020',
                      // reservationTime: '12:00',
                      userNote: userNoteTextController.text,
                      shopId: psValueHolder.shopId!,
                      userId: psValueHolder.loginUserId!,
                      userEmail: userProvider.user.data!.userEmail!,
                      userPhoneNumber: userProvider.user.data!.userPhone!,
                      userName: userProvider.user.data!.userName!,
                      noOfPeople: noOfPeopleController.text!,
                  );

              await PsProgressDialog.showDialog(context);
              final PsResource<ApiStatus> _apiStatus = await provider
                  .postReservation(reservationParameterHolder.toMap());

              if (_apiStatus.data != null) {
                PsProgressDialog.dismissDialog();
                Navigator.pop(context);
                reservationListRefreshKey.currentState?.show();
                showDialog<dynamic>(
                  barrierColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      if (_apiStatus.data!.status == 'success') {
                        return const SuccessDialog(
                          message: 'Reservation Request Has Been Submitted',
                        );
                      } else {
                        return ErrorDialog(
                          message: _apiStatus.data!.status,
                        );
                      }
                    });
              }
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
          }
        });
  }
}
