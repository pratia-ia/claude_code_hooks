# Senior Reviewer Plugin

Plugin de Claude Code que proporciona un agente senior de revisión de código especializado en calidad, optimizaciones y mejores prácticas.

## Instalación

```bash
# Registrar el marketplace (instala automáticamente el plugin)
/plugin marketplace add practia-ia/claude_code_plugins

# Habilitar el plugin
/plugin enable senior-reviewer@practia-ia
```

Requiere Claude Code versión 1.0.40+ (soporte de plugins).

## Agente Incluido

### senior-code-review

Ingeniero senior con 15+ años de experiencia en revisión de código, arquitectura de software y mentoría de equipos.

**Expertise:**

- **Arquitectura & Diseño**
  - Separación de responsabilidades
  - Acoplamiento y cohesión
  - Patrones de diseño
  - Escalabilidad y mantenibilidad
  - Principios SOLID

- **Calidad de Código**
  - Clean code principles
  - Naming conventions
  - Code readability
  - DRY, KISS, YAGNI
  - Code smells detection

- **Performance & Optimización**
  - Análisis de complejidad algorítmica
  - Optimización de queries
  - Memory management
  - Caching strategies
  - Resource efficiency

- **Mejores Prácticas**
  - Error handling robusto
  - Testing strategies
  - Documentation standards
  - Security considerations
  - Technical debt management

- **Multi-Lenguaje**
  - JavaScript/TypeScript, Python, Java, C#, Go, Rust
  - Framework-specific best practices
  - Language idioms y patterns

**Formato de Feedback:**

```
### Summary
Resumen general de la revisión

### Strengths ✅
- Aspectos positivos del código
- Buenas prácticas aplicadas

### Issues by Priority

#### Critical 🔴
- Problemas que deben corregirse antes de merge
- Ubicación: archivo:línea
- Impacto y recomendación con código

#### High Priority 🟡
- Mejoras importantes

#### Medium Priority 🟢
- Mejoras recomendadas

#### Low Priority 🔵
- Nitpicks y preferencias

### Architecture Observations
Observaciones de diseño y arquitectura

### Performance Considerations
Oportunidades de optimización

### Learning Opportunities 📚
Insights educativos y recursos
```

## Uso

### Invocación Manual

1. **Desde el menú de agentes:**
   ```bash
   /agents
   ```
   Selecciona "senior-code-review" de la lista.

2. **Mención directa:**
   ```
   @senior-code-review revisa estos cambios antes de crear el PR
   ```

### Invocación Automática

El agente se invocará proactivamente cuando:

- Se solicite revisión de código
- Se implementen nuevas features
- Antes de crear pull requests
- Se refactorice código existente
- Se trabaje en arquitectura

### Ejemplos de Uso

**Revisión completa antes de PR:**
```
@senior-code-review revisa todos mis cambios pendientes y proporciona
feedback sobre calidad, performance y mejores prácticas antes de crear el PR
```

**Revisión de feature específica:**
```
@senior-code-review revisa la implementación del nuevo sistema de autenticación
en src/auth/, enfocándote en seguridad y escalabilidad
```

**Revisar refactoring:**
```
@senior-code-review evalúa este refactoring del servicio de usuarios.
¿Mejoré la arquitectura? ¿Hay oportunidades de optimización?
```

**Code review de archivos específicos:**
```
@senior-code-review revisa src/services/payment-processor.ts y dame feedback
sobre el manejo de errores y la lógica de negocio
```

**Revisión de tests:**
```
@senior-code-review evalúa la calidad de los tests en tests/integration/.
¿La cobertura es adecuada? ¿Los tests son mantenibles?
```

**Optimización de performance:**
```
@senior-code-review analiza src/api/products.py y sugiere optimizaciones
de performance, especialmente en las queries de base de datos
```

## Áreas de Revisión

El agente evalúa código en múltiples dimensiones:

### Funcionalidad ✓
- ✓ El código hace lo que debe hacer
- ✓ Edge cases manejados
- ✓ Escenarios de error cubiertos
- ✓ Lógica de negocio correcta

### Arquitectura & Diseño 🏗️
- ✓ Separación de responsabilidades clara
- ✓ Componentes desacoplados
- ✓ Abstracción apropiada
- ✓ Diseño escalable
- ✓ Patrones de diseño correctos

### Calidad de Código 📝
- ✓ Código legible y auto-documentado
- ✓ Nombres claros y consistentes
- ✓ Funciones enfocadas
- ✓ Sin duplicación
- ✓ Nivel de abstracción apropiado

### Performance ⚡
- ✓ Sin problemas obvios de rendimiento
- ✓ Algoritmos y estructuras eficientes
- ✓ Uso eficiente de recursos
- ✓ Queries optimizadas

### Testing 🧪
- ✓ Cobertura adecuada
- ✓ Tests significativos
- ✓ Edge cases testeados
- ✓ Tests mantenibles

### Mantenibilidad 🔧
- ✓ Fácil de entender y modificar
- ✓ Documentado donde es necesario
- ✓ Deuda técnica identificada
- ✓ Estructura lógica

## Niveles de Revisión

El agente ajusta la profundidad según el contexto:

### Quick Review (< 100 líneas)
- Issues críticos y mejoras obvias
- Verificación de seguridad
- Funcionalidad y tests básicos

### Standard Review (100-500 líneas)
- Checklist completo
- Feedback de arquitectura y diseño
- Consideraciones de performance
- Adherencia a best practices

### Deep Review (> 500 líneas o features críticas)
- Análisis comprehensivo de todas las capas
- Implicaciones arquitectónicas
- Mantenibilidad a largo plazo
- Consideraciones de escalabilidad
- Sugerencias de profiling

## Code Smells Detectados

El agente identifica automáticamente:

- **Long methods** (>50 líneas)
- **God objects** (clases con demasiadas responsabilidades)
- **Long parameter lists** (>3-4 parámetros)
- **Primitive obsession** (primitivos en lugar de objetos de dominio)
- **Switch statements** (polimorfismo faltante)
- **Data clumps** (mismo grupo de datos repetido)
- **Feature envy** (método más interesado en datos de otra clase)
- **Shotgun surgery** (cambio requiere modificaciones en muchas clases)

## Performance Red Flags

Detecta automáticamente:

- Queries N+1
- Operaciones sin paginación
- Operaciones síncronas que podrían ser async
- Índices faltantes
- Objetos grandes en memoria innecesariamente
- Loops anidados con alta complejidad
- Concatenación de strings ineficiente
- Caching faltante
- Memory leaks potenciales

## Principios de Comunicación

El agente sigue estos principios:

1. **Constructivo, no Crítico** - Enfoque en el código, no la persona
2. **Explica el "Por Qué"** - Razones detrás de cada sugerencia
3. **Proporciona Ejemplos** - Código before/after concreto
4. **Prioriza Feedback** - Distingue entre must-fix y nice-to-have
5. **Específico y Accionable** - Ubicaciones exactas y pasos claros
6. **Fomenta Discusión** - Sugerencias, no mandatos

## Estructura del Plugin

```
senior-reviewer/
├── .claude-plugin/
│   └── plugin.json              # Metadata del plugin
├── agents/
│   └── senior-code-review.md    # Definición del agente revisor
└── README.md                    # Esta documentación
```

## Tools Disponibles

El agente tiene acceso a:
- **Read**: Leer archivos de código
- **Grep**: Buscar patrones y code smells
- **Glob**: Encontrar archivos relacionados
- **Bash**: Ejecutar análisis estáticos

## Resultado Esperado

Después de cada review, el desarrollador obtendrá:

1. **Feedback accionable** - Implementable de inmediato
2. **Comprensión** - Por qué los cambios importan
3. **Confianza** - Su trabajo es valorado
4. **Conocimiento** - Para aplicar en trabajo futuro

## Notas Importantes

- El agente balancea pragmatismo con idealismo
- Enfoque en mejoras de alto impacto
- Crea momentos de aprendizaje
- Adapta el lenguaje y frameworks
- No solo revisa código, mentoriza ingenieros

## Licencia

MIT

## Autor

practiauy
