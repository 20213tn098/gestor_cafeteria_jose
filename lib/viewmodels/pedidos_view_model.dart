import 'package:flutter/foundation.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/models/pedido.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';

/// Lista y crea pedidos; el personal además cambia su estado.
class PedidosViewModel extends ChangeNotifier {
  PedidosViewModel(
    this._repository, {
    required this.usuarioId,
    required this.esPersonal,
  });

  final PedidoRepository _repository;
  final String usuarioId;
  final bool esPersonal;

  List<Pedido> _pedidos = const [];
  bool _cargando = false;
  String _error = '';

  List<Pedido> get pedidos => _pedidos;
  bool get cargando => _cargando;
  String get error => _error;

  static String? validarCliente(String cliente) {
    final c = cliente.trim();
    return c.isNotEmpty && c.length <= 50
        ? null
        : 'Escribe el nombre para llamar tu pedido (1 a 50 letras).';
  }

  Future<bool> cargar() => _ejecutar('cargar los pedidos', () async {
    _pedidos = esPersonal
        ? await _repository.listarTodos()
        : await _repository.listarMios(usuarioId);
  });

  Future<bool> crear({
    required String cliente,
    required Bebida bebida,
    required Tamano tamano,
  }) async {
    final invalido = validarCliente(cliente);
    if (invalido != null) {
      _error = invalido;
      notifyListeners();
      return false;
    }
    return _ejecutar('crear el pedido', () async {
      await _repository.crear(
        usuarioId: usuarioId,
        cliente: cliente.trim(),
        bebida: bebida,
        tamano: tamano,
      );
      _pedidos = esPersonal
          ? await _repository.listarTodos()
          : await _repository.listarMios(usuarioId);
    });
  }

  Future<bool> cambiarEstado(String id, EstadoPedido estado) =>
      _ejecutar('cambiar el estado', () async {
        final actualizado = await _repository.cambiarEstado(id, estado);
        _pedidos = [for (final p in _pedidos) p.id == id ? actualizado : p];
      });

  Future<bool> _ejecutar(
    String queHacer,
    Future<void> Function() accion,
  ) async {
    _cargando = true;
    _error = '';
    notifyListeners();
    try {
      await accion();
      return true;
    } on Failure catch (f) {
      _error = _mensaje(f, queHacer);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _mensaje(Failure failure, String queHacer) => switch (failure) {
    NetworkFailure() =>
      'No pudimos $queHacer: revisa tu conexión e intenta de nuevo.',
    // Con Firestore, 403 significa que las reglas negaron la operación.
    // Va antes del caso general: Dart usa el primer patrón que coincide.
    UnexpectedFailure(statusCode: 403) =>
      'No tienes permiso para $queHacer. '
          'Solo el personal de la cafetería puede hacerlo.',
    UnexpectedFailure(:final statusCode) =>
      'Ocurrió un error inesperado ($statusCode) al $queHacer. Intenta de nuevo.',
    NotFoundFailure(:final message) => '$message. Recarga la lista.',
    ConflictFailure(:final message) => message,
    ValidationFailure() => 'Revisa los datos del pedido.',
    ServerFailure(:final statusCode) =>
      'El servidor tuvo un problema ($statusCode). Intenta más tarde.',
  };
}
