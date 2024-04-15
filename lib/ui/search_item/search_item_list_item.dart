import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';

class SearchItemListItem extends StatelessWidget {
  const SearchItemListItem(
      {Key? key,
      required this.product,
      required this.parameterHolder,
      this.onTap,
      this.animationController,
      this.animation,
      })
      : super(key: key);

  final Product product;
  final ProductParameterHolder parameterHolder;
  final Function? onTap;
  final AnimationController ?animationController;
  final Animation<double> ?animation;
  
  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: InkWell(
            onTap: onTap as void Function()?,
            child: Container(
              margin: const EdgeInsets.all(
                PsDimens.space12
              ),
                child: Ink(
                    child: SearchItemListItemWidget(
                        product: product,
                        parameterHolder: parameterHolder))
                    )),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: animation!,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation!.value), 0.0),
                  child: child));
        });
  }
}

class SearchItemListItemWidget extends StatelessWidget {
  const SearchItemListItemWidget({
    Key? key,
    required this.product,
    required this.parameterHolder,
  }) : super(key: key);

  final Product product;
  final ProductParameterHolder parameterHolder;

  @override
  Widget build(BuildContext context) {

    final String search = parameterHolder.searchTerm!;

    final TextStyle posRes =  TextStyle(
      color: PsColors.mainColor,
      fontSize: PsDimens.space14),

    negRes =  TextStyle(
      color: PsColors.iconColor,
      fontSize: PsDimens.space14);

    TextSpan searchMatch(String match) {
      if ( search == '')
        return TextSpan(text: match, style: negRes);
      final String refinedMatch = match.toLowerCase();
      final String refinedSearch = search.toLowerCase();
      if (refinedMatch.contains(refinedSearch)) {
        if (refinedMatch.substring(0, refinedSearch.length) == refinedSearch) {
          return TextSpan(
            style: posRes,
            text: match.substring(0, refinedSearch.length),
            children: <InlineSpan>[
              searchMatch(
                match.substring(
                  refinedSearch.length,
                ),
              ),
            ],
          );
        } else if (refinedMatch.length == refinedSearch.length) {
          return TextSpan(text: match, style: posRes);
        } else {
          return TextSpan(
            style: negRes,
            text: match.substring(
              0,
              refinedMatch.indexOf(refinedSearch),
            ),
            children: <InlineSpan>[
              searchMatch(
                match.substring(
                  refinedMatch.indexOf(refinedSearch),
                ),
              ),
            ],
          );
        }
      } else if (!refinedMatch.contains(refinedSearch)) {
        return TextSpan(text: match, style: negRes);
      }
      return TextSpan(
        text: match.substring(0, refinedMatch.indexOf(refinedSearch)),
        style: negRes,
        children: <InlineSpan>[
          searchMatch(match.substring(refinedMatch.indexOf(refinedSearch)))
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: PsDimens.space8,
        // left: PsDimens.space16,
        // right: PsDimens.space16,
        // bottom: PsDimens.space14
        ),
      child: RichText(
        text: searchMatch(
          product.name!,
        ),
      ),
    );
  }
}


