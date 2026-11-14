import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/models/pedido.dart';

/// Un pedido en la lista. Si [onCambiarEstado] es null no hay menú de estados.
class TarjetaPedido extends StatelessWidget {
  const TarjetaPedido({super.key, required this.pedido, this.onCambiarEstado});

  final Pedido pedido;
  final void Function(EstadoPedido estado)? onCambiarEstado;

  static const _etiquetas = {
    EstadoPedido.pending: 'Pendiente',
    EstadoPedido.preparing: 'Preparando',
    EstadoPedido.ready: 'Listo',
    EstadoPedido.delivered: 'Entregado',
    EstadoPedido.cancelled: 'Cancelado',
  };

  @override
  Widget build(BuildContext context) {
    final cambiar = onCambiarEstado;
    final siguientes = pedido.estado.siguientes;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.local_cafe)),
        title: Text('${pedido.bebida.name} · ${pedido.tamano.json}'),
        // El estado va debajo del nombre: a la derecha solo cabe el menú
        // sin apretar el texto en pantallas angostas.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para ${pedido.cliente}'),
            const SizedBox(height: 6),
            Chip(
              label: Text(_etiquetas[pedido.estado]!),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        trailing: cambiar != null && siguientes.isNotEmpty
            ? PopupMenuButton<EstadoPedido>(
                tooltip: 'Cambiar estado',
                onSelected: cambiar,
                itemBuilder: (_) => [
                  for (final e in siguientes)
                    PopupMenuItem(value: e, child: Text(_etiquetas[e]!)),
                ],
              )
            : null,
      ),
    );
  }
}
