
--------------------------------
-- caso 1
--------------------------------

SELECT  
    -- respetando las normas de visualización
    UPPER(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) 
        AS "Nombre Completo Trabajador",
        
    TO_CHAR(t.numrut, 'FM99G999G999G999') || '-' || t.dvrut
        AS "RUT Trabajador",

    NVL(UPPER(tt.desc_categoria), 'SIN CATEGORIA')
        AS "Tipo Trabajador",

    UPPER(c.nombre_ciudad)
        AS "Ciudad Trabajador",

    TO_CHAR(t.sueldo_base, 'L9G999G999')
        AS "Sueldo Base"

FROM trabajador t
LEFT JOIN tipo_trabajador tt
    ON t.id_categoria_t = tt.id_categoria
LEFT JOIN comuna_ciudad c
    ON t.id_ciudad = c.id_ciudad

-- Solo serán listados todos aquellos trabajadores cuyo sueldos
-- base esté entre un margen de $650.000 y $3.000.000
WHERE t.sueldo_base BETWEEN 650000 AND 3000000

-- Listar información específica de los trabajadores de forma ordenada
ORDER BY 
    c.nombre_ciudad DESC,
    t.sueldo_base ASC;
    
----------------------------
-- caso 2
----------------------------

SELECT  
    
    REGEXP_REPLACE(
        TO_CHAR(t.numrut, 'FM999G999G999'), ',', '.') || '-' || t.dvrut AS "RUT Trabajador",

    UPPER(t.nombre || ' ' || t.appaterno) AS "Nombre Trabajador",
    
    COUNT(tc.nro_ticket) AS "Total Tickets",
    '$' || REPLACE(TO_CHAR(SUM(tc.monto_ticket), 'FM999G999G999'), ',', '.') 
        AS "Total Vendido",

    '$' || REPLACE(TO_CHAR(SUM(NVL(ct.valor_comision,0)), 'FM999G999'), ',', '.') 
        AS "Comisión Total",
   
    UPPER(tt.desc_categoria) AS "Tipo Trabajador",
    
    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"

FROM trabajador t
    JOIN tipo_trabajador tt
        ON t.id_categoria_t = tt.id_categoria
    JOIN tickets_concierto tc
        ON tc.numrut_t = t.numrut
    LEFT JOIN comisiones_ticket ct
        ON ct.nro_ticket = tc.nro_ticket
    JOIN comuna_ciudad c
        ON t.id_ciudad = c.id_ciudad

-- listar a todos los trabajadores que tengan rol de CAJERO
WHERE UPPER(tt.desc_categoria) = 'CAJERO'

GROUP BY
    t.numrut, t.dvrut,
    t.nombre, t.appaterno,
    tt.desc_categoria,
    c.nombre_ciudad

-- Conciertos Chile solo requiere información de la suma de los
-- montos de los tickets sea superior a $50.000
HAVING SUM(tc.monto_ticket) > 50000

ORDER BY SUM(tc.monto_ticket) DESC;

-----------------------------
-- caso 3
-----------------------------

SELECT

    REGEXP_REPLACE(TO_CHAR(t.numrut, 'FM999G999G999'), ',', '.') AS "RUT Trabajador",

    INITCAP(t.nombre || ' ' || t.appaterno) AS "Trabajador Nombre",
    -- Es necesario saber el año de ingreso de cada trabajador para saber su antigüedad,
    -- si este tiene asignación familiar a través de las cargas familiares además si pertenece a
    -- ISAPRE o si es FONASA
    TO_CHAR(t.fecing, 'YYYY') AS "Año Ingreso",

    FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) AS "Años Antigüedad",
    
    COUNT(af.numrut_carga) AS "Num. Cargas Familiares",

    NVL(i.nombre_isapre, 'FONASA') AS "Nombre Isapre",

   
    '$' || REPLACE(TO_CHAR(t.sueldo_base, 'FM9G999G999'), ',', '.') AS "Sueldo Base",

    -- Si es FONASA el bono subirá un 1% en base a su sueldo.
    '$' || REPLACE(
        TO_CHAR(CASE WHEN UPPER(NVL(i.nombre_isapre, 'FONASA')) LIKE 'FONASA%' THEN t.sueldo_base * 0.01 ELSE 0 END, 'FM9G999G999'), ',', '.') AS "Bono Fonasa",

    -- El bono por años de antigüedad se asignará a todo trabajador y se calcula de la siguiente
    -- forma: con 10 o menos años trabajados se asignará un 10% de su sueldo, y los que tengan
    -- 11 o más años trabajados se le asignará un bono del 15% de su sueldo
    '$' || REPLACE(TO_CHAR(CASE WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10 THEN t.sueldo_base * 0.10 ELSE t.sueldo_base * 0.15 END, 'FM9G999G999'), ',', '.') AS "Bono Antigüedad",

    
    a.nombre_afp AS "Nombre AFP",
    ec.desc_estcivil AS "Estado Civil"

FROM trabajador t

    LEFT JOIN asignacion_familiar af
        ON t.numrut = af.numrut_t

    -- trabajadores que no tenga fecha de término del estado civil o que la fecha de término 
    -- del estado civil termine posterior a la fecha de ejecución del reporte
    JOIN est_civil est
        ON est.numrut_t = t.numrut
       AND (est.fecter_estcivil IS NULL OR est.fecter_estcivil > SYSDATE)

    JOIN estado_civil ec
        ON ec.id_estcivil = est.id_estcivil_est

    JOIN afp a
        ON a.cod_afp = t.cod_afp

    LEFT JOIN isapre i
        ON i.cod_isapre = t.cod_isapre

GROUP BY
    t.numrut,
    t.nombre, t.appaterno,
    t.fecing, t.sueldo_base,
    i.nombre_isapre,
    a.nombre_afp,
    ec.desc_estcivil

ORDER BY
    t.numrut ASC;