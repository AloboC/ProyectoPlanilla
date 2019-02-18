
GO
	USE PLANILLA_DB
GO


--INSERT INTO PORCENTAJES(PORC_ANUALIDAD,
--						PORC_ESCALAFON_C1,
--						PORC_ESCALAFON_C2,
--						PORC_EXCLUSIVIDAD,
--						PORC_DED_MAGISTERIO,
--						PORC_DED_BP,
--						PORC_DED_CCSS,
--						MONTO_DED_POLIZA,
--						PORC_DED_RENTA_INTERMEDIO,
--						PORC_DED_RENTA_MAYOR,
--						MONTO_DED_COLEGIO,
--						TOPE_SALARIO_SIN_DEDUCCION_RENTA,
--						TOPE_SALARIO_CON_DEDUCCION_RENTA)
--			VALUES(2,3,1,30,8,1,3,13450,10,15,5000,817000,1226000)







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
					  
					  
											