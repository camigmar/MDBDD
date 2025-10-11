SHOW USER;

-- drops
DROP TABLE afp CASCADE CONSTRAINTS;

DROP TABLE asig_turno CASCADE CONSTRAINTS;

DROP TABLE comuna CASCADE CONSTRAINTS;

DROP TABLE jefe_turno CASCADE CONSTRAINTS;

DROP TABLE maquina CASCADE CONSTRAINTS;

DROP TABLE operario CASCADE CONSTRAINTS;

DROP TABLE orden_mantencion CASCADE CONSTRAINTS;

DROP TABLE personal CASCADE CONSTRAINTS;

DROP TABLE planta CASCADE CONSTRAINTS;

DROP TABLE region CASCADE CONSTRAINTS;

DROP TABLE salud CASCADE CONSTRAINTS;

DROP TABLE tecn_mantencion CASCADE CONSTRAINTS;

DROP TABLE turno CASCADE CONSTRAINTS;

DROP SEQUENCE seq_region;

-----------------------------------------
--creacion tablas--
-----------------------------------------

CREATE TABLE afp (
    id_afp  NUMBER(2) NOT NULL,
    nom_afp VARCHAR2(10) NOT NULL
);

ALTER TABLE afp ADD CONSTRAINT PK_AFP_IDAFP PRIMARY KEY ( id_afp );

CREATE TABLE asig_turno (
    cod_personal NUMBER(3) NOT NULL,
    cod_turno    NUMBER(2) NOT NULL,
    cod_maquina  NUMBER(4) NOT NULL,
    rol          VARCHAR2(20)
);

ALTER TABLE asig_turno ADD CONSTRAINT PK_ASIGTURNO_IDPERSTURN PRIMARY KEY ( cod_personal,
                                                                  cod_turno );

CREATE TABLE comuna (
    id_comuna  NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1050 INCREMENT BY 5) NOT NULL,
    nom_comuna VARCHAR2(30) NOT NULL,
    cod_region NUMBER(2) NOT NULL
);

ALTER TABLE comuna ADD CONSTRAINT PK_COMUNA_IDCOMUNA PRIMARY KEY ( id_comuna );

CREATE TABLE jefe_turno (
    id_personal      NUMBER(3) NOT NULL,
    area_responsable VARCHAR2(20) NOT NULL,
    max_operarios    NUMBER(3) NOT NULL
);

ALTER TABLE jefe_turno ADD CONSTRAINT PK_JEFETURNO_IDPERS PRIMARY KEY ( id_personal );

CREATE TABLE maquina (
    num_maquina    NUMBER(4) NOT NULL,
    nom_maquina    VARCHAR2(15) NOT NULL,
    estado_maquina CHAR(1) NOT NULL,
    tipo_maquina   VARCHAR2(20) NOT NULL,
    cod_planta     NUMBER(3) NOT NULL
);

ALTER TABLE maquina ADD CONSTRAINT PK_MAQUINA_NUMMAQUINA PRIMARY KEY ( num_maquina );

CREATE TABLE operario (
    id_personal   NUMBER(3) NOT NULL,
    cat_proceso   VARCHAR2(10) NOT NULL,
    certificacion VARCHAR2(15),
    hrs_estandar  NUMBER(2) NOT NULL
);

ALTER TABLE operario ADD CONSTRAINT PK_OPERARIO_IDPERS PRIMARY KEY ( id_personal );

CREATE TABLE orden_mantencion (
    id_mantencion NUMBER NOT NULL,
    tecnico_resp  VARCHAR2(25) NOT NULL,
    fecha_inicio  DATE NOT NULL,
    fecha_termino DATE,
    descripcion   VARCHAR2(50) NOT NULL,
    cod_maquina   NUMBER(4) NOT NULL
);

ALTER TABLE orden_mantencion ADD CONSTRAINT PK_ORDMANT_IDMANT PRIMARY KEY ( id_mantencion );

CREATE TABLE personal (
    id_personal        NUMBER(3) NOT NULL,
    rut                NUMBER(10) NOT NULL,
    nom_personal       VARCHAR2(12) NOT NULL,
    apellido_paterno   VARCHAR2(15) NOT NULL,
    apellido_materno   VARCHAR2(15) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    sueldo_base        NUMBER(7) NOT NULL,
    estado_personal    CHAR(1) NOT NULL,
    tipo_personal      VARCHAR2(25) NOT NULL,
    cod_planta         NUMBER(3) NOT NULL,
    cod_afp            NUMBER(2) NOT NULL,
    cod_salud          NUMBER(2) NOT NULL,
    cod_personal       NUMBER(3) NOT NULL
);

ALTER TABLE personal ADD CONSTRAINT PK_PERSONAL_IDPERS PRIMARY KEY ( id_personal );

CREATE TABLE planta (
    id_planta  NUMBER(3) NOT NULL,
    nom_planta VARCHAR2(30) NOT NULL,
    direccion  VARCHAR2(40) NOT NULL,
    cod_comuna NUMBER(6) NOT NULL
);

ALTER TABLE planta ADD CONSTRAINT PK_PLANTA_IDPLANTA PRIMARY KEY ( id_planta );

CREATE TABLE region (
    id_region  NUMBER(2) NOT NULL,
    nom_region VARCHAR2(30) NOT NULL
);

ALTER TABLE region ADD CONSTRAINT PK_REGION_IDREGION PRIMARY KEY ( id_region );

CREATE TABLE salud (
    id_salud  NUMBER(2) NOT NULL,
    nom_salud VARCHAR2(15) NOT NULL
);

ALTER TABLE salud ADD CONSTRAINT PK_SALUD_IDSALUD PRIMARY KEY ( id_salud );

CREATE TABLE tecn_mantencion (
    id_personal       NUMBER(3) NOT NULL,
    especialidad      VARCHAR2(20) NOT NULL,
    niv_certificacion VARCHAR2(10),
    t_resp_estandar   VARCHAR2(8) NOT NULL
);

ALTER TABLE tecn_mantencion ADD CONSTRAINT PK_TECNMANT_IDPERS PRIMARY KEY ( id_personal );

CREATE TABLE turno (
    id_turno    NUMBER(2) NOT NULL,
    nom_turno   VARCHAR2(10) NOT NULL,
    hora_inicio CHAR(5) NOT NULL,
    hora_fin    CHAR(5) NOT NULL
);

ALTER TABLE turno ADD CONSTRAINT PK_TURNO_IDTURNO PRIMARY KEY ( id_turno );

------------------------------------
--fk
------------------------------------

ALTER TABLE asig_turno
    ADD CONSTRAINT FK_ASIGTURNO_CODMAQ
    FOREIGN KEY ( cod_maquina ) REFERENCES maquina ( num_maquina );

ALTER TABLE asig_turno
    ADD CONSTRAINT FK_ASIGTURNO_CODPERSONAL
    FOREIGN KEY ( cod_personal )REFERENCES personal ( id_personal );

ALTER TABLE asig_turno
    ADD CONSTRAINT FK_ASIGTURNO_CODTURNO
    FOREIGN KEY ( cod_turno )REFERENCES turno ( id_turno );

ALTER TABLE comuna
    ADD CONSTRAINT FK_COMUNA_CODREGION
    FOREIGN KEY ( cod_region )REFERENCES region ( id_region );

ALTER TABLE jefe_turno
    ADD CONSTRAINT FK_JEFETURNO_IDPERS
    FOREIGN KEY ( id_personal )REFERENCES personal ( id_personal );

ALTER TABLE maquina
    ADD CONSTRAINT FK_MAQUINA_CODPLANTA
    FOREIGN KEY ( cod_planta )REFERENCES planta ( id_planta );

ALTER TABLE operario
    ADD CONSTRAINT FK_OPERARIO_IDPERSONAL
    FOREIGN KEY ( id_personal )REFERENCES personal ( id_personal );

ALTER TABLE orden_mantencion
    ADD CONSTRAINT FK_ORDMANT_CODMAQ
    FOREIGN KEY ( cod_maquina )REFERENCES maquina ( num_maquina );

ALTER TABLE personal 
    ADD CONSTRAINT FK_PERSONAL_CODAFP
    FOREIGN KEY ( cod_afp )REFERENCES afp ( id_afp );

ALTER TABLE personal
    ADD CONSTRAINT FK_PERSONAL_CODPERS 
    FOREIGN KEY ( cod_personal )REFERENCES personal ( id_personal );

ALTER TABLE personal
    ADD CONSTRAINT FK_PERSONAL_CODPLANTA 
    FOREIGN KEY ( cod_planta )REFERENCES planta ( id_planta );

ALTER TABLE personal
    ADD CONSTRAINT FK_PERSONAL_CODSALUD 
    FOREIGN KEY ( cod_salud ) REFERENCES salud ( id_salud );

ALTER TABLE planta
    ADD CONSTRAINT FK_PLANTA_CODCOMUNA FOREIGN KEY ( cod_comuna )
        REFERENCES comuna ( id_comuna );

ALTER TABLE tecn_mantencion
    ADD CONSTRAINT FK_TECNMANT_IDPERSONAL FOREIGN KEY ( id_personal )
        REFERENCES personal ( id_personal );
        
        
-------------------------------------
--u
------------------------------------

ALTER TABLE region 
ADD CONSTRAINT UK_REGION_NOMREGION
UNIQUE (nom_region);

ALTER TABLE salud 
ADD CONSTRAINT UK_SALUD_NOMSALUD
UNIQUE (nom_salud);

ALTER TABLE afp 
ADD CONSTRAINT UK_AFP_NOMAFP
UNIQUE (nom_afp);

ALTER TABLE turno 
ADD CONSTRAINT UK_TURNO_NOMTURNO
UNIQUE (nom_turno);

ALTER TABLE maquina 
ADD CONSTRAINT UK_MAQUINA_NOMMAQUINA
UNIQUE (tipo_maquina);
        
-- secuencia
CREATE SEQUENCE seq_region 
START WITH 21 INCREMENT BY 1;

-------------------------------------------
--CK
--------------------------------------------

ALTER TABLE orden_mantencion 
ADD CONSTRAINT CK_ORDMANT_FECHATERM
CHECK (fecha_termino IS NULL OR fecha_termino >= fecha_inicio);

---------------------------------------
-- poblamiento
----------------------------------------

-- REGIÓN
INSERT INTO region VALUES (seq_region.NEXTVAL, 'Región de Valparaíso');
INSERT INTO region VALUES (seq_region.NEXTVAL, 'Región Metropolitana');

-- COMUNA
INSERT INTO comuna (nom_comuna, cod_region) VALUES ('Quilpué', 21);
INSERT INTO comuna (nom_comuna, cod_region) VALUES ('Maipú', 22);

-- PLANTA
INSERT INTO planta (id_planta, nom_planta, direccion, cod_comuna)
VALUES (45, 'Planta Oriente', 'Camino Industrial 1234', 1050);

INSERT INTO planta (id_planta, nom_planta, direccion, cod_comuna)
VALUES (46, 'Planta Costa', 'Av. Vidrieras 890', 1055);

-- TURNO
INSERT INTO turno (id_turno, nom_turno, hora_inicio, hora_fin)
VALUES (1, 'Mañana', '07:00', '15:00');

INSERT INTO turno (id_turno, nom_turno, hora_inicio, hora_fin)
VALUES (2, 'Tarde', '15:00', '23:00');

INSERT INTO turno (id_turno, nom_turno, hora_inicio, hora_fin)
VALUES (3, 'Noche', '23:00', '07:00');

-------------------------------------------
-- informes
-----------------------------------------------

-- informe 1
SELECT 
    id_turno AS "CÓDIGO TURNO",
    nom_turno AS "NOMBRE TURNO",
    hora_inicio AS "ENTRADA",
    hora_fin AS "SALIDA"
FROM turno
WHERE TO_DATE(hora_inicio, 'HH24:MI') > TO_DATE('20:00', 'HH24:MI')
ORDER BY TO_DATE(hora_inicio, 'HH24:MI') DESC;

-- informe 2
SELECT 
    id_turno AS "CÓDIGO TURNO",
    nom_turno AS "NOMBRE TURNO",
    hora_inicio AS "ENTRADA",
    hora_fin AS "SALIDA"
FROM turno
WHERE TO_DATE(hora_inicio, 'HH24:MI') 
      BETWEEN TO_DATE('06:00', 'HH24:MI') AND TO_DATE('14:59', 'HH24:MI')
ORDER BY TO_DATE(hora_inicio, 'HH24:MI') ASC;
