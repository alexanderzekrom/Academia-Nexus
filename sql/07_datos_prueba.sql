-- =====================================================
-- DATOS DE PRUEBA - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

\c academia_nexus
SET search_path TO public;

-- =====================================================
-- LIMPIEZA DE DATOS EXISTENTES (opcional para desarrollo)
-- =====================================================
TRUNCATE TABLE academia_nexus.public.evaluacion CASCADE;
TRUNCATE TABLE academia_nexus.public.inscripcion CASCADE;
TRUNCATE TABLE academia_nexus.public.asignacion_profesor CASCADE;
TRUNCATE TABLE academia_nexus.public.certificacion_profesor CASCADE;
TRUNCATE TABLE academia_nexus.public.requisito_materia CASCADE;
TRUNCATE TABLE academia_nexus.public.historial_academico CASCADE;
TRUNCATE TABLE academia_nexus.public.materia CASCADE;
TRUNCATE TABLE academia_nexus.public.profesor CASCADE;
TRUNCATE TABLE academia_nexus.public.ciclo CASCADE;
TRUNCATE TABLE academia_nexus.public.estudiante CASCADE;
TRUNCATE TABLE academia_nexus.public.area_conocimiento CASCADE;

-- Reiniciar secuencias
ALTER SEQUENCE academia_nexus.public.area_conocimiento_id_area_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.estudiante_id_estudiante_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.materia_id_materia_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.profesor_id_profesor_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.ciclo_id_ciclo_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.inscripcion_id_inscripcion_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.evaluacion_id_evaluacion_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.certificacion_profesor_id_certificacion_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.requisito_materia_id_requisito_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.asignacion_profesor_id_asignacion_seq RESTART WITH 1;
ALTER SEQUENCE academia_nexus.public.historial_academico_id_historial_seq RESTART WITH 1;

-- =====================================================
-- INSERCIÓN DE ÁREAS DE CONOCIMIENTO
-- =====================================================
INSERT INTO academia_nexus.public.area_conocimiento (nombre_area, descripcion) VALUES
('Ciencias de la Computación', 'Área enfocada en programación, algoritmos y sistemas computacionales'),
('Matemáticas', 'Área dedicada al estudio de estructuras abstractas y patrones numéricos'),
('Física', 'Ciencia que estudia las propiedades de la materia y la energía'),
('Ingeniería de Software', 'Desarrollo y mantenimiento de sistemas software a gran escala'),
('Redes y Telecomunicaciones', 'Estudio de sistemas de comunicación y transferencia de datos'),
('Base de Datos', 'Gestión y organización de información estructurada'),
('Inteligencia Artificial', 'Desarrollo de sistemas que simulan inteligencia humana');

-- =====================================================
-- INSERCIÓN DE PROFESORES
-- =====================================================
INSERT INTO academia_nexus.public.profesor (nombre_completo, correo_electronico, telefono, fecha_contratacion, estado) VALUES
('Dr. Carlos Martínez', 'carlos.martinez@nexus.edu', '+5215551234567', '2020-03-15', 'ACTIVO'),
('Dra. Ana Rodríguez', 'ana.rodriguez@nexus.edu', '+5215552345678', '2019-08-20', 'ACTIVO'),
('Dr. Miguel Sánchez', 'miguel.sanchez@nexus.edu', '+5215553456789', '2021-01-10', 'ACTIVO'),
('Dra. Laura González', 'laura.gonzalez@nexus.edu', '+5215554567890', '2020-11-05', 'ACTIVO'),
('Dr. Roberto López', 'roberto.lopez@nexus.edu', '+5215555678901', '2018-06-12', 'ACTIVO'),
('Dra. María Fernández', 'maria.fernandez@nexus.edu', '+5215556789012', '2022-02-28', 'ACTIVO'),
('Dr. Javier Torres', 'javier.torres@nexus.edu', '+5215557890123', '2019-09-18', 'ACTIVO'),
('Dra. Carmen Rivera', 'carmen.rivera@nexus.edu', '+5215558901234', '2021-07-22', 'ACTIVO');

-- =====================================================
-- INSERCIÓN DE CICLOS
-- =====================================================
INSERT INTO academia_nexus.public.ciclo (nombre_ciclo, fecha_inicio, fecha_fin, estado) VALUES
('Ciclo 2024-I', '2024-01-15', '2024-05-30', 'CERRADO'),
('Ciclo 2024-II', '2024-06-01', '2024-10-15', 'CERRADO'),
('Ciclo 2024-III', '2024-10-20', '2025-02-28', 'CERRADO'),
('Ciclo 2025-I', '2025-03-01', '2025-07-15', 'ACTIVO'),
('Ciclo 2025-II', '2025-07-20', '2025-12-01', 'FUTURO');

-- =====================================================
-- INSERCIÓN DE MATERIAS
-- =====================================================
INSERT INTO academia_nexus.public.materia (nombre_materia, codigo_materia, creditos, horario, cupo_maximo, id_area_conocimiento, nota_minima_aprobacion, estado) VALUES
-- Ciencias de la Computación
('Programación I', 'CC101', 4, 'Lun-Mie 09:00-11:00', 30, 1, 7.0, 'ACTIVA'),
('Programación II', 'CC102', 4, 'Mar-Jue 09:00-11:00', 30, 1, 7.0, 'ACTIVA'),
('Programación Avanzada', 'CC301', 5, 'Lun-Mie 14:00-16:00', 25, 1, 7.0, 'ACTIVA'),
('Estructuras de Datos', 'CC201', 4, 'Mar-Jue 14:00-16:00', 30, 1, 7.0, 'ACTIVA'),

-- Matemáticas
('Cálculo I', 'MAT101', 4, 'Lun-Mie 08:00-10:00', 35, 2, 7.0, 'ACTIVA'),
('Cálculo II', 'MAT102', 4, 'Mar-Jue 08:00-10:00', 35, 2, 7.0, 'ACTIVA'),
('Álgebra Lineal', 'MAT201', 4, 'Vie 09:00-13:00', 30, 2, 7.0, 'ACTIVA'),

-- Física
('Física I', 'FIS101', 4, 'Lun-Mie 10:00-12:00', 30, 3, 7.0, 'ACTIVA'),
('Física II', 'FIS102', 4, 'Mar-Jue 10:00-12:00', 30, 3, 7.0, 'ACTIVA'),

-- Ingeniería de Software
('Ingeniería de Software I', 'IS101', 4, 'Lun-Mie 11:00-13:00', 30, 4, 7.0, 'ACTIVA'),
('Ingeniería de Software II', 'IS201', 4, 'Mar-Jue 11:00-13:00', 30, 4, 7.0, 'ACTIVA'),

-- Redes y Telecomunicaciones
('Redes I', 'RT101', 4, 'Lun-Mie 15:00-17:00', 25, 5, 7.0, 'ACTIVA'),
('Redes II', 'RT201', 4, 'Mar-Jue 15:00-17:00', 25, 5, 7.0, 'ACTIVA'),

-- Base de Datos
('Bases de Datos I', 'BD101', 4, 'Lun-Mie 16:00-18:00', 30, 6, 7.0, 'ACTIVA'),
('Bases de Datos II', 'BD201', 4, 'Mar-Jue 16:00-18:00', 30, 6, 7.0, 'ACTIVA'),

-- Inteligencia Artificial
('Inteligencia Artificial I', 'IA101', 5, 'Lun-Mie 13:00-15:00', 20, 7, 7.0, 'ACTIVA'),
('Machine Learning', 'IA201', 5, 'Mar-Jue 13:00-15:00', 20, 7, 7.0, 'ACTIVA');

-- =====================================================
-- INSERCIÓN DE REQUISITOS DE MATERIA
-- =====================================================
INSERT INTO academia_nexus.public.requisito_materia (id_materia, id_materia_requisito, tipo_requisito) VALUES
-- Programación
(2, 1, 'APROBAR'),  -- Programación II requiere Programación I
(3, 2, 'APROBAR'),  -- Programación Avanzada requiere Programación II
(4, 2, 'APROBAR'),  -- Estructuras de Datos requiere Programación II

-- Matemáticas
(6, 5, 'APROBAR'),  -- Cálculo II requiere Cálculo I

-- Física
(9, 8, 'APROBAR'),  -- Física II requiere Física I

-- Ingeniería de Software
(11, 10, 'APROBAR'), -- Ingeniería de Software II requiere Ingeniería de Software I

-- Redes
(13, 12, 'APROBAR'), -- Redes II requiere Redes I

-- Base de Datos
(15, 14, 'APROBAR'), -- Bases de Datos II requiere Bases de Datos I

-- Inteligencia Artificial
(17, 16, 'APROBAR'), -- Machine Learning requiere IA I
(17, 4, 'CURSAR'),   -- Machine Learning también requiere Estructuras de Datos
(16, 1, 'APROBAR');  -- IA I requiere Programación I

-- =====================================================
-- INSERCIÓN DE ESTUDIANTES
-- =====================================================
INSERT INTO academia_nexus.public.estudiante (nombre_completo, fecha_nacimiento, correo_electronico, telefono, fecha_ingreso, estado, nota_promedio_general, materias_reprobadas_consecutivas) VALUES
('Juan Pérez', '2005-05-15', 'juan.perez@nexus.edu', '+5215551111222', '2024-03-01', 'ACTIVO', 8.5, 0),
('María García', '2005-08-22', 'maria.garcia@nexus.edu', '+5215552222333', '2024-03-01', 'ACTIVO', 9.1, 0),
('Carlos López', '2005-03-10', 'carlos.lopez@nexus.edu', '+5215553333444', '2024-03-01', 'ACTIVO', 7.8, 0),
('Ana Martínez', '2005-11-28', 'ana.martinez@nexus.edu', '+5215554444555', '2024-03-01', 'OBSERVACION', 6.2, 3),
('Pedro Sánchez', '2005-07-05', 'pedro.sanchez@nexus.edu', '+5215555555666', '2024-03-01', 'ACTIVO', 8.9, 0),
('Laura Rodríguez', '2005-01-18', 'laura.rodriguez@nexus.edu', '+5215556666777', '2024-03-01', 'ACTIVO', 9.3, 0),
('Roberto Fernández', '2005-09-30', 'roberto.fernandez@nexus.edu', '+5215557777888', '2024-03-01', 'ACTIVO', 7.5, 1),
('Carmen González', '2005-04-12', 'carmen.gonzalez@nexus.edu', '+5215558888999', '2024-03-01', 'ACTIVO', 8.7, 0),
('Miguel Torres', '2005-06-25', 'miguel.torres@nexus.edu', '+5215559999000', '2024-03-01', 'ACTIVO', 8.2, 0),
('Sofía Ramírez', '2005-02-14', 'sofia.ramirez@nexus.edu', '+5215550000111', '2024-03-01', 'ACTIVO', 9.0, 0);

-- =====================================================
-- INSERCIÓN DE CERTIFICACIONES DE PROFESORES
-- =====================================================
INSERT INTO academia_nexus.public.certificacion_profesor (id_profesor, id_materia, fecha_certificacion, estado) VALUES
-- Dr. Carlos Martínez (Ciencias de la Computación)
(1, 1, '2020-03-20', 'ACTIVA'),  -- Programación I
(1, 2, '2020-03-20', 'ACTIVA'),  -- Programación II
(1, 3, '2021-01-15', 'ACTIVA'),  -- Programación Avanzada
(1, 4, '2021-01-15', 'ACTIVA'),  -- Estructuras de Datos

-- Dra. Ana Rodríguez (Matemáticas)
(2, 5, '2019-08-25', 'ACTIVA'),  -- Cálculo I
(2, 6, '2020-06-10', 'ACTIVA'),  -- Cálculo II
(2, 7, '2020-06-10', 'ACTIVA'),  -- Álgebra Lineal

-- Dr. Miguel Sánchez (Física)
(3, 8, '2021-01-15', 'ACTIVA'),  -- Física I
(3, 9, '2021-06-20', 'ACTIVA'),  -- Física II

-- Dra. Laura González (Ingeniería de Software)
(4, 10, '2020-11-10', 'ACTIVA'), -- Ingeniería de Software I
(4, 11, '2021-06-15', 'ACTIVA'), -- Ingeniería de Software II
(4, 1, '2021-06-15', 'ACTIVA'), -- Programación I (certificación cruzada)

-- Dr. Roberto López (Redes)
(5, 12, '2018-06-15', 'ACTIVA'), -- Redes I
(5, 13, '2019-01-20', 'ACTIVA'), -- Redes II

-- Dra. María Fernández (Base de Datos)
(6, 14, '2022-03-01', 'ACTIVA'), -- Bases de Datos I
(6, 15, '2022-08-15', 'ACTIVA'), -- Bases de Datos II

-- Dr. Javier Torres (Inteligencia Artificial)
(7, 16, '2019-09-20', 'ACTIVA'), -- IA I
(7, 17, '2020-03-25', 'ACTIVA'), -- Machine Learning
(7, 1, '2020-03-25', 'ACTIVA'),  -- Programación I (certificación cruzada)

-- Dra. Carmen Rivera (Ingeniería de Software)
(8, 10, '2021-07-25', 'ACTIVA'), -- Ingeniería de Software I
(8, 11, '2022-01-30', 'ACTIVA'), -- Ingeniería de Software II
(8, 4, '2022-01-30', 'ACTIVA');  -- Estructuras de Datos (certificación cruzada)

-- =====================================================
-- INSERCIÓN DE ASIGNACIONES DE PROFESORES A CICLOS
-- =====================================================
INSERT INTO academia_nexus.public.asignacion_profesor (id_profesor, id_materia, id_ciclo, fecha_asignacion) VALUES
-- Ciclo 2024-I
(1, 1, 1, '2024-01-10'),  -- Programación I
(2, 5, 1, '2024-01-10'),  -- Cálculo I
(3, 8, 1, '2024-01-10'),  -- Física I
(4, 10, 1, '2024-01-10'), -- Ingeniería de Software I
(5, 12, 1, '2024-01-10'), -- Redes I
(6, 14, 1, '2024-01-10'), -- Bases de Datos I
(7, 16, 1, '2024-01-10'), -- IA I

-- Ciclo 2024-II
(1, 2, 2, '2024-05-25'),  -- Programación II
(2, 6, 2, '2024-05-25'),  -- Cálculo II
(3, 9, 2, '2024-05-25'),  -- Física II
(4, 11, 2, '2024-05-25'), -- Ingeniería de Software II
(5, 13, 2, '2024-05-25'), -- Redes II
(6, 15, 2, '2024-05-25'), -- Bases de Datos II
(7, 17, 2, '2024-05-25'), -- Machine Learning

-- Ciclo 2025-I (actual)
(1, 1, 4, '2025-02-20'),  -- Programación I
(1, 4, 4, '2025-02-20'),  -- Estructuras de Datos
(2, 5, 4, '2025-02-20'),  -- Cálculo I
(2, 7, 4, '2025-02-20'),  -- Álgebra Lineal
(3, 8, 4, '2025-02-20'),  -- Física I
(4, 10, 4, '2025-02-20'), -- Ingeniería de Software I
(5, 12, 4, '2025-02-20'), -- Redes I
(6, 14, 4, '2025-02-20'), -- Bases de Datos I
(7, 16, 4, '2025-02-20'); -- IA I

-- =====================================================
-- INSERCIÓN DE INSCRIPCIONES (Ciclos anteriores - históricos)
-- Desactivamos triggers temporalmente para datos históricos
-- =====================================================
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_requisitos_previos;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_cupo_materia;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_limite_materias;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_actualizar_reprobadas_consecutivas;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_actualizar_promedio_estudiante;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_registrar_historial_academico;

INSERT INTO academia_nexus.public.inscripcion (id_estudiante, id_materia, id_ciclo, fecha_inscripcion, nota_final, estado) VALUES
-- Juan Pérez - Ciclo 2024-I
(1, 1, 1, '2024-01-20', 8.5, 'APROBADO'),  -- Programación I
(1, 5, 1, '2024-01-20', 9.0, 'APROBADO'),  -- Cálculo I
(1, 8, 1, '2024-01-20', 7.8, 'APROBADO'),  -- Física I

-- Juan Pérez - Ciclo 2024-II
(1, 2, 2, '2024-06-05', 8.2, 'APROBADO'),  -- Programación II
(1, 6, 2, '2024-06-05', 8.7, 'APROBADO'),  -- Cálculo II
(1, 9, 2, '2024-06-05', 7.5, 'APROBADO'),  -- Física II

-- María García - Ciclo 2024-I
(2, 1, 1, '2024-01-20', 9.5, 'APROBADO'),  -- Programación I
(2, 5, 1, '2024-01-20', 9.8, 'APROBADO'),  -- Cálculo I
(2, 10, 1, '2024-01-20', 9.2, 'APROBADO'), -- Ingeniería de Software I

-- María García - Ciclo 2024-II
(2, 2, 2, '2024-06-05', 9.3, 'APROBADO'),  -- Programación II
(2, 6, 2, '2024-06-05', 9.6, 'APROBADO'),  -- Cálculo II
(2, 11, 2, '2024-06-05', 9.1, 'APROBADO'), -- Ingeniería de Software II

-- Ana Martínez - Ciclo 2024-I (estudiante con problemas)
(4, 1, 1, '2024-01-20', 6.5, 'REPROBADO'), -- Programación I
(4, 5, 1, '2024-01-20', 5.8, 'REPROBADO'), -- Cálculo I
(4, 8, 1, '2024-01-20', 6.2, 'REPROBADO'), -- Física I

-- Ana Martínez - Ciclo 2024-II (reintentos)
(4, 1, 2, '2024-06-05', 6.8, 'REPROBADO'), -- Programación I (reprobado otra vez)
(4, 5, 2, '2024-06-05', 6.1, 'REPROBADO'), -- Cálculo I (reprobado otra vez)
(4, 14, 2, '2024-06-05', 7.2, 'APROBADO'), -- Bases de Datos I (aprobó finalmente)

-- Carlos López - Ciclo 2024-I
(3, 1, 1, '2024-01-20', 8.0, 'APROBADO'),  -- Programación I
(3, 5, 1, '2024-01-20', 8.3, 'APROBADO'),  -- Cálculo I
(3, 12, 1, '2024-01-20', 8.7, 'APROBADO'), -- Redes I

-- Carlos López - Ciclo 2024-II
(3, 2, 2, '2024-06-05', 7.9, 'APROBADO'),  -- Programación II
(3, 6, 2, '2024-06-05', 8.1, 'APROBADO'),  -- Cálculo II
(3, 13, 2, '2024-06-05', 8.5, 'APROBADO'); -- Redes II

-- Reactivar triggers después de inserción histórica
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_requisitos_previos;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_cupo_materia;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_limite_materias;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_actualizar_reprobadas_consecutivas;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_actualizar_promedio_estudiante;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_registrar_historial_academico;

-- =====================================================
-- INSERCIÓN DE INSCRIPCIONES (Ciclo actual - 2046-I)
-- Desactivamos triggers temporalmente para datos de prueba
-- =====================================================
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_requisitos_previos;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_cupo_materia;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_validar_limite_materias;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_actualizar_reprobadas_consecutivas;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_actualizar_promedio_estudiante;
ALTER TABLE academia_nexus.public.inscripcion DISABLE TRIGGER trg_registrar_historial_academico;
INSERT INTO academia_nexus.public.inscripcion (id_estudiante, id_materia, id_ciclo, fecha_inscripcion, nota_final, estado) VALUES
-- Juan Pérez (inscrito en materias avanzadas)
(1, 3, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Programación Avanzada
(1, 4, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Estructuras de Datos
(1, 10, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Ingeniería de Software I
(1, 14, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Bases de Datos I

-- María García (inscrita en materias avanzadas)
(2, 3, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Programación Avanzada
(2, 4, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Estructuras de Datos
(2, 16, 4, '2025-03-05', 0.0, 'INSCRITO'), -- IA I

-- Carlos López (inscrito en materias intermedias)
(3, 4, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Estructuras de Datos
(3, 10, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Ingeniería de Software I
(3, 14, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Bases de Datos I

-- Ana Martínez (intenta recuperar - inscripción limitada)
(4, 1, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Programación I (otra vez)
(4, 5, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Cálculo I (otra vez)

-- Pedro Sánchez (estudiante nuevo en ciclo actual)
(5, 1, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Programación I
(5, 5, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Cálculo I
(5, 8, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Física I
(5, 10, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Ingeniería de Software I
(5, 12, 4, '2025-03-05', 0.0, 'INSCRITO'), -- Redes I

-- Laura Rodríguez (estudiante con alto rendimiento)
(6, 1, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Programación I
(6, 5, 4, '2025-03-05', 0.0, 'INSCRITO'),  -- Cálculo I
(6, 16, 4, '2025-03-05', 0.0, 'INSCRITO'), -- IA I
(6, 14, 4, '2025-03-05', 0.0, 'INSCRITO'); -- Bases de Datos I

-- Reactivar triggers después de inserción del ciclo actual
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_requisitos_previos;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_cupo_materia;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_validar_limite_materias;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_actualizar_reprobadas_consecutivas;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_actualizar_promedio_estudiante;
ALTER TABLE academia_nexus.public.inscripcion ENABLE TRIGGER trg_registrar_historial_academico;

-- =====================================================
-- INSERCIÓN DE HISTORIAL ACADÉMICO (para materias aprobadas)
-- =====================================================
INSERT INTO academia_nexus.public.historial_academico (id_estudiante, id_materia, id_ciclo, nota_final, fecha_aprobacion, intento_numero) VALUES
-- Juan Pérez
(1, 1, 1, 8.5, '2024-05-25', 1),
(1, 5, 1, 9.0, '2024-05-25', 1),
(1, 8, 1, 7.8, '2024-05-25', 1),
(1, 2, 2, 8.2, '2024-10-10', 1),
(1, 6, 2, 8.7, '2024-10-10', 1),
(1, 9, 2, 7.5, '2024-10-10', 1),

-- María García
(2, 1, 1, 9.5, '2024-05-25', 1),
(2, 5, 1, 9.8, '2024-05-25', 1),
(2, 10, 1, 9.2, '2024-05-25', 1),
(2, 2, 2, 9.3, '2024-10-10', 1),
(2, 6, 2, 9.6, '2024-10-10', 1),
(2, 11, 2, 9.1, '2024-10-10', 1),

-- Carlos López
(3, 1, 1, 8.0, '2024-05-25', 1),
(3, 5, 1, 8.3, '2024-05-25', 1),
(3, 12, 1, 8.7, '2024-05-25', 1),
(3, 2, 2, 7.9, '2024-10-10', 1),
(3, 6, 2, 8.1, '2024-10-10', 1),
(3, 13, 2, 8.5, '2024-10-10', 1),

-- Ana Martínez (solo aprobó Bases de Datos I)
(4, 14, 2, 7.2, '2024-10-10', 1);

-- =====================================================
-- INSERCIÓN DE EVALUACIONES (para algunas inscripciones)
-- Desactivamos triggers temporalmente para datos de prueba
-- =====================================================
ALTER TABLE academia_nexus.public.evaluacion DISABLE TRIGGER trg_calcular_nota_final;
ALTER TABLE academia_nexus.public.evaluacion DISABLE TRIGGER trg_prevenir_modificacion_nota;

INSERT INTO academia_nexus.public.evaluacion (id_inscripcion, tipo_evaluacion, descripcion, nota, fecha_evaluacion, porcentaje_peso) VALUES
-- Evaluaciones para Juan Pérez en Programación Avanzada (inscripción 25)
(25, 'EXAMEN_PARCIAL', 'Parcial 1 - Algoritmos Avanzados', 8.5, '2025-04-15', 30.0),
(25, 'TAREA', 'Tarea 1 - Implementación de Árboles', 9.0, '2025-04-01', 20.0),
(25, 'PROYECTO', 'Proyecto Semestral - Sistema de Recomendación', 8.7, '2025-05-20', 30.0),

-- Evaluaciones para Juan Pérez en Estructuras de Datos (inscripción 26)
(26, 'EXAMEN_PARCIAL', 'Parcial 1 - Listas y Pilas', 8.0, '2025-04-10', 30.0),
(26, 'TAREA', 'Tarea 1 - Implementación de Colas', 8.5, '2025-04-05', 20.0),

-- Evaluaciones para María García en IA I (inscripción 30)
(30, 'EXAMEN_PARCIAL', 'Parcial 1 - Introducción a IA', 9.5, '2025-04-12', 35.0),
(30, 'TAREA', 'Tarea 1 - Algoritmos de Búsqueda', 9.2, '2025-04-02', 15.0),
(30, 'PROYECTO', 'Proyecto - Chatbot Simple', 9.0, '2025-05-15', 35.0),

-- Evaluaciones para Pedro Sánchez en Programación I (inscripción 34)
(34, 'EXAMEN_PARCIAL', 'Parcial 1 - Fundamentos de Programación', 7.5, '2025-04-08', 30.0),
(34, 'TAREA', 'Tarea 1 - Variables y Condicionales', 8.0, '2025-04-03', 20.0),

-- Evaluaciones para Ana Martínez en Programación I (reintento - inscripción 31)
(31, 'EXAMEN_PARCIAL', 'Parcial 1 - Fundamentos de Programación', 6.0, '2025-04-08', 30.0),
(31, 'TAREA', 'Tarea 1 - Variables y Condicionales', 6.5, '2025-04-03', 20.0);

-- Reactivar triggers después de inserción de evaluaciones
ALTER TABLE academia_nexus.public.evaluacion ENABLE TRIGGER trg_calcular_nota_final;
ALTER TABLE academia_nexus.public.evaluacion ENABLE TRIGGER trg_prevenir_modificacion_nota;

-- =====================================================
-- CONFIRMACIÓN DE INSERCIÓN
-- =====================================================
SELECT 'Datos de prueba insertados exitosamente' AS mensaje;

-- Mostrar resumen de datos insertados
SELECT 
    'Áreas de Conocimiento' as tabla, COUNT(*) as total FROM academia_nexus.public.area_conocimiento
UNION ALL
SELECT 'Profesores', COUNT(*) FROM academia_nexus.public.profesor
UNION ALL
SELECT 'Ciclos', COUNT(*) FROM academia_nexus.public.ciclo
UNION ALL
SELECT 'Materias', COUNT(*) FROM academia_nexus.public.materia
UNION ALL
SELECT 'Estudiantes', COUNT(*) FROM academia_nexus.public.estudiante
UNION ALL
SELECT 'Requisitos de Materia', COUNT(*) FROM academia_nexus.public.requisito_materia
UNION ALL
SELECT 'Certificaciones', COUNT(*) FROM academia_nexus.public.certificacion_profesor
UNION ALL
SELECT 'Asignaciones', COUNT(*) FROM academia_nexus.public.asignacion_profesor
UNION ALL
SELECT 'Inscripciones', COUNT(*) FROM academia_nexus.public.inscripcion
UNION ALL
SELECT 'Historial Académico', COUNT(*) FROM academia_nexus.public.historial_academico
UNION ALL
SELECT 'Evaluaciones', COUNT(*) FROM academia_nexus.public.evaluacion;