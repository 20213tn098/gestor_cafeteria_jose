# gestor_cafeteria

App Flutter de una cafetería. Cada cliente se registra, inicia sesión y pide su bebida (nombre, bebida y tamaño); el personal de la cafetería ve todos los pedidos y los avanza de estado (`pending → preparing → ready → delivered`, o `cancelled`). La sesión vive en **Firebase Auth** y los datos en **Cloud Firestore**, protegidos con `firestore.rules`.

## Requisitos

- Flutter 3.47 o superior (Dart 3.13)
- Un emulador de Android (API 24 o superior), Chrome o un celular
- Para las reglas y el emulador: Node.js 22, Java 21 y Firebase CLI (`npm install -g firebase-tools`)

## Configurar Firebase

1. En la consola de Firebase crea el proyecto, activa **Authentication → Email/Password** y crea la base de **Firestore en modo producción**.
2. Conecta la app (genera `lib/firebase_options.dart` y `android/app/google-services.json`, que sí se suben; ver C-13 en `docs/06-convenciones.md`):

   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<id-del-proyecto> --platforms=android,web
   ```

3. Publica las reglas: `firebase deploy --only firestore:rules`.
4. Para dar el rol de personal: regístrate en la app, copia tu UID de **Authentication → Users** y crea en Firestore el documento `personal/<UID>` (con un campo `nombre` si la consola no deja crearlo vacío).

## Colecciones

| Colección | Id del documento | Campos | Quién escribe |
|---|---|---|---|
| `usuarios` | uid de Auth | `correo`, `nombre` | Cada persona, solo el suyo |
| `pedidos` | automático | `usuario_id`, `cliente`, `bebida`, `tamano`, `estado`, `creado` | El cliente lo crea en `pending`; solo el personal cambia `estado`; nadie borra |
| `personal` | uid del personal | ninguno obligatorio: que exista es el rol | Nadie desde la app |

## Ejecutar la app

```bash
flutter pub get
flutter run                     # emulador de Android o dispositivo conectado
flutter run -d chrome           # navegador
```

Sin tocar el proyecto real, con el Emulator Suite:

```bash
firebase emulators:start --only auth,firestore     # interfaz en http://127.0.0.1:4000
flutter run --dart-define=USAR_EMULADOR=true
```

## Pruebas

```bash
flutter analyze   # análisis estático
flutter test      # ViewModels, vistas y repositorios con dobles (sin red ni Firebase)

# Reglas de Firestore contra el emulador
npm install --prefix test_reglas
firebase emulators:exec --only firestore --project demo-cafeteria "npm --prefix test_reglas test"
```

## Estructura

```
lib/
  app.dart                 # CafeteriaApp: recibe los repositorios (main o pruebas)
  main.dart                # inicializa Firebase y cablea las implementaciones reales
  models/                  # Usuario, AuthFailure, Pedido
  repositories/            # contratos y sus implementaciones con Firebase
  viewmodels/              # AuthViewModel, PedidosViewModel
  views/                   # puerta de sesión, login, registro, pedidos
  components/              # Atomic Design: atoms, molecules, organisms
  core/                    # Failure y ApiClient (mini_backend)
test/                      # pruebas y dobles (test/fakes)
test_reglas/               # pruebas de firestore.rules en el emulador
firestore.rules            # reglas de mínimo privilegio
docs/06-convenciones.md    # convenciones y decisiones
```

## mini_backend (versión anterior)

Antes la app consumía la API REST [mini_backend](https://github.com/DMI-2026/mini_backend) (probada con el commit `94d2533` y Node.js 22.21.0). `ApiClient` y sus pruebas se conservan (C-19), pero la app ya no la necesita.
