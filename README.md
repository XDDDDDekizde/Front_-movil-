# chat_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Chat App (Flutter + Go + PostgreSQL)

Aplicación de chat desarrollada con:

* Frontend en Flutter
* Backend en Go (Gin)
* Base de datos en PostgreSQL

---

## Funcionalidades

* Registro de usuarios
* Inicio de sesión
* Creación de salas de chat
* Envío y almacenamiento de mensajes
* Persistencia de datos en base de datos
* Sistema de salas públicas
* Control de administrador de sala (solo el creador puede eliminarla)

---

## Tecnologías utilizadas

* Flutter
* Go (Gin)
* PostgreSQL
* API REST

---

## Instalación

### 1. Clonar repositorio

```bash
git clone https://github.com/TU_USUARIO/TU_REPO.git
cd chat_app
```

---

## Configuración de la base de datos

Usar PostgreSQL.

### Crear base de datos

```sql
CREATE DATABASE chatdb;
```

### Crear tablas

Ejecutar el script de creación de tablas proporcionado (02-create-tables.sql).

---

## Configuración del backend (Go)

### Ir a la carpeta del backend

```bash
cd backend
```

### Instalar dependencias

```bash
go mod init chat
go get github.com/gin-gonic/gin
go get github.com/lib/pq
go get github.com/google/uuid
go get golang.org/x/crypto/bcrypt
```

### Configurar conexión a la base de datos

En el archivo `main.go`:

```go
connStr := "host=localhost port=5432 user=postgres password=TU_PASSWORD dbname=chatdb sslmode=disable"
```

---

### Ejecutar backend

```bash
go run main.go
```

El servidor se ejecutará en:

```
http://localhost:8080
```

---

## Configuración del frontend (Flutter)

### Ir a la carpeta del frontend

```bash
cd chat_app
```

### Instalar dependencias

```bash
flutter pub get
```

---

### Ejecutar aplicación

```bash
flutter run
```

---

## Conexión con el backend

Dependiendo del entorno:

* En Windows (desktop):

```
http://localhost:8080/api
```

* En emulador Android:

```
http://10.0.2.2:8080/api
```

---

## Flujo de uso

1. Crear una cuenta
2. Iniciar sesión
3. Crear una sala
4. Entrar a la sala
5. Enviar mensajes

---

## Sistema de administración de salas

* El usuario que crea una sala es el administrador
* Solo el administrador puede eliminar la sala

---

## Estructura del proyecto

```
lib/
├─ models/
├─ services/
├─ screens/
├─ widgets/
```

---

## Problemas comunes

### No conecta al backend

Verificar que el servidor en Go esté en ejecución.

### Error de datos nulos en Flutter

Asegurarse de que el backend envía correctamente:

* user_id
* content

### Problemas con localhost en emulador

Usar la dirección `10.0.2.2`.

---

## Posibles mejoras

* Actualización automática de mensajes
* Sistema de amigos
* Salas privadas
* Uso de WebSockets
* Mejora de interfaz de usuario

---

## Autor

Proyecto académico de desarrollo full stack.
