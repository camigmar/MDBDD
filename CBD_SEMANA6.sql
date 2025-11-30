--------------
-- CASO 1
--------------

SELECT 
    id_profesional AS "ID",
    nombre_completo AS "PROFESIONAL",
    nro_asesorias_banca AS "NRO ASESORIA BANCA",
    monto_total_banca AS "MONTO_TOTAL_BANCA",
    nro_asesorias_retail AS "NRO ASESORIA RETAIL",
    monto_total_retail AS "MONTO_TOTAL_RETAIL",
    total_asesorias AS "TOTAL ASESORIAS",
    total_honorarios AS "TOTAL HONORARIOS"
FROM (
    -- subconsulta que junta banca con retail
    SELECT 
        b.id_profesional,
        b.nombre_completo,
        b.nro_asesorias_banca,
        b.monto_total_banca,
        r.nro_asesorias_retail,
        r.monto_total_retail,
        (b.nro_asesorias_banca + r.nro_asesorias_retail) AS total_asesorias,
        (b.monto_total_banca + r.monto_total_retail) AS total_honorarios
    FROM
        -- Subconsulta solo para BANCA (3)
        (SELECT 
            p.id_profesional,
            INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre) AS nombre_completo,
            COUNT(a.cod_empresa) AS nro_asesorias_banca,
            ROUND(SUM(a.honorario)) AS monto_total_banca
        FROM profesional p
        INNER JOIN asesoria a ON p.id_profesional = a.id_profesional
        INNER JOIN empresa e ON a.cod_empresa = e.cod_empresa
        WHERE e.cod_sector = 3
          AND a.fin_asesoria <= LAST_DAY(SYSDATE)
        GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre
        ) b
    --INNER JOIN para incluir solo los que están ambos sectores
    INNER JOIN
        -- Subconsulta solo para RETAIL (4)
        (SELECT 
            p.id_profesional,
            COUNT(a.cod_empresa) AS nro_asesorias_retail,
            ROUND(SUM(a.honorario)) AS monto_total_retail
        FROM profesional p
        INNER JOIN asesoria a ON p.id_profesional = a.id_profesional
        INNER JOIN empresa e ON a.cod_empresa = e.cod_empresa
        WHERE e.cod_sector = 4
          AND a.fin_asesoria <= LAST_DAY(SYSDATE)
        GROUP BY p.id_profesional
        ) r
    ON b.id_profesional = r.id_profesional
)
WHERE id_profesional IN (
    -- INTERSECT para usar todas las filas iguales seleccionadas por ambas consultas.
    SELECT id_profesional
    FROM asesoria a
    INNER JOIN empresa e ON a.cod_empresa = e.cod_empresa
    WHERE e.cod_sector = 3
      AND a.fin_asesoria <= LAST_DAY(SYSDATE)
    INTERSECT
    SELECT id_profesional
    FROM asesoria a
    INNER JOIN empresa e ON a.cod_empresa = e.cod_empresa
    WHERE e.cod_sector = 4
      AND a.fin_asesoria <= LAST_DAY(SYSDATE)
)
ORDER BY id_profesional ASC;

------------------------------
-- CASO 2
------------------------------
DROP TABLE REPORTE_MES;

CREATE TABLE REPORTE_MES (
    ID_PROF NUMBER(10) NOT NULL,
    NOMBRE_PROFESIONAL VARCHAR2(100) NOT NULL,
    NOMBRE_PROFESION VARCHAR2(50) NOT NULL,
    NOM_COMUNA VARCHAR2(50) NOT NULL,
    NRO_ASESORIAS NUMBER(3) NOT NULL,
    MONTO_TOTAL_HONORARIOS NUMBER(10) NOT NULL,
    PROMEDIO_HONORARIO NUMBER(10) NOT NULL,
    HONORARIO_MINIMO NUMBER(10) NOT NULL,
    HONORARIO_MAXIMO NUMBER(10) NOT NULL,
    CONSTRAINT PK_REPORTE_MES PRIMARY KEY (ID_PROF)
);

INSERT INTO REPORTE_MES (
    ID_PROF,
    NOMBRE_PROFESIONAL,
    NOMBRE_PROFESION,
    NOM_COMUNA,
    NRO_ASESORIAS,
    MONTO_TOTAL_HONORARIOS,
    PROMEDIO_HONORARIO,
    HONORARIO_MINIMO,
    HONORARIO_MAXIMO
)
SELECT
    p.id_profesional,
    INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre),
    INITCAP(NVL(prof.nombre_profesion, 'Sin Profesión')),
    INITCAP(NVL(c.nom_comuna, 'Sin Comuna')),
    COUNT(a.cod_empresa),
    ROUND(SUM(a.honorario)),
    ROUND(AVG(a.honorario)),
    ROUND(MIN(a.honorario)),
    ROUND(MAX(a.honorario))
    
    FROM profesional p
        INNER JOIN profesion prof ON p.cod_profesion = prof.cod_profesion
        LEFT JOIN comuna c ON p.cod_comuna = c.cod_comuna
        INNER JOIN asesoria a ON p.id_profesional = a.id_profesional
    
    WHERE
        EXTRACT(MONTH FROM a.fin_asesoria) = 4
        AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    
    GROUP BY 
        p.id_profesional,
        p.appaterno,
        p.apmaterno,
        p.nombre,
        prof.nombre_profesion,
        c.nom_comuna

ORDER BY id_profesional ASC;
COMMIT; 

SELECT * FROM REPORTE_MES;


------------------------------
-- CASO 3
------------------------------

-- 1°: hacer reporte de la figura 4

SELECT 
    a.honorario AS HONORARIO,
    p.id_profesional AS ID_PROFESIONAL,
    p.numrun_prof AS NUMRUN_PROF,
    p.sueldo AS SUELDO
FROM profesional p
INNER JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE 
-- filtro marzo del año pasado (que es marzo 2024)
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    AND a.fin_asesoria <= SYSDATE
ORDER BY 
    p.id_profesional ASC,
    a.honorario DESC;

-- 2° modificar datos

UPDATE profesional p
SET p.sueldo = p.sueldo * (
    CASE 
        -- Si el monto total acumulado de honorarios de esas asesorías es igual o supera
        -- $1.000.000, se aplicará un incremento adicional, de modo que el sueldo se incremente en un 15%.
        WHEN(
            SELECT NVL(SUM(a.honorario), 0)
            FROM asesoria a
            WHERE a.id_profesional = p.id_profesional
              AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
              AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
              AND a.fin_asesoria <= SYSDATE
        )>= 1000000 THEN 1.15
        
        -- Si un profesional ha finalizado asesorías en marzo del año pasado a la ejecución del
        -- reporte y el total de honorarios acumulados durante ese periodo es menor a
        -- $1.000.000, se incrementará su sueldo en un 10%
        WHEN(
            SELECT NVL(SUM(a.honorario), 0)
            FROM asesoria a
            WHERE a.id_profesional = p.id_profesional
              AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
              AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
              AND a.fin_asesoria <= SYSDATE
        )> 0 AND (
            SELECT NVL(SUM(a.honorario), 0)
            FROM asesoria a
            WHERE a.id_profesional = p.id_profesional
              AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
              AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
              AND a.fin_asesoria <= SYSDATE
        )< 1000000 THEN 1.10
        ELSE 1
    END
)
WHERE p.id_profesional IN (
    -- Solo actualizar profesionales que tienen asesorías en marzo del año pasado
    SELECT DISTINCT a.id_profesional
    FROM asesoria a
    WHERE EXTRACT(MONTH FROM a.fin_asesoria) = 3
      AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
      AND a.fin_asesoria <= SYSDATE
);
COMMIT;

-- 3° reporte con los datos modificados 

SELECT 
    a.honorario AS HONORARIO,
    p.id_profesional AS ID_PROFESIONAL,
    p.numrun_prof AS NUMRUN_PROF,
    p.sueldo AS SUELDO
FROM profesional p
INNER JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE 
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    AND a.fin_asesoria <= SYSDATE
ORDER BY 
    p.id_profesional ASC,
    a.honorario DESC;
