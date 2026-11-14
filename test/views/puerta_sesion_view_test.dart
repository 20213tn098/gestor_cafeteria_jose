import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/main.dart';
import 'package:gestor_cafeteria/models/usuario.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_pedido_repository.dart';

void main() {
  Future<void> abrir(WidgetTester tester, FakeAuthRepository auth) async {
    await tester.pumpWidget(
      CafeteriaApp(authRepository: auth, pedidoRepository: FakePedidoRepository()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin sesión la app abre en el login', (tester) async {
    await abrir(tester, FakeAuthRepository());

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Mis pedidos'), findsNothing);
  });

  testWidgets('con sesión guardada entra directo a los pedidos', (tester) async {
    await abrir(
      tester,
      FakeAuthRepository(
        inicial: const Usuario(id: 'uid-1', correo: 'ana@utez.edu.mx', nombre: 'Ana'),
      ),
    );

    expect(find.text('Mis pedidos'), findsOneWidget);
  });

  testWidgets('registrarse desde el login lleva a los pedidos', (tester) async {
    await abrir(tester, FakeAuthRepository());

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Ana');
    await tester.enterText(find.byKey(const Key('campo-correo')), 'ana@utez.edu.mx');
    await tester.enterText(find.byKey(const Key('campo-contrasena')), 'cafeteria2026');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Mis pedidos'), findsOneWidget);
  });

  testWidgets('al cambiar a registro se borra el error del login', (tester) async {
    await abrir(tester, FakeAuthRepository());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un correo válido.'), findsOneWidget);

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un correo válido.'), findsNothing);
  });

  testWidgets('cerrar sesión regresa al login', (tester) async {
    await abrir(
      tester,
      FakeAuthRepository(
        inicial: const Usuario(id: 'uid-1', correo: 'ana@utez.edu.mx', nombre: 'Ana'),
      ),
    );

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Inicia sesión'), findsOneWidget);
  });
}
