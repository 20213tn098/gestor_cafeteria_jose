import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/organisms/formulario_login.dart';
import 'package:gestor_cafeteria/viewmodels/auth_view_model.dart';

/// Pantalla de inicio de sesión; es dueña de los controladores de texto.
class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.viewModel,
    required this.onIrARegistro,
  });

  final AuthViewModel viewModel;
  final VoidCallback onIrARegistro;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _entrar() => widget.viewModel.iniciarSesion(
    correo: _correo.text,
    contrasena: _contrasena.text,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => FormularioLogin(
                  correo: _correo,
                  contrasena: _contrasena,
                  error: widget.viewModel.error,
                  cargando: widget.viewModel.cargando,
                  onEntrar: _entrar,
                  onIrARegistro: widget.onIrARegistro,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
