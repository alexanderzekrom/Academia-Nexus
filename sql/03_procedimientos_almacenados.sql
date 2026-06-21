-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- PROCEDIMIENTO: Inscribir estudiante en materia
-- Valida reglas de negocio antes de inscribir
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.inscribir_estudiante_materia(
    p_id_estudiante INTEGER,
    p_id_materia INTEGER,
    p_id_ciclo INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_materia_estado VARCHAR(20);
    v_estudiante_estado VARCHAR(20);
    v_ciclo_estado VARCHAR(20);
    v_ya_inscrito BOOLEAN;
BEGIN
    -- Validar que la materia esté activa
    SELECT estado INTO v_materia_estado
    FROM academia_nexus.public.materia
    WHERE id_materia = p_id_materia;
    
    IF v_materia_estado != 'ACTIVA' THEN
        RAISE EXCEPTION 'La materia no está activa para inscripción';
    END IF;
    
    -- Validar que el estudiante esté activo
    SELECT estado INTO v_estudiante_estado
    FROM academia_nexus.public.estudiante
    WHERE id_estudiante = p_id_estudiante;
    
    IF v_estudiante_estado NOT IN ('ACTIVO', 'OBSERVACION') THEN
        RAISE EXCEPTION 'El estudiante no está activo para inscripción';
    END IF;
    
    -- Validar que el ciclo esté activo
    SELECT estado INTO v_ciclo_estado
    FROM academia_nexus.public.ciclo
    WHERE id_ciclo = p_id_ciclo;
    
    IF v_ciclo_estado != 'ACTIVO' THEN
        RAISE EXCEPTION 'El ciclo no está activo para inscripción';
    END IF;
    
    -- Validar que no esté ya inscrito
    SELECT EXISTS(
        SELECT 1 FROM academia_nexus.public.inscripcion
        WHERE id_estudiante = p_id_estudiante
        AND id_materia = p_id_materia
        AND id_ciclo = p_id_ciclo
    ) INTO v_ya_inscrito;
    
    IF v_ya_inscrito THEN
        RAISE EXCEPTION 'El estudiante ya está inscrito en esta materia en este ciclo';
    END IF;
    
    -- Insertar inscripción (los triggers validarán las reglas de negocio)
    INSERT INTO academia_nexus.public.inscripcion (
        id_estudiante, id_materia, id_ciclo, 
        fecha_inscripcion, estado, nota_final
    ) VALUES (
        p_id_estudiante, p_id_materia, p_id_ciclo,
        CURRENT_DATE, 'INSCRITO', 0.0
    );
    
    RAISE NOTICE 'Estudiante inscrito exitosamente en la materia';
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Retirar estudiante de materia
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.retirar_estudiante_materia(
    p_id_estudiante INTEGER,
    p_id_materia INTEGER,
    p_id_ciclo INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_inscripcion_estado VARCHAR(20);
BEGIN
    -- Validar estado de la inscripción
    SELECT estado INTO v_inscripcion_estado
    FROM academia_nexus.public.inscripcion
    WHERE id_estudiante = p_id_estudiante
    AND id_materia = p_id_materia
    AND id_ciclo = p_id_ciclo;
    
    IF v_inscripcion_estado IS NULL THEN
        RAISE EXCEPTION 'No existe inscripción para retirar';
    END IF;
    
    IF v_inscripcion_estado IN ('APROBADO', 'REPROBADO', 'RETIRADO') THEN
        RAISE EXCEPTION 'No se puede retirar de una materia finalizada';
    END IF;
    
    -- Actualizar inscripción como retirada
    UPDATE academia_nexus.public.inscripcion
    SET estado = 'RETIRADO', fecha_retiro = CURRENT_DATE
    WHERE id_estudiante = p_id_estudiante
    AND id_materia = p_id_materia
    AND id_ciclo = p_id_ciclo;
    
    RAISE NOTICE 'Estudiante retirado exitosamente de la materia';
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Registrar evaluación
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.registrar_evaluacion(
    p_id_inscripcion INTEGER,
    p_tipo_evaluacion VARCHAR,
    p_descripcion TEXT,
    p_nota NUMERIC,
    p_fecha_evaluacion DATE,
    p_porcentaje_peso NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_inscripcion_estado VARCHAR(20);
    v_total_pesos NUMERIC(5,2);
BEGIN
    -- Validar estado de la inscripción
    SELECT estado INTO v_inscripcion_estado
    FROM academia_nexus.public.inscripcion
    WHERE id_inscripcion = p_id_inscripcion;
    
    IF v_inscripcion_estado IS NULL THEN
        RAISE EXCEPTION 'No existe la inscripción especificada';
    END IF;
    
    IF v_inscripcion_estado = 'RETIRADO' THEN
        RAISE EXCEPTION 'No se pueden registrar evaluaciones de materias retiradas';
    END IF;
    
    -- Validar que el porcentaje total no exceda 100%
    SELECT COALESCE(SUM(porcentaje_peso), 0) INTO v_total_pesos
    FROM academia_nexus.public.evaluacion
    WHERE id_inscripcion = p_id_inscripcion;
    
    IF v_total_pesos + p_porcentaje_peso > 100 THEN
        RAISE EXCEPTION 'El porcentaje total de evaluaciones no puede exceder 100%%. Actual: %%%, Nuevo: %%%', 
            v_total_pesos, p_porcentaje_peso;
    END IF;
    
    -- Insertar evaluación
    INSERT INTO academia_nexus.public.evaluacion (
        id_inscripcion, tipo_evaluacion, descripcion,
        nota, fecha_evaluacion, porcentaje_peso
    ) VALUES (
        p_id_inscripcion, p_tipo_evaluacion, p_descripcion,
        p_nota, p_fecha_evaluacion, p_porcentaje_peso
    );
    
    RAISE NOTICE 'Evaluación registrada exitosamente';
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Calcular y actualizar promedio de estudiante
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.calcular_promedio_estudiante(
    p_id_estudiante INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_promedio NUMERIC(3,1);
BEGIN
    -- Calcular promedio de materias aprobadas
    SELECT COALESCE(AVG(nota_final), 0) INTO v_promedio
    FROM academia_nexus.public.inscripcion
    WHERE id_estudiante = p_id_estudiante
    AND estado = 'APROBADO';
    
    -- Actualizar promedio
    UPDATE academia_nexus.public.estudiante
    SET nota_promedio_general = v_promedio
    WHERE id_estudiante = p_id_estudiante;
    
    RAISE NOTICE 'Promedio actualizado: %', v_promedio;
END;
$$;

-- =====================================================
-- FUNCIÓN: Obtener materias disponibles para inscripción
-- Retorna materias que el estudiante puede cursar
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.obtener_materias_disponibles(
    p_id_estudiante INTEGER,
    p_id_ciclo INTEGER
)
RETURNS TABLE (
    id_materia INTEGER,
    nombre_materia VARCHAR,
    codigo_materia VARCHAR,
    creditos INTEGER,
    horario VARCHAR,
    cupo_disponible INTEGER,
    area_conocimiento VARCHAR,
    requisitos_cumplidos BOOLEAN,
    puede_inscribirse BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec RECORD;
    v_requisitos_cumplidos BOOLEAN;
    v_materias_inscritas INTEGER;
BEGIN
    -- Contar materias inscritas del estudiante en el ciclo
    SELECT COUNT(*) INTO v_materias_inscritas
    FROM academia_nexus.public.inscripcion
    WHERE id_estudiante = p_id_estudiante
    AND id_ciclo = p_id_ciclo
    AND estado != 'RETIRADO';
    
    -- Retornar materias disponibles
    FOR v_rec IN
        SELECT 
            m.id_materia,
            m.nombre_materia,
            m.codigo_materia,
            m.creditos,
            m.horario,
            (m.cupo_maximo - COALESCE((
                SELECT COUNT(*) FROM academia_nexus.public.inscripcion i
                WHERE i.id_materia = m.id_materia
                AND i.id_ciclo = p_id_ciclo
                AND i.estado != 'RETIRADO'
            ), 0)) as cupo_disponible,
            a.nombre_area as area_conocimiento
        FROM academia_nexus.public.materia m
        JOIN academia_nexus.public.area_conocimiento a ON m.id_area_conocimiento = a.id_area
        WHERE m.estado = 'ACTIVA'
        AND m.cupo_maximo > COALESCE((
            SELECT COUNT(*) FROM academia_nexus.public.inscripcion i
            WHERE i.id_materia = m.id_materia
            AND i.id_ciclo = p_id_ciclo
            AND i.estado != 'RETIRADO'
        ), 0)
    LOOP
        -- Verificar requisitos previos
        SELECT COALESCE(
            -- Verificar que todos los requisitos estén cumplidos
            NOT EXISTS (
                SELECT 1 FROM academia_nexus.public.requisito_materia rm
                WHERE rm.id_materia = v_rec.id_materia
                AND NOT EXISTS (
                    SELECT 1 FROM academia_nexus.public.inscripcion i
                    WHERE i.id_estudiante = p_id_estudiante
                    AND i.id_materia = rm.id_materia_requisito
                    AND (rm.tipo_requisito = 'CURSAR' OR (rm.tipo_requisito = 'APROBAR' AND i.estado = 'APROBADO'))
                )
            ), true
        ) INTO v_requisitos_cumplidos;
        
        -- Determinar si puede inscribirse
        v_rec.puede_inscribirse := v_requisitos_cumplidos 
            AND v_materias_inscritas < 6 
            AND v_rec.cupo_disponible > 0;
        v_rec.requisitos_cumplidos := v_requisitos_cumplidos;
        
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Asignar profesor a materia en ciclo
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.asignar_profesor_materia(
    p_id_profesor INTEGER,
    p_id_materia INTEGER,
    p_id_ciclo INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profesor_estado VARCHAR(20);
    v_materia_estado VARCHAR(20);
    v_ya_asignado BOOLEAN;
BEGIN
    -- Validar estado del profesor
    SELECT estado INTO v_profesor_estado
    FROM academia_nexus.public.profesor
    WHERE id_profesor = p_id_profesor;
    
    IF v_profesor_estado != 'ACTIVO' THEN
        RAISE EXCEPTION 'El profesor no está activo';
    END IF;
    
    -- Validar estado de la materia
    SELECT estado INTO v_materia_estado
    FROM academia_nexus.public.materia
    WHERE id_materia = p_id_materia;
    
    IF v_materia_estado != 'ACTIVA' THEN
        RAISE EXCEPTION 'La materia no está activa';
    END IF;
    
    -- Validar que no esté ya asignado
    SELECT EXISTS(
        SELECT 1 FROM academia_nexus.public.asignacion_profesor
        WHERE id_profesor = p_id_profesor
        AND id_materia = p_id_materia
        AND id_ciclo = p_id_ciclo
    ) INTO v_ya_asignado;
    
    IF v_ya_asignado THEN
        RAISE EXCEPTION 'El profesor ya está asignado a esta materia en este ciclo';
    END IF;
    
    -- Insertar asignación (el trigger validará certificación)
    INSERT INTO academia_nexus.public.asignacion_profesor (
        id_profesor, id_materia, id_ciclo, fecha_asignacion
    ) VALUES (
        p_id_profesor, p_id_materia, p_id_ciclo, CURRENT_DATE
    );
    
    RAISE NOTICE 'Profesor asignado exitosamente a la materia';
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Certificar profesor para materia
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.certificar_profesor_materia(
    p_id_profesor INTEGER,
    p_id_materia INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertar o actualizar certificación
    INSERT INTO academia_nexus.public.certificacion_profesor (
        id_profesor, id_materia, fecha_certificacion, estado
    ) VALUES (
        p_id_profesor, p_id_materia, CURRENT_DATE, 'ACTIVA'
    )
    ON CONFLICT (id_profesor, id_materia)
    DO UPDATE SET 
        fecha_certificacion = CURRENT_DATE,
        estado = 'ACTIVA';
    
    RAISE NOTICE 'Profesor certificado exitosamente para la materia';
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Cambiar estado de estudiante
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.cambiar_estado_estudiante(
    p_id_estudiante INTEGER,
    p_nuevo_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar estado válido
    IF p_nuevo_estado NOT IN ('ACTIVO', 'INACTIVO', 'OBSERVACION', 'GRADUADO') THEN
        RAISE EXCEPTION 'Estado no válido. Use: ACTIVO, INACTIVO, OBSERVACION, GRADUADO';
    END IF;
    
    -- Actualizar estado
    UPDATE academia_nexus.public.estudiante
    SET estado = p_nuevo_estado
    WHERE id_estudiante = p_id_estudiante;
    
    RAISE NOTICE 'Estado del estudiante actualizado a %', p_nuevo_estado;
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Generar reporte de rendimiento de estudiante
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.generar_reporte_rendimiento(
    p_id_estudiante INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Mostrar información del estudiante
    RAISE NOTICE '=== REPORTE DE RENDIMIENTO ===';
    RAISE NOTICE 'Estudiante: %', 
        (SELECT nombre_completo FROM academia_nexus.public.estudiante WHERE id_estudiante = p_id_estudiante);
    RAISE NOTICE 'Estado: %', 
        (SELECT estado FROM academia_nexus.public.estudiante WHERE id_estudiante = p_id_estudiante);
    RAISE NOTICE 'Promedio General: %', 
        (SELECT nota_promedio_general FROM academia_nexus.public.estudiante WHERE id_estudiante = p_id_estudiante);
    RAISE NOTICE 'Materias Reprobadas Consecutivas: %', 
        (SELECT materias_reprobadas_consecutivas FROM academia_nexus.public.estudiante WHERE id_estudiante = p_id_estudiante);
    
    -- Mostrar estadísticas de inscripciones
    RAISE NOTICE '';
    RAISE NOTICE '=== ESTADÍSTICAS DE INSCRIPCIONES ===';
    RAISE NOTICE 'Total inscritas: %', 
        (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE id_estudiante = p_id_estudiante);
    RAISE NOTICE 'Aprobadas: %', 
        (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE id_estudiante = p_id_estudiante AND estado = 'APROBADO');
    RAISE NOTICE 'Reprobadas: %', 
        (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE id_estudiante = p_id_estudiante AND estado = 'REPROBADO');
    RAISE NOTICE 'Retiradas: %', 
        (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE id_estudiante = p_id_estudiante AND estado = 'RETIRADO');
    RAISE NOTICE 'En curso: %', 
        (SELECT COUNT(*) FROM academia_nexus.public.inscripcion WHERE id_estudiante = p_id_estudiante AND estado = 'INSCRITO');
    
    -- Mostrar materias aprobadas recientes
    RAISE NOTICE '';
    RAISE NOTICE '=== ÚLTIMAS MATERIAS APROBADAS ===';
    FOR rec IN
        SELECT i.nota_final, m.nombre_materia, m.codigo_materia, c.nombre_ciclo
        FROM academia_nexus.public.inscripcion i
        JOIN academia_nexus.public.materia m ON i.id_materia = m.id_materia
        JOIN academia_nexus.public.ciclo c ON i.id_ciclo = c.id_ciclo
        WHERE i.id_estudiante = p_id_estudiante AND i.estado = 'APROBADO'
        ORDER BY i.fecha_inscripcion DESC
        LIMIT 5
    LOOP
        RAISE NOTICE '% (%) - Nota: % - Ciclo: %', rec.nombre_materia, rec.codigo_materia, rec.nota_final, rec.nombre_ciclo;
    END LOOP;
END;
$$;

-- =====================================================
-- PROCEDIMIENTO: Actualizar estado de ciclo
-- =====================================================
CREATE OR REPLACE PROCEDURE academia_nexus.public.actualizar_estado_ciclo(
    p_id_ciclo INTEGER,
    p_nuevo_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar estado válido
    IF p_nuevo_estado NOT IN ('ACTIVO', 'CERRADO', 'FUTURO') THEN
        RAISE EXCEPTION 'Estado no válido. Use: ACTIVO, CERRADO, FUTURO';
    END IF;
    
    -- Actualizar estado
    UPDATE academia_nexus.public.ciclo
    SET estado = p_nuevo_estado
    WHERE id_ciclo = p_id_ciclo;
    
    RAISE NOTICE 'Estado del ciclo actualizado a %', p_nuevo_estado;
END;
$$;

-- =====================================================
-- CONFIRMACIÓN DE CREACIÓN
-- =====================================================
SELECT 'Procedimientos almacenados creados exitosamente' AS mensaje,
       COUNT(*) as total_procedimientos
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION';