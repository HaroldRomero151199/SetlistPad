# SetlistPad

**SetlistPad** es una aplicación Flutter moderna para gestionar, organizar y compartir listas de reproducción de canciones con información detallada, acceso a letras y videos de YouTube.

## Características

- 🎵 **Gestión de Canciones**: Crear, editar y organizar canciones con metadatos completos
- 📋 **Listas de Reproducción**: Organiza tus canciones en playlists temáticas
- 🎹 **Búsqueda Integrada**: Encuentra canciones y letras fácilmente
- 📝 **Letras Sincronizadas**: Accede a letras con timestamps
- 🎥 **Videos de YouTube**: Integración directa con YouTube
- 💾 **Almacenamiento Local**: Sincronización offline con Hive
- 🎨 **Diseño Moderno**: Interfaz intuitiva y responsiva

## Arquitectura

El proyecto sigue un patrón **Feature-First + Clean Architecture**:

```
lib/
├── core/
│   ├── clients/       # Clientes HTTP y modelos DTO
│   ├── config/        # Configuración global y constantes
│   ├── providers/     # Inyección de dependencias con Riverpod
│   ├── services/      # Lógica de negocio (YouTube, Letras)
│   └── theme/         # Temas y tipografía
├── features/
│   ├── songs/         # Módulo de canciones
│   └── playlists/     # Módulo de listas de reproducción
└── main.dart
```

## Stack Tecnológico

- **Framework**: Flutter 3.x
- **State Management**: Flutter Riverpod 2.x
- **Base de Datos Local**: Hive
- **HTTP Client**: http
- **Tipado**: Dart con tipos fuertes

## Requisitos Previos

- Flutter 3.0 o superior
- Dart 3.0 o superior
- iOS 11.0+ / Android 5.0+

## Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/HaroldRomero151199/SetlistPad.git
   cd SetlistPad
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## Desarrollo

### Análisis de Código
```bash
flutter analyze
```

### Ejecutar Tests
```bash
flutter test
```

### Build para Producción
```bash
flutter build apk      # Android
flutter build ios      # iOS
```

## Directrices para Agentes IA

Ver [`AGENTS.md`](./AGENTS.md) para las normas obligatorias de desarrollo, patrones arquitectónicos y mejores prácticas.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT.

## Autor

[Harold Romero](https://github.com/HaroldRomero151199)
