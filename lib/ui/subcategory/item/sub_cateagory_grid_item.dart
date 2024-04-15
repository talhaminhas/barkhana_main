import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/viewobject/sub_category.dart';

class SubCategoryGridItem extends StatelessWidget {
  const SubCategoryGridItem(
      {Key? key,
      required this.subCategory,
      this.onTap,
      this.animationController,
      this.animation})
      : super(key: key);

  final SubCategory subCategory;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double> ?animation;
  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: InkWell(
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
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: PsNetworkImage(
                                    photoKey: '',
                                    defaultPhoto: subCategory.defaultPhoto!,
                                    width: double.infinity,
                                    height: double.infinity, // Expand to available height
                                    boxfit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(PsDimens.space4),
                                  height: 20,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    child: Text(
                                      subCategory.name!,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                          color: PsColors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

                ))),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: animation!,
            child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child),
          );
        });
  }
}
