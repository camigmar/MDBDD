SHOW USER;

DROP TABLE REGION CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE PROVEEDOR CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA CASCADE CONSTRAINTS;
DROP TABLE MARCA CASCADE CONSTRAINTS;
DROP TABLE PRODUCTO CASCADE CONSTRAINTS;
DROP TABLE AFP CASCADE CONSTRAINTS;
DROP TABLE SALUD CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE ADMINISTRATIVO CASCADE CONSTRAINTS;
DROP TABLE VENDEDOR CASCADE CONSTRAINTS;
DROP TABLE MEDIO_PAGO CASCADE CONSTRAINTS;
DROP TABLE VENTA CASCADE CONSTRAINTS;
DROP TABLE DETALLE_VENTA CASCADE CONSTRAINTS;
DROP SEQUENCE seq_salud;
DROP SEQUENCE seq_empleado;


---------------------------------------------
--          CREACION DE TABLAS             --
---------------------------------------------

CREATE TABLE REGION (
    id_region        NUMBER(4),
    nom_region       VARCHAR2(25)
);

CREATE TABLE COMUNA (
    id_comuna        NUMBER(4),
    nom_comuna       VARCHAR2(100),
    cod_region       NUMBER(4)
);

CREATE TABLE PROVEEDOR (
    id_proveedor     NUMBER(5),
    nombre_proveedor VARCHAR2(150),
    rut_proveedor    VARCHAR2(10),
    telefono         VARCHAR2(10),
    email            VARCHAR2(200),
    direccion        VARCHAR2(200),
    cod_comuna       NUMBER(4)
);

CREATE TABLE CATEGORIA (
    id_categoria     NUMBER(3),
    nombre_categoria VARCHAR2(255)
);

CREATE TABLE MARCA (
    id_marca         NUMBER(3),
    nombre_marca     VARCHAR2(25)
);

CREATE TABLE PRODUCTO (
    id_producto      NUMBER(4),
    nombre_producto  VARCHAR2(100),
    precio_unitario  NUMBER,
    origen_nacional  CHAR(1),
    stock_minimo     NUMBER(3),
    activo           CHAR(1),
    cod_marca        NUMBER(3),
    cod_categoria    NUMBER(3),
    cod_proveedor    NUMBER(5)
);

CREATE TABLE AFP (
    id_afp           NUMBER(5) GENERATED ALWAYS AS IDENTITY 
                      (START WITH 210 INCREMENT BY 6),
    nom_afp          VARCHAR2(25)
);

CREATE TABLE SALUD (
    id_salud         NUMBER(4),
    nom_salud        VARCHAR2(40)
);

CREATE TABLE EMPLEADO (
    id_empleado        NUMBER(6),
    rut_empleado       VARCHAR2(10),
    nombre_empleado    VARCHAR2(25),
    apellido_paterno   VARCHAR2(25),
    apellido_materno   VARCHAR2(25),
    fecha_contratacion DATE,
    sueldo_base        NUMBER(10),
    bono_jefatura      NUMBER(10),
    activo             CHAR(1),
    tipo_empleado VARCHAR(25),
    cod_empleado       NUMBER(4),
    cod_salud          NUMBER(4),
    cod_afp            NUMBER(5)
);

CREATE TABLE ADMINISTRATIVO (
    id_empleado NUMBER(4)
);

CREATE TABLE VENDEDOR (
    id_empleado     NUMBER(4),
    comision_venta  NUMBER(5,2)
);

CREATE TABLE MEDIO_PAGO (
    id_mpago        NUMBER(3),
    nombre_mpago    VARCHAR2(50)
);

CREATE TABLE VENTA (
    id_venta        NUMBER(4) GENERATED ALWAYS AS IDENTITY 
                     (START WITH 5050 INCREMENT BY 3),
    fecha_venta     DATE,
    total_venta     NUMBER(10),
    cod_mpago       NUMBER(3),
    cod_empleado    NUMBER(4)
);

CREATE TABLE DETALLE_VENTA (
    cod_venta       NUMBER(4),
    cod_producto    NUMBER(4),
    cantidad        NUMBER(6)
);

----------------------------------------------------
-- FK -----
----------------------------------------------------

ALTER TABLE REGION 
ADD CONSTRAINT PK_REGION_ID_REGION 
PRIMARY KEY (id_region);

ALTER TABLE COMUNA 
ADD CONSTRAINT PK_COMUNA_ID_COMUNA
PRIMARY KEY (id_comuna);

ALTER TABLE PROVEEDOR 
ADD CONSTRAINT PK_PROVEEDOR_ID_PROVEEDOR 
PRIMARY KEY (id_proveedor);

ALTER TABLE CATEGORIA 
ADD CONSTRAINT PK_CATEGORIA_ID_CATEGORIA 
PRIMARY KEY (id_categoria);

ALTER TABLE MARCA 
ADD CONSTRAINT PK_MARCA_ID_MARCA 
PRIMARY KEY (id_marca);

ALTER TABLE PRODUCTO 
ADD CONSTRAINT PK_PRODUCTO_ID_PRODUCTO
PRIMARY KEY (id_producto);

ALTER TABLE AFP 
ADD CONSTRAINT PK_AFP_ID_AFP
PRIMARY KEY (id_afp);

ALTER TABLE SALUD 
ADD CONSTRAINT PK_SALUD_ID_SALUD 
PRIMARY KEY (id_salud);

ALTER TABLE EMPLEADO 
ADD CONSTRAINT PK_EMPLEADO_ID_EMPLEADO
PRIMARY KEY (id_empleado);

ALTER TABLE ADMINISTRATIVO 
ADD CONSTRAINT PK_ADMINISTRATIVO_ID_ADMINISTRATIVO
PRIMARY KEY (id_empleado);

ALTER TABLE VENDEDOR 
ADD CONSTRAINT PK_VENDEDOR_ID_VENDEDOR
PRIMARY KEY (id_empleado);

ALTER TABLE MEDIO_PAGO 
ADD CONSTRAINT PK_MEDIO_PAGO_ID_PAGO
PRIMARY KEY (id_mpago);

ALTER TABLE VENTA 
ADD CONSTRAINT PK_VENTA_ID_VENTA
PRIMARY KEY (id_venta);

ALTER TABLE DETALLE_VENTA 
ADD CONSTRAINT PK_DTLLE_VENT_COD_VENT_COD_PRODUCTO
PRIMARY KEY (cod_venta, cod_producto);

---------------------------------------
--FK--
---------------------------------------

ALTER TABLE COMUNA 
  ADD CONSTRAINT FK_COMUNA_COD_REGION
  FOREIGN KEY (cod_region) REFERENCES REGION (id_region);

ALTER TABLE PROVEEDOR 
  ADD CONSTRAINT FK_PROV_COD_COMUNA
  FOREIGN KEY (cod_comuna)REFERENCES COMUNA (id_comuna);

ALTER TABLE PRODUCTO 
  ADD CONSTRAINT FK_PROD_COD_MARCA 
  FOREIGN KEY (cod_marca)REFERENCES MARCA (id_marca);

ALTER TABLE PRODUCTO 
  ADD CONSTRAINT FK_PROD_COD_CATEGORÍA
  FOREIGN KEY (cod_categoria) REFERENCES CATEGORIA (id_categoria);

ALTER TABLE PRODUCTO 
  ADD CONSTRAINT FK_PROD_COD_PROV 
  FOREIGN KEY (cod_proveedor) REFERENCES PROVEEDOR (id_proveedor);

ALTER TABLE EMPLEADO 
  ADD CONSTRAINT FK_EMP_COD_SALUD 
  FOREIGN KEY (cod_salud) REFERENCES SALUD (id_salud);

ALTER TABLE EMPLEADO 
  ADD CONSTRAINT FK_EMP_COD_AFP
  FOREIGN KEY (cod_afp) REFERENCES AFP (id_afp);

ALTER TABLE EMPLEADO 
  ADD CONSTRAINT FK_EMP_COD_EMPLEADO
  FOREIGN KEY (cod_empleado)REFERENCES EMPLEADO (id_empleado);

ALTER TABLE ADMINISTRATIVO 
  ADD CONSTRAINT FK_ADMIN_ID_EMPLEADO
  FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado);

ALTER TABLE VENDEDOR 
  ADD CONSTRAINT FK_VEND_ID_EMPLEADO
  FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado);

ALTER TABLE VENTA 
  ADD CONSTRAINT FK_VENTA_COD_EMPLEADO 
  FOREIGN KEY (cod_empleado)REFERENCES EMPLEADO (id_empleado);

ALTER TABLE VENTA 
  ADD CONSTRAINT FK_VENTA_COD_MPAGO
  FOREIGN KEY (cod_mpago) REFERENCES MEDIO_PAGO (id_mpago);

ALTER TABLE DETALLE_VENTA 
  ADD CONSTRAINT FK_DETVENTA_COD_VENT
  FOREIGN KEY (cod_venta) REFERENCES VENTA (id_venta);

ALTER TABLE DETALLE_VENTA 
  ADD CONSTRAINT FK_DETVENTA_COD_PROD
  FOREIGN KEY (cod_producto) REFERENCES PRODUCTO (id_producto);
  
------------------------------------------------------------
--UK--
------------------------------------------------------------

ALTER TABLE PROVEEDOR 
  ADD CONSTRAINT UQ_PROVEEDOR_EMAIL 
  UNIQUE (email);

ALTER TABLE MARCA 
  ADD CONSTRAINT UQ_MARCA_NOM_MAR
  UNIQUE (nombre_marca);
  
---------------------------------------------------------
--CHECK CONSTRAINTS
---------------------------------------------------------

-- Sueldo mínimo
ALTER TABLE EMPLEADO 
  ADD CONSTRAINT CK_EMPLE_SUELDO_BASE 
  CHECK (sueldo_base >= 400000);

-- Comisión no + de 25%
ALTER TABLE VENDEDOR 
  ADD CONSTRAINT CK_VENDEDOR_COM_VENT
  CHECK (comision_venta BETWEEN 0 AND 0.25);

-- Stock mínimo de 3 productos
ALTER TABLE PRODUCTO 
  ADD CONSTRAINT CK_PRODUCTO_STOKK_MIN 
  CHECK (stock_minimo >= 3);

-- Detalle de venta mayor que 0
ALTER TABLE DETALLE_VENTA 
  ADD CONSTRAINT CK_CANTIDAD_POSITIVA 
  CHECK (cantidad > 0);
  
----------------------------------------------
-- POBLAMIENTO--
----------------------------------------------

-- secuencia para salud 2050 + 10
CREATE SEQUENCE seq_salud 
START WITH 2050 INCREMENT BY 10;

-- secuencia para empleado 750 + 3
CREATE SEQUENCE seq_empleado 
START WITH 750 INCREMENT BY 3;


--tabla region
INSERT INTO REGION VALUES(1,'Región Metropolitana');
INSERT INTO REGION VALUES(2, 'Valparaíso');
INSERT INTO REGION VALUES(3, 'Biobío');
INSERT INTO REGION VALUES(4, 'Los Lagos');

--tabla medio pago
INSERT INTO MEDIO_PAGO VALUES (11,'Efectivo');
INSERT INTO MEDIO_PAGO VALUES (12,'Tarjeta Débito');
INSERT INTO MEDIO_PAGO VALUES (13,'Tarjeta Crédito');
INSERT INTO MEDIO_PAGO VALUES (14,'Cheque');

--tabla afp
INSERT INTO AFP (nom_afp) VALUES ('AFP Habitat');
INSERT INTO AFP (nom_afp) VALUES ('AFP Cuprum');
INSERT INTO AFP (nom_afp) VALUES ('AFP Provida');
INSERT INTO AFP (nom_afp) VALUES ('AFP PlanVital');

--tabla salud

INSERT INTO SALUD VALUES (seq_salud.NEXTVAL, 'Fonasa');
INSERT INTO SALUD VALUES (seq_salud.NEXTVAL, 'Isapre Colmena');
INSERT INTO SALUD VALUES (seq_salud.NEXTVAL, 'Isapre Banmédica');
INSERT INTO SALUD VALUES (seq_salud.NEXTVAL, 'Isapre Cruz Blanca');




-- tabla empleado

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
VALUES (seq_empleado.NEXTVAL, '11111111-1', 'Marcela', 'Gonzalez', 'Perez', TO_DATE('15-03-2022','DD-MM-YYYY'), 950000, 8000, 'S', 'Administrativo', NULL, 2050, 210);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '22222222-2', 'José', 'Muñoz', 'Ramirez', TO_DATE('10-07-2021','DD-MM-YYYY'), 900000, 75000, 'S', 'Administrativo', NULL, 2060, 216);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '33333333-3', 'Verónica', 'Soto', 'Alarcón', TO_DATE('05-01-2020','DD-MM-YYYY'), 880000, 70000, 'S', 'Vendedor', 750, 2060, 228);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '44444444-4', 'Luis', 'Reyes', 'Fuentes', TO_DATE('01-04-2023','DD-MM-YYYY'), 560000, NULL, 'S', 'Vendedor', 750, 2070, 228);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '55555555-5', 'Claudia', 'Fernández', 'Lagos', TO_DATE('15-04-2023','DD-MM-YYYY'), 600000, NULL, 'S', 'Vendedor', 753, 2070, 216);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '66666666-6', 'Carlos', 'Navarro', 'Vega', TO_DATE('01-05-2023','DD-MM-YYYY'), 610000, NULL, 'S','Administrativo', 753, 2060, 210);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '77777777-7', 'Javiera', 'Pino', 'Rojas', TO_DATE('10-05-2023','DD-MM-YYYY'), 650000, NULL, 'S', 'Administrativo', 750, 2050, 210);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '88888888-8', 'Diego', 'Mella', 'Contreras', TO_DATE('12-05-2023','DD-MM-YYYY'), 620000, NULL,'S', 'Vendedor', 750, 2060, 216);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '99999999-9', 'Fernanda', 'Salas', 'Herrera', TO_DATE('18-05-2023','DD-MM-YYYY'), 570000, NULL, 'S', 'Vendedor', 753, 2070, 228);

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado,
    apellido_paterno, apellido_materno, fecha_contratacion,
    sueldo_base, bono_jefatura, activo, tipo_empleado,
    cod_empleado, cod_salud, cod_afp)
    VALUES (seq_empleado.NEXTVAL, '10101010-0', 'Tomás', 'Vidal', 'Espinoza', TO_DATE('01-06-2023','DD-MM-YYYY'), 530000, NULL, 'S', 'Vendedor', NULL, 2050, 222);

-- tabla venta

INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('12-05-2023','DD-MM-YYYY'), 225990, 12, 771);
INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('23-10-2023','DD-MM-YYYY'), 524990, 13, 777);
INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('17-02-2023','DD-MM-YYYY'), 466990, 11, 759);

-- tabla vendedor

INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (759, 0.05);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (765, 0.04);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (768, 0.06);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (771, 0.05);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (774, 0.05);

-- consultas

--1
SELECT 
    id_empleado AS "IDENTIFICADOR",
    nombre_empleado AS "NOMBRE",
    apellido_paterno AS "APELLIDO PATERNO",
    apellido_materno AS "APELLIDO MATERNO",
    sueldo_base AS "SALARIO",
    bono_jefatura AS "BONIFICACION",
    (sueldo_base + bono_jefatura) AS "SALARIO SIMULADO"
FROM empleado
WHERE activo = 'S'
  AND bono_jefatura IS NOT NULL
ORDER BY (sueldo_base + bono_jefatura) DESC, apellido_paterno DESC;

--2
SELECT 
    nombre_empleado AS "NOMBRE",
    apellido_paterno AS "APELLIDO PATERNO",
    apellido_materno AS "APELLIDO MATERNO",
    sueldo_base AS "SUELDO",
    ROUND(sueldo_base * 0.08, 0) AS "POSIBLE AUMENTO",
    sueldo_base + ROUND(sueldo_base * 0.08, 0) AS "SUELDO SIMULADO"
FROM EMPLEADO
WHERE sueldo_base BETWEEN 550000 AND 800000
ORDER BY sueldo_base ASC;

