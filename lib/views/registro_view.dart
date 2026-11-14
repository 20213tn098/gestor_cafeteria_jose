import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/organisms/formulario_registro.dart';
import 'package:gestor_cafeteria/viewmodels/auth_view_model.dart';

/// Pantalla de registro; es dueña de los tres controladores de texto.
class RegistroView extends StatefulWidget {
  const RegistroView({
    super.key,
    required this.viewModel,
    required this.onIrALogin,
  });

  final AuthViewModel viewModel;
  final VoidCallback onIrALogin;

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _enviar() => widget.viewModel.registrar(
    nombre: _nombre.text,
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
                builder: (context, _) => FormularioRegistro(
                  nombre: _nombre,
                  correo: _correo,
                  contrasena: _contrasena,
                  error: widget.viewModel.error,
                  cargando: widget.viewModel.cargando,
                  onRegistrar: _enviar,
                  onIrALogin: widget.onIrALogin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
