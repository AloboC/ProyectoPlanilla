
GO
	USE PLANILLA_DB
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
	DECLARE @Sueldo DECIMAL(10,2),--Capturar el sueldo base
			@F_inicio date,
			@Anios INT,
			@porc_Anualidad DECIMAL(4,2),
			@Anualidad DECIMAL(10,2)
			
	
		--Capturo el sueldo base ,fecha de inicio
		SELECT @Sueldo= PUESTOS.SALARIO,@F_inicio=EMPLEADOS.FECHA_INICIO FROM EMPLEADOS INNER JOIN
											 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
									    WHERE ID_EMPLEADO=@Id_empleado	

		-- se calcula cuantos años de laborar tiene el empleado
		SET @Anios=(DATEDIFF(DAY,@F_inicio,GETDATE())+1)/365
		
		IF(@Anios>0)
			BEGIN
				-- SE OBTIENE EL PORCENTAJE DE LA ANUALIDAD
				SELECT @porc_Anualidad=PORC_ANUALIDAD FROM PORCENTAJES

				SET @Anualidad=@Sueldo*(@porc_Anualidad/100)*@Anios
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
	CREATE FUNCTION FN_CALCULAR_ESCALAFON(@Id_empleado VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Sueldo DECIMAL(10,2),-- CAPTURA EL MONTO DEL SUELDO
		@Escalafon DECIMAL(10,2),
	    @Categoria INT,
		@Anios INT,
		@F_inicio date,
		@Escalafon_C1 DECIMAL(4,2),
		@Escalafon_C2 DECIMAL(4,2)
			
		--Se obtiene el sueldo,categoria y fecha de inicio
		SELECT @Sueldo= PUESTOS.SALARIO,
			   @Categoria=PUESTOS.CATEGORIA,
			   @F_inicio=EMPLEADOS.FECHA_INICIO FROM EMPLEADOS INNER JOIN
													 PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
											    WHERE ID_EMPLEADO=@Id_empleado

		-- se calcula cuantos años de laborar tiene el empleado
		SET @Anios=(DATEDIFF(DAY,@F_inicio,GETDATE())+1)/365
		IF(@Anios>0)
			BEGIN
				-- SE OBTIENE EL VALOR DE LOS 2 PORCENTAJES DE ESCALAFON
				SELECT @Escalafon_C1=PORC_ESCALAFON_C1,@Escalafon_C2=PORC_ESCALAFON_C2 FROM PORCENTAJES
				

				IF(@Categoria=1)
					BEGIN
						SET @Escalafon= @Sueldo*(@Escalafon_C1/100)*@Anios
					END
					ELSE IF(@Categoria=2)
						BEGIN
							SET @Escalafon= @Sueldo*(@Escalafon_C2/100)*@Anios
				END
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
	CREATE FUNCTION FN_CALCULAR_EXCLUSIVIDAD(@Id_empleado VARCHAR(15),@Porcentaje DECIMAL(3,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Sueldo DECIMAL(10,2),-- CAPTURA EL MONTO DEL SUELDO
		@Exclusividad DECIMAL(10,2),
		
		--OBTENER SUELDO 	
		SELECT @Sueldo= PUESTOS.SALARIO FROM EMPLEADOS INNER JOIN
										     PUESTOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO
										    WHERE ID_EMPLEADO=@Id_empleado
		IF(@Categoria=2)
		BEGIN
			SELECT @Porc_Exclus=PORC_EXCLUSIVIDAD FROM PORCENTAJES

			SET @Exclusividad= @Sueldo*(@Porc_Exclus/100)
		END
		ELSE
			BEGIN
				SET @Exclusividad=0
		END

		RETURN @Exclusividad
	END
	
GO


--select dbo.FN_CALCULAR_EXCLUSIVIDAD('888888')as exclusividad






/*                                                              FUNSIONES DE LAS DEDUCCIONES                                                                    */






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




-- DEDUCCION PRESTAMO

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_PRESTAMO(@Id_Empl VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Total_Prestamos DECIMAL(10,2)
		SET @Total_Prestamos=0
		
		IF(EXISTS(SELECT 1 FROM PRESTAMOS WHERE ID_EMPLEADO=@Id_Empl AND CANCELADO=0))
		BEGIN
			SELECT @Total_Prestamos= SUM(CUOTA_MENSUAL) FROM PRESTAMOS WHERE ID_EMPLEADO=@Id_Empl AND CANCELADO=0
		END

		RETURN @Total_Prestamos
	END
GO




-- DEDUCCION MAGISTERIO

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_MAGISTERIO(@Id_Empl VARCHAR(15),@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_Magisterio DECIMAL(10,2),
				@Porc_Magisterio DECIMAL(4,2)

		SELECT @Porc_Magisterio=PORC_DED_MAGISTERIO FROM PORCENTAJES


		SET @Ded_Magisterio=@Salario_bruto*(@Porc_Magisterio/100)

		RETURN @Ded_Magisterio
	END
GO







-- DEDUCCION COLEGIATURA
GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_COLEGIATURA(@Id_empl varchar(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		DECLARE @Colegiatura BIT,
				@Monto DECIMAL(10,2),
				@Categoria INT
		
		--OBTENER SI=1 ES COLEGIADO O NO=0 Y OBTENER LA COLEGIATURA
		SELECT @Colegiatura=COLEGIATURA FROM EMPLEADOS WHERE ID_EMPLEADO=@Id_empl
		SELECT @Categoria=CATEGORIA FROM PUESTOS INNER JOIN EMPLEADOS ON PUESTOS.COD_PUESTO=EMPLEADOS.COD_PUESTO WHERE ID_EMPLEADO=@Id_empl

		IF(@Colegiatura=1 AND @Categoria=2)
		BEGIN

			SELECT @Monto=MONTO_DED_COLEGIO FROM PORCENTAJES
		END
		ELSE
			BEGIN
				SET @Monto=0
		END

		RETURN @Monto
	END

GO






-- DEDUCCION BANCO POPULAR

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_BANCOPOPULAR(@Id_Empl VARCHAR(15),@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_BP DECIMAL(10,2),
				@Porc_Ded_BP DECIMAL(4,2)

			SELECT @Porc_Ded_BP=PORC_DED_BP FROM PORCENTAJES

			SET @Ded_BP=@Salario_bruto*(@Porc_Ded_BP/100)
		RETURN @Ded_BP
	END
GO





-- DEDUCCION CCSS

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_CCSS(@Id_Empl VARCHAR(15),@Salario_bruto DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN 
		DECLARE @Ded_CCSS DECIMAL(10,2),
				@Porc_Ded_ccss DECIMAL(4,2)
		-- OBTENER EL PORCENTAJE DE DEDUCCION CCSS
		SELECT @Porc_Ded_ccss=PORC_DED_CCSS FROM PORCENTAJES


			SET @Ded_CCSS=@Salario_bruto*(@Porc_Ded_ccss/100)
		RETURN @Ded_CCSS
	END
GO



-- CALCULO DEDUCCION RENTA

GO
	CREATE FUNCTION FN_CALCULAR_DEDUCCION_RENTA(@Id_Empl VARCHAR(15),@Salario_bruto DECIMAL(10,2))
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


		SELECT @Porc_Ded_RentaIntermedia=PORC_DED_RENTA_INTERMEDIO,
			   @Porc_Ded_RentaMayor=PORC_DED_RENTA_MAYOR,
			   @Tope_sin_D=TOPE_SALARIO_SIN_DEDUCCION_RENTA,
			   @Tope_Con_D=TOPE_SALARIO_CON_DEDUCCION_RENTA
			 FROM PORCENTAJES


		IF(@Salario_bruto<=@Tope_sin_D)
		BEGIN 
			SET @Ded_RENTA=0
		END
		ELSE IF(@Salario_bruto>@Tope_sin_D AND @Salario_bruto<@Tope_Con_D)
			BEGIN
			--se obtiene el primer tope
			SET @PrimerTope=@Salario_bruto-@Tope_sin_D
			SET @Ded_RENTA=@PrimerTope*(@Porc_Ded_RentaIntermedia/100)
		END
		ELSE
			BEGIN
				--se obtiene el primer tope
				SET @PrimerTope=@Tope_Con_D-@Tope_sin_D
				--se obtiene el segundo tope
				SET @SegundoTope=@Salario_bruto-@Tope_Con_D
				SET @Ded_RENTA=(@PrimerTope*(@Porc_Ded_RentaIntermedia/100))+(@SegundoTope*(@Porc_Ded_RentaMayor/100))
		END
			
		RETURN @Ded_RENTA
	END
GO

--SELECT dbo.FN_CALCULAR_DEDUCCION_RENTA('888888' ,1500000)AS RENTA


GO
	CREATE FUNCTION FN_OBTENER_NUMERO_MES(@Mes VARCHAR(10))
	RETURNS INT
	AS
	BEGIN
		DECLARE @Num INT
		SELECT 
			@Num= CASE @Mes
			WHEN 'Enero' THEN 1
			WHEN 'Febrero' THEN 2
			WHEN 'Marzo' THEN 3
			WHEN 'Abril' THEN 4
			WHEN 'Mayo' THEN 5
			WHEN 'Junio' THEN 6
			WHEN 'Julio' THEN 7
			WHEN 'Agosto' THEN 8
			WHEN 'Septiembre' THEN 9
			WHEN 'Obtubre' THEN 10
			WHEN 'Noviembre' THEN 11
			WHEN 'Diciembre' THEN 12
		END
		RETURN @Num		
	
	END
GO

   

-- SELECT dbo.FN_OBTENER_NUMERO_MES('Obtubre') as mes



-- CALCULO DIAS DE INCAPACIDAD

GO
	CREATE FUNCTION FN_CALCULAR_DIAS_INCAPACIDAD_X_MES(@Id_emple VARCHAR(15))
	RETURNS INT
	AS
	BEGIN
		 DECLARE @PrimerDia_Mes DATE,-- ------------------------>OBTIENE EL PRIMER DIA DEL MES ACTUAL
				 @UltimoDia_Mes DATE,-- ------------------------>OBTIENE EL ULTIMO DIA DEL MES ACTUAL
				 @Fecha_inicio DATE,
				 @Fecha_fin DATE

		DECLARE @Posicion INT,
				@Mes INT,
				@DiasIncapacitados INT,
				@DiasTotalesInc INT,
				@Total_Registros INT

		DECLARE @TEMP_FECHAS_INCAP TABLE(CONSECUTIVO INT IDENTITY(1,1),
										 FECHA_INICIO DATE,
										 FECHA_FIN DATE)

			SET @PrimerDia_Mes=CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(getdate())-1),getdate()),111)--obtener el primer dia del mes actual
			SET @UltimoDia_Mes=CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,GETDATE()))),DATEADD(mm,1,GETDATE())),111)--obtener el Último día del mes actual
			


			

		--copiar los datos de fecha de la tabla incapacidades a la variable de tabla temporal	
		INSERT INTO @TEMP_FECHAS_INCAP
				SELECT FECHA_INICIO,FECHA_FIN  FROM INCAPACIDADES WHERE ID_EMPLEADO=@Id_emple AND FECHA_INICIO<=@UltimoDia_Mes AND FECHA_FIN>=@PrimerDia_Mes
		
		--contar los registros que tiene la tabla de incapacidades
		SELECT @Total_Registros= COUNT(*) FROM @TEMP_FECHAS_INCAP
		SET @Posicion=1
		SET @DiasIncapacitados=0


		WHILE @Posicion<=@Total_Registros
			BEGIN
				SELECT @Fecha_inicio=FECHA_INICIO,@Fecha_fin=FECHA_FIN FROM @TEMP_FECHAS_INCAP WHERE @Posicion=CONSECUTIVO

				SET @DiasTotalesInc=DATEDIFF(DAY,@Fecha_inicio,@Fecha_fin)+1
				
				IF(@Fecha_inicio<@PrimerDia_Mes)
				BEGIN
					SET @Fecha_inicio=@PrimerDia_Mes
				END
				IF(@Fecha_fin>@UltimoDia_Mes)
				BEGIN
					SET @Fecha_fin=@UltimoDia_Mes
				END
				SELECT @DiasIncapacitados=@DiasIncapacitados+DATEDIFF(DAY,@Fecha_inicio,@Fecha_fin)+1

				set @Posicion=@Posicion+1

		END --FIN WHILE

		RETURN @DiasIncapacitados
	END

GO






-- ******************************************************************** PROVAR>>>>>>>>>>>>>>>


GO
	CREATE FUNCTION FN_DIAS_DE_INCAPACIDAD(@Mes INT,@Id_Empleado VARCHAR(15))
	RETURNS INT
	AS
	BEGIN
		DECLARE @F_Inicio DATE,
				@F_Fin DATE,
				@Prim_Dia_Mes DATE,
				@Ult_Dia_Mes DATE,
				@F_Sig DATE,
				@Total_Registros INT,
				@Posicion INT,
				@Dias_incap INT,
				@Total_D INT,
				@Cont INT,
				@sumaDia INT,
				@Anio INT,
				@Ms INT,
				@Dia INT,
				@NombreDia INT

		-- variable de tipo tabla 
		DECLARE @TEMP_FECHAS_INCAP TABLE(CONSECUTIVO INT IDENTITY(1,1),
									FECHA_INICIO DATE,
									FECHA_FIN DATE)
				
		-- obtener el primer dia del mes ->
		SET @Prim_Dia_Mes=CONVERT(DATE,CONVERT(VARCHAR(4),DATEPART(YEAR,getdate()))+'/'+CONVERT(VARCHAR(2),@Mes)+'/'+'01')
		-- obtiene el ultimo dia del mes ->
		SET @Ult_Dia_Mes= EOMONTH(@F_Inicio )

		--copiar los datos de fecha de la tabla incapacidades a la variable de tabla temporal	
		INSERT INTO @TEMP_FECHAS_INCAP
			SELECT FECHA_INICIO,FECHA_FIN  FROM INCAPACIDADES
				 WHERE ID_EMPLEADO=@Id_Empleado AND FECHA_INICIO<=@Ult_Dia_Mes AND FECHA_FIN>=@Prim_Dia_Mes

        -- Se cuentan los registros que hay en la tabla temporal
		SELECT @Total_Registros= COUNT(*) FROM @TEMP_FECHAS_INCAP
		SET @Posicion=0
		SET @Dias_incap=0
		SET @Cont=1
		SET @sumaDia=0
		SET @Dias_incap=0

		WHILE @Posicion<=@Total_Registros
			BEGIN
				SELECT @F_Inicio=FECHA_INICIO,@F_Fin=FECHA_FIN FROM @TEMP_FECHAS_INCAP WHERE @Posicion=CONSECUTIVO
				SET @Total_D=DATEDIFF(DAY,@F_Inicio,@F_Fin)+1
				--IDENTIFICA SI EL DIA ES DOMINGO Y SABADO PARA NO CONTARLO COMO DIA INCAPACITADO
				WHILE @Cont<=@Total_D
					BEGIN
						SET @Anio=DATEPART(YEAR,@F_Inicio)
						SET @Ms=DATEPART(MONTH,@F_Inicio)
						SET @Dia=DATEPART(DAY,@F_Inicio+@sumaDia)
						
						SET @F_Sig=CONCAT(@Anio,'-',@Ms,'-',@Dia)
						-- OBTIENE EL NUMERO QUE REPRESENTA AL DIA
						SET @NombreDia= 1+((6+DATEPART(DW,@F_Sig)+@@DATEFIRST)%7)

						IF(@NombreDia!=1 AND @NombreDia!=7)
							BEGIN
								SET @Dias_incap=@Dias_incap+1
						END
						
						SET @sumaDia=@sumaDia+1
						SET @Cont=@Cont+1
				END --fin while
				SET @Posicion=@Posicion+1

		END--fin while
		RETURN @Dias_incap
				
	END
GO

-- ******************************************************************** PROVAR<<<<<<<<<<<<<<<<<<








	--DECLARE @Anio INT ,@Ms INT,@Dia INT,@sumaDia INT =0,@F_Sig DATE
	--					SET @Anio=DATEPART(YEAR,GETDATE())
	--					SET @Ms=DATEPART(MONTH,GETDATE())
	--					SET @Dia=DATEPART(DAY,GETDATE()+@sumaDia)
						
	--					SET @F_Sig=CONCAT(@Anio,'-',@Ms,'-',@Dia)
	--					SELECT @F_Sig





-- CALCULO MONTO DE INCAPACIDAD

GO
	CREATE FUNCTION FN_CALCULAR_MONTO_INCAPACIDAD_X_MES(@Id_emple VARCHAR(15))
	RETURNS DECIMAL(10,2)
	AS
	BEGIN
		 DECLARE @PrimerDia_Mes DATE,-- ------------------------>OBTIENE EL PRIMER DIA DEL MES ACTUAL
				 @UltimoDia_Mes DATE,-- ------------------------>OBTIENE EL ULTIMO DIA DEL MES ACTUAL
				 @Fecha_inicio DATE,
				 @Fecha_fin DATE

		DECLARE @Posicion INT,
				@DiasTotalesInc INT,-- ---------------------------> OBTIENE LA CANTIDAD TOTAL DE DIAS INCAPACITADOS
				@Total_Registros INT,-- --------------------------> OBTIENE LA CANTIDAD DE INCAPACIDADES QUE TIENE UN EMPLEADO EN UN PERIODO
				@Dias_Mes_Anterior INT,-- ------------------------> SI LA INCAPACIDAD COMIENZA EN EL MES ANTERIOS Y TERMINA EN EL ACTUAL CUENTA LOS DIAS DEL MES ANTERIOR
				@Dias_Mes_Actual INT-- ---------------------------> CUENTA LOS DIAS DE INCAPACIDAD DEL MES ACTUAL
				
				

		DECLARE @MontoInc DECIMAL(10,2),
				@Salario_Base DECIMAL(10,2),
				@Salario_x_Dia DECIMAL(10,2)

		DECLARE @TEMP_FECHAS_INCAP TABLE(CONSECUTIVO INT IDENTITY(1,1),
										 FECHA_INICIO DATE,
										 FECHA_FIN DATE)

			SET @PrimerDia_Mes=CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(getdate())-1),getdate()),111)--obtener el primer dia del mes actual
			SET @UltimoDia_Mes=CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,GETDATE()))),DATEADD(mm,1,GETDATE())),111)--obtener el Último día del mes actual
			SET @MontoInc=0

		--copiar los datos de fecha de la tabla incapacidades a la variable de tabla temporal	
		INSERT INTO @TEMP_FECHAS_INCAP
				SELECT FECHA_INICIO,FECHA_FIN  FROM INCAPACIDADES WHERE ID_EMPLEADO=@Id_emple AND FECHA_INICIO<=@UltimoDia_Mes AND FECHA_FIN>=@PrimerDia_Mes

		--obtengo el salario base del empleado
		SELECT @Salario_Base=PUESTOS.SALARIO FROM PUESTOS INNER JOIN EMPLEADOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO WHERE ID_EMPLEADO=@Id_emple
		SET @Salario_x_Dia = @Salario_Base/30
		
		--contar los registros que tiene la tabla de incapacidades
		SELECT @Total_Registros= COUNT(*) FROM @TEMP_FECHAS_INCAP
		SET @Posicion=1

		-- *********************************************************>>> INICIO DEL WHILE
		WHILE @Posicion<=@Total_Registros
			BEGIN	
								
				SELECT @Fecha_inicio=FECHA_INICIO,@Fecha_fin=FECHA_FIN 
					FROM @TEMP_FECHAS_INCAP 
					WHERE @Posicion=CONSECUTIVO

				--Se cuentan los dias de incapacidad
				SET @DiasTotalesInc=DATEDIFF(DAY,@Fecha_inicio,@Fecha_fin)+1

				IF(@Fecha_inicio<@PrimerDia_Mes)
				BEGIN

					--se cuentan los dias desde la fecha de inicio hasta el primer dia del mes actual
					SET @Dias_Mes_Anterior=DATEDIFF(DAY,@Fecha_inicio,@PrimerDia_Mes)
					SET @Dias_Mes_Actual=DATEDIFF(DAY,@PrimerDia_Mes,@Fecha_fin)+1

					IF(@Dias_Mes_Anterior = 3)
						BEGIN 
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.6)*(@Dias_Mes_Actual)
					END
					ELSE IF(@Dias_Mes_Anterior < 3)
						BEGIN
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*(3-@Dias_Mes_Anterior)
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.6)*(@DiasTotalesInc-3)
					END
					ELSE IF(@Dias_Mes_Anterior > 3)
						BEGIN
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.6)*(@Dias_Mes_Actual)	
					END	

				END	
				ELSE IF(@Fecha_fin > @UltimoDia_Mes)
				BEGIN

					SET @Dias_Mes_Actual=DATEDIFF(DAY,@Fecha_inicio,@UltimoDia_Mes)+1
					
					IF(@Dias_Mes_Actual = 3)
						BEGIN 

							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*@Dias_Mes_Actual
					END
					ELSE IF(@Dias_Mes_Actual < 3)
						BEGIN
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*@Dias_Mes_Actual
					END
					ELSE IF(@Dias_Mes_Actual > 3)
						BEGIN
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*3
							SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.6)*(@Dias_Mes_Actual-3)
					END	
				END
				ELSE
					BEGIN
						IF(@DiasTotalesInc<=3)
							BEGIN
								SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*@DiasTotalesInc		
						END
						ELSE
							BEGIN
								SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.5)*3
								SET @MontoInc=@MontoInc+(@Salario_x_Dia*0.6)*(@DiasTotalesInc-3)	
						END
					
				END
				set @Posicion=@Posicion+1

		END -- ***********************************************>>> FIN WHILE

		RETURN @MontoInc
	END

GO















-- POCESOSOS ALMACENADOS












-- ****************************************************************************************************************************

												          -- TABLA EMPLEADOS
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

	con el Id_Empleado verifica si existe el registro si existe lo modifica y si no lo agrega

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






/******************************************************************************************************
                           TRIGGERS PARA LA TABLA DE EMPLEADOS 
 ******************************************************************************************************/




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

												          -- TABLA TITULOS
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

												          -- TABLA EMPLEADOS_TITULOS
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

												          -- TABLA PUESTOS
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

												          -- TABLA PENSIONES
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

												          -- TABLA INCAPACIDADES
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


												          -- CRUD PRESTAMOS



-- ****************************************************************************************************************************

/*AGREGAR Y ACTUALIZAR PRESTAMOS

	Recibe como parametros
	@Cod_Prestamo: identificador del prestamo
	@Id_Empleado: identificador del empleado
	@MontoPrestamo: Cantidad de dinero prestado
	@Cuota_Mensual: rebajo mensual para cancelar el prestamo
	@Fecha_Rige: Fecha en que se otorgo el prestamo
	@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso


	El proceso verifica si ya existe el prestamo si es asi lo modifica de lo contrario lo agrega
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













-- ****************************************************************************************************************************


												          -- TABLA DESGLOSE PLANILLA


-- ****************************************************************************************************************************


/*AGREGAR DESGLOSES_PLANILLAS --------------------------------------------------->

Recibe como parámetro  
	@Cod_Planilla: identificador de la planilla
	@Id_empl: identificador del empleado
	@Msj: mensaje que retorna el proceso informando lo que sucedió en el proceso

DESCRIPCIÓN:

El proceso verifica si la pensión existe si es así la modifica de lo contrario la ingresa al sistema
 

*/

GO
	CREATE PROCEDURE SP_AGREGAR_DESGLOSE_PLANILLA(@Id_empl VARCHAR(15),@Cod_Planilla INT,@Msj VARCHAR(100))
	AS

	DECLARE @Dias_incapacidad INT
	DECLARE @Anualidad DECIMAL(10,2),
			@Escalafon DECIMAL(10,2),
			@Exclusividad DECIMAL(10,2),
			@Ded_Pension DECIMAL(10,2),
			@Ded_Pen_Magisterio DECIMAL(10,2),
			@Ded_CCSS DECIMAL(10,2),
			@Ded_BPOPULAR DECIMAL(10,2),
			@Ded_poliza DECIMAL(10,2),
			@Ded_Renta DECIMAL(10,2),
			@Ded_Colegio DECIMAL(10,2),
			@Ded_Prestamo DECIMAL(10,2),
			@Incapacidad decimal(10,2),
			@Saldo DECIMAL(10,2)

	BEGIN TRY
		BEGIN TRAN
				SELECT @Saldo=SALARIO FROM PUESTOS INNER JOIN EMPLEADOS ON EMPLEADOS.COD_PUESTO=PUESTOS.COD_PUESTO WHERE ID_EMPLEADO=@Id_empl

				SET @Anualidad=dbo.FN_CALCULAR_ANUALIDAD(@Id_empl)-- ----------------------------> Calcular anualidad
				SET @Escalafon=dbo.FN_CALCULAR_ESCALAFON(@Id_empl)-- ---------------------------->Calcular Escalafon
				SET @Exclusividad=dbo.FN_CALCULAR_EXCLUSIVIDAD(@Id_empl)-- ---------------------------->Calcular Exclusividad
				SET @Saldo=@Saldo+@Anualidad+@Escalafon+@Exclusividad -- ------------------------------> Se obtiene el salario bruto 

				SET @Ded_Pension=dbo.FN_CALCULAR_DEDUCCION_PENSION(@Id_Empl)-- ---------------------------->Calcular deducción pension
				SET @Ded_Pen_Magisterio=dbo.FN_CALCULAR_DEDUCCION_MAGISTERIO(@Id_Empl,@Saldo)-- -----------> obtengo la deduccion del magisterio
				SET @Ded_CCSS=dbo.FN_CALCULAR_DEDUCCION_CCSS(@Id_Empl,@Saldo)-- -----> obtengo la deducción de la caja
				SET @Ded_BPOPULAR=dbo.FN_CALCULAR_DEDUCCION_BANCOPOPULAR(@Id_Empl,@Saldo)-- ------>obtengo la deduccion del banco popular
				SET @Ded_Renta=dbo.FN_CALCULAR_DEDUCCION_RENTA(@Id_Empl,@Saldo)-- ------------> Obtengo la deduccion de renta
				SET @Ded_Prestamo=dbo.FN_CALCULAR_DEDUCCION_PRESTAMO(@Id_Empl)-- ---------------------> Obtener la deduccion de prestamos
				SET @Ded_Colegio=dbo.FN_CALCULAR_DEDUCCION_COLEGIATURA(@Id_Empl)
				SET @Dias_incapacidad=dbo.FN_CALCULAR_DIAS_INCAPACIDAD_X_MES(@Id_empl)
				SET @Incapacidad=dbo.FN_CALCULAR_MONTO_INCAPACIDAD_X_MES(@Id_empl)
				SET @Ded_poliza=13450
				SET @Saldo=@Saldo-(@Saldo/30)*@Dias_incapacidad

				IF(@Saldo < @Ded_Pension)-- si el monto de la pension es mayor al saldo se suma el monto de incapacidad antes de hacer la deduccion de lo contrario
											--se suma de ultimo
					BEGIN
						SET @Saldo=@Saldo+@Incapacidad
						-- *********************************************************************************	
						IF(@Saldo >= @Ded_Pen_Magisterio)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Pen_Magisterio
						END
						ELSE
							BEGIN
								SET @Ded_Pen_Magisterio =@Saldo- @Ded_Pen_Magisterio
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_CCSS)
							BEGIN
								SET @Saldo=@Saldo-@Ded_CCSS
						END
						ELSE
							BEGIN
								SET @Ded_CCSS =@Saldo- @Ded_CCSS
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_BPOPULAR)
							BEGIN
								SET @Saldo=@Saldo-@Ded_BPOPULAR
						END
						ELSE
							BEGIN
								SET @Ded_BPOPULAR =@Saldo- @Ded_BPOPULAR
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_poliza)
							BEGIN
								SET @Saldo=@Saldo-@Ded_poliza
						END
						ELSE
							BEGIN
								SET @Ded_poliza =@Saldo- @Ded_poliza
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Renta)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Renta
						END
						ELSE
							BEGIN
								SET @Ded_Renta =@Saldo- @Ded_Renta
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Prestamo)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Prestamo
						END
						ELSE
							BEGIN
								SET @Ded_Prestamo =@Saldo- @Ded_Prestamo
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Colegio)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Colegio
						END
						ELSE
							BEGIN
								SET @Ded_Colegio =@Saldo- @Ded_Colegio
								SET @Saldo=0
						END

				END -- FIN SALDO < DED_PENSION
				ELSE
					BEGIN



						IF(@Saldo >= @Ded_Pen_Magisterio)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Pen_Magisterio
						END
						ELSE
							BEGIN
								SET @Ded_Pen_Magisterio =@Saldo- @Ded_Pen_Magisterio
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_CCSS)
							BEGIN
								SET @Saldo=@Saldo-@Ded_CCSS
						END
						ELSE
							BEGIN
								SET @Ded_CCSS =@Saldo- @Ded_CCSS
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_BPOPULAR)
							BEGIN
								SET @Saldo=@Saldo-@Ded_BPOPULAR
						END
						ELSE
							BEGIN
								SET @Ded_BPOPULAR =@Saldo- @Ded_BPOPULAR
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_poliza)
							BEGIN
								SET @Saldo=@Saldo-@Ded_poliza
						END
						ELSE
							BEGIN
								SET @Ded_poliza =@Saldo- @Ded_poliza
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Renta)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Renta
						END
						ELSE
							BEGIN
								SET @Ded_Renta =@Saldo- @Ded_Renta
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Prestamo)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Prestamo
						END
						ELSE
							BEGIN
								SET @Ded_Prestamo =@Saldo - @Ded_Prestamo
								SET @Saldo=0
						END
						-- *********************************************************************************
						IF(@Saldo >= @Ded_Colegio)
							BEGIN
								SET @Saldo=@Saldo-@Ded_Colegio
						END
						ELSE
							BEGIN
								SET @Ded_Colegio =@Saldo- @Ded_Colegio
								SET @Saldo=0
						END

						SET @Saldo=@Saldo+@Incapacidad

				END

			INSERT INTO DESGLOSE_PLANILLA(COD_PLANILLA,
										  ID_EMPLEADO,
										  QUINCENA_1,
										  QUINCENA_2,
										  TOTAL,
										  MONTO_INCAPACIDAD,
										  PAG_ANUALIDAD,
										  PAG_ESCALAFON,
										  PAG_EXCLUSIVIDAD,
										  DED_PENSION,
										  DED_MAGISTERIO,
										  DED_CCSS,
										  DED_BANCOPOPULAR,
										  DED_POLIZA,
										  DED_RENTA,
										  DED_COLEGIATURA,
										  DED_PRESTAMO)
										  VALUES(@Cod_Planilla,
												 @Id_empl,
												 @Saldo*0.4,
												 @Saldo*0.6,
												 @Saldo,
												 @Incapacidad,
												 @Anualidad,
												 @Escalafon,
												 @Exclusividad,
												 @Ded_Pension,
												 @Ded_Pen_Magisterio,
												 @Ded_CCSS,
												 @Ded_BPOPULAR,
												 @Ded_poliza,
												 @Ded_Renta,
												 @Ded_Colegio,
												 @Ded_Prestamo)

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @Msj=ERROR_MESSAGE()
	END CATCH
GO










/* AGREGAR DESGLOSE DE PLANILLA EN MASA

   Recibe como parametros :
   @Cod_Planilla: identificador de la planilla

   crea una tabla para guardar el id de los empleados registrados y llama la funcion de agregar desglose_planilla por
   cada empleado que este registrado


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
	BEGIN TRY --TEMPORAL
	-- COPIAR LOS DATOS DE LA TABLA DE EMPLEADOS A LA TABLA 
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




declare @a nvarchar(100)

set @a='create procedure spPrueva(@a int)as begin select * from empleados end'

execute sp_executesql @a

exec dbo.spPrueva 1




select * into #prod from EMPLEADOS

select * from #prod


CREATE VIEW PRUEVA1 AS SELECT  ID_EMPLEADO,NOMBRE FROM #prod

SELECT * FROM DBO.PRUEVA1
INSERT INTO dbo.PRUEVA1(ID_EMPLEADO,NOMBRE)values('12','adrian prueva')

-- ****************************************************************************************************************************

												          -- TABLA PLANILLA
-- ****************************************************************************************************************************

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
















