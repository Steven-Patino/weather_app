# 🌦️ Weather App Flutter
Dart Flutter Dio Geolocator Status

Proyecto de aplicación del clima construida con Flutter bajo los principios de **Clean Architecture** (Arquitectura Limpia) y Arquitectura Hexagonal.

El flujo actual permite obtener el clima de cualquier ciudad o de la ubicación actual del usuario, mostrando detalles extendidos como humedad, sensación térmica, viento, presión, visibilidad e índice UV. 

## 📌 Estado actual
Fase | Estado | Resultado
---|---|---
✅ **Arquitectura Base** | Completada | Capas Domain, Infrastructure y Presentation totalmente desacopladas.
✅ **Llamadas a API** | Completada | Integración exitosa con OpenWeatherMap usando Dio.
✅ **Geolocalización** | Completada | Carga del clima local automáticamente al inicio usando Geolocator.
✅ **UI y Fondos Dinámicos** | Completada | Interfaz adaptativa con assets GIF iterativos según el clima y hora.
✅ **Seguridad** | Completada | Ocultamiento de la API Key mediante variables de entorno (`.env`).
📊 **Visualizaciones** | Completada | Implementado Wrap con métricas completas y diseño responsivo.

## 🧰 Requisitos
- Flutter SDK 3.12+
- Dart SDK
- Dependencias definidas en `pubspec.yaml`
- Una API Key válida de [OpenWeatherMap](https://openweathermap.org/api)

📦 Dependencias
Este proyecto utiliza las siguientes librerías adicionales:
- **dio (>=5.4.0):** Para realizar llamadas HTTP eficientes y manejo de excepciones de red.
- **geolocator (>=13.0.0):** Para solicitar permisos de GPS y obtener la latitud/longitud del usuario.
- **flutter_dotenv (>=5.2.1):** Para leer la API Key de forma segura desde un archivo `.env` local.

## 🚀 Instalación y Ejecución
1. Clonar el repositorio:
```bash
git clone https://github.com/Steven-Patino/weather_app.git
cd weather_app
```

2. Instalar dependencias de Flutter:
```bash
flutter pub get
```

3. Configurar Variables de Entorno:
Copia el archivo `.env.template` y renómbralo a `.env`. Luego coloca tu API Key de OpenWeatherMap.
```bash
# En Linux/Mac/Git Bash
cp .env.template .env

# En Windows PowerShell
Copy-Item .env.template .env
```
Contenido de `.env`:
```env
OPENWEATHER_API_KEY=tu_api_key_aqui
```

4. Ejecutar la aplicación:
```bash
flutter run
```

## ⚙️ Estructura del Proyecto
El proyecto está dividido por "Features" respetando la Arquitectura Limpia:

```text
lib/
└── features/
    └── weather/
        ├── domain/                  # Entidades y Casos de uso puros
        │   ├── models/
        │   ├── repositories/
        │   └── usecases/
        │
        ├── infrastructure/          # Conexión externa, HTTP (Dio) y GPS
        │   ├── repositories/
        │   └── services/
        │
        └── presentation/            # UI "tonta", Screens y Widgets
            ├── backgrounds/         # Assets locales (GIFs animados)
            ├── screens/
            └── widgets/
```

Las carpetas respetan estrictamente la separación de responsabilidades: la UI nunca habla con las APIs directamente y el Dominio es completamente agnóstico sobre cómo se obtienen los datos.

## 👨‍💻 Autor
Steven Alexander Patino Arenas
Proyecto App del Clima con Clean Architecture.
