-- =====================================================
-- CREACIÓN DE BASE DE DATOS - Academia Nexus
-- PostgreSQL 15.x
-- Nomenclatura: academia_nexus.public.nombre_tabla
-- =====================================================

-- Eliminar base de datos si existe (para desarrollo)
DROP DATABASE IF EXISTS academia_nexus;

-- Crear base de datos
CREATE DATABASE academia_nexus
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_ES.UTF-8'
    LC_CTYPE = 'es_ES.UTF-8'
    TEMPLATE = template0
    CONNECTION LIMIT = -1;

-- Comentario sobre la base de datos
COMMENT ON DATABASE academia_nexus IS 'Base de datos del sistema Academia Nexus - Gestión académica. Nomenclatura: academia_nexus.public.nombre_tabla';

-- Conectar a la base de datos creada
\c academia_nexus

-- Habilitar extensión para UUID (útil para identificadores únicos)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Habilitar extensión para funciones de texto avanzadas
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Confirmación
SELECT 'Base de datos academia_nexus creada exitosamente' AS mensaje,
       'Usar nomenclatura: academia_nexus.public.nombre_tabla' AS nomenclatura;

--Esto funciono
-- Si sigues teniendo problemas, también puedes ejecutar esta versión simplificada:

-- Eliminar base de datos si existe
DROP DATABASE IF EXISTS academia_nexus;

-- Crear base de datos (sin especificar owner - usará tu usuario actual)
CREATE DATABASE academia_nexus;

-- Conectar a la base de datos
\c academia_nexus

-- Habilitar extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";