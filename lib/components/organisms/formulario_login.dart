import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/atoms/boton_principal.dart';
import 'package:gestor_cafeteria/components/molecules/campo_contrasena.dart';
import 'package:gestor_cafeteria/components/molecules/campo_texto.dart';
import 'package:gestor_cafeteria/components/molecules/mensaje_formulario.dart';

/// Formulario de inicio de sesión: pinta lo que recibe y avisa con callbacks.
class FormularioLogin extends StatelessWidget {
  const FormularioLogin({
    super.key,
    required this.correo,
    required this.contrasena,
    required this.error,
    required this.cargando,
    required this.onEntrar,
    required this.onIrARegistro,
  });

  final TextEditingController correo;
  final TextEditingController contrasena;
  final String error;
  final bool cargando;
  final VoidCallback onEntrar;
  final VoidCallback onIrARegistro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Inicia sesión',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        CampoTexto(
          key: const Key('campo-correo'),
          controller: correo,
          etiqueta: 'Correo',
          icono: Icons.mail_outline,
          teclado: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CampoContrasena(controller: contrasena, onSubmitted: onEntrar),
        const SizedBox(height: 16),
        MensajeFormulario(mensaje: error),
        const SizedBox(height: 16),
        BotonPrincipal(
          texto: 'Entrar',
          cargando: cargando,
          onPressed: onEntrar,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: cargando ? null : onIrARegistro,
          child: const Text('Crear una cuenta'),
        ),
      ],
    );
  }
}
