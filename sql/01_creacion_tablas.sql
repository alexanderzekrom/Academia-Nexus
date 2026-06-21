-- =====================================================
-- CREACIÓN DE TABLAS - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

-- Asegurarse de estar en la base de datos correcta
\c academia_nexus

-- Establecer el esquema public por defecto
SET search_path TO public;

-- =====================================================
-- TABLA: AREA_CONOCIMIENTO
-- =====================================================
CREATE TABLE academia_nexus.public.area_conocimiento (
    id_area SERIAL PRIMARY KEY,
    nombre_area VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL
);

COMMENT ON TABLE academia_nexus.public.area_conocimiento IS 'Áreas de conocimiento académicas';
COMMENT ON COLUMN academia_nexus.public.area_conocimiento.id_area IS 'Identificador único del área de conocimiento';
COMMENT ON COLUMN academia_nexus.public.area_conocimiento.nombre_area IS 'Nombre del área de conocimiento';
COMMENT ON COLUMN academia_nexus.public.area_conocimiento.descripcion IS 'Descripción detallada del área';

-- =====================================================
-- TABLA: ESTUDIANTE
-- =====================================================
CREATE TABLE academia_nexus.public.estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVO', 'INACTIVO', 'OBSERVACION', 'GRADUADO')),
    nota_promedio_general NUMERIC(3,1) NOT NULL DEFAULT 0.0,
    materias_reprobadas_consecutivas INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE academia_nexus.public.estudiante IS 'Información de los estudiantes del sistema';
COMMENT ON COLUMN academia_nexus.public.estudiante.id_estudiante IS 'Identificador único del estudiante';
COMMENT ON COLUMN academia_nexus.public.estudiante.estado IS 'Estado actual del estudiante: ACTIVO, INACTIVO, OBSERVACION, GRADUADO';
COMMENT ON COLUMN academia_nexus.public.estudiante.nota_promedio_general IS 'Promedio general de todas las materias cursadas';
COMMENT ON COLUMN academia_nexus.public.estudiante.materias_reprobadas_consecutivas IS 'Contador de materias reprobadas consecutivamente';

-- =====================================================
-- TABLA: MATERIA
-- =====================================================
CREATE TABLE academia_nexus.public.materia (
    id_materia SERIAL PRIMARY KEY,
    nombre_materia VARCHAR(150) NOT NULL,
    codigo_materia VARCHAR(20) NOT NULL UNIQUE,
    creditos INTEGER NOT NULL,
    horario VARCHAR(100) NOT NULL,
    cupo_maximo INTEGER NOT NULL,
    id_area_conocimiento INTEGER NOT NULL,
    nota_minima_aprobacion NUMERIC(3,1) NOT NULL DEFAULT 7.0,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVA', 'INACTIVA'))
);

COMMENT ON TABLE academia_nexus.public.materia IS 'Información de las materias académicas';
COMMENT ON COLUMN academia_nexus.public.materia.id_materia IS 'Identificador único de la materia';
COMMENT ON COLUMN academia_nexus.public.materia.codigo_materia Is 'Código único de la materia';
COMMENT ON COLUMN academia_nexus.public.materia.nota_minima_aprobacion IS 'Nota mínima requerida para aprobar (default 7.0)';

-- =====================================================
-- TABLA: PROFESOR
-- =====================================================
CREATE TABLE academia_nexus.public.profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

COMMENT ON TABLE academia_nexus.public.profesor IS 'Información de los profesores del sistema';
COMMENT ON COLUMN academia_nexus.public.profesor.id_profesor Is 'Identificador único del profesor';
COMMENT ON COLUMN academia_nexus.public.profesor.estado Is 'Estado actual del profesor: ACTIVO, INACTIVO';

-- =====================================================
-- TABLA: CICLO
-- =====================================================
CREATE TABLE academia_nexus.public.ciclo (
    id_ciclo SERIAL PRIMARY KEY,
    nombre_ciclo VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVO', 'CERRADO', 'FUTURO'))
);

COMMENT ON TABLE academia_nexus.public.ciclo IS 'Periodos académicos o ciclos lectivos';
COMMENT ON COLUMN academia_nexus.public.ciclo.id_ciclo Is 'Identificador único del ciclo';
COMMENT ON COLUMN academia_nexus.public.ciclo.estado Is 'Estado del ciclo: ACTIVO, CERRADO, FUTURO';

-- =====================================================
-- TABLA: INSCRIPCION
-- =====================================================
CREATE TABLE academia_nexus.public.inscripcion (
    id_inscripcion SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    id_ciclo INTEGER NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    nota_final NUMERIC(3,1) NOT NULL DEFAULT 0.0,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('INSCRITO', 'APROBADO', 'REPROBADO', 'RETIRADO')),
    fecha_retiro DATE,
    
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES academia_nexus.public.estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_materia FOREIGN KEY (id_materia) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_ciclo FOREIGN KEY (id_ciclo) 
        REFERENCES academia_nexus.public.ciclo(id_ciclo) ON DELETE CASCADE,
    CONSTRAINT uq_estudiante_materia_ciclo UNIQUE (id_estudiante, id_materia, id_ciclo)
);

COMMENT ON TABLE academia_nexus.public.inscripcion IS 'Inscripciones de estudiantes a materias en ciclos específicos';
COMMENT ON COLUMN academia_nexus.public.inscripcion.estado Is 'Estado de la inscripción: INSCRITO, APROBADO, REPROBADO, RETIRADO';

-- =====================================================
-- TABLA: EVALUACION
-- =====================================================
CREATE TABLE academia_nexus.public.evaluacion (
    id_evaluacion SERIAL PRIMARY KEY,
    id_inscripcion INTEGER NOT NULL,
    tipo_evaluacion VARCHAR(50) NOT NULL CHECK (tipo_evaluacion IN ('EXAMEN_PARCIAL', 'EXAMEN_FINAL', 'TAREA', 'PROYECTO', 'QUIZ')),
    descripcion TEXT NOT NULL,
    nota NUMERIC(3,1) NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    porcentaje_peso NUMERIC(5,2) NOT NULL,
    
    CONSTRAINT fk_evaluacion_inscripcion FOREIGN KEY (id_inscripcion) 
        REFERENCES academia_nexus.public.inscripcion(id_inscripcion) ON DELETE CASCADE
);

COMMENT ON TABLE academia_nexus.public.evaluacion IS 'Evaluaciones y calificaciones de los estudiantes';
COMMENT ON COLUMN academia_nexus.public.evaluacion.tipo_evaluacion Is 'Tipo de evaluación: EXAMEN_PARCIAL, EXAMEN_FINAL, TAREA, PROYECTO, QUIZ';
COMMENT ON COLUMN academia_nexus.public.evaluacion.porcentaje_peso Is 'Porcentaje que representa esta evaluación en la nota final';

-- =====================================================
-- TABLA: CERTIFICACION_PROFESOR
-- =====================================================
CREATE TABLE academia_nexus.public.certificacion_profesor (
    id_certificacion SERIAL PRIMARY KEY,
    id_profesor INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    fecha_certificacion DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVA', 'EXPIRADA')),
    
    CONSTRAINT fk_certificacion_profesor FOREIGN KEY (id_profesor) 
        REFERENCES academia_nexus.public.profesor(id_profesor) ON DELETE CASCADE,
    CONSTRAINT fk_certificacion_materia FOREIGN KEY (id_materia) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT uq_profesor_materia_certificacion UNIQUE (id_profesor, id_materia)
);

COMMENT ON TABLE academia_nexus.public.certificacion_profesor Is 'Certificaciones de profesores para impartir materias específicas';

-- =====================================================
-- TABLA: REQUISITO_MATERIA
-- =====================================================
CREATE TABLE academia_nexus.public.requisito_materia (
    id_requisito SERIAL PRIMARY KEY,
    id_materia INTEGER NOT NULL,
    id_materia_requisito INTEGER NOT NULL,
    tipo_requisito VARCHAR(20) NOT NULL CHECK (tipo_requisito IN ('APROBAR', 'CURSAR')),
    
    CONSTRAINT fk_requisito_materia FOREIGN KEY (id_materia) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT fk_requisito_materia_req FOREIGN KEY (id_materia_requisito) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT uq_materia_requisito UNIQUE (id_materia, id_materia_requisito),
    CONSTRAINT chk_no_autoreferencia CHECK (id_materia != id_materia_requisito)
);

COMMENT ON TABLE academia_nexus.public.requisito_materia IS 'Requisitos previos entre materias';
COMMENT ON COLUMN academia_nexus.public.requisito_materia.tipo_requisito Is 'Tipo de requisito: APROBAR (debe aprobar), CURSAR (debe haber cursado)';

-- =====================================================
-- TABLA: ASIGNACION_PROFESOR
-- =====================================================
CREATE TABLE academia_nexus.public.asignacion_profesor (
    id_asignacion SERIAL PRIMARY KEY,
    id_profesor INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    id_ciclo INTEGER NOT NULL,
    fecha_asignacion DATE NOT NULL,
    
    CONSTRAINT fk_asignacion_profesor FOREIGN KEY (id_profesor) 
        REFERENCES academia_nexus.public.profesor(id_profesor) ON DELETE CASCADE,
    CONSTRAINT fk_asignacion_materia FOREIGN KEY (id_materia) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT fk_asignacion_ciclo FOREIGN KEY (id_ciclo) 
        REFERENCES academia_nexus.public.ciclo(id_ciclo) ON DELETE CASCADE,
    CONSTRAINT uq_profesor_materia_ciclo UNIQUE (id_profesor, id_materia, id_ciclo)
);

COMMENT ON TABLE academia_nexus.public.asignacion_profesor IS 'Asignación de profesores a materias en ciclos específicos';

-- =====================================================
-- TABLA: HISTORIAL_ACADEMICO
-- =====================================================
CREATE TABLE academia_nexus.public.historial_academico (
    id_historial SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    id_ciclo INTEGER NOT NULL,
    nota_final NUMERIC(3,1) NOT NULL,
    fecha_aprobacion DATE NOT NULL,
    intento_numero INTEGER NOT NULL,
    
    CONSTRAINT fk_historial_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES academia_nexus.public.estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_historial_materia FOREIGN KEY (id_materia) 
        REFERENCES academia_nexus.public.materia(id_materia) ON DELETE CASCADE,
    CONSTRAINT fk_historial_ciclo FOREIGN KEY (id_ciclo) 
        REFERENCES academia_nexus.public.ciclo(id_ciclo) ON DELETE CASCADE
);

COMMENT ON TABLE academia_nexus.public.historial_academico IS 'Historial permanente de aprobaciones de estudiantes';
COMMENT ON COLUMN academia_nexus.public.historial_academico.intento_numero Is 'Número de intento en que se aprobó la materia';

-- =====================================================
-- RELACIÓN: MATERIA - AREA_CONOCIMIENTO
-- =====================================================
ALTER TABLE academia_nexus.public.materia
ADD CONSTRAINT fk_materia_area 
FOREIGN KEY (id_area_conocimiento) 
REFERENCES academia_nexus.public.area_conocimiento(id_area) ON DELETE CASCADE;

-- =====================================================
-- ÍNDICES PARA MEJORAR RENDIMIENTO
-- =====================================================

-- Índices en tablas de búsqueda frecuente
CREATE INDEX idx_estudiante_correo ON academia_nexus.public.estudiante(correo_electronico);
CREATE INDEX idx_estudiante_estado ON academia_nexus.public.estudiante(estado);
CREATE INDEX idx_materia_codigo ON academia_nexus.public.materia(codigo_materia);
CREATE INDEX idx_materia_area ON academia_nexus.public.materia(id_area_conocimiento);
CREATE INDEX idx_materia_estado ON academia_nexus.public.materia(estado);
CREATE INDEX idx_profesor_correo ON academia_nexus.public.profesor(correo_electronico);
CREATE INDEX idx_profesor_estado ON academia_nexus.public.profesor(estado);
CREATE INDEX idx_ciclo_estado ON academia_nexus.public.ciclo(estado);
CREATE INDEX idx_ciclo_fechas ON academia_nexus.public.ciclo(fecha_inicio, fecha_fin);
CREATE INDEX idx_inscripcion_estudiante ON academia_nexus.public.inscripcion(id_estudiante);
CREATE INDEX idx_inscripcion_materia ON academia_nexus.public.inscripcion(id_materia);
CREATE INDEX idx_inscripcion_ciclo ON academia_nexus.public.inscripcion(id_ciclo);
CREATE INDEX idx_inscripcion_estado ON academia_nexus.public.inscripcion(estado);
CREATE INDEX idx_evaluacion_inscripcion ON academia_nexus.public.evaluacion(id_inscripcion);
CREATE INDEX idx_evaluacion_fecha ON academia_nexus.public.evaluacion(fecha_evaluacion);
CREATE INDEX idx_certificacion_profesor ON academia_nexus.public.certificacion_profesor(id_profesor);
CREATE INDEX idx_certificacion_materia ON academia_nexus.public.certificacion_profesor(id_materia);
CREATE INDEX idx_requisito_materia ON academia_nexus.public.requisito_materia(id_materia);
CREATE INDEX idx_requisito_materia_req ON academia_nexus.public.requisito_materia(id_materia_requisito);
CREATE INDEX idx_asignacion_profesor ON academia_nexus.public.asignacion_profesor(id_profesor);
CREATE INDEX idx_asignacion_materia ON academia_nexus.public.asignacion_profesor(id_materia);
CREATE INDEX idx_asignacion_ciclo ON academia_nexus.public.asignacion_profesor(id_ciclo);
CREATE INDEX idx_historial_estudiante ON academia_nexus.public.historial_academico(id_estudiante);
CREATE INDEX idx_historial_materia ON academia_nexus.public.historial_academico(id_materia);

-- =====================================================
-- CONFIRMACIÓN DE CREACIÓN
-- =====================================================
SELECT 'Tablas creadas exitosamente con nomenclatura academia_nexus.public.nombre_tabla' AS mensaje,
       COUNT(*) as total_tablas
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE';