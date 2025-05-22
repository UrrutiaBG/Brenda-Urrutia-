use covidHistorico
/*****************************************
Consulta 1. Listar el top 5 de las entidades con mas casos confirmados por cada por cada uno de los años registrados en la base de datos.
Requisitos:
	N/a
Significado de valores de los catálogos:
- CLASIFICACION_FINAL: Confirmado por asociación clínica-epidemiológica, 2 = Confirmado por dictaminación, 3 = Confirmado por laboratorio
- ENTIDAD_RES: Nos da la entidad de residencia del paciente
Responsable:Alan Olea García.
Comentarios:
- WITH genera resultados temporales que pueden ser referenciados dentro de una consulta
- RANK asigna un "ranking" o número de posición a cada fila dentro de un conjunto de resultados, Los números de ranking empiezan desde 1, 
  y si hay filas con el mismo valor (en este caso, Casos_confirmados), se asigna el mismo rango, pero el siguiente rango salta por la cantidad 
  de filas con el mismo valor. 
*****************************************/
WITH datos_por_año AS (
    SELECT ENTIDAD_RES AS Entidad, 
           YEAR(FECHA_INGRESO) AS Año, 
           COUNT(*) AS Casos_confirmados
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND YEAR(FECHA_INGRESO) IN (2020, 2021, 2022)
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO)
), ranking AS (
    SELECT Entidad, Año, Casos_confirmados, 
           RANK() OVER (PARTITION BY Año ORDER BY Casos_confirmados DESC) AS ranking
    FROM datos_por_año
)
SELECT Entidad, Año, Casos_confirmados
FROM ranking
WHERE ranking <= 5
ORDER BY Año, ranking;
/*****************************************
Consulta 2. Listar el municipio con más casos confirmados recuperados por estado y por año  
Requisitos:
N/a
Significado de valores de los catálogos:
- FECHA_INGRESO: Fecha en la que el paciente fue confirmado 
- MUNICIPIO_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea García.
Comentarios:
- WITH genera resultados temporales que pueden ser referenciados dentro de una consulta
- RANK asigna un "ranking" o número de posición a cada fila dentro de un conjunto de resultados, Los números de ranking empiezan desde 1, 
  y si hay filas con el mismo valor (en este caso, Casos_confirmados), se asigna el mismo rango, pero el siguiente rango salta por la cantidad 
  de filas con el mismo valor.
- PARTITION BY se usa para dividir un conjunto de datos en particiones y realizar cálculos dentro 
	de cada una sin afectar el resto de la consulta.
*****************************************/
WITH casos_por_año as (
	select year(FECHA_INGRESO) Año, ENTIDAD_RES Entidad, MUNICIPIO_RES Municipio, count(*) Casos_recuperados
	from datoscovid
	WHERE FECHA_DEF = '9999-99-99' 
	group by year(FECHA_INGRESO),ENTIDAD_RES, MUNICIPIO_RES

)
SELECT *
FROM casos_por_año A
WHERE Casos_recuperados = (
	select max(casos_recuperados)
	from casos_por_año B
	where A.Año = B.Año AND A.Entidad = B.Entidad
)
ORDER BY Año, Entidad, Municipio;
/*****************************************
Consulta 3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensión.
Requisitos:
N/A
Significado de valores de los catálogos:
- HIPERTENSION: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- OBESIDAD: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- DIABETES: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- CLASIFICACION_FINAL: Confirmado por asociación clínica-epidemiológica, 2 = Confirmado por dictaminación, 3 = Confirmado por laboratorio
Responsable:Alan Olea García.
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
WHERE CLASIFICACION_FINAL IN (1, 2, 3)
/*****************************************
Consulta 4. Listar los municipios que no tengan casos confirmados en todas las morbilidades: hipertensión, obesidad, diabetes, tabaquismo.
Requisitos:
N/A
Significado de valores de los catálogos:
- HIPERTENSION: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- OBESIDAD: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- DIABETES: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- TABAQUISMO: Si tiene valor '1' es que tiene la enfermadad, de lo contrario '0'
- MUNICIPIO_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea García.
Comentarios:
*****************************************/
select distinct ENTIDAD_RES Entidad,  MUNICIPIO_RES Municipio
from datoscovid
where CLASIFICACION_FINAL in ('7','4','5','6') AND HIPERTENSION = '1' AND OBESIDAD = '1' AND DIABETES = '1' AND TABAQUISMO = '1'
group by ENTIDAD_RES, MUNICIPIO_RES

/*****************************************
Consulta 5. Listar los estados con más casos recuperados con neumonía.
Requisitos:
N/A
Significado de valores de los catálogos:
- NEUMONIA: Si tiene valor '1' es que tiene la enfermedad, de lo contrario '0' 
- ENTIDAD_RES: Nos da el municipio de residencia del paciente
Responsable:Alan Olea García.
Comentarios:
	Se considero la consulta en general, no se hizo la división por año
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
Consulta 6. Listar el total de casos confirmados/sospechosos por estado en cada uno de los años registrados en la base de datos.

Requisitos:
- Extraer el año de la columna FECHA_INGRESO para agrupar resultados.
- Considerar como casos confirmados aquellos con valores de CLASIFICACION_FINAL en (1, 2, 3).
- Considerar como casos sospechosos aquellos con valor de CLASIFICACION_FINAL = 6.

Significado de los valores de los catálogos:
- ENTIDAD_RES: Código de la entidad federativa donde reside el paciente.
- FECHA_INGRESO: Fecha en que el paciente ingresó al servicio de salud.
- CLASIFICACION_FINAL: Clasificación que indica cómo fue determinado el caso, donde:
    - 1: Confirmado por asociación clínica-epidemiológica.
    - 2: Confirmado por dictaminación médica.
    - 3: Confirmado por laboratorio (prueba positiva).
    - 6: Caso sospechoso (sin confirmación definitiva).

Responsable de la consulta: Mario Alexis Juarez Anguiano.

Comentarios:
- La consulta tiene dos versiones, ambas orientadas al mismo resultado pero con distinta estructura:
  1. **Sin subconsulta:** 
     - Se emplea directamente una agrupación por `YEAR(FECHA_INGRESO)` y `ENTIDAD_RES`.
     - Utiliza la función agregada `SUM()` junto con la estructura condicional `CASE WHEN` para contar de manera directa los casos confirmados y sospechosos.
  
  2. **Con subconsulta:** 
     - Primero se genera una subconsulta interna (`DATOS_FINALES`) que asigna individualmente un valor `1` (si cumple la condición) o `0` (si no la cumple) para cada caso confirmado o sospechoso.
     - Después, en la consulta principal externa, se realiza la agrupación y suma sobre estos resultados previamente clasificados.
     - Este método puede mejorar la claridad del código, especialmente si se añaden futuras condiciones más complejas.

Instrucciones adicionales utilizadas no explicadas en clase:
- Uso detallado de la función condicional `CASE WHEN` para clasificar individualmente cada registro según la categoría de clasificación final.
- Realización de consultas con y sin subconsultas para comparar rendimiento y claridad del código.
*****************************************/


-- Sin subconsulta
SELECT 
    YEAR(FECHA_INGRESO) AS AÑO,  
    ENTIDAD_RES,  
    SUM(CASE WHEN CLASIFICACION_FINAL IN (1, 2, 3) THEN 1 ELSE 0 END) AS CASOS_CONFIRMADOS,  
    SUM(CASE WHEN CLASIFICACION_FINAL = 6 THEN 1 ELSE 0 END) AS CASOS_SOSPECHOSOS  
FROM datoscovid
GROUP BY YEAR(FECHA_INGRESO), ENTIDAD_RES  
ORDER BY AÑO, ENTIDAD_RES;  


-- Con subconsulta
SELECT 
    AÑO,
    ENTIDAD_RES,
    SUM(CASOS_CONFIRMADOS) AS CASOS_CONFIRMADOS,  
    SUM(CASOS_SOSPECHOSOS) AS CASOS_SOSPECHOSOS  
FROM (
    SELECT 
        YEAR(FECHA_INGRESO) AS AÑO,  
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
GROUP BY AÑO, ENTIDAD_RES 
ORDER BY AÑO, ENTIDAD_RES;  



/*****************************************
Número de consulta: 7. Para el año 2020 y 2021, cuál fue el mes con más casos registrados (confirmados y sospechosos), diferenciando estos casos por cada estado registrado en la base de datos.

Requerimientos:
- Extraer únicamente información de los años 2020 y 2021.
- Identificar claramente el mes que tuvo el mayor número de casos registrados en cada estado.
- Contar como casos confirmados aquellos cuya CLASIFICACION_FINAL sea (1, 2, 3).
- Contar como casos sospechosos aquellos cuya CLASIFICACION_FINAL sea igual a 6.
- Usar la función analítica `ROW_NUMBER()` para ordenar y rankear cada mes según el total de casos por entidad federativa.

Significado de valores de los catálogos:
- ENTIDAD_RES: Clave numérica que identifica la entidad federativa donde reside el paciente.
- CLASIFICACION_FINAL:
    - 1: Caso confirmado por asociación clínica-epidemiológica.
    - 2: Caso confirmado por dictaminación médica.
    - 3: Caso confirmado mediante prueba de laboratorio.
    - 6: Caso sospechoso sin confirmación definitiva.

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- Esta consulta se apoya en un CTE (Common Table Expression) denominado `Casos_Por_Mes` para simplificar y organizar claramente los datos necesarios antes de la consulta principal. Esta técnica permite ordenar, agrupar y filtrar datos de manera eficiente.
- La consulta incluye únicamente los casos confirmados (CLASIFICACION_FINAL 1, 2, 3) y sospechosos (CLASIFICACION_FINAL 6) para obtener una visión precisa del comportamiento epidemiológico en los años indicados.
- Se utilizó la función analítica `ROW_NUMBER()` para generar un ranking de los meses según el número total de casos, facilitando así la identificación inmediata del mes más afectado por cada entidad federativa.
- La estructura final de la consulta devuelve, ordenados claramente por año y entidad, los resultados de los meses críticos, permitiendo así análisis más ágiles y efectivos en contextos epidemiológicos, de salud pública y toma de decisiones.

Responsable: Mario Alexis Juarez Anguiano.
*****************************************/


WITH Casos_Por_Mes AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS AÑO, 
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
SELECT AÑO, MES, TOTAL_CASOS, ENTIDAD_RES
FROM Casos_Por_Mes
WHERE RANK <= 2
ORDER BY ENTIDAD_RES, AÑO;





/*****************************************
Consulta 8. Listar el municipio con menos defunciones en el mes con más casos confirmados con neumonía en los años 2020 y 2021.

Requisitos:
- ENTIDAD_RES: Código de la entidad federativa de residencia del paciente.
- MUNICIPIO_RES: Código del municipio de residencia del paciente.
- FECHA_INGRESO: Fecha en que el paciente ingresó al servicio de salud.
- FECHA_DEF: Fecha de defunción del paciente (9999 indica sin defunción).
- CLASIFICACION_FINAL: Clasificación del resultado del caso (1 =  Confirmado por asociación clínica-epidemiológica,  2 = Confirmado por dictaminación, 3 = Confirmado por laboratorio
- NEUMONIA: Indicador si el paciente presentó neumonía (0 = No, 1 = Sí).

Responsable de la consulta: Mario Alexis Juarez Anguiano

Comentarios:
- Se creó la vista `CASOS_NEUMONIA` con el objetivo de simplificar la consulta principal y mantener un código limpio y entendible. Esta vista filtra únicamente los registros de pacientes con neumonía confirmada (`NEUMONIA = 1`) durante los años 2020 y 2021, tomando en cuenta solo casos con clasificación final 1, 2, y 3, además de excluir aquellos pacientes que no fallecieron (`FECHA_DEF` diferente a '9999').
- La vista también facilita el análisis de tendencias, al contener columnas relevantes como la fecha de ingreso, defunción, ubicación geográfica y datos demográficos.
- Para la consulta principal se agruparon y contaron los casos por entidad y municipio en meses específicos (enero de 2021 y julio de 2020), con el fin de identificar los municipios que tuvieron exactamente una defunción.
- Finalmente, se realizó un conteo general de los casos totales de neumonía durante los años 2020 y 2021 como información complementaria.

Instrucciones adicionales utilizadas no explicadas en clase:
- Creación y uso de vistas (`CREATE VIEW`) para optimizar y simplificar consultas complejas.
- Uso de la función `LEFT` para filtrar correctamente fechas de defunción.
- Aplicación del operador `UNION ALL` para combinar resultados específicos de diferentes períodos en una sola tabla.
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
SELECT ENTIDAD_RES, MUNICIPIO_RES, AÑO_INGRESO, MES_INGRESO, CASOS_DEF
FROM (
	SELECT 
		ENTIDAD_RES, 
		MUNICIPIO_RES, 
		YEAR(FECHA_INGRESO) AS AÑO_INGRESO, 
		MONTH(FECHA_INGRESO) AS MES_INGRESO, 
		COUNT(*) AS CASOS_DEF
	FROM CASOS_NEUMONIA
	WHERE YEAR(FECHA_INGRESO) = 2021 AND MONTH(FECHA_INGRESO) = 1
	GROUP BY ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

	UNION ALL

	SELECT 
		ENTIDAD_RES, 
		MUNICIPIO_RES, 
		YEAR(FECHA_INGRESO) AS AÑO_INGRESO, 
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
Número de consulta: 9. Listar los 3 municipios con menos pacientes recuperados (pacientes que no fallecieron) registrados durante los años 2020 y 2021.

Requerimientos:
- Mostrar claramente los municipios con la menor cantidad de recuperaciones registradas durante los años especificados.
- Incluir solo los pacientes que fueron confirmados como casos positivos de COVID-19 con CLASIFICACION_FINAL igual a (1, 2, 3).
- Identificar como paciente recuperado aquellos cuya FECHA_DEF está registrada como '9999-99-99'.
- Realizar el conteo y la selección utilizando la función de ventana `ROW_NUMBER()` para ordenar los municipios según la cantidad de recuperados (de menor a mayor).

Significado de valores de los catálogos:
- ENTIDAD_RES: Identificador numérico de la entidad federativa del paciente.
- MUNICIPIO_RES: Clave numérica del municipio donde reside el paciente.
- CLASIFICACION_FINAL:
    - 1: Caso confirmado por asociación clínica-epidemiológica.
    - 2: Caso confirmado por dictaminación médica.
    - 3: Caso confirmado por laboratorio (prueba positiva).
- FECHA_DEF:
    - Valor '9999-99-99': Indica que el paciente se recuperó y no hubo defunción.

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- La consulta se realizó directamente sobre la tabla original `datoscovid`, contando los pacientes recuperados (no fallecidos) mediante la validación explícita de la columna `FECHA_DEF` con el valor específico '9999-99-99'. Esto permite asegurar la precisión al identificar únicamente pacientes vivos.
- Se utilizó la función de ventana `ROW_NUMBER() OVER (ORDER BY COUNT(ID_REGISTRO) ASC)` para asignar posiciones a los municipios según el número de pacientes recuperados, permitiendo una clasificación rápida y clara.
- El uso de la función `DATEPART(YEAR, FECHA_INGRESO)` fue esencial para filtrar correctamente los años especificados (2020 y 2021), asegurando precisión en el conteo anual.
- Finalmente, la cláusula `WHERE posicion <= 3` permite obtener únicamente los tres municipios con menor cantidad de pacientes recuperados, facilitando así un análisis focalizado sobre aquellos lugares con menor recuperación registrada, lo que podría indicar áreas con menor seguimiento o atención en salud pública.

*****************************************/

SELECT ENTIDAD_RES, MUNICIPIO_RES, TOTAL_REC, AÑO_REG FROM (
    SELECT
        ENTIDAD_RES,
        MUNICIPIO_RES,
        COUNT(ID_REGISTRO) AS TOTAL_REC,
        DATEPART(YEAR, FECHA_INGRESO) AS AÑO_REG,
        ROW_NUMBER() OVER (ORDER BY COUNT(ID_REGISTRO) ASC) AS posicion
    FROM datoscovid
    WHERE FECHA_DEF = '9999-99-99'
      AND DATEPART(YEAR, FECHA_INGRESO) = 2021
    GROUP BY ENTIDAD_RES, MUNICIPIO_RES, DATEPART(YEAR, FECHA_INGRESO)
) AS MUN_RECUPERADOS
WHERE posicion <= 3;



/*****************************************
Consulta 10. Porcentaje de casos confirmados por sexo y año (2020-2021).

Requisitos:
- Calcular el porcentaje de casos confirmados por sexo (masculino, femenino, no especificado) para los años 2020 y 2021.
- Tomar únicamente los casos confirmados, identificados con los valores '1', '2' y '3' en CLASIFICACION_FINAL.
- Los porcentajes deben calcularse en función del total global de casos confirmados (la suma total de todos los casos confirmados durante ambos años).

Significado de valores de los catálogos:
- SEXO: Identificador del sexo del paciente:
    - 1: Femenino.
    - 2: Masculino.
    - 99: No especificado.
- CLASIFICACION_FINAL:
    - 1: Confirmado por asociación clínica-epidemiológica.
    - 2: Confirmado por dictaminación médica.
    - 3: Confirmado por laboratorio (prueba positiva).

Responsable: Mario Alexis Juarez Anguiano.

Comentarios:
- Se utiliza la cláusula `WITH` para crear expresiones de tabla común (CTEs), las cuales simplifican y clarifican la estructura lógica del query al definir consultas intermedias:
    - **Total_CASOS**: calcula el total global acumulado de casos confirmados para obtener la referencia del 100%.
    - **Casos_Sexo_Año** agrupa los datos por sexo y año para realizar posteriormente el cálculo porcentual.
- Se utiliza la técnica de `CROSS JOIN` para combinar cada registro agrupado por sexo y año con el total general de casos confirmados. Esto permite calcular porcentajes relativos tomando el total global como referencia.
- La función `YEAR()` extrae claramente el año de la columna FECHA_INGRESO, facilitando la agrupación anual.
- La fórmula utilizada para calcular el porcentaje es:
  (CASOS_CONFIRMADOS del sexo y año específico / Total global de casos confirmados en 2020 y 2021) * 100
*****************************************/


WITH Total_CASOS AS (
    SELECT COUNT(*) AS CASOS_TOTALES_CONFIRMADOS
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
      AND YEAR(FECHA_INGRESO) IN (2020, 2021)
),
Casos_Sexo_Año AS (
    SELECT SEXO, 
           YEAR(FECHA_INGRESO) AS AÑO,
           COUNT(*) AS CASOS_CONFIRMADOS
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
      AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY SEXO, YEAR(FECHA_INGRESO)
)
SELECT 
    CPS.SEXO,
    (CPS.CASOS_CONFIRMADOS * 100.0 / TG.CASOS_TOTALES_CONFIRMADOS) AS PORCENTAJE,
    CPS.año,
    CPS.casos_confirmados AS TOTAL_CASOS_SEXO
FROM Casos_Sexo_Año CPS
CROSS JOIN Total_CASOS TG
ORDER BY CPS.año, CPS.SEXO;

/***************
Consulta 11. Listar el porcentaje de casos hospitalizados por estado en el año 2020. 
Requisitos: N/A

Significado de valores de los catálogos:
- ENTIDAD_UM: Identifica la entidad donde se ubica la unidad medica que brindó la atención.
- entidad: muestra el nombre de los estados
- year(FECHA_INGRESO) = 2020: Selecciona los casos en donde el paciente ingresó al hospital en 2020.
- TIPO_PACIENTE = 2: Indica los casos de pacientes que fueron hospitalizados.
- FECHA_INGRESO: Indica la fecha en la que el paciente ingresó al hospital

Responsable: Brenda Urrutia González
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
Consulta 12. Listar total de casos negativos por estado en los años 2020 y 2021. 
Requisitos: N/A

Significado de valores de los catálogos:
- CLASIFICACION_FINAL=7: Muestra los casos negativos 
-  year(DC.FECHA_INGRESO) in (2020, 2021): Selecciona los casos en donde el paciente ingresó al hospital en 2020 y 2021
- ENTIDAD_UM: Identifica la entidad donde se ubica la unidad medica que brindó la atención.
- entidad: muestra el nombre de los estados

Responsable: Brenda Urrutia González
Comentarios: Sin comentarios.
***************/
 
 select CE.entidad as estado, count(*) as totalCasosNegativos
 from dbo.datoscovid DC
 join dbo.cat_entidades CE on DC.ENTIDAD_UM = CE.clave
 where DC.CLASIFICACION_FINAL=7 and year(DC.FECHA_INGRESO) in (2020, 2021)
 group by CE.entidad
 order by CE.entidad

/***************
Consulta 13. Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, 
             de 31 a 40 años, de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional.
Requisitos: N/A

Significado de valores de los catálogos:
- SEXO = 1: Selecciona a las pacientes mujeres
- SEXO = 2: Selecciona a los pacientes hombres
- CLASIFICACION_FINAL in (1,2,3): Selecciona a todos los tipos de casos confirmados

Responsable: Brenda Urrutia González
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
Consulta 14. Listar el rango de edad con más casos confirmados y que fallecieron en los años 2020 y 2021.
Requisitos: N/A

Significado de valores de los catálogos:
- CLASIFICACION_FINAL in (1,2,3): Selecciona a todos los tipos de casos confirmados
- FECHA_DEF!='9999-99-99': Indica los pacientes que fallecieron
- year(FECHA_INGRESO) in (2020, 2021): Muestra a los pacientes que ingresaron al hospital en los años 2020 y 2021

Responsable: Brenda Urrutia González
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

