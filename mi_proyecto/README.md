# MiProyecto
DESARROLLO DE APLICACIÓN DE CHAT DISTRIBUIDO

## Descripción
Este sistema simula una arquitectura distribuida donde varios nodos (cliente, pantalla, servidor) interactúan para gestionar usuarios y salas. Puede servir como una recepción virtual, un sistema de turnos o una gestión básica de mensajes entre usuarios en diferentes puntos de la red.

## Estructura del proyecto

lib/
├── mi_proyecto.ex                         # Módulo principal del sistema
├── base_de_datos/
│   └── manejoDatos.ex                     # Módulo para manejar datos y persistencia
├── estructuras/
│   ├── miembStruct.ex                     # Estructura de miembros
│   ├── msgStruc.ex                        # Estructura de mensajes
│   ├── salaStruc.ex                       # Estructura de sala
│   └── userStruc.ex                       # Estructura de usuarios
├── recepcion/
    ├── cookie.exs                         # Lógica de cookies o autenticación local
    ├── nodo_cliente.exs                   # Nodo cliente
    ├── nodo_pantalla.exs                  # Nodo que representa la pantalla
    ├── nodo_servidor.exs                  # Nodo que actúa como servidor
    └── Usuario.ex                         # Módulo para operaciones del usuario







