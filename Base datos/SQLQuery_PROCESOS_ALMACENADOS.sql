
GO
	USE PLANILLA_DB
GO


-- ****************************************************************************************************************************

												          -- CRUD EMPLEADOS
-- ****************************************************************************************************************************


/* AGREGAR Y ACTUALIZAR EMPLEADOS --------------------------------------->

recibe como parametro	
	@Id_Empleado: número de identificación
	@Nombre: Nombre del empleado 
	@Apellido_1: primer apellido
	@Apellido_2: segundo apellido
	@Telefono :número de télefono del empleado
	@correo:dirección de correo
	@Cod_puesto: identificador del puesto
	@Colegiatura: indica si esta colegiado o no 
	@Fecha_inicio: fecha en que empeso a trabajar  
	@Msj: mensaje que retorna información de lo que ocurre en el proceso


DESCRIPCIÓN:

	verifica si existe el registro si existe lo modifica y si no lo agrega

*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_EMPLEADO(@Id_Empleado VARCHAR(15) OUT,
													@Nombre VARCHAR(30),
													@Apellido_1 VARCHAR(30),
													@Apellido_2 VARCHAR(30),
													@Telefono VARCHAR(8),
													@correo VARCHAR(40),
													@Cod_puesto INT,
													@Colegiatura BIT,
													@Grado_Academico VARCHAR(12),
													@Fecha_inicio DATE,
													@Msj VARCHAR(100) OUT,
													@Filas INT OUT
												   )
	AS
	BEGIN TRY
		BEGIN TRANSACTION
			IF(EXISTS(SELECT 1 FROM EMPLEADOS WHERE ID_EMPLEADO= @Id_Empleado))
			BEGIN
				UPDATE EMPLEADOS 
				SET NOMBRE=@Nombre,
					APELLIDO_1=@Apellido_1,
					APELLIDO_2=@Apellido_2,
					TELEFONO=@Telefono,
					CORREO=@correo,
					COD_PUESTO=@Cod_puesto,
					COLEGIATURA=@Colegiatura,
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
									  COLEGIATURA,
									  GRADO_ACADEMICO,
									  FECHA_INICIO)VALUES(@Id_Empleado,
														  @Nombre,
														  @Apellido_1,
														  @Apellido_2,
														  @Telefono,
														  @correo,
														  @Cod_puesto,
														  @Colegiatura,
														  @Grado_Academico,
														  @Fecha_inicio)
								SET @Filas=CONVERT(INT,@@ROWCOUNT)
								SET @Msj='El empleado se agrego exitosamente'
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Msj=ERROR_MESSAGE()
		SET @Filas=-1
	END CATCH
GO -- FIN AGREGAR Y ACTUALIZAR EMPLEADOS




 /*ELIMINAR EMPLEADO ------------------------------------------------->

 Recibe como parámetro 
 
	@id_empleado: identificador del empleado
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	Verifica si el registro existe, Verifica si el campo borrado es igual a 0, si es igual a cero lo modifica a 1
	para que se haga el borrado lógico y retorna el mensaje de la acción que hizo

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



-- ****************************************************************************************************************************

												          -- CRUD TITULOS
-- ****************************************************************************************************************************


/* AGREGAR Y ACTUALIZAR TITULOS ---------------------------------------------------->

Recibe como parámetro

	@Cod_Titulo: identificador del título					 		 
	@Nombre =nombre del titulo
	@Institucion =institución donde se obtuvo el titulo
	@Msj = retorna el mensaje resultante de la acción

DESCRIPCIÓN:

	verifica si existe el registro si existe lo modifica y si no lo agrega

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


 /*ELIMINAR TÍTULO ---------------------------------------------------------->

 recibe como parámetro
	
	@Cod_titulo: identificador del título
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	Verifica si el registro existe y verifica que no esté relacionado con ningún empleado, si no está ligado a ningún empleado 
	lo elimina de lo contrario no se podrá eliminar

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


-- ****************************************************************************************************************************

												          -- CRUD EMPLEADOS_TITULOS
-- ****************************************************************************************************************************

/*ASIGNAR TITULOS A LOS EMPLEADOS ---------------------------------------------------->

 Recibe como parámetro
 
	@Cod_Titulo: identificador del título
	@Id_Empleado: identificador del empleado
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	verifica si ya existe la asignación si no existe se agrega de lo contrario muestra un mensaje indicando que no se puede
	asignar el titulo otra vez al cliente si este ya lo tiene asignado
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



/*DESASIGNAR TITULOS A LOS EMPLEADOS ------------------------------------------------------>

 Recibe como parámetro
	@Cod_Titulo: código del título
	@Id_Empleado: identificador del empleado
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	 verifica si ya existe la asignación si existe la elimina de lo contrario muestra un mensaje indicando que el titulo 
	 no está asignado al empleado seleccionado

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




-- ****************************************************************************************************************************

												          -- CRUD PUESTOS
-- ****************************************************************************************************************************

/*AGREGAR ACTUALIZAR PUESTOS DE TRABAJO --------------------------------------------------->

Recibe como parámetros

	@Cod_Puesto: identificador del puesto
	@nombre_P: Nombre del puesto
	@Categoria: Categoría del puesto
	@Salario: salario que se le va a asignar al puesto
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	Verifica si el puesto existe si es así lo modifica de lo contrario lo agrega



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


/*ELIMINAR PUESTOS -------------------------------------------------------->

Recibe como parámetros
	
	@Cod_Puesto: identificador del puesto
	@Msj: mensaje que retorna información de lo que ocurre en el proceso

DESCRIPCIÓN:

	Verifica si el puesto existe y si el atributo borrado es igual a 0, si es así lo modifica a 1 para marcarlo como
	borrado si ya está con el valor de 1 muestra un mensaje indicando que el puesto ya se había borrado anteriormente,
	si el puesto no existe muestra que el puesto no está registrado


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



-- ****************************************************************************************************************************

												          -- CRUD PENSIONES
-- ****************************************************************************************************************************

/*AGRGAR ACTUALIZAR PENSIÓN ---------------------------------------------------->

Recibe como parámetros
	@Cod_Pension: identificador de la pensión 
	@Id_empleado: identificador del empleado
	@Monto: monto de la pensión
	@Fecha: fecha en que se debe pagar
	@Msj: retorna mensaje de la acción que se realizo 

DESCRIPCIÓN:

	Verifica si el registro existe en la base de datos, si esta lo modifica si no está lo agrega

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

/*ELIMINAR PENSIÓN -------------------------------------------------------------->

Recibe como parámetros 

	@Cod_Pension: identificador de la pensión
	@Msj: retorna información sobre la acción que realiza el procedimiento

DESCRIPCIÓN:

	verifica si el registro existe y si el valor de borrado es 0 lo modifica a 1
	para marcarlo como borrado
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



-- ****************************************************************************************************************************

												          -- CRUD INCAPACIDADES
-- ****************************************************************************************************************************


/*AGREGAR Y ACTUALIZAR INCAPACIDADES --------------------------------------------------->

Recibe como parámetro  
	@Cod_incapacidad: identificador de la incapacidad
	@Id_empleado: identificador del empleado
	@Motivo: motivo por el cual se produjo la incapacidad
	@Fecha_inicio: fecha en que inicia la incapacidad
	@Fecha_fin: fecha en que termina la incapacidad
	@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso

DESCRIPCIÓN:

El proceso verifica si la pensión existe si es así la modifica de lo contrario la ingresa al sistema
 

*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_INCAPACIDAD(@Cod_incapacidad INT OUT,@Id_empleado VARCHAR(15),@Motivo VARCHAR(100),@Fecha_inicio DATE,@Fecha_fin DATE,@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM INCAPACIDADES WHERE COD_INCAPACIDAD=@Cod_incapacidad))
			BEGIN 
				UPDATE INCAPACIDADES
				SET ID_EMPLEADO=@Id_empleado,
					MOTIVO=@Motivo,
					FECHA_INICIO=@Fecha_inicio,
					FECHA_FIN=@Fecha_fin
				WHERE COD_INCAPACIDAD=@Cod_incapacidad
				SET @Msj='El registro de incapacidad se actualizo exitosamente'
			END
			ELSE
				BEGIN
				INSERT INTO INCAPACIDADES(ID_EMPLEADO,MOTIVO,FECHA_INICIO,FECHA_FIN)
							VALUES(@Id_empleado,@Motivo,@Fecha_inicio,@Fecha_fin)
							SET @Cod_incapacidad=IDENT_CURRENT('INCAPACIDADES')
							SET @Msj='El registro de incapacidad se guardo correctamente'
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO


/*ELIMINAR INCAPACIDAD --------------------------------------------------------------->

Recibe como parámetros 
	@Cod_incapacidad: identificador de la incapacidad
	@Msj: mensaje que retorna el proceso informando lo que sucedio en el proceso




GO
	CREATE PROCEDURE SP_ELIMINAR_INCAPACIDAD(@Cod_incapacidad INT, @Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
				IF(EXISTS(SELECT * FROM INCAPACIDADES WHERE COD_INCAPACIDAD=@Cod_incapacidad))
				BEGIN 
					
				
				END 

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO
*/



-- ****************************************************************************************************************************

												          -- CRUD DESGLOSE PLANILLA
-- ****************************************************************************************************************************


GO
	CREATE PROCEDURE SP_AGREGAR_DESGLOSE_PLANILLA_EN_MASA(@Cod_Planilla INT)
	AS
	DECLARE @Ciclo INT,
			@Total_Registros INT
	DECLARE @TEMP_EMPLEADO TABLE(CONSECUTIVO INT IDENTITY(1,1),
									 ID_EMPLEADO VARCHAR(15),
									 SALARIO DECIMAL(10,2))
	BEGIN TRY
		INSERT INTO @TEMP_EMPLEADO
			SELECT EMPLEADOS.ID_EMPLEADO,PUESTOS.SALARIO FROM EMPLEADOS INNER JOIN
						  PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
						  WHERE EMPLEADOS.BORRADO=0


		SET @Ciclo=1
		SELECT @Total_Registros=COUNT(*) FROM @TEMP_EMPLEADO


		WHILE @Ciclo<=@Total_Registros
		BEGIN
			INSERT INTO DESGLOSE_PLANILLA
				SELECT @Cod_Planilla,ID_EMPLEADO,SALARIO FROM @TEMP_EMPLEADO
				WHERE CONSECUTIVO=@Ciclo

				SET @Ciclo=@Ciclo+1
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH

GO






-- ****************************************************************************************************************************

												          -- CRUD PLANILLA
-- ****************************************************************************************************************************

GO
	CREATE PROCEDURE SP_AGREGAR_PLANILLA(@Cod_planilla int out,@Annio INT,@Mes VARCHAR(10),@Msj VARCHAR(100) OUT)
	AS
	BEGIN TRY
		BEGIN TRAN
			IF(EXISTS(SELECT 1 FROM PLANILLAS WHERE COD_PLANILLA=@Cod_planilla))
			BEGIN
				UPDATE PLANILLAS
				SET ANNIO=@Annio,
					MES=@Mes
				WHERE COD_PLANILLA=@Cod_planilla
				SET @Msj='La planilla se actualizo exitosamente'
			END 
			ELSE
				BEGIN
					INSERT INTO PLANILLAS(ANNIO,MES)VALUES(@Annio,@Mes)
					SET @Cod_planilla=CONVERT(INT,IDENT_CURRENT('PLANILLAS'))
					SET @Msj='La planilla se agrego exitosamente'

					EXEC dbo.SP_AGREGAR_DESGLOSE_PLANILLA_EN_MASA @Cod_planilla
			END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
	SET @Msj=ERROR_MESSAGE()
	END CATCH
GO































/*************************************************************************************************************************************************
                                                           FUNCIONES  
														           
**************************************************************************************************************************************************/



/*FUNSION PARA CALCULAR ANUALIDAD*/
GO
	CREATE FUNCTION FN_CALCULAR_ANUALIDAD(@Id_empleado VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Sueldo DECIMAL(10,2),-- CAPTURA EL MONTO DEL SUELDO
		@anniosLaborados DECIMAL(10,2) -- OBTIENE EL VALOR DE TIEMPO LABORADO EN AÑOS
		DECLARE @Fecha_Inicio DATE -- CAPTURA LA FECHA DE INICIO
		DECLARE @diasLaborados INT -- CUENTA LOS DIAS QUE ENTRE LA FECHA DE INICIO Y LA FECHA ACTUAL
			
		SELECT @Sueldo= PUESTOS.SALARIO FROM EMPLEADOS INNER JOIN
											 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
											  WHERE ID_EMPLEADO=@Id_empleado

		SELECT @Fecha_Inicio= FECHA_INICIO FROM EMPLEADOS WHERE ID_EMPLEADO=@Id_empleado 
		SELECT @diasLaborados= DATEDIFF(DAY,@Fecha_Inicio,GETDATE())
		SET @anniosLaborados=(@diasLaborados/12)
		SET @anniosLaborados=@anniosLaborados/30


		RETURN (@Sueldo*0.02)*@anniosLaborados
	END
	
GO


-- LLAMAR FUNCION
SELECT dbo.FN_CALCULAR_ANUALIDAD('206350342') AS ANUALIDAD




/*FUNSION PARA CALCULAR ESCALAFON*/
GO
	CREATE FUNCTION FN_CALCULAR_ESCALAFON(@Id_empleado VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Sueldo DECIMAL(10,2),-- CAPTURA EL MONTO DEL SUELDO
		@Escalafon DECIMAL(10,2)
		DECLARE @Categoria INT
			
		SELECT @Sueldo= PUESTOS.SALARIO,
			   @Categoria=PUESTOS.CATEGORIA FROM EMPLEADOS INNER JOIN
												 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
										    WHERE ID_EMPLEADO=@Id_empleado
		IF(@Categoria=1)
		BEGIN
			SET @Escalafon= @Sueldo*0.03
		END
		ELSE IF(@Categoria=2)
		BEGIN
			SET @Escalafon= @Sueldo*0.01
		END
		RETURN @Escalafon
	END
	
GO


SELECT dbo.FN_CALCULAR_ESCALAFON('235689774') as ESCALAFON




/*FUNSION PARA CALCULAR EXCLUSIVIDAD*/
GO
	CREATE FUNCTION FN_CALCULAR_EXCLUSIVIDAD(@Id_empleado VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Sueldo DECIMAL(10,2),-- CAPTURA EL MONTO DEL SUELDO
		@Exclusividad DECIMAL(10,2)
		DECLARE @Categoria INT
		
		SET @Exclusividad=0
			
		SELECT @Sueldo= PUESTOS.SALARIO,
			   @Categoria=PUESTOS.CATEGORIA FROM EMPLEADOS INNER JOIN
												 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
										    WHERE ID_EMPLEADO=@Id_empleado
		IF(@Categoria=2)
		BEGIN
			SET @Exclusividad= @Sueldo*0.30
		END

		RETURN @Exclusividad
	END
	
GO


select dbo.FN_CALCULAR_EXCLUSIVIDAD('235689774')as exclusividad

