import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/models/pedido.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';

/// Doble de [PedidoRepository] en memoria.
class FakePedidoRepository implements PedidoRepository {
  final List<Pedido> pedidos = [];

  /// Si no es null, la próxima operación lanza esta falla.
  Failure? fallaSiguiente;
  int _siguienteId = 1;

  void _revisarFalla() {
    final falla = fallaSiguiente;
    fallaSiguiente = null;
    if (falla != null) throw falla;
  }

  @override
  Future<List<Pedido>> listarMios(String usuarioId) async {
    _revisarFalla();
    return pedidos.where((p) => p.usuarioId == usuarioId).toList();
  }

  @override
  Future<List<Pedido>> listarTodos() async {
    _revisarFalla();
    return List.of(pedidos);
  }

  @override
  Future<Pedido> crear({
    required String usuarioId,
    required String cliente,
    required Bebida bebida,
    required Tamano tamano,
  }) async {
    _revisarFalla();
    final p = Pedido(
      id: '${_siguienteId++}',
      usuarioId: usuarioId,
      cliente: cliente,
      bebida: bebida,
      tamano: tamano,
    );
    pedidos.insert(0, p);
    return p;
  }

  @override
  Future<Pedido> cambiarEstado(String id, EstadoPedido estado) async {
    _revisarFalla();
    final i = pedidos.indexWhere((p) => p.id == id);
    final p = pedidos[i];
    final nuevo = Pedido(
      id: p.id,
      usuarioId: p.usuarioId,
      cliente: p.cliente,
      bebida: p.bebida,
      tamano: p.tamano,
      estado: estado,
    );
    pedidos[i] = nuevo;
    return nuevo;
  }
}
