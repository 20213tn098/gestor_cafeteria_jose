// Pruebas de ../firestore.rules. Se ejecutan con el emulador:
//   firebase emulators:exec --only firestore --project demo-cafeteria "npm --prefix test_reglas test"
import { readFileSync } from "node:fs";
import { after, before, beforeEach, test } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";

let env;
const ANA = "uid-ana";
const BETO = "uid-beto";
const STAFF = "uid-staff";

const pedidoDe = (uid, extra = {}) => ({
  usuario_id: uid,
  cliente: "Ana",
  bebida: "latte",
  tamano: "M",
  estado: "pending",
  creado: serverTimestamp(),
  ...extra,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-cafeteria",
    firestore: { rules: readFileSync(new URL("../firestore.rules", import.meta.url), "utf8") },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  // Datos iniciales sin reglas: el rol de personal y un pedido de Ana.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "personal", STAFF), { nombre: "Luis" });
    await setDoc(doc(db, "pedidos", "p1"), { ...pedidoDe(ANA), creado: new Date() });
  });
});

const como = (uid) => env.authenticatedContext(uid).firestore();
const anonimo = () => env.unauthenticatedContext().firestore();

// --- pedidos ---
test("sin sesión no se leen ni se crean pedidos", async () => {
  await assertFails(getDoc(doc(anonimo(), "pedidos", "p1")));
  await assertFails(addDoc(collection(anonimo(), "pedidos"), pedidoDe(ANA)));
});

test("un cliente crea su pedido en pending", async () => {
  await assertSucceeds(addDoc(collection(como(ANA), "pedidos"), pedidoDe(ANA)));
});

test("un cliente no crea pedidos a nombre de otra persona", async () => {
  await assertFails(addDoc(collection(como(ANA), "pedidos"), pedidoDe(BETO)));
});

test("un pedido nuevo no puede nacer en otro estado ni con campos extra", async () => {
  await assertFails(addDoc(collection(como(ANA), "pedidos"), pedidoDe(ANA, { estado: "ready" })));
  await assertFails(addDoc(collection(como(ANA), "pedidos"), pedidoDe(ANA, { precio: 0 })));
  await assertFails(addDoc(collection(como(ANA), "pedidos"), pedidoDe(ANA, { tamano: "XL" })));
  await assertFails(addDoc(collection(como(ANA), "pedidos"), pedidoDe(ANA, { cliente: "" })));
});

test("cada cliente ve solo sus pedidos", async () => {
  await assertSucceeds(getDoc(doc(como(ANA), "pedidos", "p1")));
  await assertFails(getDoc(doc(como(BETO), "pedidos", "p1")));
  await assertSucceeds(getDocs(query(collection(como(ANA), "pedidos"), where("usuario_id", "==", ANA))));
  await assertFails(getDocs(collection(como(ANA), "pedidos")));
});

test("el personal ve todos los pedidos", async () => {
  await assertSucceeds(getDocs(collection(como(STAFF), "pedidos")));
});

test("una cuenta sin rol no puede cambiar el estado, ni el de su pedido", async () => {
  await assertFails(updateDoc(doc(como(ANA), "pedidos", "p1"), { estado: "preparing" }));
});

test("el personal cambia el estado por una transición válida", async () => {
  await assertSucceeds(updateDoc(doc(como(STAFF), "pedidos", "p1"), { estado: "preparing" }));
});

test("el personal no salta estados ni edita otros campos", async () => {
  await assertFails(updateDoc(doc(como(STAFF), "pedidos", "p1"), { estado: "delivered" }));
  await assertFails(updateDoc(doc(como(STAFF), "pedidos", "p1"), { cliente: "Otro" }));
});

test("nadie borra pedidos, ni el personal", async () => {
  await assertFails(deleteDoc(doc(como(ANA), "pedidos", "p1")));
  await assertFails(deleteDoc(doc(como(STAFF), "pedidos", "p1")));
});

// --- usuarios y personal ---
test("cada quien escribe y lee solo su perfil con correo y nombre", async () => {
  const perfil = { correo: "ana@utez.edu.mx", nombre: "Ana" };
  await assertSucceeds(setDoc(doc(como(ANA), "usuarios", ANA), perfil));
  await assertSucceeds(getDoc(doc(como(ANA), "usuarios", ANA)));
  await assertFails(getDoc(doc(como(BETO), "usuarios", ANA)));
  await assertFails(setDoc(doc(como(ANA), "usuarios", ANA), { ...perfil, contrasena: "x" }));
});

test("nadie se da a sí mismo el rol de personal", async () => {
  await assertFails(setDoc(doc(como(ANA), "personal", ANA), { nombre: "Ana" }));
  await assertSucceeds(getDoc(doc(como(STAFF), "personal", STAFF)));
  await assertFails(getDoc(doc(como(ANA), "personal", STAFF)));
});
