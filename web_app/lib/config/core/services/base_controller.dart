import 'package:get/get.dart';

import '../../../data/local_datasource.dart';
import '../../../data/remote_datasource.dart';
import '../services/event_bus.dart';
import 'locator.dart';

class BaseGetxController extends GetxController {
  final localDB = locator<LocalDataSource>();
  final api = locator<API>();
  final eventbus = locator<Bus>();
}
