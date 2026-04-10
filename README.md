# Mercado Pago Visualizer

Una aplicación en Flutter para visualizar tus transacciones recientes de Mercado Pago de forma rápida y segura.

## Características

- Consulta tus transacciones del día directamente desde la API oficial de Mercado Pago.
- Configuración segura del `mp_access_token` dentro de la app (se guarda de forma local en el dispositivo del usuario).
- Interfaz moderna e intuitiva.

## Seguridad y Privacidad (Mejores Prácticas)

- **Ninguna credencial o dato sensible está "hardcodeado" (escrito en el código) en este repositorio.**
- El `mp_access_token` es configurado por el usuario final al abrir la aplicación en su dispositivo.
- El token es almacenado internamente usando `shared_preferences` y su valor es enmascarado en la interfaz una vez guardado.
- El repositorio excluye automáticamente archivos de entorno (`.env`) o de configuración de desarrollo locales a través de `.gitignore`.

## Cómo obtener tu Access Token

1. Entra al portal de [Developers de Mercado Pago](https://www.mercadopago.com/developers/panel/app).
2. Crea una aplicación en la sección "Tus Aplicaciones" o ingresa a una existente.
3. Dirígete a "Credenciales de Producción" o "Credenciales de Prueba".
4. Copia tu **Access Token** (usualmente empieza con `APP_USR-` o `TEST-`).

## Cómo ejecutar la aplicación

Asegúrate de tener Flutter instalado y clonar el repositorio:

```bash
git clone https://github.com/TU_USUARIO/mercadopago_visualizer.git
cd mercadopago_visualizer
flutter pub get
flutter run
```
