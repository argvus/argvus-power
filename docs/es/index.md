---
title: Poder
description: Administrar acciones de energía, comportamiento inactivo y modo de mantener activo.
---
`argvus-power` integra acciones de energía, tiempo de espera inactivo, manejo de bloqueo/DPMS y estado de mantener activo con la sesión. El Centro de Control y el Panel de Control exponen los controles orientados al usuario.

Utilice los asistentes instalados y `--help` para conocer sus opciones exactas. La lista de servicios de sesión y los comandos de reinicio están documentados en [Services](/docs/reference/services/).

Use **Centro de Control → Energía** para las páginas de políticas de energía/sesión disponibles y **Panel de Control → Sesión/Energía** para acciones inmediatas como bloquear, suspender, cerrar sesión o apagar cuando esas acciones estén disponibles. La acción del panel no reemplaza la configuración persistente de inactividad o DPMS.

## Mantener activo

Keep Awake está disponible en **Centro de Control → Energía**, **Panel de Control → Sesión/Energía**, y a través de `SUPER + ALT + W`. Los controles comparten el mismo estado de sesión, por lo que cambiarlo en una superficie actualiza el comportamiento de las demás. Cada activación o desactivación muestra una notificación.

Cuando está habilitado, Keep Awake evita que la política de inactividad ARGVUS inicie los temporizadores automáticos de bloqueo de pantalla y de energía de la pantalla. Keep Awake es una preferencia persistente de `/power/keep_awake`: `argvus-config` proyecta el marcador `data/power/keep-awake`, y mientras ese archivo esté habilitado, la sesión no inicia `argvus-hypridle.service`. Deshabilita Keep Awake para restaurar el comportamiento normal de inactividad y bloqueo.

:::precaución
Si la pantalla no se bloquea automáticamente, verifica si Keep Awake está habilitado y desactívalo si es necesario.
:::
