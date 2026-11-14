import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/components/molecules/mensaje_formulario.dart';
import 'package:gestor_cafeteria/components/organisms/formulario_pedido.dart';
import 'package:gestor_cafeteria/components/organisms/tarjeta_pedido.dart';
import 'package:gestor_cafeteria/models/usuario.dart';
import 'package:gestor_cafeteria/repositories/pedido_repository.dart';
import 'package:gestor_cafeteria/viewmodels/pedidos_view_model.dart';

/// Pedidos: el cliente ve y crea los suyos; el personal ve todos y los avanza.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.repository,
    required this.usuario,
    required this.esPersonal,
    required this.onCerrarSesion,
  });

  final PedidoRepository repository;
  final Usuario usuario;
  final bool esPersonal;
  final VoidCallback onCerrarSesion;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PedidosViewModel _vm = PedidosViewModel(
    widget.repository,
    usuarioId: widget.usuario.id,
    esPersonal: widget.esPersonal,
  );

  @override
  void initState() {
    super.initState();
    _vm.cargar();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _nuevoPedido() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (hoja) => Padding(
        // Teclado abierto: viewInsets. Cerrado: la barra de navegación de
        // Android (viewPadding), para que «Pedir» no quede debajo de ella.
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 +
              math.max(
                MediaQuery.viewInsetsOf(hoja).bottom,
                MediaQuery.viewPaddingOf(hoja).bottom,
              ),
        ),
        child: FormularioPedido(
          nombreInicial: widget.usuario.nombre,
          onGuardar: (cliente, bebida, tamano) async {
            final ok = await _vm.crear(
              cliente: cliente,
              bebida: bebida,
              tamano: tamano,
            );
            if (ok && hoja.mounted) Navigator.of(hoja).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esPersonal ? 'Pedidos de la cafetería' : 'Mis pedidos',
        ),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _vm.cargar,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: widget.onCerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoPedido,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                'Hola, ${widget.usuario.nombre}'
                '${widget.esPersonal ? ' (personal)' : ''}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              MensajeFormulario(mensaje: _vm.error),
              if (_vm.cargando) const LinearProgressIndicator(),
              if (!_vm.cargando && _vm.pedidos.isEmpty && _vm.error.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Todavía no hay pedidos.',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final p in _vm.pedidos)
                TarjetaPedido(
                  pedido: p,
                  // Ocultar el menú no es seguridad: las reglas también lo niegan.
                  onCambiarEstado: widget.esPersonal
                      ? (e) => _vm.cambiarEstado(p.id, e)
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }
}
