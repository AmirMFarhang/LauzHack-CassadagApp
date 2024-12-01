import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lauzhack_web/presentation/components/profile_image_card.dart';
import 'package:lauzhack_web/presentation/components/side_menu.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int selectedMenu = 0;
  @override
  Widget build(BuildContext context) {

    return Drawer(
      backgroundColor:const Color(0xFFbe2bbb),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              ProfileImageCard(
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 100))
                      .then((value) {
                  });
                },
              ),
              SizedBox(height: 50.h),
              const Text(
                'Forecasting based on:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              SideMenu(
                onPressed: () {
                  setState(() {
                    selectedMenu = 0;
                  });
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((value) {
                  });
                },
                icon: "assets/svg/check_circle.svg",
                isSelected: selectedMenu == 0,
                text: 'Flat Forecasting',
              ),
              SizedBox(height: 10.h),
              SideMenu(
                onPressed: () {
                  setState(() {
                    selectedMenu = 1;
                  });
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((value) {
                  });
                },
                icon: "assets/svg/check_circle.svg",
                isSelected: selectedMenu == 1,
                text: 'Competitor Entry',
              ),
              SizedBox(height: 5.h),
              SideMenu(
                onPressed: () {
                  setState(() {
                    selectedMenu = 2;
                  });
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((value) {
                  });
                },
                icon: "assets/svg/check_circle.svg",
                isSelected: selectedMenu == 2,
                text: 'New Product Launch',
              ),
              SizedBox(height: 5.h),
              SideMenu(
                onPressed: () {
                  setState(() {
                    selectedMenu = 3;
                  });
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((value) {
                  });
                },
                icon: "assets/svg/check_circle.svg",
                isSelected: selectedMenu == 3,
                text: 'Economic Changes',
              ),

              SizedBox(height: 5.h),
              const Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}
