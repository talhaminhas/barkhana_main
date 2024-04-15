import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';

class PsTextFieldWidget extends StatefulWidget {
   const PsTextFieldWidget({
    Key? key,
    this.textEditingController,
    this.titleText = '',
    this.hintText,
    this.textAboutMe = false,
    this.height = PsDimens.space44,
    this.showTitle = true,
    this.keyboardType = TextInputType.text,
    this.isPhoneNumber = false,
    this.isMandatory = false,
    this.isReadonly = false,
    this.onChanged,
     this.isEmail = false,
  }) : super(key: key);

  final TextEditingController? textEditingController;
  final String titleText;
  final String? hintText;
  final double height;
  final bool textAboutMe;
  final TextInputType keyboardType;
  final bool showTitle;
  final bool isPhoneNumber;
  final bool isMandatory;
  final bool isReadonly;
  final bool isEmail;
  final Function(String)? onChanged;



  @override
  _PsTextFieldWidgetState createState() => _PsTextFieldWidgetState();


}

class _PsTextFieldWidgetState extends State<PsTextFieldWidget> {

  @override
  void initState() {
    super.initState();
  }


  bool validatePhoneNumber(String phoneNumber ){
    final RegExp phoneRegExp = RegExp(r'^[0-9]{11}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
  bool validateEmail(String email) {
      final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*$');
      return emailRegExp.hasMatch(email);
  }
  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.isReadonly ? PsColors.baseLightColor :PsColors.mainColor;
    Color color = widget.isReadonly ? PsColors.baseLightColor : PsColors.backgroundColor;
    final Widget _productTextWidget =
    Text(widget.titleText, style: Theme.of(context).textTheme.bodyLarge);
    return Column(
      children: <Widget>[
        if (widget.showTitle)
          Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12,
                top: PsDimens.space6,
                right: PsDimens.space12),
            child: Row(
              children: <Widget>[
                if (widget.isMandatory)
                  Row(
                    children: <Widget>[
                      Text(widget.titleText,
                          style: Theme.of(context).textTheme.bodyLarge),
                      Text(' *',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: PsColors.discountColor))
                    ],
                  )
                else
                  _productTextWidget
              ],
            ),
          )
        else
          Container(
            height: 0,
          ),
        Container(
          width: double.infinity,
          height: widget.height,
          margin: const EdgeInsets.all(PsDimens.space12),
          decoration: BoxDecoration(
            color: color ,
            borderRadius: BorderRadius.circular(PsDimens.space4),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            onChanged: (String text){
              setState(() {
                if(widget.isPhoneNumber)
                  {
                    color = !validatePhoneNumber(widget.textEditingController!.text) ?
                    PsColors.discountColor.withOpacity(0.1) : PsColors
                        .backgroundColor;
                    borderColor = !validatePhoneNumber(widget.textEditingController!.text) ?
                    PsColors.discountColor : PsColors.mainColor;
                  }
                else if (widget.isEmail)
                  {
                    color = !validateEmail(widget.textEditingController!.text) ?
                    PsColors.discountColor.withOpacity(0.1) : PsColors
                        .backgroundColor;
                    borderColor = !validateEmail(widget.textEditingController!.text) ?
                    PsColors.discountColor : PsColors.mainColor;
                  }
                else {
                  color = widget.textEditingController?.text == '' ?
                  PsColors.discountColor.withOpacity(0.1) : PsColors
                      .backgroundColor;
                  borderColor = widget.textEditingController?.text == '' ?
                  PsColors.discountColor : PsColors.mainColor;
                }
              });
            },
            keyboardType:
            widget.isPhoneNumber ? TextInputType.phone : TextInputType.text,
            maxLines: null,

            controller: widget.textEditingController,
            style: Theme.of(context).textTheme.bodyMedium,
            readOnly: widget.isReadonly,
            decoration: widget.textAboutMe
                ? InputDecoration(
              contentPadding: const EdgeInsets.only(
                left: PsDimens.space12,
                bottom: PsDimens.space8,
                top: PsDimens.space10,
              ),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: PsColors.textPrimaryLightColor),
            )
                : InputDecoration(
              contentPadding: const EdgeInsets.only(
                left: PsDimens.space12,
                bottom: PsDimens.space8,
              ),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: PsColors.textPrimaryLightColor),
            ),
          ),
        ),
      ],
    );
  }
}



