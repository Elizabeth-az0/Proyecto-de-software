import 'dart:async';

/// Evento que se dispara cuando se agrega un nuevo gasto
class GastoAgregadoEvent {
  const GastoAgregadoEvent();
}

/// Evento que se dispara cuando se elimina un gasto
class GastoEliminadoEvent {
  const GastoEliminadoEvent();
}

/// Evento que se dispara cuando se actualiza un presupuesto
/// 
/// [tipo] puede ser: 'mensual', 'semanal' o 'anual'
class PresupuestoActualizadoEvent {
  final String tipo;
  const PresupuestoActualizadoEvent(this.tipo);
}

/// Implementación de un Event Bus usando el patrón Singleton
/// 
/// Proporciona un sistema de publicación-suscripción para eventos en la aplicación
/// Permite la comunicación entre componentes sin acoplamiento directo
class EventBus {
  // =============================================
  // 1. IMPLEMENTACIÓN DEL PATRÓN SINGLETON
  // =============================================
  
  /// Instancia única del EventBus
  static final EventBus _instance = EventBus._internal();
  
  /// Factory constructor para obtener la instancia
  factory EventBus() => _instance;
  
  /// Constructor interno privado
  EventBus._internal();

  // =============================================
  // 2. CONTROLADORES DE STREAM PARA CADA TIPO DE EVENTO
  // =============================================

  /// Controlador para eventos de gastos agregados
  final _gastoAgregadoController =
      StreamController<GastoAgregadoEvent>.broadcast();
      
  /// Controlador para eventos de gastos eliminados
  final _gastoEliminadoController =
      StreamController<GastoEliminadoEvent>.broadcast();
      
  /// Controlador para eventos de presupuestos actualizados
  final _presupuestoActualizadoController =
      StreamController<PresupuestoActualizadoEvent>.broadcast();

  // =============================================
  // 3. STREAMS PÚBLICOS PARA SUSCRIBIRSE A EVENTOS
  // =============================================

  /// Stream para suscribirse a eventos de gastos agregados
  Stream<GastoAgregadoEvent> get onGastoAgregado =>
      _gastoAgregadoController.stream;
      
  /// Stream para suscribirse a eventos de gastos eliminados
  Stream<GastoEliminadoEvent> get onGastoEliminado =>
      _gastoEliminadoController.stream;
      
  /// Stream para suscribirse a eventos de presupuestos actualizados
  Stream<PresupuestoActualizadoEvent> get onPresupuestoActualizado =>
      _presupuestoActualizadoController.stream;

  // =============================================
  // 4. MÉTODOS PARA PUBLICAR EVENTOS
  // =============================================

  /// Notifica a los suscriptores que se ha agregado un nuevo gasto
  void notifyGastoAgregado() {
    _gastoAgregadoController.add(const GastoAgregadoEvent());
  }

  /// Notifica a los suscriptores que se ha eliminado un gasto
  void notifyGastoEliminado() {
    _gastoEliminadoController.add(const GastoEliminadoEvent());
  }

  /// Notifica a los suscriptores que se ha actualizado un presupuesto
  /// 
  /// [tipo] puede ser: 'mensual', 'semanal' o 'anual'
  void notifyPresupuestoActualizado(String tipo) {
    _presupuestoActualizadoController.add(PresupuestoActualizadoEvent(tipo));
  }

  // =============================================
  // 5. LIMPIEZA DE RECURSOS
  // =============================================

  /// Libera los recursos utilizados por los controladores de streams
  /// 
  /// Debe llamarse cuando el EventBus ya no sea necesario
  void dispose() {
    _gastoAgregadoController.close();
    _gastoEliminadoController.close();
    _presupuestoActualizadoController.close();
  }
}