// ignore_for_file: unnecessary_null_comparison

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';
import '../../../config/ps_colors.dart';
import '../../../constant/ps_constants.dart';
import '../../../constant/ps_dimens.dart';
import '../../../provider/shop_info/shop_info_provider.dart';
import '../../../provider/user/user_provider.dart';
import '../../../utils/utils.dart';
import '../../../viewobject/common/ps_value_holder.dart';
import '../../../viewobject/holder/order_time_callback_holder.dart';
import '../../common/dialog/error_dialog.dart';
import '../../common/ps_button_widget.dart';

class OrderTimeView extends StatefulWidget {
  const OrderTimeView({
    Key? key,
    required this.userProvider,
    required this.shopInfoProvider,
  }) : super(key: key);

  final UserProvider? userProvider;
  final ShopInfoProvider shopInfoProvider;

  @override
  __OrderTimeViewState createState() => __OrderTimeViewState();
}

class __OrderTimeViewState extends State<OrderTimeView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController orderTimeTextEditingController =
      TextEditingController();
  TextEditingController firstTimeOrderController = TextEditingController();
  TextEditingController secondTimeOrderController = TextEditingController();
  PsValueHolder? psValueHolder;
  String? deliveryPickUpDate;
  String? deliveryPickUpTime;
  DateTime now = DateTime.now();
  String latestDate = '';
  int? hour, minute;
  String? days;
  int? monOpenHour, monCloseHour, monOpenMin, monCloseMin;
  int? tuesOpenHour, tuesCloseHour, tuesOpenMin, tuesCloseMin;
  int? wedOpenHour, wedCloseHour, wedOpenMin, wedCloseMin;
  int? thursOpenHour, thursCloseHour, thursOpenMin, thursCloseMin;
  int? friOpenHour, friCloseHour, friOpenMin, friCloseMin;
  int? satOpenHour, satCloseHour, satOpenMin, satCloseMin;
  int? sunOpenHour, sunCloseHour, sunOpenMin, sunCloseMin;
  bool? isWeekly, isOneTime;
  TextEditingController selectedDateTime = TextEditingController();


  // ? Remove comment for Schedule Order
  /* late List<ScheduleOrder> scheduleOrder;

  List<String> getSelectedDayAndTime() {
    final List<String> weekDayList = <String>[];
    final List<String> selectedTimeList = <String>[];
    final List<String> scheduleList = <String>[];
    for (ScheduleOrder schedule in scheduleOrder) {
      if (schedule.isActive) {
        weekDayList.add(schedule.weekDay);
        selectedTimeList.add(schedule.selectedTime!);
      }
    }
    final String weekDays = weekDayList.join(',');
    final String selectedTimes = selectedTimeList.join(',');

    scheduleList.addAll(<String>[weekDays, selectedTimes]);
    return scheduleList;
  }
  */


  dynamic resetOrderTime() {
    widget.userProvider!.isClickWeeklyButton = isWeekly!;
    widget.userProvider!.isClickOneTimeButton = isOneTime!;
    setState(() {});
  }

  dynamic currentDateTimeSetUp() {
    final DateTime dateTime = DateTime.now()
        .add(Duration(minutes: int.parse(psValueHolder!.defaultOrderTime!)));
    deliveryPickUpDate =  DateFormat.yMMMEd('en_US').format(dateTime);

    deliveryPickUpTime = DateFormat.Hm('en_US').format(dateTime);

    orderTimeTextEditingController.text =
        deliveryPickUpDate! + ' ' + deliveryPickUpTime!;
  }

  // ? Remove comment for Schedule Order
  /* dynamic weeklyScheduleSetUp(BuildContext context) {
    final List<ScheduleOrder> list = <ScheduleOrder>[
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_monday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_tuesday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_wednesday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_thursday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_friday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_saturday'),
          isActive: false,
          selectedTime: null),
      ScheduleOrder(
          weekDay: Utils.getString(context, 'schedule_order_weekday_sunday'),
          isActive: false,
          selectedTime: null),
    ];
    scheduleOrder = list;
  }
  */
  dynamic updateOneTimeClick() {
    if (widget.userProvider!.isClickOneTimeButton) {
      widget.userProvider!.isClickOneTimeButton = false;
      widget.userProvider!.isClickWeeklyButton = true;
    } else {
      widget.userProvider!.isClickOneTimeButton = true;
      widget.userProvider!.isClickWeeklyButton = false;
    }
    setState(() {});
  }

  dynamic updateWeeklyClick() {
    widget.userProvider!.selectedRadioBtnName =
        PsConst.ORDER_TIME_WEEKLY_SCHEDULE;

    if (widget.userProvider!.isClickWeeklyButton) {
      widget.userProvider!.isClickWeeklyButton = false;
      widget.userProvider!.isClickOneTimeButton = true;
    } else {
      widget.userProvider!.isClickWeeklyButton = true;
      widget.userProvider!.isClickOneTimeButton = false;
    }
    setState(() {});
  }

  dynamic updateOrderByData(String filterName) {
    setState(() {
      widget.userProvider!.selectedRadioBtnName = filterName;
    });
  }

  dynamic updatDateAndTime(DateTime dateTime) {
    // setState(() {});
    latestDate = '$dateTime';
    deliveryPickUpDate =
        DateFormat.yMMMEd('en_US').format(dateTime);

    deliveryPickUpTime =  DateFormat.Hm('en_US').format(dateTime);

    orderTimeTextEditingController.text =
        deliveryPickUpDate! + ' ' + deliveryPickUpTime!;
    if(!widget.userProvider!.isClickWeeklyButton){
      openAndCloseTime(widget.shopInfoProvider);
    }      

  }

  dynamic backToCheckout() {
    if (widget.userProvider!.selectedRadioBtnName == PsConst.ORDER_TIME_ASAP &&
        widget.userProvider!.isClickOneTimeButton) {
      if (firstTimeOrderController.text.isEmpty) {
        firstTimeOrderController.text =
            Utils.getString(context, 'checkout1__asap') +
                ' (' +
                psValueHolder!.defaultOrderTime! +
                'mins)';
      }
      Navigator.pop(
          context,
          OrderTimeCallBackHolder(
              firstOrderTime: firstTimeOrderController.text,
              secondOrderTime: secondTimeOrderController.text));
    } else if (widget.userProvider!.selectedRadioBtnName ==
            PsConst.ORDER_TIME_SCHEDULE &&
        widget.userProvider!.isClickOneTimeButton &&
        orderTimeTextEditingController.text.isNotEmpty) {
      Navigator.pop(
          context,
          OrderTimeCallBackHolder(
              firstOrderTime: orderTimeTextEditingController.text,
              secondOrderTime: secondTimeOrderController.text,
              selectedDateTime: selectedDateTime.text,
              ));
    }/* else if (widget.userProvider!.selectedRadioBtnName ==
            PsConst.ORDER_TIME_WEEKLY_SCHEDULE &&
        widget.userProvider!.isClickWeeklyButton) {
      Navigator.pop(
          context,
          OrderTimeCallBackHolder(
              firstOrderTime: getSelectedDayAndTime()[0],
              secondOrderTime: secondTimeOrderController.text,
              selectedTimes: getSelectedDayAndTime()[1]));
    }
    */
  }

 dynamic openAndCloseTime(ShopInfoProvider shopInfoProvider) {
    // Open Time
    final String? mondayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.mondayOpenHour!;
    final String ?tuesdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.tuesdayOpenHour!;
    final String? wednesdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.wednesdayOpenHour!;
    final String? thursdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.thursdayOpenHour!;
    final String? fridayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.fridayOpenHour!;
    final String? saturdayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.saturdayOpenHour!;
    final String? sundayOpenDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.sundayOpenHour!;

    if (mondayOpenDateAndTime != null && mondayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          mondayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String> ?openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          monOpenHour = int.parse(openHourArray[0]);
          print(monOpenHour);
          monOpenMin = int.parse(openHourArray[1]);
          print(monOpenMin);
        }
      }
    }
    if (tuesdayOpenDateAndTime != null && tuesdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          tuesdayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          tuesOpenHour = int.parse(openHourArray[0]);
          tuesOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (wednesdayOpenDateAndTime != null && wednesdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          wednesdayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          wedOpenHour = int.parse(openHourArray[0]);
          wedOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (thursdayOpenDateAndTime != null && thursdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          thursdayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String> ?openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          thursOpenHour = int.parse(openHourArray[0]);
          thursOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (fridayOpenDateAndTime != null && fridayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          fridayOpenDateAndTime.split(' ');

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          friOpenHour = int.parse(openHourArray[0]);
          friOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (saturdayOpenDateAndTime != null && saturdayOpenDateAndTime != '') {
      final List<String>? openDateAndTimeArray =
          saturdayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          satOpenHour = int.parse(openHourArray[0]);
          satOpenMin = int.parse(openHourArray[1]);
        }
      }
    }
    if (sundayOpenDateAndTime != null && sundayOpenDateAndTime != '') {
      final List<String> ?openDateAndTimeArray =
          sundayOpenDateAndTime.split(' ');
      print(openDateAndTimeArray);

      if (openDateAndTimeArray != null &&
          openDateAndTimeArray[0].contains(':')) {
        final List<String>? openHourArray = openDateAndTimeArray[0].split(':');

        if (openHourArray != null && openHourArray.isNotEmpty) {
          sunOpenHour = int.parse(openHourArray[0]);
          sunOpenMin = int.parse(openHourArray[1]);
        }
      }
    }

    // Close Time
    final String? mondayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.mondayCloseHour;
    final String? tuesdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.tuesdayCloseHour;
    final String? wednesdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.wednesdayCloseHour;
    final String ?thursdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.thursdayCloseHour;
    final String? fridayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.fridayCloseHour;
    final String? saturdayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.saturdayCloseHour;
    final String? sundayCloseDateAndTime =
        shopInfoProvider.shopInfo.data!.shopSchedules!.sundayCloseHour;

    if (mondayCloseDateAndTime != null && mondayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          mondayCloseDateAndTime.split(' ');
      print(closeDateAndTimeArray);

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          monCloseHour = int.parse(closeHourArray[0]);
          print(monCloseHour);
          monCloseMin = int.parse(closeHourArray[1]);
          print(monCloseMin);
        }
      }
    }
    if (tuesdayCloseDateAndTime != null && tuesdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          tuesdayCloseDateAndTime.split(' ');
      print(closeDateAndTimeArray);

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          tuesCloseHour = int.parse(closeHourArray[0]);
          tuesCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (wednesdayCloseDateAndTime != null && wednesdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          wednesdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String> ?closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          wedCloseHour = int.parse(closeHourArray[0]);
          wedCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (thursdayCloseDateAndTime != null && thursdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          thursdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          thursCloseHour = int.parse(closeHourArray[0]);
          thursCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (fridayCloseDateAndTime != null && fridayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          fridayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          friCloseHour = int.parse(closeHourArray[0]);
          friCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (saturdayCloseDateAndTime != null && saturdayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          saturdayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          satCloseHour = int.parse(closeHourArray[0]);
          satCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }
    if (sundayCloseDateAndTime != null && sundayCloseDateAndTime != '') {
      final List<String>? closeDateAndTimeArray =
          sundayCloseDateAndTime.split(' ');

      if (closeDateAndTimeArray != null &&
          closeDateAndTimeArray[0].contains(':')) {
        final List<String>? closeHourArray = closeDateAndTimeArray[0].split(':');

        if (closeHourArray != null && closeHourArray.isNotEmpty) {
          sunCloseHour = int.parse(closeHourArray[0]);
          sunCloseMin = int.parse(closeHourArray[1]);
        }
      }
    }

    final String? orderDateAndTime = orderTimeTextEditingController.text;

    //Split Date and Time
    if (orderDateAndTime != null &&
        orderDateAndTime != '' &&
        orderDateAndTime.contains(' ')) {
      final List<String>? orderDateAndTimeArray = orderDateAndTime.split(' ');
      final String orderDays = orderDateAndTimeArray![0];
      final List<String> ordererDayArray = orderDays.split(',');
      days = ordererDayArray[0];
      print(days);

      if (orderDateAndTimeArray.length > 4 &&
          orderDateAndTimeArray[4] != '' &&
          orderDateAndTimeArray[4].contains(':')) {
        final List<String> orderTimeArray = orderDateAndTimeArray[4].split(':');

        if (orderTimeArray.isNotEmpty &&
            orderTimeArray[0] != '' &&
            orderTimeArray[1] != '') {
          hour = int.parse(orderTimeArray[0]);
          minute = int.parse(orderTimeArray[1]);
          print(minute);
        }
      }
    }
    if (days == 'Mon') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isMondayOpen ==
          PsConst.ONE) {
        if (((hour! > monOpenHour!) ||
                (hour == monOpenHour && minute! >= monOpenMin!)) &&
            ((hour! < monCloseHour!) ||
                (hour == monCloseHour && minute! <= monCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Tue') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isTuesdayOpen ==
          PsConst.ONE) {
        if (((hour! > tuesOpenHour!) ||
                (hour == tuesOpenHour && minute! >= tuesOpenMin!)) &&
            ((hour! < tuesCloseHour!) ||
                (hour == tuesCloseHour && minute! <= tuesCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Wed') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isWednesdayOpen ==
          PsConst.ONE) {
        if (((hour! > wedOpenHour!) ||
                (hour == wedOpenHour && minute! >= wedOpenMin!)) &&
            ((hour! < wedCloseHour!) ||
                (hour == wedCloseHour && minute! <= wedCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Thu') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isThursdayOpen ==
          PsConst.ONE) {
        if (((hour! > thursOpenHour!) ||
                (hour == thursOpenHour && minute! >= thursOpenMin!)) &&
            ((hour! < thursCloseHour!) ||
                (hour == thursCloseHour && minute! <= thursCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Fri') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isFridayOpen ==
          PsConst.ONE) {
        if (((hour! > friOpenHour!) ||
                (hour == friOpenHour && minute! >= friOpenMin!)) &&
            ((hour! < friCloseHour!) ||
                (hour == friCloseHour && minute! <= friCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Sat') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isSaturdayOpen ==
          PsConst.ONE) {
        if (((hour! > satOpenHour!) ||
                (hour == satOpenHour && minute! >= satOpenMin!)) &&
            ((hour! < satCloseHour!) ||
                (hour == satCloseHour && minute! <= satCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    } else if (days == 'Sun') {
      if (shopInfoProvider.shopInfo.data!.shopSchedules!.isSundayOpen ==
          PsConst.ONE) {
        if (((hour! > satOpenHour!) ||
                (hour == satOpenHour && minute! >= satOpenMin!)) &&
            ((hour! < satCloseHour!) ||
                (hour == satCloseHour && minute! <= satCloseMin!))) {
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__delivery_order_time'),
                );
              });
        }
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(
                    context, 'warning_dialog__delivery_order_time'),
              );
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isWeekly = widget.userProvider!.isClickWeeklyButton;
    isOneTime = widget.userProvider!.isClickOneTimeButton;
  }

  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);

    if (widget.userProvider!.isClickOneTimeButton) {
      secondTimeOrderController.text =
          Utils.getString(context, 'checkout_one_page__one_time_order');
    }
    if (widget.userProvider!.isClickWeeklyButton) {
      secondTimeOrderController.text =
          Utils.getString(context, 'checkout_one_page__weekly_order');
    }
    currentDateTimeSetUp();

    // ? Remove comment for Schedule Order
    // weeklyScheduleSetUp(context);

    if (widget.userProvider?.user != null &&
        widget.userProvider?.user.data != null) {
      return WillPopScope(
        onWillPop: () async {
          resetOrderTime();
          return true;
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: PsColors.coreBackgroundColor,
          appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      Utils.getBrightnessForAppBar(context)),
              iconTheme: Theme.of(context).iconTheme.copyWith(),
              title: Text(
                '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              elevation: 0,
              actions: <Widget>[
                InkWell(
                  child: Ink(
                    child: Center(
                      child: Text(
                        Utils.getString(context, 'checkout_one_page__done'),
                        textAlign: TextAlign.justify,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            !.copyWith(fontWeight: FontWeight.bold)
                            .copyWith(color: PsColors.mainColor),
                      ),
                    ),
                  ),
                  onTap: () {
                    if(!widget.userProvider!.isClickWeeklyButton){
                      openAndCloseTime(widget.shopInfoProvider);
                    }
                    if (orderTimeTextEditingController.text.isEmpty &&
                        widget.userProvider!.isClickOneTimeButton &&
                        widget.userProvider!.selectedRadioBtnName !=
                            PsConst.ORDER_TIME_ASAP) {
                      showDialog<dynamic>(
                          context: context,
                          builder: (BuildContext context) {
                            return ErrorDialog(
                              message: Utils.getString(
                                  context, 'schedule_order_select_order_time'),
                            );
                          });
                  
                    } 
                    //? Remove comment for Scehdule Order
                    /* else if (widget.userProvider!.isClickWeeklyButton) {
                      final String weekDays = getSelectedDayAndTime()[0];
                      if (weekDays.isEmpty || weekDays == '') {
                        showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                message: Utils.getString(context,
                                    'schedule_order_select_order_day_and_time'),
                              );
                            });
                      } else {
                        backToCheckout();
                      }
                    } */
                    else {
                      backToCheckout();
                    }
                  },
                ),
                const SizedBox(
                  width: PsDimens.space16,
                ),
              ]),
          body: SingleChildScrollView(
              child: Container(
            color: PsColors.coreBackgroundColor,
            padding: const EdgeInsets.only(
                left: PsDimens.space16, right: PsDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: PsDimens.space8,
                ),
                Text(
                  Utils.getString(context, 'order_time__order_for'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: PsDimens.space8,
                ),
                _EditAndDeleteButtonWidget(
                    userProvider: widget.userProvider!,
                    shopInfoProvider: widget.shopInfoProvider,
                    updateOneTimeClick: updateOneTimeClick,
                    updateWeeklyClick: updateWeeklyClick,
                    isClickOneTimeButton:
                        widget.userProvider!.isClickOneTimeButton,
                    isClickWeeklyButton:
                        widget.userProvider!.isClickWeeklyButton),
                const SizedBox(height: PsDimens.space8),
                //? Remove comment for Scehdule Order
                // if (widget.userProvider!.isClickOneTimeButton)
                  RadioWidget(
                    userProvider: widget.userProvider!,
                    updateOrderByData: updateOrderByData,
                    orderTimeTextEditingController:
                        orderTimeTextEditingController,
                    updatDateAndTime: updatDateAndTime,
                    latestDate: latestDate,
                    firstTimeOrderController: firstTimeOrderController,
                    selectedDateTime: selectedDateTime,

                  )

                //? Remove comment for Scehdule Order
                // else
                /*
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: PsDimens.space10),
                              child: Text(Utils.getString(
                                  context, 'order_time__set_day_and_time')),
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(AntDesign.calendar),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: PsDimens.space8,
                                      left: PsDimens.space8),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        RoutePaths.scheduleOrder,
                                        arguments:
                                            widget.userProvider!.user.data,
                                      );
                                    },
                                    child: Text(
                                      Utils.getString(context,
                                          'checkout1__view_my_schedule'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          !.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: PsColors.mainColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      WeeklyOrderTimeList(
                        scheduleOrder: scheduleOrder,
                      ),
                    ],
                  ),
                      */
              ],
            ),
          )),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _EditAndDeleteButtonWidget extends StatefulWidget {
  const _EditAndDeleteButtonWidget(
      {Key? key,
      required this.userProvider,
      required this.shopInfoProvider,
      required this.isClickWeeklyButton,
      required this.isClickOneTimeButton,
      required this.updateOneTimeClick,
      required this.updateWeeklyClick})
      : super(key: key);

  final UserProvider userProvider;
  final ShopInfoProvider shopInfoProvider;
  final bool isClickOneTimeButton;
  final bool isClickWeeklyButton;
  final Function updateOneTimeClick;
  final Function updateWeeklyClick;
  @override
  __EditAndDeleteButtonWidgetState createState() =>
      __EditAndDeleteButtonWidgetState();
}

class __EditAndDeleteButtonWidgetState
    extends State<_EditAndDeleteButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: PsDimens.space12),
          SizedBox(
            width: double.infinity,
            height: PsDimens.space40,
            child: Container(
              decoration: BoxDecoration(
                color: PsColors.backgroundColor,
                border: Border.all(color: PsColors.backgroundColor),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(PsDimens.space12),
                    topRight: Radius.circular(PsDimens.space12)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: PsColors.backgroundColor,
                    blurRadius: 10.0, // has the effect of softening the shadow
                    spreadRadius: 0, // has the effect of extending the shadow
                    offset: const Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: PSButtonWidget(
                      hasShadow: true,
                      hasShape: false,
                      textColor: widget.isClickOneTimeButton
                          ? PsColors.white
                          : PsColors.black,
                      width: double.infinity,
                      colorData: widget.isClickOneTimeButton
                          ? PsColors.mainColor
                          : PsColors.white,
                      titleText:
                          Utils.getString(context, 'checkout1__order_time'),
                      onPressed: () async {
                        // if (widget
                        //         .shopInfoProvider.shopInfo.data!.pickupEnabled ==
                        //     '1') {
                        //   widget.updateOneTimeClick();
                        // }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: PsDimens.space10,
                  ),
                  /*
                  Expanded(
                    child: PSButtonWidget(
                      hasShadow: true,
                      hasShape: false,
                      width: double.infinity,
                      textColor: widget.isClickWeeklyButton
                          ? PsColors.white
                          : PsColors.black,
                      colorData: widget.isClickWeeklyButton
                          ? PsColors.mainColor
                          : PsColors.white,
                      titleText:
                          Utils.getString(context, 'checkout_one_page__weekly'),
                      onPressed: () async {
                        widget.updateWeeklyClick();
                      },
                    ),
                  ),
                  */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadioWidget extends StatefulWidget {
  const RadioWidget(
      {required this.userProvider,
      required this.updateOrderByData,
      required this.orderTimeTextEditingController,
      required this.updatDateAndTime,
      required this.latestDate,
      required this.firstTimeOrderController,
      required this.selectedDateTime,
      });
  final UserProvider userProvider;
  final Function updateOrderByData;
  final TextEditingController orderTimeTextEditingController;
  final Function updatDateAndTime;
  final String latestDate;
  final TextEditingController firstTimeOrderController;
  final TextEditingController selectedDateTime;

  @override
  _RadioWidgetState createState() => _RadioWidgetState();
}

class _RadioWidgetState extends State<RadioWidget> {
  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder =
        Provider.of<PsValueHolder>(context, listen: false);
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12,
              top: PsDimens.space12,
              right: PsDimens.space12),
          child: Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(Utils.getString(context, 'checkout1__order_time'),
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(' *',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          !.copyWith(color: PsColors.mainColor))
                ],
              )
            ],
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Radio<String>(
                    value: widget.userProvider.selectedRadioBtnName!,
                    groupValue: PsConst.ORDER_TIME_ASAP,
                    onChanged: (_) {
                      widget.updateOrderByData(PsConst.ORDER_TIME_ASAP);
                      final DateTime dateTime = DateTime.now().add(Duration(
                          minutes: int.parse(psValueHolder.defaultOrderTime!)));
                      widget.updatDateAndTime(dateTime);
                      widget.firstTimeOrderController.text =
                          Utils.getString(context, 'checkout1__asap') +
                              ' (' +
                              psValueHolder.defaultOrderTime! +
                              'mins)';
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: PsColors.mainColor,
                  ),
                  Expanded(
                    child: Text(
                      Utils.getString(context, 'checkout1__asap') +
                          ' (' +
                          psValueHolder.defaultOrderTime! +
                          'mins)',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio<String>(
                    value: widget.userProvider.selectedRadioBtnName!,
                    groupValue: PsConst.ORDER_TIME_SCHEDULE,
                    onChanged: (_) async {
                      widget.updateOrderByData(PsConst.ORDER_TIME_SCHEDULE);

                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true, onChanged: (DateTime date) {},
                          onConfirm: (DateTime date) {
                        final DateTime now = DateTime.now();
                        if (DateTime(date.year, date.month, date.day, date.hour,
                                    date.minute, date.second)
                                .difference(DateTime(now.year, now.month,
                                    now.day, now.hour, now.minute, now.second))
                                .inDays <
                            0) {
                          showDialog<dynamic>(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorDialog(
                                  message: Utils.getString(context,
                                      'chekcout1__past_date_time_error'),
                                );
                              });
                        } else {
                          print('confirm $date');
                          
                          widget.selectedDateTime.text = date.toString();
                          widget.updatDateAndTime(date);
                        }
                      }, locale: LocaleType.en);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: PsColors.mainColor,
                  ),
                  Expanded(
                    child: Text(
                      Utils.getString(context, 'checkout1__schedule'),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ]),
        Container(
            width: double.infinity,
            height: PsDimens.space44,
            margin: const EdgeInsets.all(PsDimens.space12),
            decoration: BoxDecoration(
              color: PsColors.backgroundColor,
              borderRadius: BorderRadius.circular(PsDimens.space4),
              border: Border.all(color: PsColors.mainDividerColor),
            ),
            child: TextField(
                enabled: widget.userProvider.selectedRadioBtnName ==
                    PsConst.ORDER_TIME_SCHEDULE,
                enableInteractiveSelection:
                    widget.userProvider.selectedRadioBtnName ==
                        PsConst.ORDER_TIME_SCHEDULE,
                keyboardType: TextInputType.text,
                maxLines: null,
                controller: widget.orderTimeTextEditingController,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: widget.userProvider.selectedRadioBtnName ==
                            PsConst.ORDER_TIME_ASAP
                        ? PsColors.textPrimaryLightColor
                        : PsColors.textPrimaryColor),
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: () {
                        widget.firstTimeOrderController.text =
                            Utils.getString(context, 'checkout1__schedule');
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onChanged: (DateTime date) {},
                            onConfirm: (DateTime date) {
                          final DateTime now = DateTime.now();
                          if (DateTime(date.year, date.month, date.day,
                                      date.hour, date.minute, date.second)
                                  .difference(DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      now.hour,
                                      now.minute,
                                      now.second))
                                  .inDays <
                              0) {
                            showDialog<dynamic>(
                                context: context,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    message: Utils.getString(context,
                                        'chekcout1__past_date_time_error'),
                                  );
                                });
                          } else {
                            print('confirm $date');
                            widget.selectedDateTime.text = date.toString();
                            widget.updatDateAndTime(date);
                            
                          }
                        }, locale: LocaleType.en);
                      },
                      child: Icon(
                        FontAwesome5.calendar,
                        size: PsDimens.space20,
                        color: widget.userProvider.selectedRadioBtnName ==
                                PsConst.ORDER_TIME_ASAP
                            ? PsColors.textPrimaryLightColor
                            : PsColors.mainColor,
                      )),
                  contentPadding: const EdgeInsets.only(
                    top: PsDimens.space8,
                    left: PsDimens.space12,
                    bottom: PsDimens.space8,
                  ),
                  border: InputBorder.none,
                  hintText: '2020-10-2 3:00 PM',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      !.copyWith(color: PsColors.textPrimaryLightColor),
                ))),
      ],
    );
  }
}
