import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/models/auth_failure.dart';
import 'package:gestor_cafeteria/models/usuario.dart';
import 'package:gestor_cafeteria/viewmodels/auth_view_model.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late AuthViewModel vm;

  setUp(() {
    repo = FakeAuthRepository();
    vm = AuthViewModel(repo);
  });

  tearDown(() => vm.dispose());

  group('validaciones', () {
    test('validarCorreo pide arroba y dominio', () {
      expect(AuthViewModel.validarCorreo('ana@utez.edu.mx'), isNull);
      expect(AuthViewModel.validarCorreo('ana.utez'), 'Escribe un correo válido.');
    });

    test('validarContrasena pide 8 caracteres', () {
      expect(AuthViewModel.validarContrasena('cafeteria'), isNull);
      expect(
        AuthViewModel.validarContrasena('cafe123'),
        'La contraseña debe tener al menos 8 caracteres.',
      );
    });

    test('validarNombre pide 2 letras sin contar espacios', () {
      expect(AuthViewModel.validarNombre('Al'), isNull);
      expect(
        AuthViewModel.validarNombre(' A '),
        'Escribe tu nombre (mínimo 2 letras).',
      );
    });
  });

  group('registrar', () {
    test('con nombre de una letra no llama al repositorio', () async {
      final ok = await vm.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: ' A ',
      );

      expect(ok, isFalse);
      expect(vm.usuario, isNull);
      expect(vm.error, 'Escribe tu nombre (mínimo 2 letras).');
      expect(repo.llamadas, 0);
    });

    test('con correo inválido no llama al repositorio', () async {
      final ok = await vm.registrar(
        correo: 'ana.utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: 'Ana',
      );

      expect(ok, isFalse);
      expect(vm.error, 'Escribe un correo válido.');
      expect(repo.llamadas, 0);
    });

    test('con datos válidos guarda al usuario sin espacios', () async {
      final ok = await vm.registrar(
        correo: ' ana@utez.edu.mx ',
        contrasena: 'cafeteria2026',
        nombre: ' Ana ',
      );

      expect(ok, isTrue);
      expect(vm.usuario?.correo, 'ana@utez.edu.mx');
      expect(vm.usuario?.nombre, 'Ana');
      expect(vm.error, isEmpty);
    });

    test('correo ya registrado muestra un mensaje claro', () async {
      repo.fallaSiguiente = const CorreoYaRegistrado();

      final ok = await vm.registrar(
        correo: 'ana@utez.edu.mx',
        contrasena: 'cafeteria2026',
        nombre: 'Ana',
      );

      expect(ok, isFalse);
      expect(vm.error, 'Ese correo ya tiene una cuenta. Inicia sesión.');
      expect(vm.cargando, isFalse);
    });
  });

  group('iniciarSesion', () {
    test('credenciales inválidas no muestran el código de Firebase', () async {
      repo.fallaSiguiente = const CredencialesInvalidas();

      final ok = await vm.iniciarSesion(
        correo: 'ana@utez.edu.mx',
        contrasena: 'equivocada',
      );

      expect(ok, isFalse);
      expect(vm.error, 'Correo o contraseña incorrectos.');
    });

    test('sin conexión pide revisar la red', () async {
      repo.fallaSiguiente = const SinConexion();

      await vm.iniciarSesion(correo: 'ana@utez.edu.mx', contrasena: 'cafeteria');

      expect(vm.error, 'Sin conexión. Revisa tu internet e intenta de nuevo.');
    });
  });

  test('la sesión guardada se recuerda al crear el ViewModel', () async {
    final conSesion = FakeAuthRepository(
      inicial: const Usuario(id: 'uid-1', correo: 'ana@utez.edu.mx', nombre: 'Ana'),
      personal: {'uid-1'},
    );
    final vm2 = AuthViewModel(conSesion);
    await pumpEventQueue();

    expect(vm2.listo, isTrue);
    expect(vm2.usuario?.id, 'uid-1');
    expect(vm2.esPersonal, isTrue);
    vm2.dispose();
  });

  test('limpiarError borra el mensaje', () async {
    await vm.registrar(correo: 'x', contrasena: 'x', nombre: 'x');
    vm.limpiarError();
    expect(vm.error, isEmpty);
  });
}
