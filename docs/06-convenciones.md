# Convenciones y decisiones

## Commits y ramas

- Commits convencionales: `feat:`, `fix:`, `test:`, `docs:`, `chore:`.
- Nunca se trabaja directo en `main`: una rama por issue (`feat/<issue>-<tema>`) y un PR con `Closes #<issue>`.
- Las pruebas nuevas se escriben primero y se ven fallar antes de implementar.

## Decisiones

Cada decisión registra la alternativa que se descartó y por qué.

| Clave | Decisión | Alternativa descartada | Por qué |
|---|---|---|---|
| C-01 | El cliente HTTP traduce cada respuesta no exitosa a un `Failure` tipado (`lib/core/failure.dart`). | Un solo error genérico. | La interfaz necesita distinguir «sin conexión», «no encontrado», «conflicto» y «datos inválidos». |
| C-12 | El rol de personal es que **exista** `personal/{uid}`; ese documento se crea a mano en la consola y nadie lo escribe desde la app. | Un campo `rol` dentro de `usuarios/{uid}`. | Cada persona puede escribir su propio perfil, así que podría darse el rol a sí misma. |
| C-13 | `lib/firebase_options.dart` y `android/app/google-services.json` se suben al repositorio. | Ignorarlos en `.gitignore`. | Identifican el proyecto, no dan acceso: lo que protege los datos son `firestore.rules`. Las llaves de servicio (`*-adminsdk-*.json`) sí están ignoradas y nunca se suben. |
| C-14 | Los errores de Firestore se traducen a los `Failure` existentes: `permission-denied` → `UnexpectedFailure(403)`, `unavailable`/`deadline-exceeded` → `NetworkFailure`, `not-found` → `NotFoundFailure`. | Crear una jerarquía nueva de fallos para Firestore. | El ViewModel y `failure.dart` no cambian; el 403 tiene su propio mensaje («No tienes permiso…») antes del caso general. |
| C-15 | Los pedidos se ordenan por fecha en el teléfono; la consulta solo filtra por `usuario_id`. | `where` + `orderBy('creado')` en la consulta. | Esa combinación exige un índice compuesto en Firestore solo para ordenar unos cuantos pedidos por persona. |
| C-16 | La app usa el Emulator Suite con `--dart-define=USAR_EMULADOR=true`. | Agregar y quitar a mano `useAuthEmulator`/`useFirestoreEmulator` en `main()`. | No hay que editar `main.dart` ni arriesgarse a subir esas líneas por accidente. |
| C-17 | La puerta de sesión alterna login y registro con un booleano. | `Navigator.push` hacia el registro. | Con rutas, el registro queda apilado debajo de los pedidos y «atrás» regresa a un formulario viejo. |
| C-18 | Las reglas se prueban automáticamente contra el emulador (`test_reglas/`, `@firebase/rules-unit-testing`). | Probarlas solo a mano desde la app. | Cada caso (sin rol, personal, borrar, campos extra) queda comprobado y se puede repetir antes de publicar. |
| C-19 | Se conserva `ApiClient` (mini_backend) con sus pruebas, pero la app ya no lo usa: habla directo con Firebase. | Borrar el cliente HTTP. | Es trabajo evaluado de la Práctica B y la Tarea 1; no estorba porque nada lo importa en la app. |
