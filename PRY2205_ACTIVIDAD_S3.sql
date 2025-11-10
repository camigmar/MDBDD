-----------------------------
-- CASO 1
-----------------------------

SELECT
    -- El reporte debe mostrar el RUT de los clientes con puntos y guion:
    SUBSTR(TO_CHAR(numrut_cli, 'FM999G999G999'), 1) || '-' || dvrut_cli AS "RUT Cliente",


    INITCAP(nombre_cli || ' ' || appaterno_cli || ' ' || apmaterno_cli) AS "Nombre Completo Cliente",
    INITCAP(direccion_cli) AS "Dirección Cliente",
    TO_CHAR(ROUND(renta_cli), '$999G999G999') AS "Renta Cliente",
    NVL(celular_cli, 0) AS "Celular Cliente",

    -- Medir por tramos la rentabilidad de cada uno de los clientes, considerando la siguiente escala:
    -- Renta mayor de 500.000 clasifica como 'TRAMO 1'.
    -- Renta entre 400.000 y 500.000 clasifica como 'TRAMO 2'.
    -- Renta entre 200.000 y 399.999 clasifica como 'TRAMO 3'.
    -- Renta menor de 200.000 clasifica como 'TRAMO 4'.
    CASE
        WHEN renta_cli > 500000 THEN 'TRAMO 1'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Tramo Renta Cliente"

FROM cliente
-- Mostrar solo los clientes listados entre un rango de renta definido por el operario que
-- interactúe con el informe, es decir, el desarrollo debe ser capaz de pedir el monto
-- mínimo y máximo de renta a filtrar por pantalla:
WHERE renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
-- considerar solo a los clientes que tienen registrado un número de celular
AND celular_cli IS NOT NULL
ORDER BY "Nombre Completo Cliente";

----------------------------------
-- Caso 2
----------------------------------

SELECT
    id_categoria_emp AS CODIGO_CATEGORIA,
    -- Las categorías se clasifican por el siguiente código:
    -- 1 corresponde Gerente
    -- 2 corresponde Supervisor
    -- 3 corresponde Ejecutivo de Arriendo
    -- 4 corresponde Auxiliar:
    CASE id_categoria_emp
        WHEN 1 THEN 'Gerente'
        WHEN 2 THEN 'Supervisor'
        WHEN 3 THEN 'Ejecutivo de Arriendo'
        WHEN 4 THEN 'Auxiliar'
        ELSE 'Sin Categoría'
    END AS DESCRIPCION_CATEGORIA,
    COUNT(*) AS CANTIDAD_EMPLEADOS,
    -- 10 corresponde Sucursal Las Condes
    -- 20 corresponde Sucursal Santiago Centro
    -- 30 corresponde Sucursal Providencia
    -- 40 corresponde Sucursal Vitacura
    CASE id_sucursal
        WHEN 10 THEN 'Sucursal Las Condes'
        WHEN 20 THEN 'Sucursal Santiago Centro'
        WHEN 30 THEN 'Sucursal Providencia'
        WHEN 40 THEN 'Sucursal Vitacura'
        ELSE 'Otra Sucursal'
    END AS SUCURSAL,
    -- De la cantidad de empleados por sucursal se debe calcular el promedio de sueldo y
    -- formatear con signo pesos separando miles.
    TO_CHAR(ROUND(AVG(NVL(sueldo_emp,0))), '$999G999G999') AS SUELDO_PROMEDIO
    
FROM empleado
GROUP BY id_categoria_emp, id_sucursal
-- el usuario podrá ingresar por pantalla el valor del sueldo promedio mínimo a
-- considerar en el reporte.
HAVING AVG(NVL(sueldo_emp,0)) >= &SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(NVL(sueldo_emp,0)) DESC;

---------------------------
-- caso 3
---------------------------

SELECT
    id_tipo_propiedad AS CODIGO_TIPO,
    -- se espera que se transforme el código del tipo de propiedad en una descripción legible:
    CASE id_tipo_propiedad
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
        ELSE 'OTRO TIPO'
    END AS DESCRIPCION_TIPO,
    
    COUNT(*) AS TOTAL_PROPIEDADES,
    TO_CHAR(ROUND(AVG(NVL(valor_arriendo, 0))), '$999G999G999') AS PROMEDIO_ARRIENDO,
    TO_CHAR(ROUND(AVG(NVL(superficie, 0)), 2), '999G999D99') AS PROMEDIO_SUPERFICIE,
    TO_CHAR(ROUND(AVG(NVL(valor_arriendo, 0)) / NULLIF(AVG(NVL(superficie, 0)), 0)), '$999G999') AS VALOR_ARRIENDO_M2,
    
    -- El reporte final deberá incluir, además de los indicadores anteriores, una clasificación de
    -- las propiedades basada en el valor de arriendo por metro cuadrado, asignando
    -- categorías como menor de 5.000 m2 es "Económico", entre 5.000 y 10.000 m2 "Medio" o
    -- superior a todos los anteriores "Alto", según los umbrales establecidos
    CASE
        WHEN (AVG(NVL(valor_arriendo, 0)) / NULLIF(AVG(NVL(superficie, 0)), 0)) < 5000 THEN 'Económico'
        WHEN (AVG(NVL(valor_arriendo, 0)) / NULLIF(AVG(NVL(superficie, 0)), 0)) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS CLASIFICACION
FROM propiedad
GROUP BY id_tipo_propiedad
-- el reporte solo mostrará los registros cuyo promedio del valor de arriendo por m2 sea superior a 1.000
HAVING (AVG(NVL(valor_arriendo, 0)) / NULLIF(AVG(NVL(superficie, 0)), 0)) > 1000
ORDER BY (AVG(NVL(valor_arriendo, 0)) / NULLIF(AVG(NVL(superficie, 0)), 0)) DESC;