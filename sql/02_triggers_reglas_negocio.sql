-- =====================================================
-- TRIGGERS PARA REGLAS DE NEGOCIO - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- FUNCIÓN: Validar límite de 6 materias por ciclo
-- Regla 1: Un estudiante no puede inscribir más de 6 materias por ciclo
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.validar_limite_materias()
RETURNS TRIGGER AS $$
DECLARE
    materias_inscritas INTEGER;
BEGIN
    -- Contar materias inscritas en el mismo ciclo (excluyendo RETIRADO)
    SELECT COUNT(*) INTO materias_inscritas
    FROM academia_nexus.public.inscripcion
    WHERE id_estudiante = NEW.id_estudiante
    AND id_ciclo = NEW.id_ciclo
    AND estado != 'RETIRADO';
    
    -- Si es una inserción nueva, verificar que no supere 6
    IF TG_OP = 'INSERT' THEN
        IF materias_inscritas >= 6 THEN
            RAISE EXCEPTION 'Regla 1: El estudiante no puede inscribir más de 6 materias por ciclo. Actualmente tiene % materias.', materias_inscritas;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar límite de materias
CREATE TRIGGER trg_validar_limite_materias
BEFORE INSERT OR UPDATE ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.validar_limite_materias();

-- =====================================================
-- FUNCIÓN: Validar requisitos previos de materia
-- Regla 2: Para cursar ciertas materias necesita aprobar otras previamente
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.validar_requisitos_previos()
RETURNS TRIGGER AS $$
DECLARE
    requisito_rec RECORD;
    requisito_aprobado BOOLEAN;
    requisito_cursado BOOLEAN;
BEGIN
    -- Verificar requisitos previos de la materia
    FOR requisito_rec IN
        SELECT rm.id_materia_requisito, rm.tipo_requisito
        FROM academia_nexus.public.requisito_materia rm
        WHERE rm.id_materia = NEW.id_materia
    LOOP
        -- Verificar si el requisito se aprobó
        SELECT EXISTS(
            SELECT 1 FROM academia_nexus.public.inscripcion i
            WHERE i.id_estudiante = NEW.id_estudiante
            AND i.id_materia = requisito_rec.id_materia_requisito
            AND i.estado = 'APROBADO'
        ) INTO requisito_aprobado;
        
        -- Verificar si el requisito se cursó
        SELECT EXISTS(
            SELECT 1 FROM academia_nexus.public.inscripcion i
            WHERE i.id_estudiante = NEW.id_estudiante
            AND i.id_materia = requisito_rec.id_materia_requisito
        ) INTO requisito_cursado;
        
        -- Validar según tipo de requisito
        IF requisito_rec.tipo_requisito = 'APROBAR' AND NOT requisito_aprobado THEN
            RAISE EXCEPTION 'Regla 2: Para cursar esta materia debe aprobar previamente la materia con ID %', requisito_rec.id_materia_requisito;
        ELSIF requisito_rec.tipo_requisito = 'CURSAR' AND NOT requisito_cursado THEN
            RAISE EXCEPTION 'Regla 2: Para cursar esta materia debe haber cursado previamente la materia con ID %', requisito_rec.id_materia_requisito;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar requisitos previos
CREATE TRIGGER trg_validar_requisitos_previos
BEFORE INSERT ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.validar_requisitos_previos();

-- =====================================================
-- FUNCIÓN: Validar certificación del profesor
-- El profesor debe estar certificado para impartir la materia
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.validar_certificacion_profesor()
RETURNS TRIGGER AS $$
DECLARE
    esta_certificado BOOLEAN;
BEGIN
    -- Verificar si el profesor está certificado para la materia
    SELECT EXISTS(
        SELECT 1 FROM academia_nexus.public.certificacion_profesor cp
        WHERE cp.id_profesor = NEW.id_profesor
        AND cp.id_materia = NEW.id_materia
        AND cp.estado = 'ACTIVA'
    ) INTO esta_certificado;
    
    IF NOT esta_certificado THEN
        RAISE EXCEPTION 'El profesor no está certificado para impartir esta materia';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar certificación del profesor
CREATE TRIGGER trg_validar_certificacion_profesor
BEFORE INSERT ON academia_nexus.public.asignacion_profesor
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.validar_certificacion_profesor();

-- =====================================================
-- FUNCIÓN: Calcular nota final de inscripción basada en evaluaciones
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.calcular_nota_final()
RETURNS TRIGGER AS $$
DECLARE
    nota_calculada NUMERIC(3,1);
    nota_minima NUMERIC(3,1);
BEGIN
    -- Calcular nota final ponderada
    SELECT COALESCE(SUM(e.nota * e.porcentaje_peso / 100), 0) INTO nota_calculada
    FROM academia_nexus.public.evaluacion e
    WHERE e.id_inscripcion = NEW.id_inscripcion;
    
    -- Obtener nota mínima de aprobación de la materia
    SELECT m.nota_minima_aprobacion INTO nota_minima
    FROM academia_nexus.public.materia m
    JOIN academia_nexus.public.inscripcion i ON m.id_materia = i.id_materia
    WHERE i.id_inscripcion = NEW.id_inscripcion;
    
    -- Actualizar nota final en la inscripción
    UPDATE academia_nexus.public.inscripcion
    SET nota_final = nota_calculada
    WHERE id_inscripcion = NEW.id_inscripcion;
    
    -- Actualizar estado de la inscripción según nota
    IF nota_calculada >= nota_minima THEN
        UPDATE academia_nexus.public.inscripcion
        SET estado = 'APROBADO'
        WHERE id_inscripcion = NEW.id_inscripcion;
    ELSE
        UPDATE academia_nexus.public.inscripcion
        SET estado = 'REPROBADO'
        WHERE id_inscripcion = NEW.id_inscripcion;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para calcular nota final
CREATE TRIGGER trg_calcular_nota_final
AFTER INSERT OR UPDATE ON academia_nexus.public.evaluacion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.calcular_nota_final();

-- =====================================================
-- FUNCIÓN: Actualizar contador de materias reprobadas consecutivas
-- Regla 4: Tres materias reprobadas consecutivas generan estado de observación
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.actualizar_reprobadas_consecutivas()
RETURNS TRIGGER AS $$
DECLARE
    ultimas_inscripciones RECORD;
    consecutivas INTEGER;
BEGIN
    -- Si la inscripción pasó a REPROBADO
    IF NEW.estado = 'REPROBADO' AND (OLD.estado IS NULL OR OLD.estado != 'REPROBADO') THEN
        -- Incrementar contador de materias reprobadas consecutivas
        UPDATE academia_nexus.public.estudiante
        SET materias_reprobadas_consecutivas = materias_reprobadas_consecutivas + 1
        WHERE id_estudiante = NEW.id_estudiante;
        
        -- Verificar si llegó a 3 materias reprobadas consecutivas
        IF (SELECT materias_reprobadas_consecutivas FROM academia_nexus.public.estudiante WHERE id_estudiante = NEW.id_estudiante) >= 3 THEN
            UPDATE academia_nexus.public.estudiante
            SET estado = 'OBSERVACION'
            WHERE id_estudiante = NEW.id_estudiante;
        END IF;
    ELSIF NEW.state = 'APROBADO' AND (OLD.estado IS NULL OR OLD.estado != 'APROBADO') THEN
        -- Si aprobó, reiniciar contador
        UPDATE academia_nexus.public.estudiante
        SET materias_reprobadas_consecutivas = 0
        WHERE id_estudiante = NEW.id_estudiante;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar materias reprobadas consecutivas
CREATE TRIGGER trg_actualizar_reprobadas_consecutivas
AFTER UPDATE ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.actualizar_reprobadas_consecutivas();

-- =====================================================
-- FUNCIÓN: Actualizar promedio general del estudiante
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.actualizar_promedio_estudiante()
RETURNS TRIGGER AS $$
DECLARE
    promedio_calculado NUMERIC(3,1);
BEGIN
    -- Calcular promedio de todas las materias aprobadas
    SELECT COALESCE(AVG(nota_final), 0) INTO promedio_calculado
    FROM academia_nexus.public.inscripcion
    WHERE id_estudiante = NEW.id_estudiante
    AND estado = 'APROBADO';
    
    -- Actualizar promedio en la tabla estudiante
    UPDATE academia_nexus.public.estudiante
    SET nota_promedio_general = promedio_calculado
    WHERE id_estudiante = NEW.id_estudiante;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar promedio general
CREATE TRIGGER trg_actualizar_promedio_estudiante
AFTER INSERT OR UPDATE ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.actualizar_promedio_estudiante();

-- =====================================================
-- FUNCIÓN: Registrar en historial académico al aprobar materia
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.registrar_historial_academico()
RETURNS TRIGGER AS $$
DECLARE
    intento_num INTEGER;
BEGIN
    -- Si el estado cambió a APROBADO
    IF NEW.estado = 'APROBADO' AND (OLD.estado IS NULL OR OLD.estado != 'APROBADO') THEN
        -- Contar intentos previos de esta materia
        SELECT COALESCE(COUNT(*), 0) + 1 INTO intento_num
        FROM academia_nexus.public.historial_academico
        WHERE id_estudiante = NEW.id_estudiante
        AND id_materia = NEW.id_materia;
        
        -- Insertar en historial académico
        INSERT INTO academia_nexus.public.historial_academico (
            id_estudiante, id_materia, id_ciclo, nota_final, 
            fecha_aprobacion, intento_numero
        ) VALUES (
            NEW.id_estudiante, NEW.id_materia, NEW.id_ciclo, 
            NEW.nota_final, CURRENT_DATE, intento_num
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar historial académico
CREATE TRIGGER trg_registrar_historial_academico
AFTER UPDATE ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.registrar_historial_academico();

-- =====================================================
-- FUNCIÓN: Validar cupo máximo en materia
-- No se puede inscribir si se alcanzó el cupo máximo
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.validar_cupo_materia()
RETURNS TRIGGER AS $$
DECLARE
    cupo_maximo INTEGER;
    inscripciones_actuales INTEGER;
BEGIN
    -- Obtener cupo máximo de la materia
    SELECT cupo_maximo INTO cupo_maximo
    FROM academia_nexus.public.materia
    WHERE id_materia = NEW.id_materia;
    
    -- Contar inscripciones actuales (excluyendo RETIRADO)
    SELECT COUNT(*) INTO inscripciones_actuales
    FROM academia_nexus.public.inscripcion
    WHERE id_materia = NEW.id_materia
    AND id_ciclo = NEW.id_ciclo
    AND estado != 'RETIRADO';
    
    -- Validar cupo
    IF inscripciones_actuales >= cupo_maximo THEN
        RAISE EXCEPTION 'La materia ha alcanzado su cupo máximo de % estudiantes', cupo_maximo;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar cupo máximo
CREATE TRIGGER trg_validar_cupo_materia
BEFORE INSERT ON academia_nexus.public.inscripcion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.validar_cupo_materia();

-- =====================================================
-- FUNCIÓN: Prevenir modificación de notas de evaluación
-- Una vez creada, la nota de evaluación no debe modificarse
-- =====================================================
CREATE OR REPLACE FUNCTION academia_nexus.public.prevenir_modificacion_nota()
RETURNS TRIGGER AS $$
BEGIN
    -- Prevenir modificación de nota
    IF TG_OP = 'UPDATE' AND OLD.nota IS DISTINCT FROM NEW.nota THEN
        RAISE EXCEPTION 'Las notas de evaluación no pueden modificarse una vez registradas';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para prevenir modificación de notas
CREATE TRIGGER trg_prevenir_modificacion_nota
BEFORE UPDATE ON academia_nexus.public.evaluacion
FOR EACH ROW
EXECUTE FUNCTION academia_nexus.public.prevenir_modificacion_nota();

-- =====================================================
-- CONFIRMACIÓN DE CREACIÓN
-- =====================================================
SELECT 'Triggers para reglas de negocio creados exitosamente' AS mensaje,
       COUNT(*) as total_triggers
FROM information_schema.triggers
WHERE trigger_schema = 'public';