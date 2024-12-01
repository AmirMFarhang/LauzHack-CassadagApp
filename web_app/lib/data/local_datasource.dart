import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../config/core/constants/constants.dart';

@lazySingleton
class LocalDataSource {
  late Box localDB;
  Map<String, String> headers = {};




  init() async {
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    localDB = await Hive.openBox(Constants.localDB);
  }





}
