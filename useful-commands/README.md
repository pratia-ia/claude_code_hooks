# Useful Commands Plugin

Plugin de Claude Code con comandos útiles para gestión de PRs y documentación de sesiones.

## Instalación

```bash
# Registrar el marketplace (instala automáticamente el plugin)
/plugin marketplace add practia-ia/claude_code_plugins

# Habilitar el plugin
/plugin enable useful-commands@practia-ia
```

Requiere Claude Code versión 1.0.40+ (soporte de plugins).

## Comandos Disponibles

### `/create-pr`

Crea un Pull Request en Azure DevOps hacia la rama main.

**Funcionalidad:**

- Verifica el estado de git y commits pendientes
- Analiza los cambios desde main
- Extrae Work Items de los mensajes de commit
- Genera descripción detallada del PR en español
- Crea el PR con título y descripción automáticos

### `/update-pr`

Actualiza un Pull Request existente en Azure DevOps.

**Funcionalidad:**

- Similar a `/create-pr` pero actualiza un PR existente
- Preserva imágenes existentes en la descripción
- Actualiza la descripción con los nuevos cambios

### `/document`

Documenta la sesión actual de Claude Code.

**Funcionalidad:**

- Crea un resumen detallado de la sesión
- Guarda en `/docs/logs/session_YYYY-MM-DD_HH-MM-SS.md`
- Incluye tareas completadas, problemas resueltos, archivos modificados
- Genera próximos pasos sugeridos

## Estructura

```
useful-commands/
├── .claude-plugin/
│   └── plugin.json          # Metadata del plugin
├── commands/
│   ├── create-pr.md         # Comando /create-pr
│   ├── document.md          # Comando /document
│   └── update-pr.md         # Comando /update-pr
└── README.md
```

## Notas

- Los comandos están diseñados para el proyecto "Mesa de Ayuda" en Azure DevOps
- Las descripciones de PR se generan en español
- El comando `/document` crea la estructura de directorios si no existe
