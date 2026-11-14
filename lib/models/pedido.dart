//Pedido de la cafeteria: mismos valores que valida mini_backend

enum Bebida { espresso, americano, latte, cappuccino, mocha }

enum Tamano {
  s('S'),
  m('M'),
  l('L');

  const Tamano(this.json);

  /// Valor guardado en el documento (igual que la API).
  final String json;

  static Tamano desdeJson(String valor) =>
      values.firstWhere((t) => t.json == valor);
}

enum EstadoPedido {
  pending,
  preparing,
  ready,
  delivered,
  cancelled;

  /// Transiciones permitidas; firestore.rules repite la misma tabla.
  List<EstadoPedido> get siguientes => switch (this) {
    pending => const [preparing, cancelled],
    preparing => const [ready, cancelled],
    ready => const [delivered],
    delivered || cancelled => const [],
  };
}

class Pedido {
  const Pedido({
    required this.id,
    required this.usuarioId,
    required this.cliente,
    required this.bebida,
    required this.tamano,
    this.estado = EstadoPedido.pending,
    this.creado,
  });

  final String id;
  final String usuarioId;
  final String cliente;
  final Bebida bebida;
  final Tamano tamano;
  final EstadoPedido estado;
  final DateTime? creado;

  /// Campos del documento en `pedidos/{id}`; el id y la fecha los pone Firestore.
  Map<String, dynamic> toJson() => {
    'usuario_id': usuarioId,
    'cliente': cliente,
    'bebida': bebida.name,
    'tamano': tamano.json,
    'estado': estado.name,
  };

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    id: json['id'] as String,
    usuarioId: json['usuario_id'] as String,
    cliente: json['cliente'] as String,
    bebida: Bebida.values.byName(json['bebida'] as String),
    tamano: Tamano.desdeJson(json['tamano'] as String),
    estado: EstadoPedido.values.byName(json['estado'] as String),
    creado: json['creado'] as DateTime?,
  );
}
