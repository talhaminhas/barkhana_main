import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';

class PSButtonWidget extends StatefulWidget {
  const PSButtonWidget(
      {this.onPressed,
      this.titleText = '',
      this.titleTextAlign = TextAlign.center,
      this.colorData,
      this.width,
      this.gradient,
      this.hasShadow = false,
      this.hasShape = true,
      this.textColor});

  final Function? onPressed;
  final String titleText;
  final Color? colorData;
  final double? width;
  final Gradient? gradient;
  final bool hasShadow;
  final bool hasShape;
  final Color? textColor;
  final TextAlign titleTextAlign;

  @override
  _PSButtonWidgetState createState() => _PSButtonWidgetState();
}

class _PSButtonWidgetState extends State<PSButtonWidget> {
  Gradient? _gradient;
  Color? _color;
  @override
  Widget build(BuildContext context) {
    _color = widget.colorData;
    _gradient = null;

    _color ??= PsColors.mainColor;

    if (widget.gradient == null && _color == PsColors.mainColor) {
      _gradient = LinearGradient(colors: <Color>[
        PsColors.mainColor,
        PsColors.mainDarkColor,
      ]);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      decoration: ShapeDecoration(
        shape: /*widget.hasShape ? const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
        ): */RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        color: _color,
        /*_gradient == null ? _color : null,
        gradient: _gradient,
        shadows: <BoxShadow>[
          if (widget.hasShadow)
            BoxShadow(
                color: Utils.isLightMode(context)
                    ? _color!.withOpacity(0.6)
                    : PsColors.mainShadowColor,
                offset: const Offset(0, 4),
                blurRadius: 8.0,
                spreadRadius: 3.0),
        ],*/
      ),
      child: Material(
        color: PsColors.transparent,
        type: MaterialType.card,
        clipBehavior: Clip.antiAlias,
        shape: widget.hasShape ? const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(PsDimens.space8))):
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsDimens.space8),
        ),
        child: InkWell(
          onTap: widget.onPressed as void Function()?,
          highlightColor: PsColors.mainDarkColor,
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: PsDimens.space8, right: PsDimens.space8),
              child: Text(
                widget.titleText.toUpperCase(),
                textAlign: widget.titleTextAlign,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: widget.textColor ?? PsColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PSButtonWithIconWidget extends StatefulWidget {
  const PSButtonWithIconWidget(
      {this.onPressed,
      this.titleText = '',
      this.colorData,
      this.width,
      this.gradient,
      this.icon,
      this.iconAlignment = MainAxisAlignment.center,
      this.hasShadow = false});

  final Function? onPressed;
  final String titleText;
  final Color? colorData;
  final double? width;
  final IconData? icon;
  final Gradient? gradient;
  final MainAxisAlignment iconAlignment;
  final bool hasShadow;

  @override
  _PSButtonWithIconWidgetState createState() => _PSButtonWithIconWidgetState();
}

class _PSButtonWithIconWidgetState extends State<PSButtonWithIconWidget> {
  Gradient? _gradient;
  Color? _color;
  @override
  Widget build(BuildContext context) {
    _color = widget.colorData;
    _gradient = null;

    _color ??= PsColors.mainColor;

    if (widget.gradient == null && _color == PsColors.mainColor) {
      _gradient = LinearGradient(colors: <Color>[
        PsColors.mainColor,
        PsColors.mainDarkColor,
      ]);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
        ),
        color: PsColors.mainColor/*_gradient == null ? _color : null,*/
        //gradient: _gradient,
        /*shadows: <BoxShadow>[
          if (widget.hasShadow)
            BoxShadow(
                color: Utils.isLightMode(context)
                    ? _color!.withOpacity(0.6)
                    : PsColors.mainShadowColor,
                offset: const Offset(0, 4),
                blurRadius: 8.0,
                spreadRadius: 3.0),
        ],*/
      ),
      child: Material(
        color: _color,
        type: MaterialType.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // You can adjust the radius as needed
        ),
        child: InkWell(
          onTap: widget.onPressed as void Function()?,
          highlightColor: PsColors.mainDarkColor,
          child: Stack(
            children: <Widget>[
              if (widget.icon != null)
                Positioned(
                  left: 5, bottom: 8, top: 8,
                    child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(widget.icon, color: PsColors.white),
                )),
              Positioned.fill(
                child: Center(
                  child: Text(
                    widget.titleText.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: PsColors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),


        ),
      ),
    );
  }
}
