
GO
	USE PLANILLA
GO


-- ****************************************************************************************************************************

												          -- CRUD EMPLEADOS
-- ****************************************************************************************************************************


/* AGREGAR Y ACTUALIZAR EMPLEADOS

   recibe como parametro @Nombre 
						@Apellido_1 
						@Apellido_2 
						@Telefono 
						@correo 
						@Cod_puesto 
						@Colegiatura
						@Fecha_inicio 
						@Msj 
	verifica si existe el registro si existe lo modifica y si no lo agrega
*/
GO
	CREATE PROCEDURE SP_AGREGAR_ACTUALIZAR_EMPLEADO(@Id_Empleado INT OUT,
													@Nombre VARCHAR(30),
													@Apellido_1 VARCHAR(30),
													@Apellido_2 VARCHAR(30),
													@Telefono VARCHAR(8),
													@correo VARCHAR(40),
													@Cod_puesto INT,
													@Colegiatura BIT,
													@Fecha_inicio DATE,
													@Msj VARCHAR(100) OUT
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
					FECHA_INICIO=@Fecha_inicio
				WHERE ID_EMPLEADO=@Id_Empleado	
			END
			ELSE
				BEGIN
				INSERT INTO EMPLEADOS(NOMBRE,
									  APELLIDO_1,
									  APELLIDO_2,
									  TELEFONO,
									  CORREO,
									  COD_PUESTO,
									  COLEGIATURA,
									  FECHA_INICIO)VALUES(@Nombre,
														  @Apellido_1,
														  @Apellido_2,
														  @Telefono,
														  @correo,
														  @Cod_puesto,
														  @Colegiatura,
														  @Fecha_inicio)
				SELECT @Id_Empleado=IDENT_CURRENT('EMPLEADOS')
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO -- FIN AGREGAR Y ACTUALIZAR EMPLEADOS






 /*
 ELIMINAR EMPLEADO
 recibe como parametro el @id_empleado

 Verifica si el registro existe, Verifica si el campo borrado es igual a 0, si es igual a cero lo modifica a 1
  para que se haga el borrado logico y retorna el mensaje de la acción que hizo*/
  
GO
	CREATE PROCEDURE SP_ELIMINAR_EMPLEADO(@Id_Empleado int,@Msj VARCHAR(100) OUT)
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


/* AGREGAR Y ACTUALIZAR TITULOS

   recibe como parametro @Cod_Titulo 
						 @Nombre =nombre del titulo
						 @Institucion =institución donde se obtuvo el titulo
						 @Msj = retorna el mensaje resultante de la acción

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


 /*
 ELIMINAR titulo
 recibe como parametro el @Cod_titulo
						  @Msj

 Verifica si el registro existe y verifica que no este relacionado con ningun empleado, si no esta ligado a ningun empleado 
  lo elimina de lo contrario no se podra eliminar
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

/*ASIGNAR TITULOS A LOS EMPLEADOS

 Recibe como parámetro el código del título y el id del empleado
 verifica si ya existe la asignación si no existe se agrega de lo contrario muestra un mensaje indicando que no se puede
 asignar el titulo otra vez al cliente si este ya lo tiene asignado
*/


GO

	CREATE PROCEDURE SP_ASIGNARTITULO(@Cod_Titulo INT,@Id_Empleado INT ,@Msj VARCHAR(100) OUT )
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



/*DESASIGNAR TITULOS A LOS EMPLEADOS

 Recibe como parámetro el código del título y el id del empleado
 verifica si ya existe la asignación si existe la elimina de lo contrario muestra un mensaje indicando que el titulo 
 no esta asignado al empleado seleccionado
 */


GO

	CREATE PROCEDURE SP_DESASIGNARTITULO(@Cod_Titulo INT,@Id_Empleado INT ,@Msj VARCHAR(100) OUT )
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
