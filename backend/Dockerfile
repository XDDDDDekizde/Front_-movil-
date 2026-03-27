# ========================
# Etapa 1: Builder (compilación)
# ========================
FROM golang:1.23-alpine AS builder

# Instalar dependencias del sistema
RUN apk add --no-cache git

# Configurar directorio de trabajo
WORKDIR /app

# Copiar go.mod y go.sum primero (para cachear dependencias)
COPY go.mod go.sum ./
RUN go mod download

# Copiar todo el código fuente
COPY . .

# Compilar la aplicación (producción optimizada)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /app/main ./cmd/app

# ========================
# Etapa 2: Imagen final (ligera)
# ========================
FROM alpine:latest

# Instalar certificados (necesario para HTTPS en algunos casos)
RUN apk --no-cache add ca-certificates tzdata

# Crear usuario no-root por seguridad
RUN adduser -D -g '' appuser

WORKDIR /app

# Copiar el binario compilado desde la etapa builder
COPY --from=builder /app/main .

# Cambiar permisos y usuario
RUN chown -R appuser:appuser /app
USER appuser

# Exponer el puerto
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["./main"]