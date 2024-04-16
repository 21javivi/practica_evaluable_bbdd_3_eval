-- 14 Contar el número de empleados que han cambiado de categoría al menos 3 veces en la empresa.
SELECT COUNT(*) AS cantEmpleado 
FROM (SELECT COUNT(*) AS cambiosCategoria FROM dept_emp GROUP BY emp_no HAVING cambiosCategoria>2) 
AS empleadosMas2Cambios;

-- 15 Indica el número de jefes/encargados que cuenta cada departamento.
SELECT COUNT(*) AS cantEncargados FROM dept_manager;

-- 16 Encargado con mayor tiempo en la empresa. Código, nombre completo y puesto.
SELECT emp_no AS codEmpleado, CONCAT(first_name,' ', last_name) AS nombre , hire_date
FROM dept_manager D JOIN employees E USING (emp_no) WHERE
TIMESTAMPDIFF(DAY,E.hire_date, NOW()) = (SELECT MIN(TIMESTAMPDIFF(DAY,hire_date, NOW())) FROM employees);


-- 17 Empleados que hayan estado en más de un departamento. Indica sus nombres completos.

-- 18 Encargado que mayor salario ha tenido. Indica el código de empleado, nombre completo, salario y departamento.

-- 19 Empleados que fueron jefes y en la actualidad no lo son. Indica el código del empleado, nombre completo y tiempo que estuvo como jefe.

-- 20 Regalos de Navidad. El presidente de la empresa va a realizar un regalo de navidad, dependiendo de la antigüedad del empleado. 
-- Si lleva 30 años o más le va a regalar un “jamón de pata negra” valorado en 90€ y si lleva menos de 30 años un “podómetro digital” valorado en 30€. 
CREATE VIEW nombreAntiguedad AS SELECT CONCAT(first_name,' ',last_name) AS nombre, TIMESTAMPDIFF(YEAR, hire_date, NOW()) AS antiguedad FROM employees;

-- 20a Mostrar una consulta con los nombres de empleados, antigüedad, y el regalo que se le va a realizar.
SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad;

-- 20b Calcular el número de Jamones y el número de podómetros que se van a regalar.
SELECT regalo, COUNT(regalo) AS cantidad 
FROM(SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') 
AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad) 
AS tabla2 GROUP BY regalo;

-- 20c Añadir el precio total que se va a gastar de cada producto.
SELECT regalo, COUNT(regalo) AS cantidad, COUNT(regalo)*30 AS precioTotalProducto
FROM(SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') 
AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad) AS tabla2 GROUP BY regalo HAVING regalo LIKE 'Podómetro Digital'
UNION
SELECT regalo, COUNT(regalo) AS cantidad, COUNT(regalo)*90 AS precioTotalProducto
FROM(SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') 
AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad) AS tabla2 GROUP BY regalo HAVING regalo LIKE 'Jamón de Pata Negra';

-- CREACION DE LA VISTA PARA VER EL PRECIO TOTAL POR CADA ARTICULO (CANTIDAD*PRECIO POR AGRUPACION)
CREATE VIEW precioTotalPorArticulo AS SELECT regalo, COUNT(regalo) AS cantidad, COUNT(regalo)*30 AS precioTotalProducto
FROM(SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad) AS tabla2 GROUP BY regalo HAVING regalo LIKE 'Podómetro Digital'
UNION
SELECT regalo, COUNT(regalo) AS cantidad, COUNT(regalo)*90 AS precioTotalProducto
FROM(SELECT nombre, antiguedad, IF(antiguedad < 30, 'Podómetro Digital', 'Jamón de Pata Negra') AS regalo, IF(antiguedad < 30, CONCAT(30,'€'), CONCAT(90,'€')) AS precio
FROM nombreAntiguedad) AS tabla2 GROUP BY regalo HAVING regalo LIKE 'Jamón de Pata Negra';

-- 20d Obtener el coste total que tendrá que gastarse la empresa en realizar el regalo de navidad.

-- OPCION PRECIO TOTAL JUNTO REPETIDO
SELECT regalo, cantidad, precioTotalProducto, (SELECT SUM(precioTotalProducto) FROM precioTotalPorArticulo) AS precioTotal FROM precioTotalPorArticulo;

-- OPCION POR SEPARADO:
SELECT regalo, cantidad, precioTotalProducto, '' AS precioTotal FROM precioTotalPorArticulo
UNION
SELECT '' AS regalo, '' cantidad, '' precioTotalProducto, (SELECT SUM(precioTotalProducto) FROM precioTotalPorArticulo) AS precioTotal FROM precioTotalPorArticulo;
