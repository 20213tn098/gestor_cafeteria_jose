# gestor_cafeteria

App Flutter de una cafetería: muestra y gestiona los pedidos (cliente, bebida, tamaño y estado) que guarda el servidor **mini_backend**. El cliente HTTP (`ApiClient`) traduce cada respuesta del servidor a un tipo de error (`Failure`) para que la interfaz distinga «no encontrado», «conflicto», «datos inválidos», «falla del servidor» y «sin conexión».

## Requisitos

- Flutter 3.47 o superior (Dart 3.13)
- Node.js 22.13 o superior (`node --version`)
- Un emulador de Android, Chrome o un celular

## Servidor: mini_backend

mini_backend es un repositorio aparte; no se copia dentro de este proyecto.

- Repositorio: https://github.com/DMI-2026/mini_backend (rama `master`)
- Versión con la que se probó: commit `94d2533` con Node.js 22.21.0

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
node server.js
```

No hace falta `npm install`. Debe aparecer `Listening on http://0.0.0.0:8000`; compruébalo en http://localhost:8000/health (responde `{"status":"ok"}`).

## Ejecutar la app

```bash
flutter pub get
flutter run                     # emulador de Android: usa http://10.0.2.2:8000
flutter run -d chrome           # Chrome: usa http://localhost:8000
flutter run --dart-define=API_URL=http://<IP de tu computadora>:8000   # celular en la misma red
```

`API_URL` sobrescribe la dirección del servidor en cualquier plataforma.

## Pruebas

```bash
flutter test      # pruebas de Failure y del ApiClient con MockClient (no necesitan servidor)
flutter analyze   # análisis estático
```

## Estructura

```
lib/
  core/
    failure.dart       # sealed class Failure y sus subtipos
    http_client.dart   # ApiClient: peticiones HTTP y mapeo de errores a Failure
  features/orders/     # (por implementar) feature de pedidos: domain, data, ui
  main.dart            # pantalla de prueba con la lista de pedidos
test/core/
  failure_test.dart
  http_client_test.dart
```
