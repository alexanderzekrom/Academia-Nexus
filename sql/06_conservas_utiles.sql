-- =====================================================
-- CONSULTAS ÚTILES - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- CONSULTAS DE ESTUDIANTES
-- =====================================================

-- Obtener todos los estudiantes activos ordenados por promedio
SELECT * FROM academia_nexus.public.v_estudiantes
WHERE estado = 'ACTIVO'
ORDER BY nota_promedio_general DESC;

-- Buscar estudiantes en estado de observación
SELECT * FROM academia_nexus.public.v_estudiantes_observacion;

-- Obtener historial académico de un estudiante específico
SELECT * FROM academia_nexus.public.v_historial_academico_completo
WHERE nombre_estudiante = '[NOMBRE_ESTUDIANTE]'
ORDER BY fecha_aprobacion DESC;

-- Estudiantes con más materias reprobadas
SELECT 
    nombre_completo,
    correo_electronico,
    materias_reprobadas_consecutivas,
    nota_promedio_general
FROM academia_nexus.public.estudiante
WHERE materias_reprobadas_consecutivas > 0
ORDER BY materias_reprobadas_consecutivas DESC;

-- =====================================================
-- CONSULTAS DE MATERIAS
-- =====================================================

-- Obtener todas las materias activas
SELECT * FROM academia_nexus.public.v_materias_completa
WHERE estado = 'ACTIVA'
ORDER BY nombre_area, nombre_materia;

-- Materias por área de conocimiento
SELECT * FROM academia_nexus.public.v_materias_por_area
ORDER BY total_creditos DESC;

-- Materias con menor tasa de aprobación (prioridad de revisión)
SELECT * FROM academia_nexus.public.v_rendimiento_materia
WHERE total_intentos > 5
ORDER BY tasa_aprobacion_porcentaje ASC
LIMIT 10;

-- Cupos disponibles en materias para el ciclo actual
SELECT * FROM academia_nexus.public.v_cupos_disponibles
WHERE estado_cupo = 'DISPONIBLE'
ORDER BY porcentaje_ocupacion DESC;

-- Requisitos previos de una materia específica
SELECT * FROM academia_nexus.public.v_requisitos_materias
WHERE materia_principal = '[NOMBRE_MATERIA]';

-- =====================================================
-- CONSULTAS DE PROFESORES
-- =====================================================

-- Todos los profesores activos
SELECT * FROM academia_nexus.public.v_profesores_certificados
WHERE estado = 'ACTIVO'
ORDER BY nombre_completo;

-- Profesores con más certificaciones
SELECT * FROM academia_nexus.public.v_profesores_certificados
ORDER BY certificaciones_activas DESC;

-- Matriz de asignaciones de profesores
SELECT * FROM academia_nexus.public.v_matriz_asignaciones
WHERE estado_ciclo = 'ACTIVO'
ORDER BY nombre_profesor, nombre_materia;

-- Certificaciones por área de conocimiento
SELECT * FROM academia_nexus.public.v_certificaciones_por_area
WHERE porcentaje_cobertura_area > 50
ORDER BY nombre_area, porcentaje_cobertura_area DESC;

-- =====================================================
-- CONSULTAS DE INSCRIPCIONES
-- =====================================================

-- Inscripciones actuales por ciclo
SELECT * FROM academia_nexus.public.v_inscripciones_detalle
WHERE estado = 'INSCRITO'
ORDER BY nombre_ciclo, nombre_estudiante;

-- Inscripciones detalladas de un estudiante
SELECT * FROM academia_nexus.public.v_inscripciones_detalle
WHERE correo_estudiante = '[CORREO_ESTUDIANTE]'
ORDER BY fecha_inscripcion DESC;

-- Estudiantes inscritos en una materia específica
SELECT * FROM academia_nexus.public.v_inscripciones_detalle
WHERE nombre_materia = '[NOMBRE_MATERIA]'
AND estado = 'INSCRITO'
ORDER BY nombre_estudiante;

-- =====================================================
-- CONSULTAS DE CICLOS
-- =====================================================

-- Estadísticas de ciclos
SELECT * FROM academia_nexus.public.v_ciclos_estadisticas
ORDER BY fecha_inicio DESC;

-- Ciclo activo actual
SELECT * FROM academia_nexus.public.v_ciclos_estadisticas
WHERE estado = 'ACTIVO'
ORDER BY fecha_inicio DESC
LIMIT 1;

-- Análisis de carga académica por ciclo
SELECT * FROM academia_nexus.public.v_analisis_carga_academica
WHERE nombre_ciclo = '[NOMBRE_CICLO]'
ORDER BY nivel_carga DESC, materias_inscritos DESC;

-- =====================================================
-- CONSULTAS DE EVALUACIONES
-- =====================================================

-- Evaluaciones completas por inscripción
SELECT * FROM academia_nexus.public.v_evaluaciones_completas
WHERE nombre_estudiante = '[NOMBRE_ESTUDIANTE]'
AND nombre_materia = '[NOMBRE_MATERIA]'
ORDER BY fecha_evaluacion;

-- Evaluaciones reprobadas por tipo
SELECT 
    tipo_evaluacion,
    COUNT(*) as total_evaluaciones,
    COUNT(CASE WHEN nota < 7.0 THEN 1 END) as reprobadas,
    ROUND(AVG(nota), 2) as promedio_nota
FROM academia_nexus.public.evaluacion
GROUP BY tipo_evaluacion
ORDER BY reprobadas DESC;

-- =====================================================
-- CONSULTAS DE RENDIMIENTO
-- =====================================================

-- Dashboard académico general
SELECT * FROM academia_nexus.public.v_dashboard_academico;

-- Rendimiento detallado por estudiante
SELECT * FROM academia_nexus.public.v_rendimiento_estudiante_detalle
ORDER BY tasa_aprobacion_porcentaje ASC;

-- Trayectoria académica de estudiantes
SELECT * FROM academia_nexus.public.v_trayectoria_academica
WHERE nombre_completo = '[NOMBRE_ESTUDIANTE]'
ORDER BY fecha_aprobacion;

-- Top 5 estudiantes por promedio
SELECT * FROM academia_nexus.public.v_rendimiento_estudiante_detalle
ORDER BY nota_promedio_general DESC
LIMIT 5;

-- Estudiantes que necesitan intervención (prioridad)
SELECT * FROM academia_nexus.public.v_rendimiento_estudiante_detalle
WHERE estado_estudiante = 'OBSERVACION' OR materias_reprobadas_consecutivas >= 2
ORDER BY materias_reprobadas_consecutivas DESC, nota_promedio_general ASC;

-- =====================================================
-- CONSULTAS DE REPORTES
-- =====================================================

-- Reporte general del sistema
SELECT 
    'ESTADÍSTICAS GENERALES' as categoria,
    json_build_object(
        'estudiantes_activos', (SELECT COUNT(*) FROM academia_nexus.public.estudiante WHERE estado = 'ACTIVO'),
        'profesores_activos', (SELECT COUNT(*) FROM academia_nexus.public.profesor WHERE estado = 'ACTIVO'),
        'materias_activas', (SELECT COUNT(*) FROM academia_nexus.public.materia WHERE estado = 'ACTIVA'),
        'ciclos_activos', (SELECT COUNT(*) FROM academia_nexus.public.ciclo WHERE estado = 'ACTIVO')
    ) as datos;

-- Reporte de rendimiento por área
SELECT 
    a.nombre_area,
    COUNT(m.id_materia) as total_materias,
    COUNT(DISTINCT i.id_estudiante) as total_estudiantes,
    ROUND(AVG(i.nota_final), 2) as promedio_general,
    ROUND(COUNT(CASE WHEN i.estado = 'APROBADO' THEN 1 END)::NUMERIC / 
          NULLIF(COUNT(*), 0) * 100, 2) as tasa_aprobacion
FROM academia_nexus.public.area_conocimiento a
LEFT JOIN academia_nexus.public.materia m ON a.id_area = m.id_area_conocimiento
LEFT JOIN academia_nexus.public.inscripcion i ON m.id_materia = i.id_materia
GROUP BY a.id_area, a.nombre_area
ORDER BY tasa_aprobacion ASC;

-- =====================================================
-- CONSULTAS DE VALIDACIÓN
-- =====================================================

-- Verificar estudiantes que exceden límite de materias (no debería haber ninguno)
SELECT 
    e.id_estudiante,
    e.nombre_completo,
    COUNT(i.id_inscripcion) as materias_inscritas
FROM academia_nexus.public.estudiante e
JOIN academia_nexus.public.inscripcion i ON e.id_estudiante = i.id_estudiante
WHERE i.estado != 'RETIRADO'
AND i.id_ciclo = (SELECT id_ciclo FROM academia_nexus.public.ciclo WHERE estado = 'ACTIVO' LIMIT 1)
GROUP BY e.id_estudiante, e.nombre_completo
HAVING COUNT(i.id_inscripcion) > 6;

-- Verificar profesores asignados sin certificación (no debería haber ninguno)
SELECT 
    p.nombre_completo,
    m.nombre_materia,
    c.nombre_ciclo
FROM academia_nexus.public.asignacion_profesor ap
JOIN academia_nexus.public.profesor p ON ap.id_profesor = p.id_profesor
JOIN academia_nexus.public.materia m ON ap.id_materia = m.id_materia
JOIN academia_nexus.public.ciclo c ON ap.id_ciclo = c.id_ciclo
LEFT JOIN academia_nexus.public.certificacion_profesor cp 
    ON p.id_profesor = cp.id_profesor AND m.id_materia = cp.id_materia
WHERE cp.id_certificacion IS NULL OR cp.estado != 'ACTIVA';

-- Verificar inscripciones sin profesor asignado
SELECT 
    m.nombre_materia,
    c.nombre_ciclo,
    COUNT(i.id_inscripcion) as estudiantes_sin_profesor
FROM academia_nexus.public.inscripcion i
JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
JOIN academia_nexus.public.ciclo c ON i.id_ciclo = c.id_ciclo
LEFT JOIN academia_nexus.public.asignacion_profesor ap 
    ON m.id_materia = ap.id_materia AND c.id_ciclo = ap.id_ciclo
WHERE ap.id_asignacion IS NULL
AND i.estado = 'INSCRITO'
GROUP BY m.nombre_materia, c.nombre_ciclo;

-- =====================================================
-- CONSULTAS DE AUDITORÍA
-- =====================================================

-- Últimos cambios en inscripciones
SELECT 
    'INSCRIPCIONES' as tabla,
    i.id_inscripcion,
    i.fecha_inscripcion as fecha_ultimo_cambio,
    CASE 
        WHEN i.estado = 'INSCRITO' THEN 'Nueva inscripción'
        WHEN i.estado = 'APROBADO' THEN 'Aprobación registrada'
        WHEN i.estado = 'REPROBADO' THEN 'Reprobación registrada'
        WHEN i.estado = 'RETIRADO' THEN 'Retiro registrado'
        ELSE 'Cambio de estado'
    END as tipo_cambio
FROM academia_nexus.public.inscripcion i
WHERE i.fecha_inscripcion >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY i.fecha_inscripcion DESC;

-- Actividad reciente de evaluaciones
SELECT 
    e.tipo_evaluacion,
    ev.fecha_evaluacion,
    est.nombre_completo as estudiante,
    m.nombre_materia,
    ev.nota
FROM academia_nexus.public.evaluacion ev
JOIN academia_nexus.public.inscripcion e ON ev.id_inscripcion = e.id_inscripcion
JOIN academia_nexus.public.estudiante est ON e.id_estudiante = est.id_estudiante
JOIN academia_nexus.public.materia m ON e.id_materia = m.id_materia
WHERE ev.fecha_evaluacion >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY ev.fecha_evaluacion DESC;

-- =====================================================
-- NOTAS DE USO
-- =====================================================
-- Reemplazar [NOMBRE_ESTUDIANTE], [CORREO_ESTUDIANTE], [NOMBRE_MATERIA], [NOMBRE_CICLO]
-- con los valores correspondientes según necesidad

-- Todas las consultas usan la nomenclatura academia_nexus.public.nombre_tabla
-- Pueden ejecutarse individualmente o adaptarse según necesidades específicas