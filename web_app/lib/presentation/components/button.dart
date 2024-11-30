import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key,
      this.onClick,
      required this.title,
      required this.backgroundColor,
      required this.titleColor});
  final Function()? onClick;
  final String title;
  final Color backgroundColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
          onPressed: onClick,
          style: ButtonStyle(
            padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28,vertical: 12),
            child: Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.labelMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor)),
          )),
    );
  }
}
