CREATE DATABASE PLANILLA
--DROP DATABASE PLANILLA
GO
USE PLANILLA
GO



--                                          CREAR LAS TABLAS QUE VAN A CONFORMAR LA BASE DE DATOS


-- 1 TABLA PUESTOS
CREATE TABLE PUESTOS(
	COD_PUESTO INT PRIMARY KEY IDENTITY(1,1),
	NOMBRE_PUESTO VARCHAR(40) NOT NULL,
	CATEGORIA INT NOT NULL,
	SALARIO DECIMAL(10,2) NOT NULL,
	BORRADO BIT NOT NULL 
)

ALTER TABLE PUESTOS ADD CONSTRAINT DF_BORRADO_PUESTO DEFAULT 0 FOR BORRADO
ALTER TABLE PUESTOS ADD CONSTRAINT CHK_CATEGORIA CHECK(CATEGORIA IN(1,2))

-- 2 TABLA EMPLEADOS 
CREATE TABLE EMPLEADOS(
	ID_EMPLEADO INT PRIMARY KEY IDENTITY(1,1),
	NOMBRE VARCHAR(30) NOT NULL,
	APELLIDO_1 VARCHAR(30) NOT NULL,
	APELLIDO_2 VARCHAR(30),
	TELEFONO VARCHAR(8) NOT NULL,
	CORREO VARCHAR(40),
	COD_PUESTO INT NOT NULL,
	COLEGIATURA BIT NOT NULL,
	FECHA_INICIO DATE NOT NULL,
	BORRADO BIT NOT NULL
)

ALTER TABLE EMPLEADOS ADD CONSTRAINT DF_BORRADO_EMPLEADO DEFAULT 0 FOR BORRADO
ALTER TABLE EMPLEADOS ADD CONSTRAINT DF_COLEGIATURA DEFAULT 0 FOR COLEGIATURA --COLEGIATURA POR DEFECTO 0 NOTIENE COLEGIATURA
ALTER TABLE EMPLEADOS ADD CONSTRAINT CHK_COLEGIATURA CHECK( COLEGIATURA IN (0,1)) -- SOLO PERMITE 1 Y 0
ALTER TABLE EMPLEADOS ADD CONSTRAINT FK_PUESTO_EMPLEADO FOREIGN KEY (COD_PUESTO) REFERENCES PUESTOS(COD_PUESTO) --LLAVE FORANEA



-- 3 TABLA TITULOS

CREATE TABLE TITULOS(
	COD_TITULO INT PRIMARY KEY IDENTITY(1,1),
	NOMBRE_TITULO VARCHAR(50) NOT NULL,
	INSTITUCION VARCHAR(50) NOT NULL
)


-- 4 EMPLEADOS TITULOS
CREATE TABLE EMPLEADO_TITULOS(
	COD_TITULO INT NOT NULL,
	ID_EMPLEADO INT NOT NULL
)

ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT PK_EMPLEADOS_TITULOS PRIMARY KEY(COD_TITULO,ID_EMPLEADO) -- LLAVE COMPUESTA
ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT FK_EMPLEADO_TITULOS_TITULOS FOREIGN KEY (COD_TITULO) REFERENCES TITULOS(COD_TITULO) --LLAVE FORANEA
ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT FK_EMPLEADO_TITULOS_EMPLEADOS FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) --LLAVE FORANEA


-- 5 TABLA INCAPACIDADES
CREATE TABLE INCAPACIDADES(
	COD_INCAPACIDAD INT PRIMARY KEY IDENTITY(1,1),
	ID_EMPLEADO INT NOT NULL,
	MOTIVO VARCHAR(100) NOT NULL,
	FECHA_INICIO DATE NOT NULL,
	FECHA_FIN DATE NOT NULL
)

ALTER TABLE INCAPACIDADES ADD CONSTRAINT FK_INCAPACIDADES_EMPLEADOS FOREIGN KEY(ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) -- LLAVE FORANEA
ALTER TABLE INCAPACIDADES ADD CONSTRAINT CHK_FECHAS_INCAPACIDAD CHECK(FECHA_FIN>=FECHA_INICIO)-- CONTROL DE FECHAS 

-- 6 TABLA PENSIONES
CREATE TABLE PENSIONES(
	COD_PENSION INT PRIMARY KEY IDENTITY(1,1),
	ID_EMPLEADO INT NOT NULL,
	MONTO DECIMAL(10,2) NOT NULL,
	FECHA_RIGE DATE NOT NULL,
	BORRADO BIT NOT NULL
)

ALTER TABLE PENSIONES ADD CONSTRAINT FK_PENSIONES_EMPLEADOS FOREIGN KEY(ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) -- LLAVE FORANEA
ALTER TABLE PENSIONES ADD CONSTRAINT DF_BORRADO_PENSIONES DEFAULT 0 FOR BORRADO


-- 7 TABLA PRESTAMOS
CREATE TABLE PRESTAMOS(
	COD_PRESTAMO INT PRIMARY KEY IDENTITY(1,1),
	ID_EMPLEADO INT NOT NULL,
	MONTO_PRESTAMO DECIMAL(10,2) NOT NULL,
	CUOTA_MENSUAL DECIMAL(6,2) NOT NULL,
	FECHA_PAGO DATE NOT NULL,
	FINANCIERA VARCHAR(50) NOT NULL,
	CANCELADO BIT NOT NULL

)

ALTER TABLE PRESTAMOS ADD CONSTRAINT FK_PRESTAMOS_EMPLEADOS FOREIGN KEY(ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) -- LLAVE FORANEA
ALTER TABLE PRESTAMOS ADD CONSTRAINT DF_CANCELADO_PRESTAMO DEFAULT 0 FOR CANCELADO

-- 8 TABLA PLANILLA
CREATE TABLE PLANILLAS(
	COD_PLANILLA INT PRIMARY KEY IDENTITY(1,1),
	ANNIO INT NOT NULL,
	MES VARCHAR(10) NOT NULL
)

ALTER TABLE PLANILLAS ADD CONSTRAINT CHK_ANNIO CHECK(ANNIO=YEAR(GETDATE()))-- OBTIENE EL A�O ACTUAL
ALTER TABLE PLANILLAS ADD CONSTRAINT CHK_MES CHECK(MES IN('Enero',
														 'Febrero',
														 'Marzo',
														 'Abril',
														 'Mayo',
														 'Junio',
														 'Julio',
														 'Agosto',
														 'Septiembre',
														 'Obtubre',
														 'Noviembre',
														 'Diciembre'
														 ))

-- 9 TABLA DESGLOSE PLANILLA
CREATE TABLE DESGLOSE_PLANILLA(
	COD_PLANILLA INT NOT NULL,
	ID_EMPLEADO INT NOT NULL,
	TOTAL DECIMAL(10,2) NOT NULL
)

ALTER TABLE DESGLOSE_PLANILLA ADD CONSTRAINT PK_DESGLOSE_PLANILLA PRIMARY KEY(COD_PLANILLA,ID_EMPLEADO) -- LLAVE COMPUESTA

-- 10 TABLA DEDUCCIONES
CREATE TABLE DEDUCCIONES(
	COD_DEDUCCION INT PRIMARY KEY IDENTITY(1,1),
	COD_PLANILLA INT NOT NULL,
	DED_PENSION DECIMAL(7,2),
	DED_BANCOPOPULAR DECIMAL(7,2),
	DED_POLIZA DECIMAL(7,2),
	DED_RENTA DECIMAL(7,2),
	DED_COLEGIATURA DECIMAL(7,2),
	DED_PRESTAMO DECIMAL(7,2)
)

ALTER TABLE DEDUCCIONES ADD CONSTRAINT FK_DEDUCCIONES_PLANILLA FOREIGN KEY(COD_PLANILLA)REFERENCES PLANILLAS(COD_PLANILLA)


-- 11 PAGOS 
CREATE TABLE PAGOS(
	COD_PAGO INT PRIMARY KEY IDENTITY(1,1),
	COD_PLANILLA INT NOT NULL,
	PAG_ANUALIDAD DECIMAL(7,2),
	PAG_ESCALAFON DECIMAL(7,2),
	PAG_EXCLUSIVIDAD DECIMAL(7,2)
)

ALTER TABLE PAGOS ADD CONSTRAINT FK_PAGOS_PLANILLA FOREIGN KEY(COD_PLANILLA)REFERENCES PLANILLAS(COD_PLANILLA)