import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_detail.dart';
import 'package:provider/provider.dart';

class TransactionItemView extends StatelessWidget {
  const TransactionItemView({
    Key? key,
    required this.transaction,
    this.animationController,
    this.animation,
    this.onTap,
  }) : super(key: key);

  final TransactionDetail transaction;
  final Function? onTap;
  final AnimationController ?animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    return AnimatedBuilder(
        animation: animationController!,
        child: GestureDetector(
          onTap: onTap as void Function()?,
          child: _ItemWidget(
            transaction: transaction,
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation!.value), 0.0),
                child: child,
              ));
        });
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final TransactionDetail transaction;

  @override
  Widget build(BuildContext context) {
    double? balancePrice;
    String? attributeName;
    PsValueHolder? valueHolder;
    //print(transaction.transStatus?.title);
    const Widget ?_dividerWidget = Divider(
      height: PsDimens.space2,
    );
    valueHolder = Provider.of<PsValueHolder>(context, listen: false);

    // if (transaction.productAttributeName != null &&
    //     transaction.productAttributeName != '') {
    //   attributeName = transaction.productAttributeName.replaceAll('#', ',');
    // }
    if (transaction.originalPrice != '0' && transaction.discountAmount != '0') {
      balancePrice = (double.parse(transaction.originalPrice!) -
              double.parse(transaction.discountAmount!)) *
          double.parse(transaction.qty!);
    } else {
      balancePrice = double.parse(transaction.originalPrice!) *
          double.parse(transaction.qty!);
    }
    String formattedAddOnPrices = '';
    if(transaction.productAddonPrice! != '') {
      final List<String> priceList = transaction.productAddonPrice!.split('#');
      final List<String> formattedPrices = priceList.map((String price) {
        print(price);
        final double priceValue = double.parse(price);
        final String formattedPrice = priceValue.toStringAsFixed(2);
        return formattedPrice;
      }).toList();
      formattedAddOnPrices = formattedPrices.join('#');
    }
    return Container(
        //color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(
            top: PsDimens.space8,
            left: PsDimens.space12,
            right: PsDimens.space12,
        ),

        decoration: BoxDecoration(
          border: Border.all(
            color: PsColors.mainColor, // Border color
            width: 2.0,          // Border width
          ),
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.restaurant,
                  ),
                  const SizedBox(
                    width: PsDimens.space16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            transaction.productName ?? '-',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: PsColors.mainColor, // Button background color
                            borderRadius: BorderRadius.circular(5.0), // Rounded corners
                          ),
                          child: GestureDetector(
                            onTap: null,
                            child: const Text(
                              'View Product',
                              style: TextStyle(
                                color: Colors.white, // Button text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
            _dividerWidget,

              Row(
                children: <Widget>[
                  if (transaction.productColorCode != null &&
                      transaction.productColorCode != '')
                    Container(
                      margin: const EdgeInsets.all(PsDimens.space10),
                      width: PsDimens.space32,
                      height: PsDimens.space32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Utils.hexToColor(transaction.productColorCode!),
                        // border: Border.all(width: 1, color: PsColors.grey),
                      ),
                    )
                  else
                    Container(),
                  if (attributeName != null && attributeName != '')
                    Flexible(
                      child: Text(
                        attributeName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  const SizedBox(
                    width: PsDimens.space16,
                  ),
                ],
              ),
            if(transaction.productAddonName! != '')
              _CustomizedAndAddOnTextWidget(
                addOnNames: '${transaction.productAddonName!.replaceAll('#', ' :\n')} :',
                addOnPrices: '+ £${formattedAddOnPrices.replaceAll('#', '\n£ ')}',
                title:
                '${Utils.getString(context, 'transaction_detail__add_on')} :',
              ),
            _TransactionNoTextWidget(
              transationInfoText: '${transaction.qty}',
              title: '${Utils.getString(context, 'transaction_detail__qty')} :',
            ),


            if (transaction.discountAmount != null && transaction.discountAmount != '0')
              Column(
                children: <Widget>[
                  _TransactionNoTextWidget(
                    transationInfoText:
                    '- ${transaction.currencySymbol}${Utils.getPriceFormat(transaction.discountAmount.toString(), valueHolder)}',
                    title: '${Utils.getString(context, 'transaction_detail__discount_avaiable_amount')} :',
                  ),
                  /*_TransactionNoTextWidget(
                    transationInfoText:
                    '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.price.toString(), valueHolder)}',
                    title: '${Utils.getString(context, 'transaction_detail__discounted_price')} :',
                  ),*/
                ],
              ),

            _TransactionNoTextWidget(
              transationInfoText:
              '${transaction.currencySymbol}${Utils.getPriceFormat(transaction.originalPrice!,valueHolder)}',
              title:
              '${Utils.getString(context, 'transaction_detail__price')} :',
            ),
            const SizedBox(height: PsDimens.space12),
            _dividerWidget,
            _TransactionNoTextWidget(
              transationInfoText:
                  ' ${transaction.currencySymbol}${Utils.getPriceFormat(balancePrice.toString(),valueHolder)}',
              title:
                  '${Utils.getString(context, 'transaction_detail__sub_total')} :',
            ),
            const SizedBox(height: PsDimens.space12),
            /*_CustomizedAndAddOnTextWidget(
              infoText:
                  '${transaction.productCustomizedName!.replaceAll('#', ', ')}',
              title:
                  '${Utils.getString(context, 'transaction_detail__customized')} :',
            ),*/

          ],
        ));
  }
}

class _CustomizedAndAddOnTextWidget extends StatelessWidget {
  const _CustomizedAndAddOnTextWidget(
      {Key? key, 
      required this.title, required this.addOnNames, required this.addOnPrices})
      : super(key: key);

  final String title;
  final String addOnNames;
  final String addOnPrices;
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(
        left: PsDimens.space16,
        right: PsDimens.space16,
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space12,
          ),
          Visibility(
            visible: addOnNames != ' :',
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Visibility(
            visible: addOnNames != ' :',
            child: Container(
              margin: const EdgeInsets.all(PsDimens.space12),
              child: Row(
                children: <Widget>[
                  Text(
                    addOnNames,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    addOnPrices,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ],
              )

            ),
          ),
          const Divider(
            height: PsDimens.space2,
          ),
        ],
      ),
    );
  }
}

class _TransactionNoTextWidget extends StatelessWidget {
  const _TransactionNoTextWidget({
    Key? key,
    required this.transationInfoText,
    this.title,
  }) : super(key: key);

  final String transationInfoText;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
          top: PsDimens.space12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            transationInfoText ,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}
