import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/models/pedido.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';

/// Traduce el código de error de Firestore a los [Failure] que la app ya
/// conoce. No hay HTTP aquí: 403 es una equivalencia para «sin permiso».
Failure failureDesdeFirestore(String codigo) => switch (codigo) {
  'permission-denied' => const UnexpectedFailure(403, 'permission-denied'),
  'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
  'not-found' => const NotFoundFailure('El pedido ya no existe'),
  _ => UnexpectedFailure(0, 'Firestore: $codigo'),
};

/// Pedidos en Cloud Firestore (colección `pedidos`).
class FirestorePedidoRepository implements PedidoRepository {
  FirestorePedidoRepository({FirebaseFirestore? firestore})
    : _pedidos = (firestore ?? FirebaseFirestore.instance).collection(
        'pedidos',
      );

  final CollectionReference<Map<String, dynamic>> _pedidos;

  /// El id vive en el documento, no en sus campos: se agrega al leer.
  Pedido _aPedido(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data()!;
    final creado = datos['creado'];
    return Pedido.fromJson({
      ...datos,
      'id': doc.id,
      'creado': creado is Timestamp ? creado.toDate() : null,
    });
  }

  Future<T> _intentar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on FirebaseException catch (e) {
      throw failureDesdeFirestore(e.code);
    }
  }

  List<Pedido> _recientesPrimero(QuerySnapshot<Map<String, dynamic>> q) {
    final lista = q.docs.map(_aPedido).toList();
    // Sin orderBy en la consulta: evita crear un índice compuesto
    // (usuario_id + creado) solo para ordenar unos cuantos pedidos.
    lista.sort(
      (a, b) => (b.creado ?? DateTime(0)).compareTo(a.creado ?? DateTime(0)),
    );
    return lista;
  }

  @override
  Future<List<Pedido>> listarMios(String usuarioId) => _intentar(() async {
    // El filtro es obligatorio: las reglas rechazan una consulta que
    // pudiera traer pedidos de otras personas.
    final q = await _pedidos.where('usuario_id', isEqualTo: usuarioId).get();
    return _recientesPrimero(q);
  });

  @override
  Future<List<Pedido>> listarTodos() =>
      _intentar(() async => _recientesPrimero(await _pedidos.get()));

  @override
  Future<Pedido> crear({
    required String usuarioId,
    required String cliente,
    required Bebida bebida,
    required Tamano tamano,
  }) => _intentar(() async {
    final nuevo = Pedido(
      id: '',
      usuarioId: usuarioId,
      cliente: cliente,
      bebida: bebida,
      tamano: tamano,
    );
    final ref = await _pedidos.add({
      ...nuevo.toJson(),
      // La hora la pone el servidor; las reglas exigen request.time.
      'creado': FieldValue.serverTimestamp(),
    });
    return _aPedido(await ref.get());
  });

  @override
  Future<Pedido> cambiarEstado(String id, EstadoPedido estado) =>
      _intentar(() async {
        await _pedidos.doc(id).update({'estado': estado.name});
        return _aPedido(await _pedidos.doc(id).get());
      });
}
