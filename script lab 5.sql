-- ==========================================
-- PASO 1: CREAR BASE DE DATOS Y TABLAS
-- ==========================================

-- Borrar la base si existe, crearla limpia y seleccionarla
DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

-- Crear tabla tiendas
CREATE TABLE tiendas (
    id_tienda INT PRIMARY KEY,
    nombre VARCHAR(60),
    comuna VARCHAR(60)
);

-- Crear tabla vendedores
CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY,
    nombre VARCHAR(60),
    id_tienda INT,
    fecha_ingreso DATE,
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

-- Crear tabla bicicletas
CREATE TABLE bicicletas (
    id_bicicleta INT PRIMARY KEY,
    modelo VARCHAR(60),
    categoria ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana'),
    precio DECIMAL(10,2)
);

-- Crear tabla ventas (con auto_increment como pide el modelo)
CREATE TABLE ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_vendedor INT,
    id_bicicleta INT,
    fecha DATE,
    unidades INT,
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta)
);

-- ==========================================
-- PASO 2: CARGAR LOS DATOS OFICIALES
-- ==========================================

-- Insertar datos en tiendas
INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú', 'Maipú'),
(3, 'Andes Concepción', 'Concepción'),
(4, 'Andes La Serena', 'La Serena');

-- Insertar datos en vendedores
INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
(1, 'Camila Ortiz', 1, '2024-06-20'),
(2, 'Diego Fuentes', 1, '2024-01-15'),
(3, 'Javiera Soto', 2, '2023-07-24'),
(4, 'Matías Herrera', 2, '2024-01-15'),
(5, 'Paula Riquelme', 3, '2022-11-02'),
(6, 'Ignacio Vera', 3, '2024-08-19'),
(7, 'Fernanda Lillo', 1, '2025-02-03'),
(8, 'Rubén Castro', NULL, '2025-06-10');

-- Insertar datos en bicicletas
INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
(1, 'Cordillera 29', 'Montaña', 549990.00),
(2, 'Ruta Austral', 'Ruta', 899990.00),
(3, 'Urbana Pro', 'Urbana', 329990.00),
(4, 'Pequeño Andes', 'Infantil', 149990.00),
(5, 'Volt City', 'Eléctrica', 1249990.00),
(6, 'Trail Master', 'Montaña', 749990.00),
(7, 'Urbana Lite', 'Urbana', 229990.00),
(8, 'Sprint R7', 'Ruta', 109990.00);

-- Insertar datos en ventas
INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1, 5, '2025-04-02', 1),
(2, 2, '2025-03-04', 1),
(2, 1, '2025-04-11', 3),
(2, 7, '2025-05-06', 2),
(3, 4, '2025-03-21', 4),
(3, 3, '2025-04-15', 2),
(3, 6, '2025-05-20', 1),
(4, 1, '2025-03-27', 1),
(4, 5, '2025-05-09', 2),
(5, 2, '2025-04-08', 1),
(5, 6, '2025-04-23', 2),
(5, 4, '2025-06-02', 5),
(6, 3, '2025-05-13', 3),
(6, 7, '2025-06-17', 1),
(6, 1, '2025-06-24', 2),
(1, 6, '2025-06-30', 1);
SELECT v.nombre, COUNT(ve.id_venta) AS cantidad_ventas
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY cantidad_ventas DESC, v.nombre ASC;
SELECT t.nombre, COUNT(ve.id_venta) AS cantidad_ventas, IFNULL(SUM(ve.unidades), 0) AS unidades_vendidas
FROM tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades_vendidas DESC;
SELECT t.nombre
FROM tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
WHERE v.id_vendedor IS NULL;
SELECT b.modelo
FROM bicicletas b
WHERE b.id_bicicleta NOT IN (
    SELECT id_bicicleta 
    FROM ventas 
    WHERE fecha BETWEEN '2025-06-01' AND '2025-06-30'
);
SELECT v.nombre, t.nombre AS nombre_tienda
FROM vendedores v
LEFT JOIN tiendas t ON v.id_tienda = t.id_tienda
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
WHERE ve.id_venta IS NULL;
SELECT v1.nombre AS vendedor_1, v2.nombre AS vendedor_2, 
       v1.fecha_ingreso AS ingreso_1, v2.fecha_ingreso AS ingreso_2, 
       t.nombre AS tienda
FROM vendedores v1
JOIN vendedores v2 ON v1.id_tienda = v2.id_tienda AND v1.fecha_ingreso < v2.fecha_ingreso
JOIN tiendas t ON v1.id_tienda = t.id_tienda;
SELECT t.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM tiendas t
JOIN vendedores v ON t.id_tienda = v.id_tienda
JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
JOIN bicicletas b ON ve.id_bicicleta = b.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING monto_total > 2000000
ORDER BY monto_total DESC;
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;
SELECT v.nombre, AVG(ve.unidades) AS promedio_unidades
FROM vendedores v
JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, v.nombre ASC;
SELECT v.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
LEFT JOIN bicicletas b ON ve.id_bicicleta = b.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto_total DESC;