//Fallas de la sesion: el ViewModel solo conoce estas, nunca una excepcion de Firebase

sealed class AuthFailure implements Exception {
  const AuthFailure();
}

//Correo o contraseña mal (Firebase ya no distingue cual de los dos)
final class CredencialesInvalidas extends AuthFailure {
  const CredencialesInvalidas();
}

final class CorreoYaRegistrado extends AuthFailure {
  const CorreoYaRegistrado();
}

final class ContrasenaDebil extends AuthFailure {
  const ContrasenaDebil();
}

final class DemasiadosIntentos extends AuthFailure {
  const DemasiadosIntentos();
}

final class CuentaDeshabilitada extends AuthFailure {
  const CuentaDeshabilitada();
}

final class SinConexion extends AuthFailure {
  const SinConexion();
}

//Cualquier codigo que todavia no traducimos
final class AuthDesconocida extends AuthFailure {
  const AuthDesconocida();
}
