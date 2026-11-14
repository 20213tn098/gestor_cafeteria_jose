import 'package:flutter/material.dart';

/// Botón principal: se desactiva y muestra un indicador mientras [cargando].
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  final String texto;
  final VoidCallback onPressed;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(texto),
      ),
    );
  }
}
