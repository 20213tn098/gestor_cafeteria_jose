/// Persona con sesión. El [id] es el uid de Firebase Auth.
class Usuario {
  const Usuario({required this.id, required this.correo, required this.nombre});

  final String id;
  final String correo;
  final String nombre;
}
