import 'dart:async';

class GastoAgregadoEvent {
  const GastoAgregadoEvent();
}

class GastoEliminadoEvent {
  const GastoEliminadoEvent();
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _gastoAgregadoController = StreamController<GastoAgregadoEvent>.broadcast();
  final _gastoEliminadoController = StreamController<GastoEliminadoEvent>.broadcast();

  Stream<GastoAgregadoEvent> get onGastoAgregado => _gastoAgregadoController.stream;
  Stream<GastoEliminadoEvent> get onGastoEliminado => _gastoEliminadoController.stream;

  void notifyGastoAgregado() {
    _gastoAgregadoController.add(const GastoAgregadoEvent());
  }

  void notifyGastoEliminado() {
    _gastoEliminadoController.add(const GastoEliminadoEvent());
  }

  void dispose() {
    _gastoAgregadoController.close();
    _gastoEliminadoController.close();
  }
}