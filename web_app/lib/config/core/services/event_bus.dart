import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class Bus {
  EventBus eventBus = EventBus();
}


