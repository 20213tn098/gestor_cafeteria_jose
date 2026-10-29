import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

//Crea un ApiClient con un MockClient que siempre responde lo indicado
ApiClient clienteQueResponde(Object? cuerpo, int codigo) {
  final mock = MockClient((request) async {
    return http.Response(
      cuerpo == null ? '' : jsonEncode(cuerpo),
      codigo,
      headers: {'content-type': 'application/json'},
    );
  });
  return ApiClient(client: mock, baseUrl: 'http://prueba');
}

void main() {
  group('ApiClient', () {
    test('GET exitoso devuelve el JSON decodificado', () async {
      final api = clienteQueResponde([
        {'id': 1, 'customer': 'Ana'},
      ], 200);

      final resultado = await api.get('/orders');

      expect(resultado, [
        {'id': 1, 'customer': 'Ana'},
      ]);
    });

    test('404 lanza NotFoundFailure con el mensaje de detail', () {
      final api = clienteQueResponde({'detail': 'Order 9 not found'}, 404);

      expect(
        api.get('/orders/9'),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.message,
            'message',
            'Order 9 not found',
          ),
        ),
      );
    });

    test('409 lanza ConflictFailure con el mensaje de detail', () {
      final api = clienteQueResponde({
        'detail': 'Cannot change status from pending to delivered',
      }, 409);

      expect(
        api.patch('/orders/1', {'status': 'delivered'}),
        throwsA(
          isA<ConflictFailure>().having(
            (f) => f.message,
            'message',
            'Cannot change status from pending to delivered',
          ),
        ),
      );
    });

    test('422 lanza ValidationFailure con los campos de detail', () {
      final api = clienteQueResponde({
        'detail': [
          {
            'loc': ['body', 'customer'],
            'msg': 'Must be 1-50 characters',
          },
        ],
      }, 422);

      expect(
        api.post('/orders', {'customer': '', 'drink': 'latte', 'size': 'M'}),
        throwsA(
          isA<ValidationFailure>().having((f) => f.fields, 'fields', {
            'customer': 'Must be 1-50 characters',
          }),
        ),
      );
    });

    test('503 lanza ServerFailure con statusCode 503', () {
      final api = clienteQueResponde({'detail': 'Simulated failure'}, 503);

      expect(
        api.get('/orders'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('sin conexión lanza NetworkFailure', () {
      final mock = MockClient((request) async {
        throw http.ClientException('sin red');
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('tiempo agotado lanza NetworkFailure', () {
      final mock = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('[]', 200);
      });
      final api = ApiClient(
        client: mock,
        baseUrl: 'http://prueba',
        timeout: const Duration(milliseconds: 50),
      );

      expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('300 no es éxito: lanza UnexpectedFailure', () {
      final api = clienteQueResponde({'detail': 'Multiple Choices'}, 300);

      expect(
        api.get('/orders'),
        throwsA(
          isA<UnexpectedFailure>()
              .having((f) => f.statusCode, 'statusCode', 300)
              .having((f) => f.message, 'message', 'Multiple Choices'),
        ),
      );
    });
  });
}
