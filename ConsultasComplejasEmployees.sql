-- 14 Contar el número de empleados que han cambiado de categoría al menos 3 veces en la empresa.
SELECT COUNT(*) AS cantEmpleado 
FROM (SELECT COUNT(*) AS cambiosCategoria FROM dept_emp GROUP BY emp_no HAVING cambiosCategoria>2) 
AS empleadosMas2Cambios;

-- 15 Indica el número de jefes/encargados que cuenta cada departamento.
SELECT COUNT(*) AS cantEncargados FROM dept_manager;

-- 16 Encargado con mayor tiempo en la empresa. Código, nombre completo y puesto.
CREATE VIEW fechaMaximaEncargado AS SELECT emp_no, MAX(to_date) AS maximaFecha, MIN(from_date) AS minimaFecha FROM dept_manager 
WHERE to_date = (SELECT MAX(to_date) FROM dept_manager) GROUP BY emp_no;

SELECT emp_no as codEmpleado, CONCAT(first_name,' ', last_name) AS nombre, hire_date AS fechaContratacion, dept_name as puesto
FROM dept_manager DM
JOIN employees E USING(emp_no)
JOIN departments D USING (dept_no)
JOIN fechaMaximaEncargado F USING (emp_no)
WHERE DM.from_date = F.minimaFecha AND DM.to_date = F.maximaFecha 
AND E.emp_no = (SELECT emp_no FROM  dept_manager 
WHERE to_date = (SELECT MAX(to_date) FROM dept_manager) AND from_date = (SELECT MIN(from_date) FROM dept_manager WHERE to_date = (SELECT MAX(to_date) FROM dept_manager)));

-- 17 Empleados que hayan estado en más de un departamento. Indica sus nombres completos.
SELECT CONCAT(first_name,' ', last_name) AS nombre, COUNT(dept_no) AS cantidad FROM dept_emp JOIN employees USING (emp_no) GROUP BY emp_no HAVING cantidad>1;

-- 18 Encargado que mayor salario ha tenido. Indica el código de empleado, nombre completo, salario y departamento.
SELECT E.emp_no AS codEmpleado, CONCAT(first_name,' ', last_name) AS nombre, salary AS salarioMax, D.dept_no AS departamento 
FROM salaries S JOIN employees E USING (emp_no) JOIN dept_emp USING (emp_no) JOIN departments D USING (dept_no) WHERE salary = (SELECT MAX(salary) FROM salaries);

-- 19 Empleados que fueron jefes y en la actualidad no lo son. Indica el código del empleado, nombre completo y tiempo que estuvo como jefe.
SELECT emp_no, CONCAT(first_name,' ', last_name) AS nombre, TIMESTAMPDIFF(YEAR, from_date, to_date) AS duracionAños FROM dept_manager JOIN employees USING (emp_no) WHERE to_date<NOW();
SELECT emp_no, CONCAT(first_name,' ', last_name) AS nombre, TIMESTAMPDIFF(MONTH, from_date, to_date) AS duracionMeses FROM dept_manager JOIN employees USING (emp_no) WHERE to_date<NOW();
SELECT emp_no, CONCAT(first_name,' ', last_name) AS nombre, TIMESTAMPDIFF(DAY, from_date, to_date) AS duracionDias FROM dept_manager JOIN employees USING (emp_no) WHERE to_date<NOW();

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