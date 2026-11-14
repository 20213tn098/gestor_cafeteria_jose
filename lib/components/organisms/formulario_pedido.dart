import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/atoms/boton_principal.dart';
import 'package:gestor_cafeteria/components/molecules/campo_texto.dart';
import 'package:gestor_cafeteria/models/pedido.dart';

/// Formulario de pedido nuevo: nombre para llamarlo, bebida y tamaño.
class FormularioPedido extends StatefulWidget {
  const FormularioPedido({
    super.key,
    required this.nombreInicial,
    required this.onGuardar,
  });

  final String nombreInicial;
  final void Function(String cliente, Bebida bebida, Tamano tamano) onGuardar;

  @override
  State<FormularioPedido> createState() => _FormularioPedidoState();
}

class _FormularioPedidoState extends State<FormularioPedido> {
  late final _cliente = TextEditingController(text: widget.nombreInicial);
  Bebida _bebida = Bebida.latte;
  Tamano _tamano = Tamano.m;

  @override
  void dispose() {
    _cliente.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Nuevo pedido', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        CampoTexto(
          key: const Key('campo-cliente'),
          controller: _cliente,
          etiqueta: 'Nombre para llamarte',
          icono: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Bebida>(
          initialValue: _bebida,
          decoration: const InputDecoration(
            labelText: 'Bebida',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final b in Bebida.values)
              DropdownMenuItem(value: b, child: Text(b.name)),
          ],
          onChanged: (b) => setState(() => _bebida = b ?? _bebida),
        ),
        const SizedBox(height: 16),
        SegmentedButton<Tamano>(
          segments: [
            for (final t in Tamano.values)
              ButtonSegment(value: t, label: Text(t.json)),
          ],
          selected: {_tamano},
          onSelectionChanged: (s) => setState(() => _tamano = s.first),
        ),
        const SizedBox(height: 24),
        BotonPrincipal(
          texto: 'Pedir',
          onPressed: () => widget.onGuardar(_cliente.text, _bebida, _tamano),
        ),
      ],
    );
  }
}
