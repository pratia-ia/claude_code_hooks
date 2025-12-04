# Claude Code Plugins - Conversation Logger

Plugin para Claude Code que registra automáticamente las conversaciones en archivos de log locales con rotación automática.

## Descripción

Este plugin captura y guarda:
- **Mensajes del usuario**: Cada prompt enviado a Claude
- **Uso de herramientas**: Registro de las herramientas utilizadas (Read, Write, Edit, Bash, Grep, etc.)
- **Respuestas del asistente**: El texto de respuesta generado por Claude

Los logs se guardan en `.claude/logs/` dentro del proyecto con rotación automática cuando alcanzan 512 KB.

## Requisitos

- **Claude Code** versión 1.0.40 o superior (soporte de plugins)
- **Windows** con PowerShell 5.1 o superior

## Instalación

```bash
# Registrar el marketplace
/plugin marketplace add practia-ia/claude_code_hooks

# Instalar el plugin
/plugin install conversation-logger@practia-ia

# Verificar instalación
/plugin list
```

## Licencia

MIT

## Autor

practiauy
