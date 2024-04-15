import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

import '../../config/ps_colors.dart';
import '../../config/ps_config.dart';
import '../../constant/ps_dimens.dart';
import '../../utils/ps_curve_animation.dart';
import '../../utils/utils.dart';
import '../checkout/checkout1_view.dart';

class WeeklyOrderTimeList extends StatefulWidget {
  const WeeklyOrderTimeList({Key? key, required this.scheduleOrder})
      : super(key: key);

  final List<ScheduleOrder> scheduleOrder;

  @override
  State<WeeklyOrderTimeList> createState() => _WeeklyOrderTimeListState();
}

class _WeeklyOrderTimeListState extends State<WeeklyOrderTimeList>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.scheduleOrder.length,
        primary: false,
        itemBuilder: (BuildContext context, int index) {
          return AnimatedBuilder(
            animation: animationController,
            child: WeeklyOrderTimeListItem(
              schedule: widget.scheduleOrder[index],
            ),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0,
                      100 *
                          (1.0 -
                              curveAnimation(animationController, index,
                                      widget.scheduleOrder.length)
                                  .value),
                      0),
                  child: child,
                ),
              );
            },
          );
        });
  }
}

class WeeklyOrderTimeListItem extends StatefulWidget {
  const WeeklyOrderTimeListItem({
    required this.schedule,
  });
  final ScheduleOrder schedule;

  @override
  State<WeeklyOrderTimeListItem> createState() =>
      _WeeklyOrderTimeListItemState();
}

class _WeeklyOrderTimeListItemState extends State<WeeklyOrderTimeListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(PsDimens.space12),
      // height: PsDimens.space44,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Checkbox(
                activeColor: PsColors.mainColor,
                value: widget.schedule.isActive,
                onChanged: widget.schedule.selectedTime == null
                    ? null
                    : (bool? val) {
                        setState(() {
                          widget.schedule.isActive = val!;
                        });
                      },
              ),
              Text(widget.schedule.weekDay),
            ],
          ),
          RawMaterialButton(
            onPressed: () {
              DatePicker.showTimePicker(
                context,
                onConfirm: (DateTime time) {
                  setState(() {
                    widget.schedule.selectedTime =
                        '${DateFormat('hh:mm').format(time)}';
                    widget.schedule.isActive = true;
                  });
                },
                showSecondsColumn: false,
              );
            },
            child: Container(
              width: PsDimens.space160,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(PsDimens.space12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PsDimens.space4),
                  border: Border.all(
                    color: PsColors.mainDividerColor,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.schedule.selectedTime != null
                      ? '${widget.schedule.selectedTime}'
                      : Utils.getString(context, 'schedule_order_set_time')),
                  Icon(widget.schedule.selectedTime != null
                      ? Icons.access_time_filled_rounded
                      : Icons.schedule_sharp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
