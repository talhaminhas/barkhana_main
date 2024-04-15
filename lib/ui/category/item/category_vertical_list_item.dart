import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/viewobject/category.dart';

class CategoryVerticalListItem extends StatelessWidget {
  const CategoryVerticalListItem(
      {Key? key,
      required this.category,
      this.onTap,
      //this.animationController,
      //this.animation
      })
      : super(key: key);

  final Category category;

  final Function? onTap;
  //final AnimationController? animationController;
  //final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    //animationController!.forward();
    return /*AnimatedBuilder*/Container(
        //animation: animationController!,
        child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Card(
                elevation: 0.3,
                child: Container(
                    decoration: BoxDecoration(
                      color: PsColors.black.withAlpha(210),
                      border: Border.all(
                        color: PsColors.mainColor, // Set the desired border color here
                        width: 2, // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(5), // Set the desired border radius
                    ),
                    child:Column(
                      children: <Widget>[
                        Expanded(
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              final double width = constraints.maxWidth; // Get parent's width
                              final double remainingHeight = constraints.maxHeight - 30; // 50 is the fixed height of the Text

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Container(
                                  width: width,
                                  height: remainingHeight, // Adjust the height to cover remaining space
                                  child: PsNetworkImage(
                                    photoKey: '',
                                    defaultPhoto: category.defaultPhoto!,
                                    boxfit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: PsDimens.space4,
                        ),
                        Container(
                          height: 25,
                          padding: const EdgeInsets.only(left: PsDimens.space10,right: PsDimens.space10),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              category.name!,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: PsColors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: PsDimens.space4,
                        ),
                      ],
                    )

                ))),
        /*builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child,
              ));
        }*/);
  }
}
