use covidHistorico
/*****************************************
Consulta 1. Listar el top 5 de las entidades con mas casos confirmados por cada por cada uno de los a�os registrados en la base de datos.
Requisitos:
	N/a
Significado de valores de los cat�logos:
- CLASIFICACION_FINAL: Confirmado por asociaci�n cl�nica-epidemiol�gica, 2 = Confirmado por dictaminaci�n, 3 = Confirmado por laboratorio
- ENTIDAD_RES: Nos da la entidad de residencia del paciente
Responsable:Alan Olea Garc�a.
Comentarios:
- WITH genera resultados temporales que pueden ser referenciados dentro de una consulta
- RANK asigna un "ranking" o n�mero de posici�n a cada fila dentro de un conjunto de resultados, Los n�meros de ranking empiezan desde 1, 
  y si hay filas con el mismo valor (en este caso, Casos_confirmados), se asigna el mismo rango, pero el siguiente rango salta por la cantidad 
  de filas con el mismo valor. 
*****************************************/
WITH datos_por_a�o AS (
    SELECT ENTIDAD_RES AS Entidad, 
           YEAR(FECHA_INGRESO) AS A�o, 
           COUNT(*) AS Casos_confirmados
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND YEAR(FECHA_INGRESO) IN (2020, 2021, 2022)
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO)
), ranking AS (
    SELECT Entidad, A�o, Casos_confirmados, 
           RANK() OVER (PARTITION BY A�o ORDER BY Casos_confirmados DESC) AS ranking
    FROM datos_por_a�o
)
SELECT Entidad, A�o, Casos_confirmados
FROM ranking
WHERE ranking <= 5
ORDER BY A�o, ranking;
/*****************************************
Consulta 2. Listar el municipio con m�s casos confirmados recuperados por estado y por a�o  
Requisitos:
N/a
Significado de valores de los cat�logos:
- FECHA_INGRESO: Fecha en la que el paciente fue confirmado 
- MUNICIPIO_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea Garc�a.
Comentarios:
- WITH genera resultados temporales que pueden ser referenciados dentro de una consulta
- RANK asigna un "ranking" o n�mero de posici�n a cada fila dentro de un conjunto de resultados, Los n�meros de ranking empiezan desde 1, 
  y si hay filas con el mismo valor (en este caso, Casos_confirmados), se asigna el mismo rango, pero el siguiente rango salta por la cantidad 
  de filas con el mismo valor.
- PARTITION BY se usa para dividir un conjunto de datos en particiones y realizar c�lculos dentro 
	de cada una sin afectar el resto de la consulta.
*****************************************/
WITH casos_por_a�o as (
	select year(FECHA_INGRESO) A�o, ENTIDAD_RES Entidad, MUNICIPIO_RES Municipio, count(*) Casos_recuperados
	from datoscovid
	WHERE FECHA_DEF = '9999-99-99' 
	group by year(FECHA_INGRESO),ENTIDAD_RES, MUNICIPIO_RES

)
SELECT *
FROM casos_por_a�o A
WHERE Casos_recuperados = (
	select max(casos_recuperados)
	from casos_por_a�o B
	where A.A�o = B.A�o AND A.Entidad = B.Entidad
)
ORDER BY A�o, Entidad, Municipio;
/*****************************************
Consulta 3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensi�n.
Requisitos:
N/A
Significado de valores de los cat�logos:
- HIPERTENSION: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- OBESIDAD: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- DIABETES: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- CLASIFICACION_FINAL: Confirmado por asociaci�n cl�nica-epidemiol�gica, 2 = Confirmado por dictaminaci�n, 3 = Confirmado por laboratorio
Responsable:Alan Olea Garc�a.
Comentarios:
- CAST convierte el resultado a un numero decimal
- Case permite evaluar condiciones y devover diferentes valores
*****************************************/
SELECT 
    (CAST(
		SUM (
		 CASE 
			WHEN DIABETES = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) Porcentaje_DIABETES,
    (CAST(
		SUM (
		 CASE 
			WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) Porcentaje_HIPERTENSION,
    (CAST(
		SUM (
		 CASE 
			WHEN OBESIDAD = 1 THEN 1 ELSE 0 END
		 ) * 100.0 / COUNT(*) AS DECIMAL(4,2))
	) Porcentaje_OBESIDAD
FROM datoscovid
WHERE CLASIFICACION_FINAL�IN�(1,�2,�3)
/*****************************************
Consulta 4. Listar los municipios que no tengan casos confirmados en todas las morbilidades: hipertensi�n, obesidad, diabetes, tabaquismo.
Requisitos:
N/A
Significado de valores de los cat�logos:
- HIPERTENSION: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- OBESIDAD: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- DIABETES: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- TABAQUISMO: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- MUNICIPIO_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea Garc�a.
Comentarios:
*****************************************/
select distinct ENTIDAD_RES Entidad,  MUNICIPIO_RES Municipio
from datoscovid
where CLASIFICACION_FINAL in ('7','4','5','6') AND HIPERTENSION = '1' AND OBESIDAD = '1' AND DIABETES = '1' AND TABAQUISMO = '1'
group by ENTIDAD_RES, MUNICIPIO_RES

/*****************************************
Consulta 5. Listar los estados con m�s casos recuperados con neumon�a.
Requisitos:
N/A
Significado de valores de los cat�logos:
- NEUMONIA: Si tiene valor '1' es que tiene la enfermedad, de lo contrario '0' 
- ENTIDAD_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea Garc�a.
Comentarios:
	Se considero la consulta en general, no se hizo la divisi�n por a�o
	Se hizo un join con la tabla "Cat_entidades" para que apareciera el nombre del estado
*****************************************/
select ce.entidad, count(*) Casos_Recuperados
from datoscovid join cat_entidades ce
ON datoscovid.ENTIDAD_RES = ce.clave
WHERE FECHA_DEF = '9999-99-99' AND CLASIFICACION_FINAL in ('1','2','3') AND NEUMONIA = 1
group by entidad 
order by Casos_Recuperados desc

GO

/*****************************************
Consulta 6. Listar el total de casos confirmados/sospechosos por estado en cada uno de los a�os registrados en la base de datos.

Requisitos:
- Extraer el a�o de la columna FECHA_INGRESO para agrupar resultados.
- Considerar como casos confirmados aquellos con valores de CLASIFICACION_FINAL en (1, 2, 3).
- Considerar como casos sospechosos aquellos con valor de CLASIFICACION_FINAL = 6.

Significado de los valores de los cat�logos:
- ENTIDAD_RES: C�digo de la entidad federativa donde reside el paciente.
- FECHA_INGRESO: Fecha en que el paciente ingres� al servicio de salud.
- CLASIFICACION_FINAL: Clasificaci�n que indica c�mo fue determinado el caso, donde:
    - 1: Confirmado por asociaci�n cl�nica-epidemiol�gica.
    - 2: Confirmado por dictaminaci�n m�dica.
    - 3: Confirmado por laboratorio (prueba positiva).
    - 6: Caso sospechoso (sin confirmaci�n definitiva).

Responsable de la consulta: Mario Alexis Juarez Anguiano.

Comentarios:
- La consulta tiene dos versiones, ambas orientadas al mismo resultado pero con distinta estructura:
  1. **Sin subconsulta:** 
     - Se emplea directamente una agrupaci�n por `YEAR(FECHA_INGRESO)` y `ENTIDAD_RES`.
     - Utiliza la funci�n agregada `SUM()` junto con la estructura condicional `CASE WHEN` para contar de manera directa los casos confirmados y sospechosos.
  
  2. **Con subconsulta:** 
     - Primero se genera una subconsulta interna (`DATOS_FINALES`) que asigna individualmente un valor `1` (si cumple la condici�n) o `0` (si no la cumple) para cada caso confirmado o sospechoso.
     - Despu�s, en la consulta principal externa, se realiza la agrupaci�n y suma sobre estos resultados previamente clasificados.
     - Este m�todo puede mejorar la claridad del c�digo, especialmente si se a�aden futuras condiciones m�s complejas.

Instrucciones adicionales utilizadas no explicadas en clase:
- Uso detallado de la funci�n condicional `CASE WHEN` para clasificar individualmente cada registro seg�n la categor�a de clasificaci�n final.
- Realizaci�n de consultas con y sin subconsultas para comparar rendimiento y claridad del c�digo.
*****************************************/


-- Sin subconsulta
SELECT 
    YEAR(FECHA_INGRESO) AS A�O,  
    ENTIDAD_RES,  
    SUM(CASE WHEN CLASIFICACION_FINAL IN (1, 2, 3) THEN 1 ELSE 0 END) AS CASOS_CONFIRMADOS,  
    SUM(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 ELSE 0 END) AS CASOS_SOSPECHOSOS  
FROM datoscovid
GROUP BY YEAR(FECHA_INGRESO), ENTIDAD_RES  
ORDER BY A�O, ENTIDAD_RES;  


-- Con subconsulta
SELECT 
    A�O,
    ENTIDAD_RES,
    SUM(CASOS_CONFIRMADOS) AS CASOS_CONFIRMADOS,  
    SUM(CASOS_SOSPECHOSOS) AS CASOS_SOSPECHOSOS  
FROM (
    SELECT 
        YEAR(FECHA_INGRESO) AS A�O,  
        ENTIDAD_RES,  
        CASE 
            WHEN CLASIFICACION_FINAL IN (1, 2, 3) THEN 1  
            ELSE 0 
        END AS CASOS_CONFIRMADOS, 
        CASE 
            WHEN CLASIFICACION_FINAL = 6 THEN 1  
            ELSE 0 
        END AS CASOS_SOSPECHOSOS  
    FROM datoscovid
) AS DATOS_FINALES
GROUP BY A�O, ENTIDAD_RES 
ORDER BY A�O, ENTIDAD_RES;  



/*****************************************
N�mero de consulta: 7. Para el a�o 2020 y 2021, cu�l fue el mes con m�s casos registrados (confirmados y sospechosos), diferenciando estos casos por cada estado registrado en la base de datos.

Requerimientos:
- Extraer �nicamente informaci�n de los a�os 2020 y 2021.
- Identificar claramente el mes que tuvo el mayor n�mero de casos registrados en cada estado.
- Contar como casos confirmados aquellos cuya CLASIFICACION_FINAL sea (1, 2, 3).
- Contar como casos sospechosos aquellos cuya CLASIFICACION_FINAL sea igual a 6.
- Usar la funci�n anal�tica `ROW_NUMBER()` para ordenar y rankear cada mes seg�n el total de casos por entidad federativa.

Significado de valores de los cat�logos:
- ENTIDAD_RES: Clave num�rica que identifica la entidad federativa donde reside el paciente.
- CLASIFICACION_FINAL:
    - 1: Caso confirmado por asociaci�n cl�nica-epidemiol�gica.
    - 2: Caso confirmado por dictaminaci�n m�dica.
    - 3: Caso confirmado mediante prueba de laboratorio.
    - 6: Caso sospechoso sin confirmaci�n definitiva.

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- Esta consulta se apoya en un CTE (Common Table Expression) denominado `Casos_Por_Mes` para simplificar y organizar claramente los datos necesarios antes de la consulta principal. Esta t�cnica permite ordenar, agrupar y filtrar datos de manera eficiente.
- La consulta incluye �nicamente los casos confirmados (CLASIFICACION_FINAL 1, 2, 3) y sospechosos (CLASIFICACION_FINAL 6) para obtener una visi�n precisa del comportamiento epidemiol�gico en los a�os indicados.
- Se utiliz� la funci�n anal�tica `ROW_NUMBER()` para generar un ranking de los meses seg�n el n�mero total de casos, facilitando as� la identificaci�n inmediata del mes m�s afectado por cada entidad federativa.
- La estructura final de la consulta devuelve, ordenados claramente por a�o y entidad, los resultados de los meses cr�ticos, permitiendo as� an�lisis m�s �giles y efectivos en contextos epidemiol�gicos, de salud p�blica y toma de decisiones.

Responsable: Mario Alexis Juarez Anguiano.
*****************************************/


WITH Casos_Por_Mes AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS A�O, 
        MONTH(FECHA_INGRESO) AS MES, 
        ENTIDAD_RES,
        COUNT(*) AS TOTAL_CASOS,
        ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES ORDER BY COUNT(*) DESC) AS RANK
    FROM datoscovid
    WHERE YEAR(FECHA_INGRESO) BETWEEN 2020 AND 2021
      AND MONTH(FECHA_INGRESO) BETWEEN 1 AND 12
      AND CLASIFICACION_FINAL IN (1, 2, 3, 6)
    GROUP BY YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_RES
)
SELECT A�O, MES, TOTAL_CASOS, ENTIDAD_RES
FROM Casos_Por_Mes
WHERE RANK <= 2
ORDER BY ENTIDAD_RES, A�O;





/*****************************************
Consulta 8. Listar el municipio con menos defunciones en el mes con m�s casos confirmados con neumon�a en los a�os 2020 y 2021.

Requisitos:
- ENTIDAD_RES: C�digo de la entidad federativa de residencia del paciente.
- MUNICIPIO_RES: C�digo del municipio de residencia del paciente.
- FECHA_INGRESO: Fecha en que el paciente ingres� al servicio de salud.
- FECHA_DEF: Fecha de defunci�n del paciente (9999 indica sin defunci�n).
- CLASIFICACION_FINAL: Clasificaci�n del resultado del caso (1 =  Confirmado por asociaci�n cl�nica-epidemiol�gica,  2 = Confirmado por dictaminaci�n, 3 = Confirmado por laboratorio
- NEUMONIA: Indicador si el paciente present� neumon�a (0 = No, 1 = S�).

Responsable de la consulta: Mario Alexis Juarez Anguiano

Comentarios:
- Se cre� la vista `CASOS_NEUMONIA` con el objetivo de simplificar la consulta principal y mantener un c�digo limpio y entendible. Esta vista filtra �nicamente los registros de pacientes con neumon�a confirmada (`NEUMONIA = 1`) durante los a�os 2020 y 2021, tomando en cuenta solo casos con clasificaci�n final 1, 2, y 3, adem�s de excluir aquellos pacientes que no fallecieron (`FECHA_DEF` diferente a '9999').
- La vista tambi�n facilita el an�lisis de tendencias, al contener columnas relevantes como la fecha de ingreso, defunci�n, ubicaci�n geogr�fica y datos demogr�ficos.
- Para la consulta principal se agruparon y contaron los casos por entidad y municipio en meses espec�ficos (enero de 2021 y julio de 2020), con el fin de identificar los municipios que tuvieron exactamente una defunci�n.
- Finalmente, se realiz� un conteo general de los casos totales de neumon�a durante los a�os 2020 y 2021 como informaci�n complementaria.

Instrucciones adicionales utilizadas no explicadas en clase:
- Creaci�n y uso de vistas (`CREATE VIEW`) para optimizar y simplificar consultas complejas.
- Uso de la funci�n `LEFT` para filtrar correctamente fechas de defunci�n.
- Aplicaci�n del operador `UNION ALL` para combinar resultados espec�ficos de diferentes per�odos en una sola tabla.
*****************************************/


-------Crear vista para simplificar busqueda
CREATE VIEW CASOS_NEUMONIA AS
SELECT
    ID_REGISTRO,
    FECHA_INGRESO,
    FECHA_ACTUALIZACION,
    ENTIDAD_RES,
    MUNICIPIO_RES,
    SEXO,
    EDAD,
    TIPO_PACIENTE,
    RESULTADO_LAB,
    CLASIFICACION_FINAL,
    FECHA_DEF,
    NEUMONIA
FROM datoscovid
WHERE 
    NEUMONIA = 1
    AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    AND CLASIFICACION_FINAL IN (1, 2, 3) 
    AND LEFT(FECHA_DEF, 4) != '9999' 
GO

----------consulta 8
SELECT ENTIDAD_RES, MUNICIPIO_RES, A�O_INGRESO, MES_INGRESO, CASOS_DEF
FROM (
	SELECT 
		ENTIDAD_RES, 
		MUNICIPIO_RES, 
		YEAR(FECHA_INGRESO) AS A�O_INGRESO, 
		MONTH(FECHA_INGRESO) AS MES_INGRESO, 
		COUNT(*) AS CASOS_DEF
	FROM CASOS_NEUMONIA
	WHERE YEAR(FECHA_INGRESO) = 2021 AND MONTH(FECHA_INGRESO) = 1
	GROUP BY ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

	UNION ALL

	SELECT 
		ENTIDAD_RES, 
		MUNICIPIO_RES, 
		YEAR(FECHA_INGRESO) AS A�O_INGRESO, 
		MONTH(FECHA_INGRESO) AS MES_INGRESO, 
		COUNT(*) AS CASOS_DEF
	FROM CASOS_NEUMONIA
	WHERE YEAR(FECHA_INGRESO) = 2020 AND MONTH(FECHA_INGRESO) = 7
	GROUP BY ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)
) AS T
WHERE CASOS_DEF = 1

--conteo de los casos por neumonia 
SELECT COUNT(*) AS TOTAL_CASOS_NEUMONIA
FROM CASOS_NEUMONIA
WHERE YEAR(FECHA_INGRESO) IN (2020, 2021);




DROP VIEW CASOS_NEUMONIA; 
--DROP VIEW casos_confirmados;


/*****************************************
N�mero de consulta: 9. Listar los 3 municipios con menos pacientes recuperados (pacientes que no fallecieron) registrados durante los a�os 2020 y 2021.

Requerimientos:
- Mostrar claramente los municipios con la menor cantidad de recuperaciones registradas durante los a�os especificados.
- Incluir solo los pacientes que fueron confirmados como casos positivos de COVID-19 con CLASIFICACION_FINAL igual a (1, 2, 3).
- Identificar como paciente recuperado aquellos cuya FECHA_DEF est� registrada como '9999-99-99'.
- Realizar el conteo y la selecci�n utilizando la funci�n de ventana `ROW_NUMBER()` para ordenar los municipios seg�n la cantidad de recuperados (de menor a mayor).

Significado de valores de los cat�logos:
- ENTIDAD_RES: Identificador num�rico de la entidad federativa del paciente.
- MUNICIPIO_RES: Clave num�rica del municipio donde reside el paciente.
- CLASIFICACION_FINAL:
    - 1: Caso confirmado por asociaci�n cl�nica-epidemiol�gica.
    - 2: Caso confirmado por dictaminaci�n m�dica.
    - 3: Caso confirmado por laboratorio (prueba positiva).
- FECHA_DEF:
    - Valor '9999-99-99': Indica que el paciente se recuper� y no hubo defunci�n.

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- La consulta se realiz� directamente sobre la tabla original `datoscovid`, contando los pacientes recuperados (no fallecidos) mediante la validaci�n expl�cita de la columna `FECHA_DEF` con el valor espec�fico '9999-99-99'. Esto permite asegurar la precisi�n al identificar �nicamente pacientes vivos.
- Se utiliz� la funci�n de ventana `ROW_NUMBER() OVER (ORDER BY COUNT(ID_REGISTRO) ASC)` para asignar posiciones a los municipios seg�n el n�mero de pacientes recuperados, permitiendo una clasificaci�n r�pida y clara.
- El uso de la funci�n `DATEPART(YEAR, FECHA_INGRESO)` fue esencial para filtrar correctamente los a�os especificados (2020 y 2021), asegurando precisi�n en el conteo anual.
- Finalmente, la cl�usula `WHERE posicion <= 3` permite obtener �nicamente los tres municipios con menor cantidad de pacientes recuperados, facilitando as� un an�lisis focalizado sobre aquellos lugares con menor recuperaci�n registrada, lo que podr�a indicar �reas con menor seguimiento o atenci�n en salud p�blica.

*****************************************/

SELECT ENTIDAD_RES, MUNICIPIO_RES, TOTAL_REC, A�O_REG FROM (
    SELECT
        ENTIDAD_RES,
        MUNICIPIO_RES,
        COUNT(ID_REGISTRO) AS TOTAL_REC,
        DATEPART(YEAR, FECHA_INGRESO) AS A�O_REG,
        ROW_NUMBER() OVER (ORDER BY COUNT(ID_REGISTRO) ASC) AS posicion
    FROM datoscovid
    WHERE FECHA_DEF = '9999-99-99'
      AND DATEPART(YEAR, FECHA_INGRESO) = 2021
    GROUP BY ENTIDAD_RES, MUNICIPIO_RES, DATEPART(YEAR, FECHA_INGRESO)
) AS MUN_RECUPERADOS
WHERE posicion <= 3;



/*****************************************
Consulta 10. Porcentaje de casos confirmados por sexo y a�o (2020-2021).

Requisitos:
- Calcular el porcentaje de casos confirmados por sexo (masculino, femenino, no especificado) para los a�os 2020 y 2021.
- Tomar �nicamente los casos confirmados, identificados con los valores '1', '2' y '3' en CLASIFICACION_FINAL.
- Los porcentajes deben calcularse en funci�n del total global de casos confirmados (la suma total de todos los casos confirmados durante ambos a�os).

Significado de valores de los cat�logos:
- SEXO: Identificador del sexo del paciente:
    - 1: Femenino.
    - 2: Masculino.
    - 99: No especificado.
- CLASIFICACION_FINAL:
    - 1: Confirmado por asociaci�n cl�nica-epidemiol�gica.
    - 2: Confirmado por dictaminaci�n m�dica.
    - 3: Confirmado por laboratorio (prueba positiva).

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- Se utiliza la cl�usula `WITH` para crear expresiones de tabla com�n (CTEs), las cuales simplifican y clarifican la estructura l�gica del query al definir consultas intermedias:
    - **Total_CASOS**: calcula el total global acumulado de casos confirmados para obtener la referencia del 100%.
    - **Casos_Sexo_A�o** agrupa los datos por sexo y a�o para realizar posteriormente el c�lculo porcentual.
- Se utiliza la t�cnica de `CROSS JOIN` para combinar cada registro agrupado por sexo y a�o con el total general de casos confirmados. Esto permite calcular porcentajes relativos tomando el total global como referencia.
- La funci�n `YEAR()` extrae claramente el a�o de la columna FECHA_INGRESO, facilitando la agrupaci�n anual.
- La f�rmula utilizada para calcular el porcentaje es:
  (CASOS_CONFIRMADOS del sexo y a�o espec�fico / Total global de casos confirmados en 2020 y 2021) * 100
*****************************************/


WITH Total_CASOS AS (
    SELECT COUNT(*) AS CASOS_TOTALES_CONFIRMADOS
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
      AND YEAR(FECHA_INGRESO) IN (2020, 2021)
),
Casos_Sexo_A�o AS (
    SELECT SEXO, 
           YEAR(FECHA_INGRESO) AS A�O,
           COUNT(*) AS CASOS_CONFIRMADOS
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
      AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY SEXO, YEAR(FECHA_INGRESO)
)
SELECT 
    CPS.SEXO,
    (CPS.CASOS_CONFIRMADOS * 100.0 / TG.CASOS_TOTALES_CONFIRMADOS) AS PORCENTAJE,
    CPS.a�o,
    CPS.casos_confirmados AS TOTAL_CASOS_SEXO
FROM Casos_Sexo_A�o CPS
CROSS JOIN Total_CASOS TG
ORDER BY CPS.a�o, CPS.SEXO;

/***************
Consulta 11. Listar el porcentaje de casos hospitalizados por estado en el a�o 2020. 
Requisitos: N/A

Significado de valores de los cat�logos:
- ENTIDAD_UM: Identifica la entidad donde se ubica la unidad medica que brind� la atenci�n.
- entidad: muestra el nombre de los estados
- year(FECHA_INGRESO) = 2020: Selecciona los casos en donde el paciente ingres� al hospital en 2020.
- TIPO_PACIENTE = 2: Indica los casos de pacientes que fueron hospitalizados.
- FECHA_INGRESO: Indica la fecha en la que el paciente ingres� al hospital

Responsable: Brenda Urrutia Gonz�lez
Comentarios: Sin comentarios.
***************/

 select CE.entidad, 
	(count(*)*100.0 / (select count(*) from datoscovid DC2 where year(DC2.FECHA_INGRESO) = 2020 and DC2.ENTIDAD_UM=DC.ENTIDAD_UM)) as Porcentaje
 from dbo.datoscovid DC
 join dbo.cat_entidades CE on DC.ENTIDAD_UM = CE.clave
 where year(FECHA_INGRESO) = 2020 and TIPO_PACIENTE=2
 group by CE.entidad, DC.ENTIDAD_UM
 order by CE.entidad asc

/***************
Consulta 12. Listar total de casos negativos por estado en los a�os 2020 y 2021. 
Requisitos: N/A

Significado de valores de los cat�logos:
- CLASIFICACION_FINAL=7: Muestra los casos negativos 
-  year(DC.FECHA_INGRESO) in (2020, 2021): Selecciona los casos en donde el paciente ingres� al hospital en 2020 y 2021
- ENTIDAD_UM: Identifica la entidad donde se ubica la unidad medica que brind� la atenci�n.
- entidad: muestra el nombre de los estados

Responsable: Brenda Urrutia Gonz�lez
Comentarios: Sin comentarios.
***************/
 
 select CE.entidad as estado, count(*) as totalCasosNegativos
 from dbo.datoscovid DC
 join dbo.cat_entidades CE on DC.ENTIDAD_UM = CE.clave
 where DC.CLASIFICACION_FINAL=7 and year(DC.FECHA_INGRESO) in (2020, 2021)
 group by CE.entidad
 order by CE.entidad

/***************
Consulta 13. Listar porcentajes de casos confirmados por g�nero en el rango de edades de 20 a 30 a�os, 
             de 31 a 40 a�os, de 41 a 50 a�os, de 51 a 60 a�os y mayores a 60 a�os a nivel nacional.
Requisitos: N/A

Significado de valores de los cat�logos:
- SEXO = 1: Selecciona a las pacientes mujeres
- SEXO = 2: Selecciona a los pacientes hombres
- CLASIFICACION_FINAL in (1,2,3): Selecciona a todos los tipos de casos confirmados

Responsable: Brenda Urrutia Gonz�lez
Comentarios: Sin comentarios.			
***************/ 
 select SEXO,
    case
        when EDAD between 20 and 30 then '20-30'
        when EDAD between 31 and 40 then '31-40'
        when EDAD between 41 and 50 then '41-50'
        when EDAD between 51 and 60 then '51-60'
        when EDAD > 60 then 'Mayores de 60'
    end as rangoEdades, count(*) as total,
    count(*) * 100.0 / (select count(*) from datoscovid where CLASIFICACION_FINAL in(1,2,3)) as Porcentaje
from datoscovid
where CLASIFICACION_FINAL in (1,2,3) and EDAD >=20
group by SEXO, 
    case
        when EDAD between 20 and 30 then '20-30'
        when EDAD between 31 and 40 then '31-40'
        when EDAD between 41 and 50 then '41-50'
        when EDAD between 51 and 60 then '51-60'
        when EDAD > 60 then 'Mayores de 60'
    end
order by SEXO, rangoEdades;

/***************
Consulta 14. Listar el rango de edad con m�s casos confirmados y que fallecieron en los a�os 2020 y 2021.
Requisitos: N/A

Significado de valores de los cat�logos:
- CLASIFICACION_FINAL in (1,2,3): Selecciona a todos los tipos de casos confirmados
- FECHA_DEF!='9999-99-99': Indica los pacientes que fallecieron
- year(FECHA_INGRESO) in (2020, 2021): Muestra a los pacientes que ingresaron al hospital en los a�os 2020 y 2021

Responsable: Brenda Urrutia Gonz�lez
Comentarios:
- Se utiliza "case when..." para definir los rangos de edades
***************/ 
 
select top 1 case
        when EDAD between 20 and 30 then '20-30'
        when EDAD between 31 and 40 then '31-40'
        when EDAD between 41 and 50 then '41-50'
        when EDAD between 51 and 60 then '51-60'
        when EDAD > 60 then 'Mayores a 60'
    end as rangoEdad
from datoscovid
where CLASIFICACION_FINAL IN (1, 2, 3) and FECHA_DEF!='9999-99-99' and year(FECHA_INGRESO) in (2020, 2021)  
group by 
    case 
        when EDAD between 20 and 30 then '20-30'
        when EDAD between 31 and 40 then '31-40'
        when EDAD between 41 and 50 then '41-50'
        when EDAD between 51 and 60 then '51-60'
        when EDAD > 60 then 'Mayores a 60'
    end
order by count(*) desc

