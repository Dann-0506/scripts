# Linux Automation Scripts

Un conjunto de herramientas y scripts ligeros diseñados para automatizar flujos de trabajo en Ubuntu, mantener limpio el sistema de archivos y optimizar la gestión diaria de documentos.

---

## Estructura del Repositorio

```bash
linux-automation-scripts/
├── README.md               # Documentación del proyecto
├── .gitignore              # Archivos ignorados por Git
├── install.sh              # Script de instalación automatizada
├── bin/
│   └── watch_downloads.sh  # Demonio de monitoreo de Descargas a Escritorio
└── systemd/
    └── watch-downloads.service # Configuración del servicio de usuario systemd
```

---

## Requisitos previos

Antes de instalar los scripts es necesario tener las siguientes herramientas instaladas para el monitoreo de eventos en tiempo real.

```bash
sudo apt update
sudo apt install inotify-tools
```

---

## Instalacion

1. Clona este repositorio en tu equipo:

```bash
git clone https://github.com/Dann-0506/scripts
cd ./scripts
```

2. Dale permisos de ejecucion al instalador:

```bash
chmod +x ./install.sh
```

3. Ejecuta el instalador:

```bash
./install.sh
```

El script se encargará automáticamente de copiar los binarios a `~/.local/bin`, configurar la unidad de systemd y poner en marcha el servicio en segundo plano.

---

## Verificacion y control

Puedes verificar que el demonio de descargas está corriendo correctamente en tu sesión con el siguiente comando:

```bash
systemctl --user status watch-downloads.service
```

Si en algún momento necesitas detener o reiniciar el servicio:

- Reiniciar: `systemctl --user restart watch-downloads.service`
- Detener: `systemctl --user stop watch-downloads.service`