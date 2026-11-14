import 'package:flutter/material.dart';

/// Campo de texto con etiqueta e ícono, con el estilo de los formularios.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.teclado = TextInputType.text,
  });

  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final TextInputType teclado;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
