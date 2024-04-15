import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';

class PostalAddressListItem extends StatelessWidget {
  const PostalAddressListItem(
      {Key? key,
      required this.address, required this.city,
      this.onTap,
      this.animationController,
      this.animation})
      : super(key: key);

  final String address;
  final String city;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();

    return AnimatedBuilder(
      animation: animationController!,
      child: GestureDetector(
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0), // Add margin around the DecoratedBox
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: PsColors.backgroundColor, // Background color
              borderRadius: BorderRadius.circular(8.0), // Border radius
              border: Border.all(
                color: PsColors.mainColor, // Border color
                width: 1.0, // Border width
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(PsDimens.space10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                address,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                city,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )


        ,
      ),
      builder: (BuildContext contenxt, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 100 * (1.0 - animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }
}
