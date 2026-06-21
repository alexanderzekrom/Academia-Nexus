-- =====================================================
-- VISTAS ALMACENADAS - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- VISTA: Vista general de estudiantes
-- Proporciona información resumida de estudiantes
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_estudiantes AS
SELECT 
    e.id_estudiante,
    e.nombre_completo,
    e.correo_electronico,
    e.telefono,
    e.fecha_ingreso,
    e.estado,
    e.nota_promedio_general,
    e.materias_reprobadas_consecutivas,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fecha_nacimiento)) as edad,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fecha_ingreso)) as anos_en_institucion
FROM academia_nexus.public.estudiante e
ORDER BY e.nombre_completo;

COMMENT ON VIEW academia_nexus.public.v_estudiantes IS 'Vista general de estudiantes con información calculada';

-- =====================================================
-- VISTA: Vista de materias con área de conocimiento
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_materias_completa AS
SELECT 
    m.id_materia,
    m.nombre_materia,
    m.codigo_materia,
    m.creditos,
    m.horario,
    m.cupo_maximo,
    m.nota_minima_aprobacion,
    m.estado,
    a.nombre_area,
    a.descripcion as area_descripcion,
    (SELECT COUNT(*) FROM academia_nexus.public.requisito_materia rm WHERE rm.id_materia = m.id_materia) as cantidad_requisitos
FROM academia_nexus.public.materia m
JOIN academia_nexus.public.area_conocimiento a ON m.id_area_conocimiento = a.id_area
ORDER BY a.nombre_area, m.nombre_materia;

COMMENT ON VIEW academia_nexus.public.v_materias_completa IS 'Vista de materias con información de área y requisitos';

-- =====================================================
-- VISTA: Vista de profesores con certificaciones
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_profesores_certificados AS
SELECT 
    p.id_profesor,
    p.nombre_completo,
    p.correo_electronico,
    p.telefono,
    p.fecha_contratacion,
    p.estado,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.fecha_contratacion)) as anos_experiencia,
    (SELECT COUNT(*) FROM academia_nexus.public.certificacion_profesor cp 
     WHERE cp.id_profesor = p.id_profesor AND cp.estado = 'ACTIVA') as certificaciones_activas,
    (SELECT COUNT(*) FROM academia_nexus.public.asignacion_profesor ap 
     WHERE ap.id_profesor = p.id_profesor) as total_asignaciones
FROM academia_nexus.public.profesor p
ORDER BY p.nombre_completo;

COMMENT ON VIEW academia_nexus.public.v_profesores_certificados IS 'Vista de profesores con conteo de certificaciones';

-- =====================================================
-- VISTA: Vista de inscripciones detalladas
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_inscripciones_detalle AS
SELECT 
    i.id_inscripcion,
    e.nombre_completo as nombre_estudiante,
    e.correo_electronico as correo_estudiante,
    m.nombre_materia,
    m.codigo_materia,
    m.creditos,
    c.nombre_ciclo,
    i.fecha_inscripcion,
    i.nota_final,
    i.estado,
    i.fecha_retiro,
    CASE 
        WHEN i.estado = 'APROBADO' THEN '✓ Aprobado'
        WHEN i.estado = 'REPROBADO' THEN '✗ Reprobado'
        WHEN i.estado = 'INSCRITO' THEN '→ En curso'
        WHEN i.estado = 'RETIRADO' THEN '⚠ Retirado'
        ELSE i.estado
    END as estado_descripcion
FROM academia_nexus.public.inscripcion i
JOIN academia_nexus.public.estudiante e ON i.id_estudiante = e.id_estudiante
JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
JOIN academia_nexus.public.ciclo c ON i.id_ciclo = c.id_ciclo
ORDER BY c.nombre_ciclo, e.nombre_completo, m.nombre_materia;

COMMENT ON VIEW academia_nexus.public.v_inscripciones_detalle IS 'Vista de inscripciones con información completa';

-- =====================================================
-- VISTA: Vista de ciclos activos con estadísticas
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_ciclos_estadisticas AS
SELECT 
    c.id_ciclo,
    c.nombre_ciclo,
    c.fecha_inicio,
    c.fecha_fin,
    c.estado,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i WHERE i.id_ciclo = c.id_ciclo AND i.estado != 'RETIRADO') as total_inscripciones,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i WHERE i.id_ciclo = c.id_ciclo AND i.estado = 'APROBADO') as total_aprobados,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i WHERE i.id_ciclo = c.id_ciclo AND i.estado = 'REPROBADO') as total_reprobados,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i WHERE i.id_ciclo = c.id_ciclo AND i.estado = 'INSCRITO') as total_en_curso,
    (SELECT COUNT(*) FROM academia_nexus.public.asignacion_profesor ap WHERE ap.id_ciclo = c.id_ciclo) as total_profesores_asignados
FROM academia_nexus.public.ciclo c
ORDER BY c.fecha_inicio DESC;

COMMENT ON VIEW academia_nexus.public.v_ciclos_estadisticas IS 'Vista de ciclos con estadísticas de inscripciones';

-- =====================================================
-- VISTA: Vista de estudiantes en observación
-- Alerta temprana de estudiantes con problemas académicos
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_estudiantes_observacion AS
SELECT 
    e.id_estudiante,
    e.nombre_completo,
    e.correo_electronico,
    e.materias_reprobadas_consecutivas,
    e.nota_promedio_general,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
     WHERE i.id_estudiante = e.id_estudiante AND i.estado = 'REPROBADO') as total_reprobadas,
    (SELECT COUNT(*) FROM academia_nexus.public.inscripcion i 
     WHERE i.id_estudiante = e.id_estudiante AND i.estado = 'INSCRITO') as materias_actuales
FROM academia_nexus.public.estudiante e
WHERE e.estado = 'OBSERVACION' OR e.materias_reprobadas_consecutivas >= 2
ORDER BY e.materias_reprobadas_consecutivas DESC, e.nota_promedio_general ASC;

COMMENT ON VIEW academia_nexus.public.v_estudiantes_observacion IS 'Alerta temprana de estudiantes en riesgo académico';

-- =====================================================
-- VISTA: Vista de materias por área de conocimiento
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_materias_por_area AS
SELECT 
    a.id_area,
    a.nombre_area,
    COUNT(m.id_materia) as total_materias,
    SUM(m.creditos) as total_creditos,
    AVG(m.creditos) as promedio_creditos,
    STRING_AGG(m.nombre_materia, ', ' ORDER BY m.nombre_materia) as lista_materias
FROM academia_nexus.public.area_conocimiento a
LEFT JOIN academia_nexus.public.materia m ON a.id_area = m.id_area_conocimiento AND m.estado = 'ACTIVA'
GROUP BY a.id_area, a.nombre_area
ORDER BY a.nombre_area;

COMMENT ON VIEW academia_nexus.public.v_materias_por_area IS 'Resumen de materias por área de conocimiento';

-- =====================================================
-- VISTA: Vista de rendimiento por materia
-- Estadísticas de aprobación/reprobación por materia
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_rendimiento_materia AS
SELECT 
    m.id_materia,
    m.nombre_materia,
    m.codigo_materia,
    m.nota_minima_aprobacion,
    COUNT(i.id_inscripcion) as total_intentos,
    COUNT(CASE WHEN i.estado = 'APROBADO' THEN 1 END) as total_aprobados,
    COUNT(CASE WHEN i.estado = 'REPROBADO' THEN 1 END) as total_reprobados,
    COUNT(CASE WHEN i.estado = 'RETIRADO' THEN 1 END) as total_retirados,
    ROUND(COUNT(CASE WHEN i.estado = 'APROBADO' THEN 1 END)::NUMERIC / 
          NULLIF(COUNT(i.id_inscripcion), 0) * 100, 2) as tasa_aprobacion_porcentaje,
    ROUND(AVG(CASE WHEN i.estado = 'APROBADO' THEN i.nota_final END), 2) as promedio_notas_aprobadas,
    ROUND(AVG(CASE WHEN i.estado = 'REPROBADO' THEN i.nota_final END), 2) as promedio_notas_reprobadas
FROM academia_nexus.public.materia m
LEFT JOIN academia_nexus.public.inscripcion i ON m.id_materia = i.id_materia
GROUP BY m.id_materia, m.nombre_materia, m.codigo_materia, m.nota_minima_aprobacion
ORDER BY tasa_aprobacion_porcentaje ASC;

COMMENT ON VIEW academia_nexus.public.v_rendimiento_materia IS 'Estadísticas de rendimiento por materia';

-- =====================================================
-- VISTA: Vista de historial académico completo
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_historial_academico_completo AS
SELECT 
    h.id_historial,
    e.nombre_completo as nombre_estudiante,
    m.nombre_materia,
    m.codigo_materia,
    c.nombre_ciclo,
    h.nota_final,
    h.fecha_aprobacion,
    h.intento_numero,
    a.nombre_area as area_conocimiento,
    CASE 
        WHEN h.intento_numero = 1 THEN 'Primer intento'
        WHEN h.intento_numero = 2 THEN 'Segundo intento'
        WHEN h.intento_numero = 3 THEN 'Tercer intento'
        ELSE CONCAT(h.intento_numero, '° intento')
    END as descripcion_intento
FROM academia_nexus.public.historial_academico h
JOIN academia_nexus.public.estudiante e ON h.id_estudiante = e.id_estudiante
JOIN academia_nexus.public.materia m ON h.id_materia = m.id_materia
JOIN academia_nexus.public.ciclo c ON h.id_ciclo = c.id_ciclo
JOIN academia_nexus.public.area_conocimiento a ON m.id_area_conocimiento = a.id_area
ORDER BY e.nombre_completo, h.fecha_aprobacion DESC;

COMMENT ON VIEW academia_nexus.public.v_historial_academico_completo IS 'Historial académico completo con detalles';

-- =====================================================
-- VISTA: Vista de requisitos de materias
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_requisitos_materias AS
SELECT 
    m_principal.id_materia as id_materia_principal,
    m_principal.nombre_materia as materia_principal,
    m_principal.codigo_materia as codigo_principal,
    m_req.id_materia as id_materia_requisito,
    m_req.nombre_materia as materia_requisito,
    m_req.codigo_materia as codigo_requisito,
    rm.tipo_requisito,
    a.nombre_area as area_conocimiento
FROM academia_nexus.public.requisito_materia rm
JOIN academia_nexus.public.materia m_principal ON rm.id_materia = m_principal.id_materia
JOIN academia_nexus.public.materia m_req ON rm.id_materia_requisito = m_req.id_materia
JOIN academia_nexus.public.area_conocimiento a ON m_req.id_area_conocimiento = a.id_area
ORDER BY m_principal.nombre_materia, m_req.nombre_materia;

COMMENT ON VIEW academia_nexus.public.v_requisitos_materias IS 'Relación de requisitos previos entre materias';

-- =====================================================
-- VISTA: Vista de cupos disponibles por materia
-- =====================================================
CREATE OR REPLACE VIEW academia_nexus.public.v_cupos_disponibles AS
SELECT 
    m.id_materia,
    m.nombre_materia,
    m.codigo_materia,
    m.cupo_maximo,
    c.id_ciclo,
    c.nombre_ciclo,
    m.cupo_maximo - COALESCE(insc.count, 0) as cupos_disponibles,
    CASE 
        WHEN m.cupo_maximo - COALESCE(insc.count, 0) <= 0 THEN 'LLENO'
        WHEN m.cupo_maximo - COALESCE(insc.count, 0) <= 5 THEN 'POCAS PLAZAS'
        ELSE 'DISPONIBLE'
    END as estado_cupo,
    ROUND(COALESCE(insc.count, 0)::NUMERIC / m.cupo_maximo * 100, 2) as porcentaje_ocupacion
FROM academia_nexus.public.materia m
CROSS JOIN academia_nexus.public.ciclo c
LEFT JOIN (
    SELECT id_materia, id_ciclo, COUNT(*) as count
    FROM academia_nexus.public.inscripcion
    WHERE estado != 'RETIRADO'
    GROUP BY id_materia, id_ciclo
) insc ON m.id_materia = insc.id_materia AND c.id_ciclo = insc.id_ciclo
WHERE m.estado = 'ACTIVA'
ORDER BY porcentaje_ocupacion DESC;

COMMENT ON VIEW academia_nexus.public.v_cupos_disponibles IS 'Estado de cupos disponibles por materia y ciclo';

-- =====================================================
-- CONFIRMACIÓN DE CREACIÓN
-- =====================================================
SELECT 'Vistas almacenadas creadas exitosamente' AS mensaje,
       COUNT(*) as total_vistas
FROM information_schema.views
WHERE table_schema = 'public';