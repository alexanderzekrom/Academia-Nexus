-- =====================================================
-- VISTAS CON JOINS COMPLEJOS - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- VISTA: Dashboard académico general
-- Join complejo para visión completa del sistema
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_dashboard_academico AS
SELECT 
    -- Estadísticas generales
    (SELECT COUNT(*) FROM academia_nexus.public.estudiante WHERE estado = 'ACTIVO') as estudiantes_activos,
    (SELECT COUNT(*) FROM academia_nexus.public.estudiante WHERE estado = 'OBSERVACION') as estudiantes_observacion,
    (SELECT COUNT(*) FROM academia_nexus.public.profesor WHERE estado = 'ACTIVO') as profesores_activos,
    (SELECT COUNT(*) FROM academia_nexus.public.materia WHERE estado = 'ACTIVA') as materias_activas,
    (SELECT COUNT(*) FROM academia_nexus.public.ciclo WHERE estado = 'ACTIVO') as ciclos_activos,
    
    -- Estadísticas de inscripciones actuales
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE estado = 'INSCRITO') as inscripciones_activas,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE estado = 'APROBADO') as total_aprobaciones_historicas,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE estado = 'REPROBADO') as total_reprobaciones_historicas,
    
    -- Promedios generales
    (SELECT AVG(nota_promedio_general) FROM academia_nexus.public.estudiante WHERE estado = 'ACTIVO') as promedio_general_estudiantes,
    (SELECT AVG(materias_reprobadas_consecutivas) FROM academia_nexus.public.estudiante WHERE estado = 'OBSERVACION') as promedio_reprobadas_observacion;

COMMENT ON VIEW academia_nexus.public.v_dashboard_academico IS 'Dashboard académico con estadísticas generales del sistema';

-- =====================================================
-- VISTA: Rendimiento detallado por estudiante
-- Join múltiple para análisis individual
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_rendimiento_estudiante_detalle AS
SELECT 
    e.id_estudiante,
    e.nombre_completo,
    e.correo_electronico,
    e.estado as estado_estudiante,
    e.nota_promedio_general,
    e.materias_reprobadas_consecutivas,
    e.fecha_ingreso,
    
    -- Conteos de inscripciones
    COALESCE(ins_counts.total_inscripciones, 0) as total_inscripciones,
    COALESCE(ins_counts.aprobadas, 0) as total_aprobadas,
    COALESCE(ins_counts.reprobadas, 0) as total_reprobadas,
    COALESCE(ins_counts.retiradas, 0) as total_retiradas,
    COALESCE(ins_counts.en_curso, 0) as en_curso,
    
    -- Calcular tasa de aprobación
    CASE 
        WHEN COALESCE(ins_counts.total_inscripciones, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(ins_counts.aprobadas, 0)::NUMERIC / 
                  COALESCE(ins_counts.total_inscripciones, 0) * 100, 2)
    END as tasa_aprobacion_porcentaje,
    
    -- Última actividad
    (SELECT MAX(i.fecha_inscripcion) 
     FROM academia_nexus.public.inscripcion i 
     WHERE i.id_estudiante = e.id_estudiante) as ultima_inscripcion,
    
    -- Áreas de conocimiento cursadas
    (SELECT COUNT(DISTINCT m.id_area_conocimiento)
     FROM academia_nexus.public.inscripcion i
     JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
     WHERE i.id_estudiante = e.id_estudiante
     AND i.estado = 'APROBADO') as areas_cursadas,
    
    -- Créditos acumulados
    (SELECT COALESCE(SUM(m.creditos), 0)
     FROM academia_nexus.public.inscripcion i
     JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
     WHERE i.id_estudiante = e.id_estudiante
     AND i.estado = 'APROBADO') as creditos_acumulados

FROM academia_nexus.public.estudiante e
LEFT JOIN (
    SELECT 
        i.id_estudiante,
        COUNT(*) as total_inscripciones,
        COUNT(CASE WHEN i.estado = 'APROBADO' THEN 1 END) as aprobadas,
        COUNT(CASE WHEN i.estado = 'REPROBADO' THEN 1 END) as reprobadas,
        COUNT(CASE WHEN i.estado = 'RETIRADO' THEN 1 END) as retiradas,
        COUNT(CASE WHEN i.estado = 'INSCRITO' THEN 1 END) as en_curso
    FROM academia_nexus.public.inscripcion i
    GROUP BY i.id_estudiante
) ins_counts ON e.id_estudiante = ins_counts.id_estudiante
ORDER BY e.nota_promedio_general DESC;

COMMENT ON VIEW academia_nexus.public.v_rendimiento_estudiante_detalle IS 'Análisis detallado de rendimiento por estudiante';

-- =====================================================
-- VISTA: Matriz de profesor-materia-ciclo
-- Join triple para asignaciones
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_matriz_asignaciones AS
SELECT 
    p.id_profesor,
    p.nombre_completo as nombre_profesor,
    p.correo_electronico as correo_profesor,
    m.id_materia,
    m.nombre_materia,
    m.codigo_materia,
    m.creditos,
    m.horario,
    a.nombre_area as area_conocimiento,
    c.id_ciclo,
    c.nombre_ciclo,
    c.fecha_inicio,
    c.fecha_fin,
    c.estado as estado_ciclo,
    ap.fecha_asignacion,
    
    -- Estudiantes inscritos en esta combinación
    (SELECT COUNT(*) 
     FROM academia_nexus.public.inscripcion i 
     WHERE i.id_materia = m.id_materia 
     AND i.id_ciclo = c.id_ciclo
     AND i.estado != 'RETIRADO') as estudiantes_inscritos,
    
    -- Estado de la asignación
    CASE 
        WHEN c.estado = 'CERRADO' THEN 'FINALIZADO'
        WHEN c.estado = 'FUTURO' THEN 'PROGRAMADO'
        WHEN (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
              WHERE i.id_materia = m.id_materia 
              AND i.id_ciclo = c.id_ciclo) > 0 THEN 'ACTIVO CON ESTUDIANTES'
        ELSE 'ACTIVO SIN ESTUDIANTES'
    END as estado_asignacion

FROM academia_nexus.public.profesor p
INNER JOIN academia_nexus.public.asignacion_profesor ap ON p.id_profesor = ap.id_profesor
INNER JOIN academia_nexus.public.materia m ON ap.id_materia = m.id_materia
INNER JOIN academia_nexus.public.area_conocimiento a ON m.id_area_conocimiento = a.id_area
INNER JOIN academia_nexus.public.ciclo c ON ap.id_ciclo = c.id_ciclo
ORDER BY c.fecha_inicio DESC, p.nombre_completo, m.nombre_materia;

COMMENT ON VIEW academia_nexus.public.v_matriz_asignaciones IS 'Matriz completa de asignaciones profesor-materia-ciclo';

-- =====================================================
-- VISTA: Trayectoria académica de estudiante
-- Join con historial para análisis temporal
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_trayectoria_academica AS
SELECT 
    e.id_estudiante,
    e.nombre_completo,
    e.fecha_ingreso,
    
    -- Datos del historial
    h.id_historial,
    m.nombre_materia,
    m.codigo_materia,
    m.creditos,
    a.nombre_area as area_conocimiento,
    c.nombre_ciclo,
    h.nota_final,
    h.fecha_aprobacion,
    h.intento_numero,
    
    -- Cálculos temporales
    DATE_PART('day', AGE(h.fecha_aprobacion, e.fecha_ingreso)) as dias_desde_ingreso,
    DATE_PART('month', AGE(h.fecha_aprobacion, e.fecha_ingreso)) as meses_desde_ingreso,
    
    -- Clasificación por rendimiento
    CASE 
        WHEN h.nota_final >= 9.0 THEN 'Excelente'
        WHEN h.nota_final >= 8.0 THEN 'Muy Bueno'
        WHEN h.nota_final >= 7.0 THEN 'Bueno'
        WHEN h.nota_final >= 6.0 THEN 'Suficiente'
        ELSE 'Insuficiente'
    END as clasificacion_rendimiento,
    
    -- Dificultad percibida (basada en intentos)
    CASE 
        WHEN h.intento_numero = 1 THEN 'Fácil'
        WHEN h.intento_numero = 2 THEN 'Moderada'
        ELSE 'Difícil'
    END as nivel_dificultad

FROM academia_nexus.public.estudiante e
INNER JOIN academia_nexus.public.historial_academico h ON e.id_estudiante = h.id_estudiante
INNER JOIN academia_nexus.public.materia m ON h.id_materia = m.id_materia
INNER JOIN academia_nexus.public.area_conocimiento a ON m.id_area_conocimiento = a.id_area
INNER JOIN academia_nexus.public.ciclo c ON h.id_ciclo = c.id_ciclo
ORDER BY e.nombre_completo, h.fecha_aprobacion;

COMMENT ON VIEW academia_nexus.public.v_trayectoria_academica IS 'Análisis temporal de trayectoria académica por estudiante';

-- =====================================================
-- VISTA: Evaluaciones completas por inscripción
-- Join para ver todas las evaluaciones de cada inscripción
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_evaluaciones_completas AS
SELECT 
    i.id_inscripcion,
    e.nombre_completo as nombre_estudiante,
    m.nombre_materia,
    m.codigo_materia,
    c.nombre_ciclo,
    ev.id_evaluacion,
    ev.tipo_evaluacion,
    ev.descripcion,
    ev.nota,
    ev.fecha_evaluacion,
    ev.porcentaje_peso,
    i.nota_final as nota_final_inscripcion,
    
    -- Contribución a la nota final
    ROUND(ev.nota * (ev.porcentaje_peso / 100), 2) as contribucion_nota_final,
    
    -- Clasificación de tipo de evaluación
    CASE 
        WHEN ev.tipo_evaluacion = 'EXAMEN_FINAL' THEN 'Evaluación Final'
        WHEN ev.tipo_evaluacion = 'EXAMEN_PARCIAL' THEN 'Evaluación Parcial'
        WHEN ev.tipo_evaluacion = 'TAREA' THEN 'Tarea'
        WHEN ev.tipo_evaluacion = 'PROYECTO' THEN 'Proyecto'
        WHEN ev.tipo_evaluacion = 'QUIZ' THEN 'Quiz'
        ELSE ev.tipo_evaluacion
    END as tipo_descripcion,
    
    -- Estado de evaluación
    CASE 
        WHEN ev.nota >= 7.0 THEN 'APROBADA'
        ELSE 'NO APROBADA'
    END as estado_evaluacion

FROM academia_nexus.public.inscripcion i
INNER JOIN academia_nexus.public.estudiante e ON i.id_estudiante = e.id_estudiante
INNER JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
INNER JOIN academia_nexus.public.ciclo c ON i.id_ciclo = c.id_ciclo
INNER JOIN academia_nexus.public.evaluacion ev ON i.id_inscripcion = ev.id_inscripcion
ORDER BY c.nombre_ciclo, e.nombre_completo, m.nombre_materia, ev.fecha_evaluacion;

COMMENT ON VIEW academia_nexus.public.v_evaluaciones_completas IS 'Detalle completo de evaluaciones por inscripción';

-- =====================================================
-- VISTA: Certificaciones por área de conocimiento
-- Join para análisis de especialización docente
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_certificaciones_por_area AS
SELECT 
    a.id_area,
    a.nombre_area,
    p.id_profesor,
    p.nombre_completo as nombre_profesor,
    p.correo_electronico,
    cp.fecha_certificacion,
    cp.estado as estado_certificacion,
    
    -- Materias certificadas en esta área
    (SELECT COUNT(*) 
     FROM academia_nexus.public.certificacion_profesor cp2 
     WHERE cp2.id_profesor = p.id_profesor 
     AND cp2.id_materia IN (SELECT m.id_materia FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area)
     AND cp2.estado = 'ACTIVA') as total_certificaciones_area,
    
    -- Total materias en área
    (SELECT COUNT(*) FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area) as total_materias_area,
    
    -- Porcentaje de cobertura del profesor en el área
    CASE 
        WHEN (SELECT COUNT(*) FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area) = 0 THEN 0
        ELSE ROUND((SELECT COUNT(*) 
                   FROM academia_nexus.public.certificacion_profesor cp2 
                   WHERE cp2.id_profesor = p.id_profesor 
                   AND cp2.id_materia IN (SELECT m.id_materia FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area)
                   AND cp2.estado = 'ACTIVA')::NUMERIC / 
                  (SELECT COUNT(*) FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area) * 100, 2)
    END as porcentaje_cobertura_area

FROM academia_nexus.public.area_conocimiento a
CROSS JOIN academia_nexus.public.profesor p
LEFT JOIN academia_nexus.public.certificacion_profesor cp ON 
    cp.id_profesor = p.id_profesor 
    AND cp.id_materia IN (SELECT m.id_materia FROM academia_nexus.public.materia m WHERE m.id_area_conocimiento = a.id_area)
WHERE p.estado = 'ACTIVO'
ORDER BY a.nombre_area, porcentaje_cobertura_area DESC;

COMMENT ON VIEW academia_nexus.public.v_certificaciones_por_area IS 'Análisis de cobertura de certificaciones por área';

-- =====================================================
-- VISTA: Análisis de carga académica por ciclo
-- Join complejo para distribución de carga
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_analisis_carga_academica AS
SELECT 
    c.id_ciclo,
    c.nombre_ciclo,
    c.fecha_inicio,
    c.fecha_fin,
    e.id_estudiante,
    e.nombre_completo,
    e.estado as estado_estudiante,
    
    -- Materias inscritas en el ciclo
    (SELECT COUNT(*) 
     FROM academia_nexus.public.inscripcion i 
     WHERE i.id_estudiante = e.id_estudiante 
     AND i.id_ciclo = c.id_ciclo
     AND i.estado != 'RETIRADO') as materias_inscritas,
    
    -- Créditos totales inscritos
    (SELECT COALESCE(SUM(m.creditos), 0)
     FROM academia_nexus.public.inscripcion i
     JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
     WHERE i.id_estudiante = e.id_estudiante 
     AND i.id_ciclo = c.id_ciclo
     AND i.estado != 'RETIRADO') as creditos_inscritos,
    
    -- Clasificación de carga
    CASE 
        WHEN (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
              WHERE i.id_estudiante = e.id_estudiante 
              AND i.id_ciclo = c.id_ciclo
              AND i.estado != 'RETIRADO') >= 6 THEN 'CARGA MÁXIMA'
        WHEN (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
              WHERE i.id_estudiante = e.id_estudiante 
              AND i.id_ciclo = c.id_ciclo
              AND i.estado != 'RETIRADO') >= 4 THEN 'CARGA ALTA'
        WHEN (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
              WHERE i.id_estudiante = e.id_estudiante 
              AND i.id_ciclo = c.id_ciclo
              AND i.estado != 'RETIRADO') >= 2 THEN 'CARGA MEDIA'
        ELSE 'CARGA BAJA'
    END as nivel_carga,
    
    -- Promedio de notas del ciclo
    (SELECT AVG(i.nota_final)
     FROM academia_nexus.public.inscripcion i
     WHERE i.id_estudiante = e.id_estudiante 
     AND i.id_ciclo = c.id_ciclo
     AND i.estado IN ('APROBADO', 'REPROBADO')) as promedio_ciclo

FROM academia_nexus.public.ciclo c
CROSS JOIN academia_nexus.public.estudiante e
WHERE c.estado = 'ACTIVO' AND e.estado IN ('ACTIVO', 'OBSERVACION')
ORDER BY c.nombre_ciclo, materias_inscritos DESC;

COMMENT ON VIEW academia_nexus.public.v_analisis_carga_academica IS 'Análisis de carga académica por ciclo y estudiante';

-- =====================================================
-- CONFIRMACIÓN DE CREACIÓN
-- =====================================================
SELECT 'Vistas con joins complejos creadas exitosamente' AS mensaje,
       COUNT(*) as total_vistas
FROM information_schema.views
WHERE table_schema = 'public';