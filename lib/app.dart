import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/repositories/auth_repository.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';
import 'package:gestor_cafeteria/views/puerta_sesion_view.dart';

/// Raíz de la app. Recibe los repositorios desde main() y las pruebas le
/// pasan dobles, así ninguna pantalla depende de Firebase.
class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({
    super.key,
    required this.authRepository,
    required this.pedidoRepository,
  });

  final AuthRepository authRepository;
  final PedidoRepository pedidoRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true),
      home: PuertaSesionView(
        authRepository: authRepository,
        pedidoRepository: pedidoRepository,
      ),
    );
  }
}
