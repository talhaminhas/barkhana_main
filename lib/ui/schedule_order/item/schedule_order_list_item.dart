import 'package:flutter/material.dart';

import '../../../config/ps_colors.dart';
import '../../../utils/utils.dart';

class ScheduleOrderListItem extends StatelessWidget {
  const ScheduleOrderListItem({
    Key? key,
    required this.scheduleIndex,
    required this.scheduleDay,
    required this.scheduleTime,
    required this.isActive,
    required this.address,
    required this.itemList,
    required this.onDeleted,
    required this.onChanged,
  }) : super(key: key);
  final int scheduleIndex;
  final String scheduleDay;
  final String scheduleTime;
  final String itemList;
  final String address;
  final bool isActive;
  final Function() onDeleted;
  final Function() onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PsColors.coreBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Schedule $scheduleIndex'),
                IconButton(
                  onPressed: onDeleted,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: PsColors.mainColor.withGreen(170),
                    size: 28,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text(
              '$scheduleDay $scheduleTime',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600, color: PsColors.mainColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Text(
              itemList,
              style:
                  Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              address,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Utils.getString(context, 'checkout3__cod'),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(.6))),
                Row(
                  children: <Widget>[
                    Text(
                        isActive
                            ? Utils.getString(
                                context, 'schedule_order_status_active')
                            : Utils.getString(
                                context, 'schedule_order_status_pause'),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PsColors.mainColor)),
                    Switch(
                      value: isActive,
                      activeColor: PsColors.mainColor,
                      onChanged: (bool val) {
                        onChanged();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
