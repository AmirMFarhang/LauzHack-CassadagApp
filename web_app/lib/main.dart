
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'config/core/routes/app_routes.dart';
import 'config/core/services/locator.dart';
import 'data/local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await setupLocator();
  await locator<LocalDataSource>().init();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
        designSize: const Size(375, 844),
        useInheritedMediaQuery: true,
        minTextAdapt: true,
        builder: (context, child) {
        return GetMaterialApp(
          builder: (context, child) {
            return child!;
          },
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoutes,
        );
      }
    );
  }
}


