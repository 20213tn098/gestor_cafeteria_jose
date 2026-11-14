import 'package:flutter/material.dart';

/// Aviso de error de un formulario; no ocupa espacio si no hay mensaje.
class MensajeFormulario extends StatelessWidget {
  const MensajeFormulario({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    if (mensaje.isEmpty) return const SizedBox.shrink();
    final colores = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colores.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: colores.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
