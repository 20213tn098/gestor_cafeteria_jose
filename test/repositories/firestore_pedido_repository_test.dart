import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/models/pedido.dart';
import 'package:gestor_cafeteria/repositories/firestore_pedido_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePedidoRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestorePedidoRepository(firestore: db);
  });

  test('crear guarda los campos del contrato con estado pending', () async {
    final p = await repo.crear(
      usuarioId: 'ana',
      cliente: 'Ana',
      bebida: Bebida.latte,
      tamano: Tamano.m,
    );

    final doc = await db.collection('pedidos').doc(p.id).get();
    expect(doc.data()!..remove('creado'), {
      'usuario_id': 'ana',
      'cliente': 'Ana',
      'bebida': 'latte',
      'tamano': 'M',
      'estado': 'pending',
    });
    expect(p.estado, EstadoPedido.pending);
  });

  test('listarMios trae solo los pedidos de esa persona', () async {
    await repo.crear(
      usuarioId: 'ana',
      cliente: 'Ana',
      bebida: Bebida.latte,
      tamano: Tamano.m,
    );
    await repo.crear(
      usuarioId: 'beto',
      cliente: 'Beto',
      bebida: Bebida.mocha,
      tamano: Tamano.l,
    );

    final mios = await repo.listarMios('ana');

    expect(mios.map((p) => p.cliente), ['Ana']);
    expect(await repo.listarTodos(), hasLength(2));
  });

  test('cambiarEstado solo modifica el estado', () async {
    final p = await repo.crear(
      usuarioId: 'ana',
      cliente: 'Ana',
      bebida: Bebida.latte,
      tamano: Tamano.s,
    );

    final actualizado = await repo.cambiarEstado(p.id, EstadoPedido.preparing);

    expect(actualizado.estado, EstadoPedido.preparing);
    expect(actualizado.cliente, 'Ana');
    expect(actualizado.tamano, Tamano.s);
  });
}
