import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/atoms/boton_principal.dart';
import 'package:gestor_cafeteria/components/molecules/campo_contrasena.dart';
import 'package:gestor_cafeteria/components/molecules/campo_texto.dart';
import 'package:gestor_cafeteria/components/molecules/mensaje_formulario.dart';

/// Formulario de registro: mismo patrón que [FormularioLogin] más el nombre.
class FormularioRegistro extends StatelessWidget {
  const FormularioRegistro({
    super.key,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.error,
    required this.cargando,
    required this.onRegistrar,
    required this.onIrALogin,
  });

  final TextEditingController nombre;
  final TextEditingController correo;
  final TextEditingController contrasena;
  final String error;
  final bool cargando;
  final VoidCallback onRegistrar;
  final VoidCallback onIrALogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crea tu cuenta',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        CampoTexto(
          key: const Key('campo-nombre'),
          controller: nombre,
          etiqueta: 'Nombre',
          icono: Icons.person_outline,
          teclado: TextInputType.name,
        ),
        const SizedBox(height: 16),
        CampoTexto(
          key: const Key('campo-correo'),
          controller: correo,
          etiqueta: 'Correo',
          icono: Icons.mail_outline,
          teclado: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CampoContrasena(controller: contrasena, onSubmitted: onRegistrar),
        const SizedBox(height: 16),
        MensajeFormulario(mensaje: error),
        const SizedBox(height: 16),
        BotonPrincipal(
          texto: 'Registrarme',
          cargando: cargando,
          onPressed: onRegistrar,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: cargando ? null : onIrALogin,
          child: const Text('Ya tengo cuenta'),
        ),
      ],
    );
  }
}
