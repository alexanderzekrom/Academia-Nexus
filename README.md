# Academia Nexus - Sistema de Gestión Académica

Sistema de gestión académica completo implementado en PostgreSQL 15.x para el control de estudiantes, profesores, materias, ciclos académicos y evaluaciones.

## 📋 Descripción del Proyecto

Academia Nexus es un sistema educativo innovador donde los estudiantes construyen su carrera profesional mediante rutas de aprendizaje especializadas. El sistema implementa un modelo educativo basado en áreas de conocimiento, requisitos previos, certificación de profesores y seguimiento académico integral.

### Características Principales

- **Gestión de Estudiantes:** Control completo de información académica, historial y estado
- **Gestión de Profesores:** Sistema de certificación por materia y asignación a ciclos
- **Gestión de Materias:** Organización por áreas de conocimiento con requisitos previos
- **Ciclos Académicos:** Control de periodos lectivos con estados (ACTIVO, CERRADO, FUTURO)
- **Evaluaciones:** Sistema de evaluaciones continuas con cálculo automático de notas
- **Reglas de Negocio:** Implementación de 9 triggers para validación automática
- **Procedimientos Almacenados:** 10 procedimientos para operaciones comunes
- **Vistas:** 17 vistas para simplificar consultas y análisis avanzado

## 🏗️ Estructura del Proyecto

```
/
├── docs/                 # Documentación del proyecto
│   ├── contexto.txt       # Contexto completo del proyecto
│   ├── documentos_proyecto.txt  # Lista de documentos y estructura
│   ├── etapas_proyecto.txt       # Planificación de fases futuras
│   ├── entidades_relaciones.txt  # Definición de entidades y relaciones
│   └── diagrama_er.txt           # Diagrama entidad-relación visual
└── sql/                  # Scripts SQL de base de datos
    ├── 00_creacion_base_datos.sql
    ├── 01_creacion_tablas.sql
    ├── 02_triggers_reglas_negocio.sql
    ├── 03_procedimientos_almacenados.sql
    ├── 04_vistas_almacenadas.sql
    ├── 05_vistas_joins_complejos.sql
    ├── 06_conservas_utiles.sql
    └── 07_datos_prueba.sql
```

## 🚀 Requisitos Técnicos

- **Motor de base de datos:** PostgreSQL 15.x o superior
- **Memoria RAM mínima:** 4GB (recomendado 8GB)
- **Espacio en disco:** 50GB mínimo para producción
- **Sistema operativo:** Linux (Ubuntu 22.04 LTS recomendado) o Windows Server 2019+
- **Conexión:** TCP/IP, puerto 5432 (configurable)

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/alexanderzekrom/Academia-Nexus.git
cd Academia-Nexus
```

### 2. Ejecutar los scripts SQL en orden

```bash
cd sql/

# Crear base de datos
psql -U postgres -f 00_creacion_base_datos.sql

# Crear tablas
psql -U postgres -d academia_nexus -f 01_creacion_tablas.sql

# Crear triggers de reglas de negocio
psql -U postgres -d academia_nexus -f 02_triggers_reglas_negocio.sql

# Crear procedimientos almacenados
psql -U postgres -d academia_nexus -f 03_procedimientos_almacenados.sql

# Crear vistas almacenadas
psql -U postgres -d academia_nexus -f 04_vistas_almacenadas.sql

# Crear vistas con joins complejos
psql -U postgres -d academia_nexus -f 05_vistas_joins_complejos.sql

# Crear consultas útiles
psql -U postgres -d academia_nexus -f 06_conservas_utiles.sql

# Insertar datos de prueba
psql -U postgres -d academia_nexus -f 07_datos_prueba.sql
```

## 🗄️ Esquema de Base de Datos

### Tablas Principales

- **area_conocimiento:** Áreas de conocimiento (Ciencias de la Computación, Matemáticas, etc.)
- **estudiante:** Información de estudiantes con estado académico
- **materia:** Materias con requisitos, cupos y horarios
- **profesor:** Profesores con información de contacto y estado
- **ciclo:** Periodos lectivos con fechas y estados
- **inscripcion:** Inscripciones de estudiantes en materias
- **evaluacion:** Evaluaciones por inscripción con notas
- **certificacion_profesor:** Certificaciones de profesores por materia
- **requisito_materia:** Requisitos previos entre materias
- **asignacion_profesor:** Asignación de profesores a materias por ciclo
- **historial_academico:** Historial de materias aprobadas por estudiantes

### Nomenclatura

- **Base de datos:** `academia_nexus`
- **Formato completo:** `academia_nexus.public.nombre_tabla`
- **Versión PostgreSQL:** 15.x

## 📐 Reglas de Negocio Implementadas

1. **Límite de materias:** Un estudiante no puede inscribir más de 6 materias por ciclo
2. **Requisitos previos:** Validación automática de requisitos previos antes de inscribir
3. **Certificación de profesores:** Solo profesores certificados pueden impartir materias
4. **Cálculo de nota final:** Cálculo automático de nota final basado en evaluaciones
5. **Materias reprobadas consecutivas:** Seguimiento de reprobaciones consecutivas
6. **Promedio general:** Actualización automática del promedio general del estudiante
7. **Historial académico:** Registro automático de materias aprobadas
8. **Cupo máximo:** Validación de cupo máximo por materia
9. **Prevención de modificación:** Protección de notas de evaluación ya registradas

## 🔄 Procedimientos Almacenados

- `inscribir_estudiante_materia()`: Inscribir estudiante en materia
- `retirar_estudiante_materia()`: Retirar estudiante de materia
- `registrar_evaluacion()`: Registrar evaluación para inscripción
- `calcular_promedio_estudiante()`: Calcular promedio de un estudiante
- `obtener_materias_disponibles()`: Obtener materias disponibles para inscripción
- `asignar_profesor_materia()`: Asignar profesor a materia en ciclo
- `cambiar_estado_estudiante()`: Cambiar estado de estudiante
- `cambiar_estado_ciclo()`: Cambiar estado de ciclo
- `generar_reporte_rendimiento()`: Generar reporte de rendimiento
- `obtener_estudiantes_observacion()`: Obtener estudiantes en observación

## 📊 Vistas Disponibles

### Vistas Básicas
- `vista_estudiantes`: Información resumida de estudiantes
- `vista_materias`: Información de materias con áreas
- `vista_profesores_certificados`: Profesores con certificaciones
- `vista_inscripciones_detalle`: Inscripciones con información completa
- `vista_ciclos_estadisticas`: Ciclos con estadísticas
- `vista_estudiantes_observacion`: Estudiantes en observación académica
- `vista_materias_area`: Materias por área de conocimiento
- `vista_rendimiento_materia`: Rendimiento por materia
- `vista_historial_completo`: Historial académico completo
- `vista_requisitos_materia`: Requisitos de materias
- `vista_cupos_disponibles`: Cupos disponibles por materia

### Vistas con Joins Complejos
- `vista_dashboard_academico`: Dashboard académico general
- `vista_rendimiento_estudiante_detalle`: Rendimiento detallado por estudiante
- `vista_matriz_asignaciones`: Matriz profesor-materia-ciclo
- `vista_trayectoria_estudiante`: Trayectoria académica de estudiante
- `vista_evaluaciones_completas`: Evaluaciones completas por inscripción
- `vista_certificaciones_area`: Certificaciones por área
- `vista_carga_academica_ciclo`: Carga académica por ciclo

## 📈 Estado del Proyecto

**FASE 1 COMPLETADA** (20 de junio de 2025)

### Logros Fase 1
- ✅ Base de datos creada con todas las estructuras
- ✅ 11 tablas con relaciones y restricciones
- ✅ 9 triggers implementando reglas de negocio
- ✅ 10 procedimientos almacenados para operaciones comunes
- ✅ 10 vistas almacenadas para simplificar consultas
- ✅ 7 vistas con joins complejos para análisis avanzado
- ✅ Consultas útiles para operaciones frecuentes
- ✅ Datos de prueba para validar el sistema
- ✅ Sistema validado y funcionando correctamente

### KPIs Fase 1 (Logrados)
- Tiempo de ejecución de consultas: < 100ms promedio
- Integridad referencial: 100%
- Cobertura de reglas de negocio: 100%
- Tests de validación: 100% exitosos

## 🔮 Fases Futuras Planificadas

- **FASE 2:** Sistema de Roles y Permisos [CRÍTICA]
- **FASE 3:** Reglas de Negocio Adicionales [IMPORTANTE]
- **FASE 4:** Módulo de Horarios y Aulas [IMPORTANTE]
- **FASE 5:** Módulo de Pagos y Becas [IMPORTANTE]
- **FASE 6:** Módulo de Comunicación [OPCIONAL]
- **FASE 7:** Reportes y Analítica Avanzada [OPCIONAL]
- **FASE 8:** Integración y API [OPCIONAL]

Para más detalles sobre las fases futuras, ver `docs/etapas_proyecto.txt`.

## 📝 Documentación

- **Contexto del proyecto:** `docs/contexto.txt`
- **Documentos del proyecto:** `docs/documentos_proyecto.txt`
- **Etapas del desarrollo:** `docs/etapas_proyecto.txt`
- **Entidades y relaciones:** `docs/entidades_relaciones.txt`
- **Diagrama entidad-relación:** `docs/diagrama_er.txt`

## 👥 Autores

- **Alexander** - Desarrollador principal

## 📄 Licencia

Este proyecto es parte del sistema Academia Nexus Learning Institute.

## 🤝 Contribuciones

Para contribuir al proyecto, por favor sigue las siguientes etapas:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/NuevaFuncionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/NuevaFuncionalidad`)
5. Abre un Pull Request

## 📞 Soporte

Para consultas sobre el proyecto, revisar la documentación en la carpeta `docs/` o contactar al desarrollador.

---

**Academia Nexus** © 2025 - Sistema de Gestión Académica
