import 'dart:async';

class GastoAgregadoEvent {
  const GastoAgregadoEvent();
}

class GastoEliminadoEvent {
  const GastoEliminadoEvent();
}

class PresupuestoActualizadoEvent {
  final String tipo; // 'mensual', 'semanal', 'anual'
  const PresupuestoActualizadoEvent(this.tipo);
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _gastoAgregadoController =
      StreamController<GastoAgregadoEvent>.broadcast();
  final _gastoEliminadoController =
      StreamController<GastoEliminadoEvent>.broadcast();
  final _presupuestoActualizadoController =
      StreamController<PresupuestoActualizadoEvent>.broadcast();

  Stream<GastoAgregadoEvent> get onGastoAgregado =>
      _gastoAgregadoController.stream;
  Stream<GastoEliminadoEvent> get onGastoEliminado =>
      _gastoEliminadoController.stream;
  Stream<PresupuestoActualizadoEvent> get onPresupuestoActualizado =>
      _presupuestoActualizadoController.stream;

  void notifyGastoAgregado() {
    _gastoAgregadoController.add(const GastoAgregadoEvent());
  }

  void notifyGastoEliminado() {
    _gastoEliminadoController.add(const GastoEliminadoEvent());
  }

  void notifyPresupuestoActualizado(String tipo) {
    _presupuestoActualizadoController.add(PresupuestoActualizadoEvent(tipo));
  }

  void dispose() {
    _gastoAgregadoController.close();
    _gastoEliminadoController.close();
    _presupuestoActualizadoController.close();
  }
}
