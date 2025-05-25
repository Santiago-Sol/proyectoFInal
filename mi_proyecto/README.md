# MiProyecto  
**DESARROLLO DE APLICACIÓN DE CHAT DISTRIBUIDO**

## Descripción

Este sistema simula una arquitectura distribuida donde varios nodos (cliente, pantalla, servidor) interactúan para gestionar usuarios y salas. Puede ser utilizado como:

- Una recepción virtual  
- Un sistema de turnos  
- Un sistema básico de mensajería entre usuarios en distintos puntos de la red  

El enfoque distribuido permite que cada nodo desempeñe un rol específico dentro del sistema, promoviendo escalabilidad y modularidad.

## Estructura del proyecto

```
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
│   ├── cookie.exs                         # Lógica de cookies o autenticación local
│   ├── nodo_cliente.exs                   # Nodo cliente
│   ├── nodo_pantalla.exs                  # Nodo que representa la pantalla
│   ├── nodo_servidor.exs                  # Nodo que actúa como servidor
│   └── Usuario.ex                         # Módulo para operaciones del usuario
```

---

📁 Cada carpeta tiene una responsabilidad clara dentro del sistema:  
- **base_de_datos/**: manejo y persistencia de la información.  
- **estructuras/**: definición de las estructuras de datos del sistema.  
- **recepcion/**: lógica de autenticación y nodos que conforman la red.
