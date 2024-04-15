import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/product_parameter_holder.dart';

import '../../constant/ps_constants.dart';
import '../../utils/utils.dart';
import '../dashboard/core/drawer_view.dart';

class PsSearchTextFieldWidget extends StatelessWidget {
  const PsSearchTextFieldWidget(
      {this.textEditingController,
      this.hintText,
      this.height = PsDimens.space44,
      this.keyboardType = TextInputType.text,
      this.textInputAction = TextInputAction.done,
      this.psValueHolder,
        this.onTextChange,
        required this.focusNode
      });

  final TextEditingController? textEditingController;
  final String? hintText;
  final double height;
  final TextInputType keyboardType;
  final PsValueHolder? psValueHolder;
  final TextInputAction textInputAction;
  final Function(String)? onTextChange;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final ProductParameterHolder productParameterHolder =
        ProductParameterHolder().getLatestParameterHolder();
    final Widget _productTextFieldWidget = TextField(
      focusNode: focusNode,
        onChanged: onTextChange,
        keyboardType: TextInputType.text,
        textInputAction: textInputAction,
        maxLines: null,
        controller: textEditingController,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: PsDimens.space12,
            bottom: PsDimens.space12,
            right: PsDimens.space12,
          ),
          border: InputBorder.none,
          hintText: hintText,
        ),
        onSubmitted: (String value) {
          // Your onSubmitted code here
          productParameterHolder.searchTerm = textEditingController!.text;
          dashboardViewKey.currentState?.selectedProductParameterHolder = productParameterHolder;
          dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(
              Utils.getString(context, 'home__bottom_app_bar_search'),
              PsConst.REQUEST_CODE__DASHBOARD_SEARCH_ITEM_LIST_FRAGMENT);
        },
      )

    ;

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.all(PsDimens.space12),
          decoration: BoxDecoration(
              color: PsColors.mainDividerColor,
              borderRadius: BorderRadius.circular(PsDimens.space4),
              border: Border.all(color: PsColors.mainDividerColor),
            ),
          child: _productTextFieldWidget,
        ),
      ],
    );
  }
}