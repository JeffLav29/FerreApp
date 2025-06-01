# FerreApp 🔧

Aplicación móvil para ferretería desarrollada en Flutter. Una solución completa para la gestión y venta de productos ferreteros.

## 🚀 Instalación y Configuración

### Prerrequisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.0 o superior)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- Un dispositivo Android/iOS o emulador configurado

### Clonar el repositorio

```bash
git clone https://github.com/JeffLav29/FerreApp.git
cd FerreApp
```

### Instalar dependencias

```bash
flutter pub get
```

### Verificar configuración

```bash
flutter doctor
```

### Ejecutar la aplicación

```bash
# En modo debug
flutter run

# Para un dispositivo específico
flutter devices
flutter run -d <device-id>
```

## 📱 Funcionalidades Implementadas

- ✅ **Catálogo de productos** - Visualización de productos ferreteros
- ⏳ Carrito de compras
- ⏳ Gestión de usuarios
- ⏳ Sistema de búsqueda
- ⏳ Gestión de inventario
- ⏳ Sistema de pagos

## 👥 Colaboración

### Para colaboradores del proyecto:

1. **Clonar el repositorio** (comandos de arriba)
2. **Antes de trabajar, siempre:**
   ```bash
   git pull
   ```
3. **Hacer cambios y commit:**
   ```bash
   git add .
   git commit -m "descripción del cambio"
   git push
   ```

### Flujo de trabajo con ramas:

```bash
# Crear nueva rama para tu feature
git checkout -b feature/nombre-feature

# Trabajar en tus cambios...

# Subir la rama
git push -u origin feature/nombre-feature

# Crear Pull Request en GitHub
```

## 🛠️ Tecnologías

- **Framework:** Flutter 3.x
- **Lenguaje:** Dart
- **IDE recomendado:** Android Studio / VS Code
- **Control de versiones:** Git + GitHub

## 📁 Estructura del Proyecto

```
lib/
├── main.dart           # Punto de entrada de la app
├── screens/           # Pantallas de la aplicación
│   └── catalog/       # Pantalla de catálogo
├── widgets/           # Componentes reutilizables
├── models/            # Modelos de datos
├── services/          # Servicios y APIs
└── utils/             # Utilidades y helpers
```

## 🐛 Solución de Problemas

### Error: "Flutter command not found"
```bash
# Verificar instalación de Flutter
flutter --version

# Si no está instalado, seguir: https://flutter.dev/docs/get-started/install
```

### Error: "No devices found"
```bash
# Verificar dispositivos disponibles
flutter devices

# Iniciar emulador desde Android Studio o
# Conectar dispositivo físico con USB debugging habilitado
```

### Error: "Pub get failed"
```bash
# Limpiar y reinstalar dependencias
flutter clean
flutter pub get
```

## 📞 Contacto

Si tienes problemas o preguntas sobre el proyecto, contacta al equipo de desarrollo.

---

**¿Listo para empezar? 🚀**
```bash
git clone https://github.com/JeffLav29/FerreApp.git && cd FerreApp && flutter pub get && flutter run
```
