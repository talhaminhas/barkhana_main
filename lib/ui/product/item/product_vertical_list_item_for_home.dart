import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/ui/common/ps_hero.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/product.dart';

class ProductVeticalListItemForHome extends StatelessWidget {
  const ProductVeticalListItemForHome(
      {Key? key,
      required this.product,
      required this.psValueHolder,
      this.onTap,
      this.onButtonTap,
      this.coreTagKey})
      : super(key: key);

  final Product product;
  final Function? onTap;
  final Function? onButtonTap;
  final String? coreTagKey;
  final PsValueHolder psValueHolder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap as void Function()?,
        child: GridTile(
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: PsDimens.space8, vertical: PsDimens.space8),
            decoration: BoxDecoration(
              color: PsColors.backgroundColor,
              borderRadius:
                  const BorderRadius.all(Radius.circular(PsDimens.space8)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(PsDimens.space8)),
                    ),
                    child: ClipPath(
                      child: PsNetworkImage(
                        photoKey: '$coreTagKey${PsConst.HERO_TAG__IMAGE}',
                        defaultPhoto: product.defaultPhoto!,
                        width: PsDimens.space180,
                        height: PsDimens.space160,
                        boxfit: BoxFit.cover,
                        onTap: () {
                          Utils.psPrint(product.defaultPhoto!.imgParentId!);
                          onTap!();
                        },
                      ),
                      clipper: const ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(PsDimens.space8),
                                  topRight: Radius.circular(PsDimens.space8)))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: PsDimens.space8,
                      top: PsDimens.space8,
                      right: PsDimens.space8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: PsHero(
                        tag: '$coreTagKey$PsConst.HERO_TAG__UNIT_PRICE',
                        flightShuttleBuilder: Utils.flightShuttleBuilder,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                              '${product.currencySymbol}${Utils.getPriceFormat(product.unitPrice!,psValueHolder)}',
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: PsColors.mainColor,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                      )),
                      if (product.isDiscount == PsConst.ONE)
                        Expanded(
                          child: Text(
                              '  ${product.discountPercent}% ' +
                                  Utils.getString(
                                      context, 'product_detail__discount_off'),
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: PsColors.discountColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        )
                      else
                        Container()
                    ],
                  ),
                ),
                Container(
                    child: Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: PsDimens.space8,
                          top: PsDimens.space8,
                          right: PsDimens.space8,
                          bottom: PsDimens.space12),
                      child: PsHero(
                        tag: '$coreTagKey${PsConst.HERO_TAG__TITLE}',
                        child: Text(
                          product.name!,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: PsDimens.space4),
                      child: IconButton(
                          iconSize: PsDimens.space32,
                          icon:
                              Icon(Icons.add_circle, color: PsColors.mainColor),
                          onPressed: () {
                            onButtonTap!();
                          })),
                ])),
              ],
            ),
          ),
        ));
  }
}
