import 'package:event_bus/event_bus.dart';

class ApplicationEvent {
  static EventBus event = new EventBus();
}

class DeviceEvent {
  var devices;

  DeviceEvent(this.devices);
}
