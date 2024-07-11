import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {

  final void Function()? onPressed;
  final Widget? child;
  final Color? buttonColor;
  final Color? textColor;
  final BorderRadiusGeometry borderRadius;
  

  const CustomFilledButton({
    super.key, 
    this.onPressed, 
    required this.child, 
    this.buttonColor, 
    this.textColor = Colors.black, 
    required this.borderRadius, 
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
          borderRadius: borderRadius
        )),        
        onPressed: onPressed, 
        child: child
      ),
    );
  }
}