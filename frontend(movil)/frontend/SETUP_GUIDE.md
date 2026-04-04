# 📱 Guía de Configuración - Frontend Móvil (Flutter) + Backend

## 🎯 Resumen de la integración

El frontend móvil (Flutter) ahora está completamente conectado con el mismo backend que el frontend web (Vue).

### URLs de conexión:
- **API Backend**: `http://localhost:8080`
- **WebSocket Chat**: `ws://localhost:3000`

---

## 🚀 Pasos para ejecutar el proyecto

### 1️⃣ Backend (Proyecto Principal)

Desde `c:\Users\Victor\Downloads\Proyecto-B-main\Fronend-projectoB-main`:

```bash
# Instalar dependencias
npm install

# Ejecutar servidor WebSocket (puerto 3000)
npm run server

# En otra terminal, ejecutar frontend web (Vite)
npm run dev
```

Backend estará disponible en:
- `http://localhost:8080` - API REST
- `ws://localhost:3000` - WebSocket

---

### 2️⃣ Frontend Móvil (Flutter)

Desde `c:\Users\Victor\Downloads\Proyecto-B-main\Front_-movil-\frontend(movil)\frontend`:

```bash
# Instalar dependencias Flutter
flutter pub get

# Ejecutar en emulador o dispositivo
flutter run

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para web (si lo necesitas)
flutter run -d web
```

---

## 📋 Cambios realizados en el frontend móvil

### ✅ Servicios creados/actualizados

#### 1. **auth_service.dart** (Nuevo)
- Conexión con API REST del backend
- Manejo de registro y login
- Almacenamiento de tokens en SharedPreferences
- Funciones para verificar autenticación

#### 2. **chat_service.dart** (Nuevo)
- Conexión WebSocket a ws://localhost:3000
- Métodos para enviar mensajes
- Métodos para responder mensajes
- Métodos para reenviar y eliminar mensajes

#### 3. **pubspec.yaml** (Actualizado)
- Agregadas dependencias: `http` y `web_socket_channel`

### 📱 Pantallas actualizadas

#### **Login Page**
- Ahora usa email en lugar de usuario
- Se conecta al API backend
- Muestra indicador de carga
- Almacena token en SharedPreferences

#### **Register Page**
- Captura username, email y contraseña
- Validación de contraseña confirmada
- Se conecta al API backend

#### **Home Page**
- Muestra información de conexión
- Opción para entrar a salas de chat
- Botón de logout que limpia la sesión

---

## 🧪 Cómo probar

### Opción 1: Android Emulator

```bash
flutter run
```

### Opción 2: iOS Simulator (macOS)

```bash
flutter run -d ios
```

### Opción 3: Web

```bash
flutter run -d web
```

### Opción 4: Dispositivo físico

Conecta el dispositivo por USB y ejecuta:
```bash
flutter run
```

---

## 🔧 Configuración requerida

### Requisitos:
- ✅ Flutter SDK (versión 3.11.4+)
- ✅ Emulador de Android/iOS o dispositivo físico
- ✅ Backend corriendo en http://localhost:8080
- ✅ WebSocket corriendo en ws://localhost:3000

### Para cambiar URLs del backend:

Edita los siguientes archivos si necesitas cambiar las URLs:

**auth_service.dart**:
```dart
static const String baseUrl = 'http://localhost:8080';  // Cambiar aquí
```

**chat_service.dart**:
```dart
static const String wsUrl = 'ws://localhost:3000';  // Cambiar aquí
```

---

## 📊 Flujo de autenticación

```mermaid
Usuario → LoginPage → AuthService.login() → Backend (localhost:8080/api/auth/login)
            ↓
        Backend valida credenciales
            ↓
        Retorna token + datos del usuario
            ↓
        Guardar en SharedPreferences
            ↓
        HomePage ← Mostrar bienvenida
```

---

## 💬 Flujo de chat

```mermaid
Usuario → HomePage → Entra a sala de chat
            ↓
        ChatService.connect() → WebSocket (ws://localhost:3000)
            ↓
        Conectado a la sala
            ↓
        ChatService.sendMessage() → Envía mensaje
            ↓
        Backend distribuye a otros usuarios en la misma sala
```

---

## 🐛 Solución de problemas

### Error: "Connection refused"
**Causa**: El backend no está corriendo
**Solución**: 
```bash
cd c:\Users\Victor\Downloads\Proyecto-B-main\Fronend-projectoB-main
npm run server
```

### Error: "WebSocket connection failed"
**Causa**: El servidor WebSocket no está en puerto 3000
**Solución**: Verifica que `server.js` está corriendo correctamente

### Error: "Invalid token"
**Causa**: El token expiró o no es válido
**Solución**: Haz logout y vuelve a login

### El emulador no puede conectar a localhost:8080
**Solución para Android**:
- Cambia `localhost` por `10.0.2.2` (dirección del host desde el emulador)
- Edita `auth_service.dart` y `chat_service.dart`

```dart
// Para Android emulator:
static const String baseUrl = 'http://10.0.2.2:8080';
static const String wsUrl = 'ws://10.0.2.2:3000';
```

**Solución para iOS Simulator**:
- iOS simulator usa `localhost` sin cambios

---

## 📝 Notas importantes

1. **Token Persistence**: Los tokens se guardan en SharedPreferences para que el usuario permanezca logeado
2. **CORS**: El backend debe tener CORS habilitado para aceptar peticiones del frontend móvil si está en diferente máquina
3. **Network Security**: En Android 9+ debes configurar Network Security Policy para HTTP en desarrollo
4. **Emulador**: Los emuladores de Android usan 10.0.2.2 para acceder a localhost del host

---

## ✨ Próximos pasos

1. Implementar pantalla de salas de chat
2. Implementar pantalla de mensajes en tiempo real
3. Agregar notificaciones push
4. Agregar almacenamiento local de mensajes
5. Implementar búsqueda y filtrado de salas

---

**Backend URL**: http://localhost:8080  
**WebSocket URL**: ws://localhost:3000  
**Frontend Web**: http://localhost:5173  
**Frontend Móvil**: En emulador/dispositivo
