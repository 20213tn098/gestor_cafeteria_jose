import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/repositories/auth_repository.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';
import 'package:gestor_cafeteria/viewmodels/auth_view_model.dart';
import 'package:gestor_cafeteria/views/home_view.dart';
import 'package:gestor_cafeteria/views/login_view.dart';
import 'package:gestor_cafeteria/views/registro_view.dart';

/// Decide qué pantalla mostrar a partir del estado de la sesión.
class PuertaSesionView extends StatefulWidget {
  const PuertaSesionView({
    super.key,
    required this.authRepository,
    required this.pedidoRepository,
  });

  final AuthRepository authRepository;
  final PedidoRepository pedidoRepository;

  @override
  State<PuertaSesionView> createState() => _PuertaSesionViewState();
}

class _PuertaSesionViewState extends State<PuertaSesionView> {
  late final AuthViewModel _auth = AuthViewModel(widget.authRepository);
  bool _mostrarRegistro = false;

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        // Mientras Firebase dice si hay sesión guardada.
        if (!_auth.listo) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final usuario = _auth.usuario;
        if (usuario != null) {
          return HomeView(
            // Otra persona o rol: HomeView nueva con su propio ViewModel.
            key: ValueKey('${usuario.id}-${_auth.esPersonal}'),
            repository: widget.pedidoRepository,
            usuario: usuario,
            esPersonal: _auth.esPersonal,
            onCerrarSesion: _auth.cerrarSesion,
          );
        }
        // Un booleano en lugar de rutas: al entrar no queda nada apilado
        // debajo de los pedidos.
        if (_mostrarRegistro) {
          return RegistroView(
            viewModel: _auth,
            onIrALogin: () => _cambiarA(registro: false),
          );
        }
        return LoginView(
          viewModel: _auth,
          onIrARegistro: () => _cambiarA(registro: true),
        );
      },
    );
  }

  void _cambiarA({required bool registro}) {
    _auth.limpiarError();
    setState(() => _mostrarRegistro = registro);
  }
}
