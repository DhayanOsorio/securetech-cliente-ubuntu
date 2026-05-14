## Estructura del repositorio

- `config-real/etc-securetech/`: configuración real del cliente Ubuntu.
- `scripts/usr-local-bin/`: scripts de backup, agente, Restic y restauración.
- `cron/root-crontab.txt`: tareas programadas del cliente.
- `wireguard/`: configuración VPN usada para conectar con el servidor SecureTECH.
- `datos-pyme/`: referencia a la carpeta de datos protegida.
- `docs/`: evidencias, permisos, paquetes y verificaciones del cliente.

## Ruta protegida

La carpeta protegida por las copias de seguridad es:

/datos_pyme

## Automatización

El cliente usa cron para ejecutar backups automáticos y para consultar tareas pendientes al servidor.
