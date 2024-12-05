import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String icon;
  final bool isSelected;
  const SideMenu(
      {super.key,
      this.isSelected = false,
      this.onPressed,
      required this.text,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          width: isSelected ? 240.w : 0,
          height: 50.h,
          left: 0,
          child: Container(
            width: 10.w,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        ListTile(
          onTap: onPressed,
          dense: true,
          leading: SizedBox(
            height: 28.h,
            child: SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                  isSelected ? Colors.black : Colors.white,
                  BlendMode.srcIn),
            ),
          ),
          title: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
