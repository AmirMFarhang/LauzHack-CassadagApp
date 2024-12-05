import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:lauzhack_web/config/core/services/event_bus.dart';
import '../../../data/local_datasource.dart';
import '../../../data/remote_datasource.dart';

final locator = GetIt.instance;

@injectableInit
setupLocator() async {
  locator.registerLazySingleton(() => LocalDataSource());
  locator.registerLazySingleton(() => Bus());
  locator.registerLazySingleton(() => API());
}
