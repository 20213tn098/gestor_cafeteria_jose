import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gestor_cafeteria/models/auth_failure.dart';
import 'package:gestor_cafeteria/models/usuario.dart';
import 'package:gestor_cafeteria/repositories/auth_repository.dart';

/// Estado de la sesión para las vistas de login, registro y la puerta.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _suscripcion = _repository.sesion.listen(_alCambiarSesion);
  }

  final AuthRepository _repository;
  late final StreamSubscription<Usuario?> _suscripcion;

  static final _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Usuario? _usuario;
  bool _esPersonal = false;
  bool _listo = false;
  bool _cargando = false;
  String _error = '';
  int _turnoSesion = 0;
  bool _desechado = false;

  Usuario? get usuario => _usuario;
  bool get esPersonal => _esPersonal;

  /// false hasta que el repositorio dice si hay sesión guardada.
  bool get listo => _listo;
  bool get cargando => _cargando;
  String get error => _error;

  Future<void> _alCambiarSesion(Usuario? u) async {
    final turno = ++_turnoSesion;
    final personal = u != null && await _repository.esPersonal(u.id);
    // Se desechó mientras esperaba, o ya llegó un cambio de sesión más nuevo.
    if (_desechado || turno != _turnoSesion) return;
    _usuario = u;
    _esPersonal = personal;
    _listo = true;
    notifyListeners();
  }

  static String? validarCorreo(String correo) =>
      _formatoCorreo.hasMatch(correo.trim())
      ? null
      : 'Escribe un correo válido.';

  static String? validarContrasena(String contrasena) => contrasena.length >= 8
      ? null
      : 'La contraseña debe tener al menos 8 caracteres.';

  static String? validarNombre(String nombre) =>
      nombre.trim().length >= 2 ? null : 'Escribe tu nombre (mínimo 2 letras).';

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) {
    return _ejecutar(
      [validarCorreo(correo), validarContrasena(contrasena)],
      () async {
        _usuario = await _repository.iniciarSesion(
          correo: correo.trim(),
          contrasena: contrasena,
        );
      },
    );
  }

  Future<bool> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
  }) {
    return _ejecutar(
      [
        validarNombre(nombre),
        validarCorreo(correo),
        validarContrasena(contrasena),
      ],
      () async {
        _usuario = await _repository.registrar(
          correo: correo.trim(),
          contrasena: contrasena,
          nombre: nombre.trim(),
        );
      },
    );
  }

  Future<void> cerrarSesion() => _repository.cerrarSesion();

  void limpiarError() {
    if (_error.isEmpty) return;
    _error = '';
    notifyListeners();
  }

  /// Valida antes de llamar al repositorio: un dato mal escrito no gasta red.
  Future<bool> _ejecutar(
    List<String?> validaciones,
    Future<void> Function() accion,
  ) async {
    final invalido = validaciones.firstWhere(
      (m) => m != null,
      orElse: () => null,
    );
    if (invalido != null) {
      _error = invalido;
      notifyListeners();
      return false;
    }
    _cargando = true;
    _error = '';
    notifyListeners();
    try {
      await accion();
      return true;
    } on AuthFailure catch (e) {
      _error = _mensaje(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  String _mensaje(AuthFailure falla) => switch (falla) {
    CredencialesInvalidas() => 'Correo o contraseña incorrectos.',
    CorreoYaRegistrado() => 'Ese correo ya tiene una cuenta. Inicia sesión.',
    ContrasenaDebil() => 'Esa contraseña es muy débil. Usa una más larga.',
    DemasiadosIntentos() =>
      'Demasiados intentos. Espera unos minutos e intenta de nuevo.',
    CuentaDeshabilitada() =>
      'Tu cuenta está deshabilitada. Habla con la cafetería.',
    SinConexion() => 'Sin conexión. Revisa tu internet e intenta de nuevo.',
    AuthDesconocida() => 'No pudimos completar la operación. Intenta de nuevo.',
  };

  @override
  void dispose() {
    _desechado = true;
    _suscripcion.cancel();
    super.dispose();
  }
}
