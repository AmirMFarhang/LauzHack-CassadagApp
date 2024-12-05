import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../config/theme/app_colors.dart';

class ItemCountry extends StatelessWidget {
  final String text;
  final String flag;
  final bool isSelected;
  final Function()? function;
  const ItemCountry(
      {Key? key,
      required this.text,
      required this.flag,
      this.function,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.blue
          .withOpacity(0.2), // Optional: set the color of the splash effect
      onTap: function,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 1),
            color: Theme.of(Get.context!).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(
              5,
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 8))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 11),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://flagcdn.com/84x63/${flag.toLowerCase()}.png",
                      width: 24,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            text,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: SvgPicture.asset(
                      "assets/svg/stepper/step_done.svg",
                      width: 20,
                    ),
                  ),
                if (!isSelected)
                  const Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: SizedBox(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
