import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/models/pedido.dart';
import 'package:gestor_cafeteria/viewmodels/pedidos_view_model.dart';

import '../fakes/fake_pedido_repository.dart';

void main() {
  late FakePedidoRepository repo;

  PedidosViewModel cliente() =>
      PedidosViewModel(repo, usuarioId: 'ana', esPersonal: false);

  setUp(() => repo = FakePedidoRepository());

  test('el cliente solo carga sus pedidos', () async {
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
      tamano: Tamano.s,
    );
    final vm = cliente();

    await vm.cargar();

    expect(vm.pedidos.map((p) => p.cliente), ['Ana']);
    expect(vm.error, isEmpty);
  });

  test('el personal carga todos los pedidos', () async {
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
      tamano: Tamano.s,
    );
    final vm = PedidosViewModel(repo, usuarioId: 'staff', esPersonal: true);

    await vm.cargar();

    expect(vm.pedidos, hasLength(2));
  });

  test('crear valida el nombre antes de llamar al repositorio', () async {
    final vm = cliente();

    final ok = await vm.crear(
      cliente: '   ',
      bebida: Bebida.latte,
      tamano: Tamano.m,
    );

    expect(ok, isFalse);
    expect(
      vm.error,
      'Escribe el nombre para llamar tu pedido (1 a 50 letras).',
    );
    expect(repo.pedidos, isEmpty);
  });

  test('crear agrega el pedido y recarga la lista', () async {
    final vm = cliente();

    final ok = await vm.crear(
      cliente: ' Ana ',
      bebida: Bebida.latte,
      tamano: Tamano.m,
    );

    expect(ok, isTrue);
    expect(vm.pedidos.single.cliente, 'Ana');
    expect(vm.pedidos.single.estado, EstadoPedido.pending);
  });

  test('sin permiso (403) lo dice en lugar de culpar a los datos', () async {
    final vm = cliente();
    repo.fallaSiguiente = const UnexpectedFailure(403, 'permission-denied');

    final ok = await vm.cambiarEstado('1', EstadoPedido.preparing);

    expect(ok, isFalse);
    expect(
      vm.error,
      'No tienes permiso para cambiar el estado. '
      'Solo el personal de la cafetería puede hacerlo.',
    );
  });

  test('otro código inesperado sí muestra el código', () async {
    final vm = cliente();
    repo.fallaSiguiente = const UnexpectedFailure(418, 'Firestore: raro');

    await vm.cargar();

    expect(
      vm.error,
      'Ocurrió un error inesperado (418) al cargar los pedidos. Intenta de nuevo.',
    );
  });

  test('sin conexión pide revisar la red', () async {
    final vm = cliente();
    repo.fallaSiguiente = const NetworkFailure();

    await vm.cargar();

    expect(
      vm.error,
      'No pudimos cargar los pedidos: revisa tu conexión e intenta de nuevo.',
    );
  });
}
