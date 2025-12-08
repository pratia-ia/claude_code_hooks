# Security Agent Plugin

Plugin de Claude Code que proporciona un agente especializado en auditorías de seguridad y detección de vulnerabilidades.

## Instalación

```bash
# Registrar el marketplace (instala automáticamente el plugin)
/plugin marketplace add practia-ia/claude_code_plugins

# Habilitar el plugin
/plugin enable security-agent@practia-ia
```

Requiere Claude Code versión 1.0.40+ (soporte de plugins).

## Agente Incluido

### security-review

Agente experto en seguridad que realiza auditorías de código, detecta vulnerabilidades y verifica el cumplimiento de mejores prácticas de seguridad.

**Características:**

- **Detección de vulnerabilidades OWASP Top 10**
  - SQL/NoSQL injection
  - XSS (Cross-Site Scripting)
  - Autenticación y autorización rotas
  - Exposición de datos sensibles
  - Configuraciones inseguras
  - Deserialización insegura

- **Análisis de código sensible**
  - Credenciales hardcodeadas
  - API keys y secrets expuestos
  - Validación de entrada
  - Manejo de errores
  - Gestión de sesiones

- **Auditoría de dependencias**
  - Librerías con vulnerabilidades conocidas (CVE)
  - Versiones desactualizadas
  - Dependencias innecesarias

- **Reportes estructurados**
  - Clasificación por severidad (Critical/High/Medium/Low)
  - Ubicación exacta (archivo:línea)
  - Código vulnerable vs. código seguro
  - Pasos de remediación específicos
  - Referencias a CWE cuando aplique

## Uso

### Invocación Manual

1. **Desde el menú de agentes:**
   ```bash
   /agents
   ```
   Selecciona "security-review" de la lista de agentes disponibles.

2. **Mención directa en tu prompt:**
   ```
   @security-review revisa los archivos de autenticación en busca de vulnerabilidades
   ```

### Invocación Automática

El agente se invocará proactivamente cuando:

- Claude detecte código relacionado con autenticación/autorización
- Se estén manejando datos sensibles
- Se esté trabajando con entrada de usuario
- Se solicite explícitamente una revisión de seguridad
- Antes de crear PRs con cambios en código sensible

### Ejemplos de Uso

**Auditoría completa del proyecto:**
```
@security-review realiza una auditoría de seguridad completa del proyecto,
priorizando los endpoints de la API y la autenticación de usuarios
```

**Revisar un archivo específico:**
```
@security-review revisa el archivo src/auth/login.js en busca de
vulnerabilidades de seguridad
```

**Verificar antes de un commit:**
```
@security-review verifica que mis cambios pendientes no introduzcan
vulnerabilidades de seguridad
```

**Análisis de dependencias:**
```
@security-review revisa package.json y busca dependencias con
vulnerabilidades conocidas
```

**Validación de configuración:**
```
@security-review verifica la configuración de seguridad en los archivos
.env y config/*
```

## Checklist de Seguridad

El agente verifica automáticamente:

### Autenticación & Autorización
- ✓ Sin credenciales hardcodeadas
- ✓ Políticas de contraseñas fuertes
- ✓ Gestión segura de sesiones
- ✓ Verificaciones de autorización en operaciones sensibles

### Validación de Entrada
- ✓ Todas las entradas validadas y sanitizadas
- ✓ Queries parametrizadas (sin concatenación SQL)
- ✓ Prevención de XSS con encoding correcto
- ✓ Protección CSRF implementada

### Protección de Datos
- ✓ Datos sensibles encriptados en reposo
- ✓ Canales de comunicación seguros (HTTPS/TLS)
- ✓ Sin datos sensibles en URLs o logs
- ✓ Algoritmos criptográficos robustos

### Manejo de Errores & Logging
- ✓ Mensajes de error genéricos a usuarios
- ✓ Logs detallados en servidor
- ✓ Sin logging de passwords o tokens
- ✓ Prevención de log injection

### Dependencias & Configuración
- ✓ Dependencias actualizadas
- ✓ Sin dependencias vulnerables conocidas
- ✓ Security headers configurados
- ✓ CORS configurado correctamente

## Clasificación de Severidad

El agente clasifica los hallazgos en:

- **Critical**: Ejecución remota de código, bypass de autenticación, secrets en producción
- **High**: XSS, bypass de autorización, exposición de datos sensibles
- **Medium**: Headers de seguridad faltantes, criptografía débil, CSRF en operaciones no críticas
- **Low**: Mensajes de error verbosos, problemas menores de configuración

## Formato de Reporte

Cada vulnerabilidad encontrada incluye:

```
[SEVERITY] Título de la Vulnerabilidad

- Ubicación: archivo.js:123
- Categoría: SQL Injection / XSS / etc.
- CWE: CWE-XXX

Descripción: Explicación clara del problema

Código Vulnerable:
[snippet del código problemático]

Impacto: Consecuencias potenciales

Remediación:
[código corregido con mejores prácticas]

Best Practice: Explicación de por qué esta solución es segura
```

## Estructura del Plugin

```
security-agent/
├── .claude-plugin/
│   └── plugin.json          # Metadata del plugin
├── agents/
│   └── security-review.md   # Definición del agente de seguridad
└── README.md                # Esta documentación
```

## Tools Disponibles

El agente tiene acceso a:
- **Read**: Leer archivos de código
- **Grep**: Buscar patrones de vulnerabilidades
- **Glob**: Encontrar archivos sensibles
- **Bash**: Ejecutar herramientas de análisis estático

## Notas Importantes

- El agente distingue entre código de test y producción
- Proporciona contexto y explicaciones, no solo alertas
- Balancea seguridad con usabilidad
- Sugiere herramientas adicionales (SAST, DAST) cuando es apropiado
- Se enfoca en hallazgos accionables con pasos claros de remediación

## Mejores Prácticas

1. **Ejecuta el agente antes de crear PRs** con cambios en código sensible
2. **Usa el agente durante code reviews** de features de seguridad
3. **Realiza auditorías periódicas** del código existente
4. **Combina con herramientas automáticas** como dependabot o snyk
5. **Documenta las excepciones** cuando decides no seguir una recomendación

## Licencia

MIT

## Autor

practiauy
