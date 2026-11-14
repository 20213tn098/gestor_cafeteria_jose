import 'package:gestor_cafeteria/models/pedido.dart';

/// Contrato de los pedidos. Las implementaciones lanzan solo `Failure`.
abstract interface class PedidoRepository {
  /// Pedidos de una persona, del más reciente al más antiguo.
  Future<List<Pedido>> listarMios(String usuarioId);

  /// Todos los pedidos (solo el personal tiene permiso).
  Future<List<Pedido>> listarTodos();

  Future<Pedido> crear({
    required String usuarioId,
    required String cliente,
    required Bebida bebida,
    required Tamano tamano,
  });

  Future<Pedido> cambiarEstado(String id, EstadoPedido estado);
}
