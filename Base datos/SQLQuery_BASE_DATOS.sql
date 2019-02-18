CREATE DATABASE PLANILLA_DB

GO
USE PLANILLA_DB
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
	ID_EMPLEADO VARCHAR(15) PRIMARY KEY,
	NOMBRE VARCHAR(30) NOT NULL,
	APELLIDO_1 VARCHAR(30) NOT NULL,
	APELLIDO_2 VARCHAR(30),
	TELEFONO VARCHAR(8) NOT NULL,
	CORREO VARCHAR(40),
	COD_PUESTO INT NOT NULL,
	FECHA_INICIO DATE NOT NULL,
	GRADO_ACADEMICO VARCHAR(12) NOT NULL,
	BORRADO BIT NOT NULL
)

ALTER TABLE EMPLEADOS ADD CONSTRAINT CHK_GRADO_ACADEMICO CHECK(GRADO_ACADEMICO IN('Diplomado',
																				  'Técnico',
																				  'Bachillerato',
																				  'Licenciatura',
																				  'Maestría',
																				  'Doctorado'))
ALTER TABLE EMPLEADOS ADD CONSTRAINT DF_BORRADO_EMPLEADO DEFAULT 0 FOR BORRADO
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
	ID_EMPLEADO VARCHAR(15) NOT NULL
)

ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT PK_EMPLEADOS_TITULOS PRIMARY KEY(COD_TITULO,ID_EMPLEADO) -- LLAVE COMPUESTA
ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT FK_EMPLEADO_TITULOS_TITULOS FOREIGN KEY (COD_TITULO) REFERENCES TITULOS(COD_TITULO) --LLAVE FORANEA
ALTER TABLE EMPLEADO_TITULOS ADD CONSTRAINT FK_EMPLEADO_TITULOS_EMPLEADOS FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) --LLAVE FORANEA



-- 6 TABLA PENSIONES
CREATE TABLE PENSIONES(
	COD_PENSION INT PRIMARY KEY IDENTITY(1,1),
	ID_EMPLEADO VARCHAR(15) NOT NULL,
	MONTO DECIMAL(10,2) NOT NULL,
	FECHA_RIGE DATE NOT NULL,
	BORRADO BIT NOT NULL
)

ALTER TABLE PENSIONES ADD CONSTRAINT FK_PENSIONES_EMPLEADOS FOREIGN KEY(ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) -- LLAVE FORANEA
ALTER TABLE PENSIONES ADD CONSTRAINT DF_BORRADO_PENSIONES DEFAULT 0 FOR BORRADO


-- 7 TABLA PRESTAMOS
CREATE TABLE PRESTAMOS(
	COD_PRESTAMO INT PRIMARY KEY IDENTITY(1,1),
	ID_EMPLEADO VARCHAR(15) NOT NULL,
	MONTO_PRESTAMO DECIMAL(10,2) NOT NULL,
	CUOTA_MENSUAL DECIMAL(10,2) NOT NULL,
	FECHA_RIGE DATE NOT NULL,
	CANCELADO BIT NOT NULL

)

ALTER TABLE PRESTAMOS ADD CONSTRAINT FK_PRESTAMOS_EMPLEADOS FOREIGN KEY(ID_EMPLEADO) REFERENCES EMPLEADOS(ID_EMPLEADO) -- LLAVE FORANEA
ALTER TABLE PRESTAMOS ADD CONSTRAINT DF_CANCELADO_PRESTAMO DEFAULT 0 FOR CANCELADO

-- 8 TABLA PLANILLA
CREATE TABLE PLANILLAS(
	COD_PLANILLA INT PRIMARY KEY IDENTITY(1,1),
	ANNIO INT NOT NULL,
	MES VARCHAR(10) NOT NULL,
	FECHA_CREADA DATE NOT NULL DEFAULT GETDATE()
)

ALTER TABLE PLANILLAS ADD CONSTRAINT CHK_ANNIO CHECK(ANNIO=YEAR(GETDATE()))-- OBTIENE EL AÑO ACTUAL
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
	COD_DESGLOSE INT PRIMARY KEY IDENTITY(1,1),
	COD_PLANILLA INT NOT NULL,
	ID_EMPLEADO VARCHAR(15) NOT NULL,
	SALARIO_BRUTO DECIMAL(10,2),
	SALARIO_NETO DECIMAL(10,2),
	QUINCENA_1 DECIMAL(10,2),
	QUINCENA_2 DECIMAL(10,2)
	
		
)

ALTER TABLE DESGLOSE_PLANILLA ADD CONSTRAINT FK_PK_DESGLOSE_PLANILLA_PLANILLA FOREIGN KEY(COD_PLANILLA)REFERENCES PLANILLAS(COD_PLANILLA)
ALTER TABLE DESGLOSE_PLANILLA ADD CONSTRAINT FK_PK_DESGLOSE_PLANILLA_EMPLEADO FOREIGN KEY(ID_EMPLEADO)REFERENCES EMPLEADOS(ID_EMPLEADO)


CREATE TABLE DETALLE_DESGLOSES(
	COD_DETALLE INT PRIMARY KEY IDENTITY(1,1),
	COD_DESGLOSE INT NOT NULL,
	DESCRIPCION VARCHAR(200),
	MONTO DECIMAL(10,2))

ALTER TABLE DETALLE_DESGLOSES ADD CONSTRAINT FK_DETALLE_DESGLOSE_DESGLOSE_PLANILLA FOREIGN KEY(COD_DESGLOSE)REFERENCES DESGLOSE_PLANILLA(COD_DESGLOSE)


CREATE TABLE DEDUCCIONES_PLUSES(
						 CODIGO_DEDUCCION_PLUSES INT PRIMARY KEY IDENTITY(1,1),
						 NOMBRE VARCHAR(200)NOT NULL,
						 TIPO VARCHAR(9)NOT NULL,
						 MODO VARCHAR(10) NOT NULL,
						 PORCENTAJE DECIMAL(3,2),
					     MONTO DECIMAL(10,2),
						 BORRADO BIT DEFAULT 0
						 )

ALTER TABLE DEDUCCIONES_PLUSES ADD CONSTRAINT CHK_TIPO CHECK(TIPO IN('DEDUCCION','PLUSES'))
ALTER TABLE DEDUCCIONES_PLUSES ADD CONSTRAINT CHK_MODO CHECK(MODO IN('PORCENTAJE','MONTO FIJO'))

CREATE TABLE TOPES(COD INT PRIMARY KEY IDENTITY(1,1),
					DESCRIPCION VARCHAR(30) NOT NULL,
					MONTO_TOPE DECIMAL(10,2))




--llenar tablas

INSERT INTO TOPES(DESCRIPCION,MONTO_TOPE) VALUES('PRIMER TOPE RENTA',792000),('SEGUNDO TOPE RENTA',1188000)


INSERT DEDUCCIONES_PLUSES(NOMBRE,TIPO,MODO,PORCENTAJE,MONTO)VALUES('Pago Anualidad','pluses','Porcentaje',0.02,0),
																  ('Pago Escalafon puestos categoria 1','pluses','Porcentaje',0.03,0),
																  ('Pago Escalafon puestos categoria 2','pluses','Porcentaje',0.01,0),
																  ('Pago Exclusividad','pluses','Porcentaje',0.3,0),
																  ('Deducción Magisterio','Deduccion','Porcentaje',0.08,0),
																  ('Deducción Banco Popular','Deduccion','Porcentaje',0.01,0),
																  ('Deducción CCSS','Deduccion','Porcentaje',0.03,0),
																  ('Deducción Póliza de vida','Deduccion','Monto fijo',0,13450),
																  ('Deducción Renta Primer Tope','Deduccion','Porcentaje',0.1,0),
																  ('Deducción Renta Segundo Tope','Deduccion','Porcentaje',0.15,0),
																  ('Deducción Colegiatura','Deduccion','Monto fijo',0,5000)






INSERT INTO PUESTOS(NOMBRE_PUESTO,CATEGORIA,SALARIO )VALUES('Personal de Apoyo',1,250000),
															('Administrativo 1',1,320000),
															('Técnico especializado',1,415000),
															('Administrativo 2',2,500000),
															('Profesional de Apoyo',2,580000),
															('Docente Licenciado',2,620000),
															('Docente Master',2,750000),
															('Jefe 1',2,800000),
															('Jefe 2',2,950000),
															('Director',2,1500000)



INSERT INTO EMPLEADOS(ID_EMPLEADO,
					  NOMBRE,
					  APELLIDO_1,
					  APELLIDO_2,
					  TELEFONO,
					  CORREO,
					  COD_PUESTO,
					  FECHA_INICIO,
					  GRADO_ACADEMICO)
				VALUES('000000','Marielos','guzman','loria','25649877','mguzman@gmail.com',1,'2015-1-23','Diplomado'),
					  ('111111','Luis','Campos','Marín','27540071','lgampos@gmail.com',2,'2016-3-4','Técnico'),
					  ('222222','Luz','Arias','Arias','89756422','larias@gmail.com',1,'2017-1-23','Técnico'),
					  ('333333','Javier','Chavez','Rodriguez','88969887','jChavez@gmail.com',4,'2018-1-12','Bachillerato'),
					  ('444444','Silvia','Araya','Campos','88754899','saraya@gmail.com',5,'2015-1-23','Bachillerato'),
					  ('555555','Maria Elena','Campos','Alpizar','88965746','mecampos@gmail.com',6,'2017-10-13','Maestría'),
                      ('666666','Marielos','loaisa','gomez','23508912','mloaisa@gmail.com',2,'2018-4-2','Diplomado'),
					  ('777777','Daniel','guzman','Porras','56897214','dguzman@gmail.com',7,'2016-11-23','Maestría'),
					  ('888888','Juan','Campos','Campos','88999872','jcampos@gmail.com',10,'2015-10-13','Doctorado'),
					  ('999999','Juan Campos Alpizar','guzman','loria','25649877','mguzman@gmail.com',8,'2015-1-23','Bachillerato')
					   
					  
					  
INSERT INTO PENSIONES(ID_EMPLEADO,
					  MONTO,
					  FECHA_RIGE)
				VALUES('000000',85000,'2019-01-01'),
					  ('444444',100000,'2019-01-12'),
					  ('888888',150000,'2019-01-25'),
					  ('888888',150000,'2019-01-25'),
					  ('111111',150000,'2019-01-16')     
					  
					  
INSERT INTO PRESTAMOS(ID_EMPLEADO,
					  MONTO_PRESTAMO,
					  CUOTA_MENSUAL,
					  FECHA_RIGE)
				VALUES('000000',8000000,82000,'2019-01-22'),
					  ('000000',600000,62000,'2019-01-11'),
					  ('111111',1000000,17000,'2019-01-01'),
					  ('888888',1500000,25000,'2019-01-10')	








/*************************************************************************************************************************************************
                                                           FUNCIONES  
														           
**************************************************************************************************************************************************/



/*FUNSION PARA CALCULAR ANUALIDAD*/
GO
	CREATE FUNCTION FN_CALCULAR_ANUALIDAD(@Id_empleado VARCHAR(15),@Porcentaje DECIMAL(3,2),@Salario DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
	DECLARE @F_inicio date,
			@Anios INT,
			@Anualidad DECIMAL(10,2)
			
	
		--Capturo La fecha de inicio
		SELECT @F_inicio=EMPLEADOS.FECHA_INICIO FROM EMPLEADOS INNER JOIN
											 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
									    WHERE ID_EMPLEADO=@Id_empleado	

		-- se calcula cuantos años de laborar tiene el empleado
		SET @Anios=(DATEDIFF(DAY,@F_inicio,GETDATE())+1)/365
		
		IF(@Anios>0)
			BEGIN
				-- SE OBTIENE EL PORCENTAJE DE LA ANUALIDAD
				

				SET @Anualidad=@Salario*@Porcentaje*@Anios
		END	
		ELSE
			BEGIN
				SET @Anualidad=0						
		END				
		RETURN @Anualidad
	END
	
GO

-- LLAMAR FUNCION
--SELECT dbo.FN_CALCULAR_ANUALIDAD('666666') AS ANUALIDAD




/*FUNSION PARA CALCULAR ESCALAFON*/
GO
	CREATE FUNCTION FN_CALCULAR_ESCALAFON(@Id_empleado VARCHAR(15),@Porcentaje DECIMAL(3,2),@Salario DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE 
		@Escalafon DECIMAL(10,2),
		@Anios INT,
		@F_inicio date
		--Se obtiene el sueldo,categoria y fecha de inicio
		SELECT  @F_inicio=EMPLEADOS.FECHA_INICIO FROM EMPLEADOS INNER JOIN
													 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
											    WHERE ID_EMPLEADO=@Id_empleado

		-- se calcula cuantos años de laborar tiene el empleado
		SET @Anios=(DATEDIFF(DAY,@F_inicio,GETDATE())+1)/365
		IF(@Anios>0)
			BEGIN
				SET @Escalafon= @Salario*@Porcentaje*@Anios		
		END
		ELSE
			BEGIN
				SET @Escalafon=0
		END

		RETURN @Escalafon
	END
GO


--SELECT dbo.FN_CALCULAR_ESCALAFON('666666') as ESCALAFON






/*FUNSION PARA CALCULAR EXCLUSIVIDAD*/
GO
	CREATE FUNCTION FN_CALCULAR_EXCLUSIVIDAD(@Id_empleado VARCHAR(15),@Porcentaje DECIMAL(3,2),@Salario DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE 
		@Exclusividad DECIMAL(10,2)
			SET @Exclusividad= @Salario*@Porcentaje
		
		RETURN @Exclusividad
	END
	
GO


--select dbo.FN_CALCULAR_EXCLUSIVIDAD('888888')as exclusividad




-- DEDUCCION MAGISTERIO

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_MAGISTERIO(@Id_Empl VARCHAR(15),@Porcent DECIMAL(10,2),@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_Magisterio DECIMAL(10,2)

		SET @Ded_Magisterio=@Salario_bruto*@Porcent

		RETURN @Ded_Magisterio
	END
GO


-- DEDUCCION BANCO POPULAR

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_BANCOPOPULAR(@Salario_bruto DECIMAL(10,2),@Porcent decimal(3,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_BP DECIMAL(10,2)

			SET @Ded_BP=@Salario_bruto*@Porcent
		RETURN @Ded_BP
	END
GO




-- DEDUCCION CCSS

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_CCSS(@Porcent DECIMAL(3,2),@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_CCSS DECIMAL(10,2)
		
			SET @Ded_CCSS=@Salario_bruto*@Porcent
		RETURN @Ded_CCSS
	END
GO


--Obtener monto de deduccion poliza

GO
	CREATE FUNCTION FN_OBTENER_MONTO_DEDUCCION_POLIZA()
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @MontoPoliza DECIMAL(10,2)
		SELECT @MontoPoliza=MONTO FROM DEDUCCIONES_PLUSES  WHERE CODIGO_DEDUCCION_PLUSES=8
		RETURN @MontoPoliza
	END


GO

--obtener monto Colegiatura
GO
	CREATE FUNCTION FN_OBTENER_MONTO_COLEGIATURA()
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @MontoColegiatura DECIMAL(10,2)
		SELECT @MontoColegiatura=MONTO FROM DEDUCCIONES_PLUSES  WHERE CODIGO_DEDUCCION_PLUSES=11
		RETURN @MontoColegiatura
	END


GO



--deduccion renta

-- CALCULO DEDUCCION RENTA

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_RENTA(@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_RENTA DECIMAL(10,2),
				@PrimerTope DECIMAL(10,2),
				@SegundoTope DECIMAL(10,2),
				@Tope_sin_D DECIMAL(10,2),-- OBTIENE EL MONTO DEL SALARIO SIN DEDUCCION QUE ESTA EN LA BASE DE DATOS
				@Tope_Con_D DECIMAL(10,2),-- OBTIENE EL MONTO DEL SALARIO CON DEDUCCION QUE ESTA REGISTRADO EN LA BD
				@Porc_Ded_RentaIntermedia DECIMAL(4,2),
				@Porc_Ded_RentaMayor DECIMAL(4,2)


		SELECT @Porc_Ded_RentaIntermedia=PORCENTAJE FROM DEDUCCIONES_PLUSES WHERE CODIGO_DEDUCCION_PLUSES=9
		SELECT @Porc_Ded_RentaMayor=PORCENTAJE FROM DEDUCCIONES_PLUSES WHERE CODIGO_DEDUCCION_PLUSES=10
		SELECT @Tope_sin_D=MONTO_TOPE FROM TOPES WHERE COD=1
		SELECT @Tope_Con_D=MONTO_TOPE FROM TOPES WHERE COD=2
 
		IF(@Salario_bruto<=@Tope_sin_D)
		BEGIN 
			SET @Ded_RENTA=0
		END
		ELSE IF(@Salario_bruto>@Tope_sin_D AND @Salario_bruto<@Tope_Con_D)
			BEGIN
			--se obtiene el primer tope
			SET @PrimerTope=@Salario_bruto-@Tope_sin_D
			SET @Ded_RENTA=@PrimerTope*@Porc_Ded_RentaIntermedia
		END
		ELSE
			BEGIN
				--se obtiene el primer tope
				SET @PrimerTope=@Tope_Con_D-@Tope_sin_D
				--se obtiene el segundo tope
				SET @SegundoTope=@Salario_bruto-@Tope_Con_D
				SET @Ded_RENTA=(@PrimerTope*@Porc_Ded_RentaIntermedia)+(@SegundoTope*@Porc_Ded_RentaMayor)
		END
			
		RETURN @Ded_RENTA
	END
GO

--SELECT dbo.FN_CALCULAR_DEDUCCION_RENTA(1500000)AS RENTA








/*****************************************************************************************************************************

                                                           PROCESOS ALMACENADOS



******************************************************************************************************************************/

--TABLA DEDUCCIONES_PLUSES
/*
							GUARDAR Y ACTUALIZAR LAS DEDUCCIONES O PLUSES


RESIVE COMO PARAMETROS
				@Cod ------------------- CODIGO DEL REGISTRO QUE QUIERO GUARDAR O MODIFICAR
				@Nombre ---------------- NOMBRE DE LA DEDUCCION
				@Monto ----------------- MONTO FIJO
				@Porcentaje ------------ PORCENTAJE
				@Tipo ------------------ DEDUCCION O PLUSE
				@Modo  ----------------- MONTO FIJO O PORCENTAJE
				@Msj VARCHAR(100) ------ RETORNA MENSAJE

				


*/

GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_DEDUCCIONES_PLUSES(@Cod INT OUT,
															  @Nombre VARCHAR(30),
															  @Monto DECIMAL(10,2),
															  @Porcentaje DECIMAL(3,2),
															  @Tipo VARCHAR(9),
															  @Modo VARCHAR(10),
													          @Msj VARCHAR(100) OUT
													           )
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM DEDUCCIONES_PLUSES WHERE CODIGO_DEDUCCION_PLUSES=@Cod))
			BEGIN 
				UPDATE DEDUCCIONES_PLUSES 
				SET NOMBRE=@Nombre,
					MODO=@Modo,
					TIPO=@Tipo
					WHERE CODIGO_DEDUCCION_PLUSES=@Cod
					IF(@Modo='PORCENTAJE')
						BEGIN
						UPDATE DEDUCCIONES_PLUSES
						SET MONTO=NULL,
							PORCENTAJE=@Porcentaje
						WHERE CODIGO_DEDUCCION_PLUSES=@Cod
					END
					ELSE
						BEGIN
							UPDATE DEDUCCIONES_PLUSES
								SET MONTO=@Monto,
								PORCENTAJE=NULL
							WHERE CODIGO_DEDUCCION_PLUSES=@Cod
					END
					SET @Msj='El registro se actualizo con exito'
			END
			--no existe el registro
			ELSE
				BEGIN
					
					INSERT INTO DEDUCCIONES_PLUSES(NOMBRE,TIPO,PORCENTAJE,MONTO,MODO)
					VALUES(@Nombre,@Tipo,@Porcentaje,@Monto,@Modo)
					SELECT @Cod=IDENT_CURRENT('DEDUCCIONES_PLUSES')
					SET @Msj='El registro se guardó exitosamente '
			END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
			SET @Msj=ERROR_MESSAGE()
	END CATCH
GO



--TABLA DEDUCCIONES_PLUSES
/*
							ELIMINAR DEDUCCIONES O PLUSES


RESIVE COMO PARAMETROS
				@Cod ------------------- CODIGO DEL REGISTRO QUE QUIERO ELIMINAR
				@Msj VARCHAR(100) ------ RETORNA MENSAJE


*/
GO
	CREATE PROCEDURE SP_ELIMINAR_DEDUCCIONES_PLUSES(@Cod INT ,@Msj VARCHAR(100)OUT)
	AS 
	BEGIN TRY
		IF(EXISTS(SELECT 1 FROM DEDUCCIONES_PLUSES WHERE CODIGO_DEDUCCION_PLUSES=@Cod))
		BEGIN 
			IF(EXISTS(SELECT 1 FROM DEDUCCIONES_PLUSES WHERE CODIGO_DEDUCCION_PLUSES=@Cod AND BORRADO=0))
			BEGIN

				UPDATE DEDUCCIONES_PLUSES
					SET BORRADO=0
					WHERE CODIGO_DEDUCCION_PLUSES=@Cod
					SET @Msj='El registro se borro exitosamente'
			END
			ELSE
				BEGIN 
				SET @Msj='La deduccion no esta registrada'
			END

		END
		ELSE
			BEGIN
				SET @Msj='El registro no existe'
		END
	END TRY
	BEGIN CATCH
		SET @Msj=ERROR_MESSAGE()
	END CATCH

GO






--TABLA EMPLEADOS
/*
							GUARDAR Y ACTUALIZAR LOS EMPLEADOS


RESIVE COMO PARAMETROS
				@Id_Empleado VARCHAR(15) OUT -- CODIGO DEL EMPLEADO
				@Nombre VARCHAR(30) ----------- NOMBRE DEL EMPLEADO 
				@Apellido_1 VARCHAR(30) ------- PRIMER APELLIDO
				@Apellido_2 VARCHAR(30) ------- SEGUNDO APELLIDO
				@Telefono VARCHAR(8) ---------- TELÉFONO
				@correo VARCHAR(40) ----------- EMAIL
				@Cod_puesto INT --------------- CODIGO DEL PUESTO QUE SE LE VA A ASIGNAR
				@Grado_Academico VARCHAR(12) -- GRADO ACADEMICO QUE TIENE EL EMPLEADO
				@Fecha_inicio DATE ------------ FECHA EN QUE INICIO A TRABAJAR
				@Msj VARCHAR(100) OUT --------- RETORNA MENSAJE


*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_EMPLEADO(@Id_Empleado VARCHAR(15) OUT,
													@Nombre VARCHAR(30),
													@Apellido_1 VARCHAR(30),
													@Apellido_2 VARCHAR(30),
													@Telefono VARCHAR(8),
													@correo VARCHAR(40),
													@Cod_puesto INT,
													@Grado_Academico VARCHAR(12),
													@Fecha_inicio DATE,
													@Msj VARCHAR(100) OUT
												   )
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM EMPLEADOS WHERE ID_EMPLEADO= @Id_Empleado))
			BEGIN
				UPDATE EMPLEADOS 
				SET NOMBRE=@Nombre,
					APELLIDO_1=@Apellido_1,
					APELLIDO_2=@Apellido_2,
					TELEFONO=@Telefono,
					CORREO=@correo,
					COD_PUESTO=@Cod_puesto,
					GRADO_ACADEMICO=@Grado_Academico,
					FECHA_INICIO=@Fecha_inicio
				WHERE ID_EMPLEADO=@Id_Empleado	
				SET @Msj='El empleado se actualizo exitosamente'
			END
			ELSE
				BEGIN
				INSERT INTO EMPLEADOS(ID_EMPLEADO,
									  NOMBRE,
									  APELLIDO_1,
									  APELLIDO_2,
									  TELEFONO,
									  CORREO,
									  COD_PUESTO,
									  GRADO_ACADEMICO,
									  FECHA_INICIO)VALUES(@Id_Empleado,
														  @Nombre,
														  @Apellido_1,
														  @Apellido_2,
														  @Telefono,
														  @correo,
														  @Cod_puesto,
														  @Grado_Academico,
														  @Fecha_inicio)
								SET @Msj='El empleado se agrego exitosamente'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO -- FIN AGREGAR Y ACTUALIZAR EMPLEADOS


/*1 TRIGGER TR_AGREGAR_EMPLEADO -------------> TABLA EMPLEADOS

	controla que al insertar un nuevo registro de empleados este no se le pueda asignar un 
	puesto de categoría 2 si el empleado no tiene un título universitario.
	se dispara cuando se inserta un nuevo registro en la tabla de empleados
*/

GO

	CREATE TRIGGER TR_AGREGAR_EMPLEADO ON EMPLEADOS FOR INSERT 
	AS
	DECLARE @Cod_puesto INT
	DECLARE @Categoria INT
	DECLARE @Grado VARCHAR(12)
	SET @Cod_puesto=(SELECT COD_PUESTO FROM inserted)
	SET @Grado=(SELECT GRADO_ACADEMICO FROM inserted)
	SET @Categoria=(SELECT CATEGORIA FROM PUESTOS WHERE COD_PUESTO=@Cod_puesto)

	IF((@Grado='Diplomado' OR @Grado='Técnico') AND @Categoria=2)
	BEGIN 
		RAISERROR('las personas sin títtulos universitarios no pueden tener un trabajo de categoria 2',16,1)
	END

GO



/*2 TRIGGER TR_ACTUALIZAR_EMPLEADO -------------> TABLA EMPLEADOS

	controla que al actualizar un nuevo registro de empleados este no se le pueda asignar un 
	puesto de categoría 2 si el empleado no tiene un título universitario.
	se dispara cuando se modifica el campo COD_PUESTO
*/

GO

	CREATE TRIGGER TR_ACTUALIZAR_EMPLEADO ON EMPLEADOS FOR UPDATE 
	AS
	IF UPDATE(COD_PUESTO)
	BEGIN
		DECLARE @Cod_puesto INT
		DECLARE @Categoria INT
		DECLARE @Grado VARCHAR(12)
		SET @Cod_puesto=(SELECT COD_PUESTO FROM inserted)
		SET @Grado=(SELECT GRADO_ACADEMICO FROM inserted)
		SET @Categoria=(SELECT CATEGORIA FROM PUESTOS WHERE COD_PUESTO=@Cod_puesto)


		IF((@Grado='Diplomado' OR @Grado='Técnico') AND @Categoria=2)
		BEGIN 
			RAISERROR('las personas sin títtulos universitarios no pueden tener un trabajo de categoria 2',16,1)
		END
	END
GO




--TABLA EMPLEADOS
/*
							ELIMINAR EMPLEADOS


RESIVE COMO PARAMETROS
				@Id_Empleado VARCHAR(15) OUT -- CODIGO DEL EMPLEADO
				@Msj VARCHAR(100) OUT --------- RETORNA MENSAJE


*/
GO
	CREATE PROCEDURE SP_ELIMINAR_EMPLEADO(@Id_Empleado VARCHAR(15),@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM EMPLEADOS WHERE ID_EMPLEADO=@Id_Empleado))
			BEGIN
				IF(EXISTS(SELECT 1 FROM EMPLEADOS WHERE ID_EMPLEADO=@Id_Empleado AND BORRADO=0))
				BEGIN
					UPDATE EMPLEADOS SET BORRADO=1 WHERE ID_EMPLEADO=@Id_Empleado
					SET @Msj='El registro se eliminó con éxito'
				END
				ELSE
					BEGIN
						SET @Msj='El empleado seleccionado fue eliminado anteriormente'
				END
			END
			ELSE
				BEGIN
					SET @Msj='El empleado seleccionado no está registrado en el sistema'
			END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
	ROLLBACK TRAN
	SET @Msj=ERROR_MESSAGE()
	
	END CATCH
GO --FIN ELIMINAR EMPLEADO


--TABLA TITULOS
/*
							AGREGAR Y ACTUALIZAR TITULOS


RESIVE COMO PARAMETROS
					@Cod_Titulo: identificador del título					 		 
					@Nombre =nombre del titulo
					@Institucion =institución donde se obtuvo el titulo
					@Msj = retorna el mensaje resultante de la acción


*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_TITULO(@Cod_Titulo INT OUT,
													@Nombre VARCHAR(50),
													@Institucion VARCHAR(50),
													@Msj VARCHAR(100) OUT
												   )
	AS
	BEGIN TRY
		BEGIN TRANSACTION
			IF(EXISTS(SELECT 1 FROM TITULOS WHERE COD_TITULO= @Cod_Titulo))
			BEGIN
				UPDATE TITULOS 
				SET NOMBRE_TITULO=@Nombre,
					INSTITUCION=@Institucion
				WHERE COD_TITULO=@Cod_Titulo
				SET @Msj='El registro se actualizo correctamente'
			END
			ELSE
				BEGIN
				INSERT INTO TITULOS(NOMBRE_TITULO,
									  INSTITUCION)
									  VALUES(@Nombre,
											 @Institucion)
				SELECT @Cod_Titulo=IDENT_CURRENT('TITULOS')
				SET @Msj='El titulo se guardó correctamente'
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO -- FIN AGREGAR Y ACTUALIZAR TITULOS





--TABLA TITULOS
/*
							ELIMINAR TITULOS


RESIVE COMO PARAMETROS
					@Cod_Titulo: identificador del título					 		 
					@Msj = retorna el mensaje resultante de la acción


*/
GO
	CREATE PROCEDURE SP_ELIMINAR_TITULOS(@Cod_titulo int,@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM TITULOS WHERE COD_TITULO=@Cod_titulo))
			BEGIN
				IF(EXISTS(SELECT 1 FROM EMPLEADO_TITULOS WHERE COD_TITULO=@Cod_titulo))
				BEGIN
					SET @Msj='El titulo no se puede eliminar porque esta asignado a algún empleado'
				END
				ELSE
				BEGIN
					DELETE TITULOS WHERE COD_TITULO=@Cod_titulo
					SET @Msj='El titulo se elimino correctamente'
				END
			END
			ELSE
				BEGIN
				SET @Msj='El titulo no está registrado en el sistema'
			END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
	ROLLBACK TRAN
	SET @Msj=ERROR_MESSAGE()
	
	END CATCH
GO --FIN ELIMINAR TITULO





--TABLA EMPLEADOS_TITULOS
/*
							ASIGNAR TITULOS A LOS EMPLEADOS


RESIVE COMO PARAMETROS
					@Cod_Titulo: identificador del título
					@Id_Empleado: identificador del empleado
					@Msj: mensaje que retorna información de lo que ocurre en el proceso


*/

GO

	CREATE PROCEDURE SP_ASIGNARTITULO(@Cod_Titulo INT,@Id_Empleado VARCHAR(15) ,@Msj VARCHAR(100) OUT )
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM EMPLEADO_TITULOS WHERE COD_TITULO=@Cod_Titulo AND ID_EMPLEADO=@Id_Empleado))
			BEGIN 
				SET @Msj='El empleado ya tiene asignado este título, no se le puede asignar otra vez'
			END
			ELSE
				BEGIN
				INSERT INTO EMPLEADO_TITULOS(COD_TITULO,ID_EMPLEADO)VALUES(@Cod_Titulo,@Id_Empleado)
				SET @Msj='El titulo se asigno al empleado correctamente'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO


--TABLA EMPLEADOS_TITULOS
/*
							DESASIGNAR TITULOS A LOS EMPLEADOS


RESIVE COMO PARAMETROS
					@Cod_Titulo: código del título
					@Id_Empleado: identificador del empleado
					@Msj: mensaje que retorna información de lo que ocurre en el proceso


*/
GO

	CREATE PROCEDURE SP_DESASIGNARTITULO(@Cod_Titulo INT,@Id_Empleado VARCHAR(15) ,@Msj VARCHAR(100) OUT )
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM EMPLEADO_TITULOS WHERE COD_TITULO=@Cod_Titulo AND ID_EMPLEADO=@Id_Empleado))
			BEGIN 
				DELETE EMPLEADO_TITULOS WHERE COD_TITULO=@Cod_Titulo AND ID_EMPLEADO=@Id_Empleado
				SET @Msj='El titulo se desasigno del empleado correctamente'
			END
			ELSE
				BEGIN
				SET @Msj='Este titulo no esta asignado a este empleado'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO




--TABLA  PUESTOS
/*
							AGREGAR ACTUALIZAR PUESTOS DE TRABAJO


RESIVE COMO PARAMETROS
					@Cod_Puesto: identificador del puesto
					@nombre_P: Nombre del puesto
					@Categoria: Categoría del puesto
					@Salario: salario que se le va a asignar al puesto
					@Msj: mensaje que retorna información de lo que ocurre en el proceso


*/

GO
CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_PUESTOS(@Cod_Puesto INT OUT,@nombre_P VARCHAR(40),@Categoria INT,@Salario DECIMAL(10,2),@Msj VARCHAR(100) OUT)
AS
BEGIN TRY
	BEGIN TRAN
		IF(EXISTS(SELECT 1 FROM PUESTOS WHERE COD_PUESTO=@Cod_Puesto))
		BEGIN
			UPDATE PUESTOS SET NOMBRE_PUESTO=@nombre_P,
							   CATEGORIA=@Categoria,
							   SALARIO=@Salario
							WHERE COD_PUESTO=@Cod_Puesto
					SET @Msj='La información del puesto se actualizo correctamente'
		END
		ELSE
			BEGIN
				INSERT INTO PUESTOS(NOMBRE_PUESTO,CATEGORIA,SALARIO)VALUES(@nombre_P,@Categoria,@Salario)
				SET @Cod_Puesto=IDENT_CURRENT('PUESTOS')
				SET @Msj='El puesto se ingreso correctamente'
		END
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	SET @Msj=ERROR_MESSAGE()

END CATCH
GO


--TABLA  PUESTOS
/*
							ELIMINAR PUESTOS 


RESIVE COMO PARAMETROS
					@Cod_Puesto: identificador del puesto
					@Msj: mensaje que retorna información de lo que ocurre en el proceso


*/

GO
	CREATE PROCEDURE SP_ELIMINAR_PUESTO(@Cod_Puesto INT ,@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PUESTOS WHERE COD_PUESTO=@Cod_Puesto))
			BEGIN
				IF(EXISTS(SELECT 1 FROM EMPLEADOS WHERE COD_PUESTO=@Cod_Puesto))
				BEGIN 
					UPDATE PUESTOS SET BORRADO=1 WHERE COD_PUESTO=@Cod_Puesto
					SET @Msj='El puesto se elimino satisfactoriamente'
				END
				ELSE
					BEGIN
						DELETE FROM PUESTOS WHERE COD_PUESTO=@Cod_Puesto
						SET @Msj='El puesto se elimino satisfactoriamente'
				END
			END
			ELSE
				BEGIN
					SET @Msj='El puesto no esta registrado en el sistema'
			END
			

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()

	END CATCH
GO


--TABLA  PENSIONES
/*
							AGRGAR ACTUALIZAR PENSIÓN  


RESIVE COMO PARAMETROS
					@Cod_Pension: identificador de la pensión 
					@Id_empleado: identificador del empleado
					@Monto: monto de la pensión
					@Fecha: fecha en que se debe pagar
					@Msj: retorna mensaje de la acción que se realizo 


*/

GO
	CREATE PROCEDURE AGREGAR_ACTUALIZAR_PENSION(@Cod_Pension INT OUT,@Id_empleado VARCHAR(15),@Monto DECIMAL(10,2),@Fecha DATE,@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PENSIONES WHERE COD_PENSION=@Cod_Pension))
			BEGIN 
				UPDATE PENSIONES SET ID_EMPLEADO=@Id_empleado,
									 MONTO=@Monto,
									 FECHA_RIGE=@Fecha
								WHERE COD_PENSION=@Cod_Pension
								SET @Msj='El registro de pensión se actualizo con exitosamente'
			END
			ELSE
				BEGIN
					INSERT INTO PENSIONES(ID_EMPLEADO,MONTO,FECHA_RIGE) VALUES(@Id_empleado,@Monto,@Fecha)
					SET @Cod_Pension=IDENT_CURRENT('PENSIONES')
					SET @Msj='El registro de pensión se guardo correctamente'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO
-- AQUI VA UN TRIGGER PARA QUE EL MONTO DE LA PENSION NO SEA MAYOR AL 50% DE SALARIO


GO

	CREATE TRIGGER TR_AGREGAR_PENSION ON PENSIONES FOR INSERT 
	AS
	DECLARE @SalarioBase decimal(10,2),@monto decimal(10,2),@id int 

	select @id= ID_EMPLEADO,@monto= MONTO from inserted
	SET @SalarioBase=(SELECT SALARIO FROM PUESTOS inner join EMPLEADOS on EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO where ID_EMPLEADO=@id)
	

	IF((@monto> @SalarioBase-(@SalarioBase*0.5)))
	BEGIN 
		RAISERROR('El monto de la pensión no puede ser mayor al 50% del salario base',16,1)
	END

GO

GO

	CREATE TRIGGER TR_ACTUALIZAR_PENSION ON PENSIONES FOR UPDATE 
	AS
	IF UPDATE (MONTO)
	BEGIN 
			DECLARE @SalarioBase decimal(10,2),@monto decimal(10,2),@id int 

			select @id= ID_EMPLEADO,@monto= MONTO from inserted
			SET @SalarioBase=(SELECT SALARIO FROM PUESTOS inner join EMPLEADOS on EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO where ID_EMPLEADO=@id)
	

			IF((@monto> @SalarioBase-(@SalarioBase*0.5)))
			BEGIN 
				RAISERROR('El monto de la pensión no puede ser mayor al 50% del salario base',16,1)
			END
	END
GO






--TABLA  PENSIONES
/*
							ELIMINAR PENSIÓN  


RESIVE COMO PARAMETROS
					@Cod_Pension: identificador de la pensión
					@Msj: retorna información sobre la acción que realiza el procedimiento 


*/
GO
	CREATE PROCEDURE SP_ELIMINAR_PENSION(@Cod_Pension int,@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PENSIONES WHERE COD_PENSION=@Cod_Pension))
			BEGIN 
				IF(EXISTS(SELECT 1 FROM PENSIONES WHERE COD_PENSION=@Cod_Pension AND BORRADO=0))
				BEGIN 
					UPDATE PENSIONES SET BORRADO=1 WHERE COD_PENSION=@Cod_Pension
					SET @Msj='El registro de pensión fue eliminado exitosamente '
				END
				ELSE
					BEGIN
						SET @Msj='El registro de pensión fue eliminado anteriormente'
				END

			END 
			ELSE
				BEGIN
					SET @Msj='El registro de pensión no existe en la base de datos del sistema '
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO


--TABLA  PRESTAMOS
/*
							AGREGAR Y ACTUALIZAR PRESTAMOS 


RESIVE COMO PARAMETROS
					@Cod_Prestamo: identificador del prestamo
					@Id_Empleado: identificador del empleado
					@MontoPrestamo: Cantidad de dinero prestado
					@Cuota_Mensual: rebajo mensual para cancelar el prestamo
					@Fecha_Rige: Fecha en que se otorgo el prestamo
					@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso 


*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_PRESTAMOS(@Cod_Prestamo INT OUT,@Id_Empleado VARCHAR(15),@MontoPrestamo DECIMAL(10,2),@Cuota_Mensual DECIMAL(10,2),@Fecha_Rige DATE,@Msj VARCHAR(100)OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PRESTAMOS WHERE COD_PRESTAMO=@Cod_Prestamo ))
			BEGIN
				UPDATE PRESTAMOS
				SET ID_EMPLEADO=@Id_Empleado,
					MONTO_PRESTAMO=@MontoPrestamo,
					CUOTA_MENSUAL=@Cuota_Mensual,
					FECHA_RIGE=@Fecha_Rige
				SET @Msj='El prestamo se actualizo exitosamente'
			END
			ELSE
				BEGIN
					INSERT INTO PRESTAMOS(ID_EMPLEADO
					                     ,MONTO_PRESTAMO
										 ,CUOTA_MENSUAL
										 ,FECHA_RIGE)
								   VALUES(@Id_Empleado
									     ,@MontoPrestamo
									     ,@Cuota_Mensual
									     ,@Fecha_Rige)
								   SET @Cod_Prestamo=IDENT_CURRENT('PRESTAMOS')
								   SET @Msj='El prestamo se guardo exitosamente'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH



GO






GO

	CREATE TRIGGER TR_AGREGAR_PRESTAMO ON PRESTAMOS FOR INSERT 
	AS
	DECLARE @SalarioBase decimal(10,2),@monto decimal(10,2),@id int 

	select @id= ID_EMPLEADO,@monto= CUOTA_MENSUAL from inserted
	SET @SalarioBase=(SELECT SALARIO FROM PUESTOS inner join EMPLEADOS on EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO where ID_EMPLEADO=@id)
	

	IF((@monto> @SalarioBase-(@SalarioBase*0.5)))
	BEGIN 
		RAISERROR('La cuota mensual del prestamo no puede ser mayor al 50% del salario base',16,1)
	END

GO

GO

	CREATE TRIGGER TR_ACTUALIZAR_PRESTAMO ON PRESTAMOS FOR UPDATE 
	AS
	IF UPDATE (CUOTA_MENSUAL)
	BEGIN 
			DECLARE @SalarioBase decimal(10,2),@monto decimal(10,2),@id int 

			select @id= ID_EMPLEADO,@monto= CUOTA_MENSUAL from inserted
			SET @SalarioBase=(SELECT SALARIO FROM PUESTOS inner join EMPLEADOS on EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO where ID_EMPLEADO=@id)
	

			IF((@monto> @SalarioBase-(@SalarioBase*0.5)))
			BEGIN 
				RAISERROR('La cuota mensual del prestamo no puede ser mayor al 50% del salario base',16,1)
			END
	END
GO










--TABLA  PRESTAMOS
/*
							ELIMINAR PRESTAMOS 


RESIVE COMO PARAMETROS
					@Cod_Prestamo: identificador del prestamo
					@Id_Empleado: identificador del empleado
					@MontoPrestamo: Cantidad de dinero prestado
					@Cuota_Mensual: rebajo mensual para cancelar el prestamo
					@Fecha_Rige: Fecha en que se otorgo el prestamo
					@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso 


*/





--TABLA  DETALLE_DESGLOSES
/*
							AGREGAR DETALLE_DESGLOSES 


RESIVE COMO PARAMETROS
					@Cod_Planilla: identificador de la planilla
					@Id_empl: identificador del empleado
					@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso
*/





GO
	CREATE PROCEDURE SP_AGREGAR_DETALLE_DESGLOSE(@Cod_DesglosePlanilla INT,@Id_Empleado VARCHAR(15),@Msj VARCHAR(100)OUT)
	AS
		DECLARE @CodDeduccion INT,@Row INT, @Categoria int,
			    @Total_Registros INT,
				@Cont INT,@Resultado DECIMAL(10,2),@Sueldo decimal(10,2),@MontoPoliza decimal(10,2),
				@Estado BIT,
				@Descripcion VARCHAR(200),
				@Porcent DECIMAL(3,2),
				@Sueldo_Bruto DECIMAL(10,2)
				SET @Cont=1
				SET @Estado=0
				SELECT @Sueldo= PUESTOS.SALARIO FROM EMPLEADOS INNER JOIN
										     PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
										    WHERE ID_EMPLEADO=@Id_empleado
				SET @Sueldo_Bruto=@Sueldo
				
	    --DECLARO VARIABLE DE TIPO TABLA 
		DECLARE  @TEMP_PAGOS TABLE(ID INT IDENTITY(1,1),
								   COD_PAGO INT,
							 	   NOMBRE VARCHAR(200),
								   MONTO DECIMAL(10,2),
								   PORCENTAJE DECIMAL(3,2),
								   TIPO VARCHAR(9),
								   MODO VARCHAR(10))

		DECLARE  @TEMP_DEDUCCIONES TABLE(ID INT IDENTITY(1,1),
								   COD_DEDUCCION INT,
							 	   NOMBRE VARCHAR(200),
								   MONTO DECIMAL(10,2),
								   PORCENTAJE DECIMAL(3,2),
								   TIPO VARCHAR(9),
								   MODO VARCHAR(10))		
	BEGIN TRY
		--COPIO LOS DATOS DE LA TABLA DEDUCCIONES PLUSES
		INSERT INTO @TEMP_PAGOS SELECT CODIGO_DEDUCCION_PLUSES,NOMBRE,MONTO,PORCENTAJE,TIPO,MODO FROM DEDUCCIONES_PLUSES WHERE TIPO='PLUSES'AND BORRADO=0
		--COPIO LOS DATOS DE LA TABLA DEDUCCIONES 
		INSERT INTO @TEMP_DEDUCCIONES SELECT CODIGO_DEDUCCION_PLUSES,NOMBRE,MONTO,PORCENTAJE,TIPO,MODO FROM DEDUCCIONES_PLUSES WHERE TIPO='DEDUCCION' AND BORRADO=0
		--CUENTO CUANTOS REGISTROS TIENE LA TABLA TEMP DE PAGOS
		SELECT @Total_Registros=COUNT(*) FROM @TEMP_PAGOS
		SET @Row=1

		-- EN UNA BUELTA CALCULA DEDUCCIONES Y EN LA OTRA PAGOS 
		WHILE(@CONT<=2)
		BEGIN 
			IF(@Cont=2 AND @Estado=0)--REINICIO EL CONTADOR Y CUENTO LAS FILAS DE DEDUCCIONES
			BEGIN 
				SELECT @Total_Registros=COUNT(*) FROM @TEMP_DEDUCCIONES
				SET @Row=1
				SET @Estado=1
			END

				WHILE(@Row<=@Total_Registros)
					BEGIN
						IF(@Cont=1)--REINICIO EL CONTADOR Y CUENTO LAS FILAS DE DEDUCCIONES
							BEGIN 
								SELECT @CodDeduccion = COD_PAGO, @Porcent=PORCENTAJE,@Descripcion=NOMBRE FROM @TEMP_PAGOS WHERE ID=@Row
						END
						ELSE
							BEGIN
								SELECT @CodDeduccion = COD_DEDUCCION, @Porcent=PORCENTAJE,@Descripcion=NOMBRE FROM @TEMP_DEDUCCIONES WHERE ID=@Row
						END


						--OBTENGO LA CATEGORIA DEL PUSTO
						SELECT @Categoria= CATEGORIA FROM PUESTOS INNER JOIN EMPLEADOS ON PUESTOS.COD_PUESTO=EMPLEADOS.COD_PUESTO WHERE ID_EMPLEADO=@Id_Empleado
						IF((@Categoria=1 AND @CodDeduccion=3) OR (@Categoria=2 AND @CodDeduccion=2 )OR(@Categoria=1 AND @CodDeduccion=4 )OR(@Categoria=1 AND @CodDeduccion=11 ))
						BEGIN 
							SET @CodDeduccion=-1
						END
						ELSE
							BEGIN	
								SET @Resultado=	CASE @CodDeduccion
										WHEN  1 THEN 	
											 dbo.FN_CALCULAR_ANUALIDAD(@Id_Empleado,@Porcent,@Sueldo)		
										WHEN  2 THEN 
											 dbo.FN_CALCULAR_ESCALAFON(@Id_Empleado,@Porcent,@Sueldo)
										WHEN  3 THEN 
											dbo.FN_CALCULAR_ESCALAFON(@Id_Empleado,@Porcent,@Sueldo)
										WHEN  4 THEN 
											dbo.FN_CALCULAR_EXCLUSIVIDAD(@Id_Empleado,@Porcent,@Sueldo)
										WHEN  5 THEN 
											dbo.FN_CALCULAR_DEDUCCION_MAGISTERIO(@Id_Empleado,@Porcent,@Sueldo_Bruto)
										WHEN  6 THEN 
											dbo.FN_CALCULAR_DEDUCCION_BANCOPOPULAR(@Sueldo_Bruto,@Porcent)
										WHEN  7 THEN 
											dbo.FN_CALCULAR_DEDUCCION_CCSS(@Porcent,@Sueldo_Bruto)		
										WHEN  8 THEN
												dbo.FN_OBTENER_MONTO_DEDUCCION_POLIZA()
										WHEN  9 THEN 
											dbo.FN_CALCULAR_DEDUCCION_RENTA(@Sueldo_Bruto)	
										WHEN  10 THEN 
											dbo.FN_CALCULAR_DEDUCCION_RENTA(@Sueldo_Bruto)
										WHEN  11 THEN
											dbo.FN_OBTENER_MONTO_COLEGIATURA()
										WHEN  -1 THEN -1 -- NO LO GUARDA EN LA TABLA DE DEDUCCIONES	
									END 
							
									IF(@Cont=1 AND @Resultado<>-1 )
									BEGIN 
										SET @Sueldo_Bruto=@Sueldo_Bruto+@Resultado
									END

									IF(@Resultado<>-1)
									BEGIN
										INSERT INTO DETALLE_DESGLOSES(COD_DESGLOSE,DESCRIPCION,MONTO)VALUES(@Cod_DesglosePlanilla,@Descripcion,@Resultado)	
									END
									ELSE
										BEGIN
										IF(@Resultado=NULL)
										BEGIN
											RAISERROR('Por favor cominique a su programador que debe registrar el nuevo calculo que desea realizar',16,1)
										END
									END
							END


					SET @Row=@Row+1
				END	--FIN WHILE

				--PREGUNTO SI TIENE PENSIONES Y PRESTAMOS

			SET @Cont=@Cont+1
		END--FIN WHILE CONT
	END TRY
	BEGIN CATCH
		SET @Msj=ERROR_MESSAGE()
	END CATCH

GO








--TABLA  DESGLOSE PLANILLA
/*
							AGREGAR DESGLOSE DE PLANILLA 


RESIVE COMO PARAMETROS
					@Cod_Planilla: identificador de la planilla
					@Id_empl: identificador del empleado
					@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso


*/

GO
	CREATE PROCEDURE SP_AGREGAR_DESGLOSE_PLANILLA(@Id_empl VARCHAR(15),@Cod_Planilla INT,@Msj VARCHAR(100))
	AS
	BEGIN TRY
		BEGIN TRAN
	DECLARE @CodigoDesglose INT
		IF(NOT EXISTS(SELECT 1 FROM DESGLOSE_PLANILLA WHERE ID_EMPLEADO=@Id_empl AND COD_PLANILLA=@Cod_Planilla))
		BEGIN
			INSERT INTO DESGLOSE_PLANILLA(ID_EMPLEADO,COD_PLANILLA) VALUES(@Id_empl,@Cod_Planilla)
			SET @CodigoDesglose=IDENT_CURRENT('DESGLOSE_PLANILLA')

			EXEC SP_AGREGAR_DETALLE_DESGLOSE @CodigoDesglose ,@Id_empl,@Msj OUT
		END
		ELSE
			BEGIN
			SET @Msj='Ya existe un registro de desglose de  planilla para este empleado y no puede tener mas de uno en la misma planilla'
		END

		COMMIT TRAN
	END TRY 
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE();
	END CATCH
GO










--TABLA  DESGLOSE PLANILLA
/*
							AGREGAR DESGLOSE DE PLANILLA EN MASA 


RESIVE COMO PARAMETROS
					@Cod_Planilla: identificador de la planilla


*/
GO
	CREATE PROCEDURE SP_AGREGAR_DESGLOSE_PLANILLA_EN_MASA(@Cod_Planilla INT)
	AS
	DECLARE @Ciclo INT,
			@Total_Registros INT,
	    	@Id_empl VARCHAR(15),
			@Msj VARCHAR(100)

	-- variable de tipo tabla
	DECLARE @TEMP_EMPLEADO TABLE(CONSECUTIVO INT IDENTITY(1,1),
									 ID_EMPLEADO VARCHAR(15))
	BEGIN TRY
	-- COPIAR LOS DATOS DE LA TABLA DE EMPLEADOS A LA TABLA TEMPORAL
		INSERT INTO @TEMP_EMPLEADO
			SELECT ID_EMPLEADO FROM EMPLEADOS
		    WHERE EMPLEADOS.BORRADO=0

		SET @Ciclo=1
		SELECT @Total_Registros=COUNT(*) FROM @TEMP_EMPLEADO


		WHILE @Ciclo<=@Total_Registros
			BEGIN
			--INSERT INTO DESGLOSE_PLANILLA
				SELECT @Id_empl=ID_EMPLEADO FROM @TEMP_EMPLEADO
				WHERE CONSECUTIVO=@Ciclo
					
					EXEC dbo.SP_AGREGAR_DESGLOSE_PLANILLA @Id_empl,@Cod_Planilla,@Msj
			
				SET @Ciclo=@Ciclo+1
		END-- FIN DEL WHILE
	END TRY
	BEGIN CATCH
		--ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
		RAISERROR(@Msj,16,1)
	END CATCH

GO



--TABLA PLANILLA
/*
							AGREGAR PLANILLA 


RESIVE COMO PARAMETROS
					@Cod_Planilla: identificador de la planilla


*/

GO
	CREATE PROCEDURE SP_AGREGAR_PLANILLA(@Cod_planilla int out,@Annio INT,@Mes VARCHAR(10),@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PLANILLAS WHERE ANNIO=@Annio AND MES=@Mes))
			BEGIN
				RAISERROR('No se puede generar mas de una planilla para el mismo mes',16,1)
			END 
			ELSE
				BEGIN
					INSERT INTO PLANILLAS(ANNIO,MES)VALUES(@Annio,@Mes)
					SET @Cod_planilla=IDENT_CURRENT('PLANILLAS')
					SET @Msj='La planilla se agrego exitosamente'

					EXEC dbo.SP_AGREGAR_DESGLOSE_PLANILLA_EN_MASA @Cod_planilla
			END
	   COMMIT TRAN
	END TRY
	BEGIN CATCH
	SET @Msj=ERROR_MESSAGE()
	END CATCH
GO




/***********************************************************************************************************************************************************
															          FUNSIONES

************************************************************************************************************************************************************/


-- DEDUCCION PENSIONES

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_PENSION(@Id_Empl VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Total_Pensiones DECIMAL(10,2)
		SET @Total_Pensiones=0
		
		IF(EXISTS(SELECT 1 FROM PENSIONES WHERE ID_EMPLEADO=@Id_Empl AND BORRADO=0))
		BEGIN
			SELECT @Total_Pensiones= SUM(MONTO) FROM PENSIONES WHERE ID_EMPLEADO=@Id_Empl AND BORRADO=0
		END

		RETURN @Total_Pensiones
	END
GO












