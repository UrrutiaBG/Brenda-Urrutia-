
-----------------------------------------------------
-- Consulta dinámica
-----------------------------------------------------

DROP PROCEDURE IF EXISTS consultaDinamicaMorbilidad;
GO

CREATE PROCEDURE consultaDinamicaMorbilidad
(
    @Conexion NVARCHAR(100),
    @Tabla NVARCHAR(100)
)
AS
BEGIN
    DECLARE @SQLString NVARCHAR(MAX);
    DECLARE @QueryRemota NVARCHAR(MAX);

    -- Consulta que se ejecutará remotamente
    SET @QueryRemota = '
        SELECT 
            CAST(SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS DECIMAL(18,2)) AS Total_DIABETES,
            CAST(SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS DECIMAL(18,2)) AS Total_HIPERTENSION,
            CAST(SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS DECIMAL(18,2)) AS Total_OBESIDAD,
            COUNT(*) AS Total_Casos
        FROM ' + @Tabla + '
        WHERE CLASIFICACION_FINAL IN (1, 2, 3)
    ';

    SET @SQLString = 
        'EXEC (''' + REPLACE(@QueryRemota, '''', '''''') + ''') AT [' + @Conexion + ']';

    -- Ejecutar
    EXEC(@SQLString);
END
GO

EXEC sp_serveroption @server = 'AZURE_BRENDA', @optname = 'rpc', @optvalue = 'true';
EXEC sp_serveroption @server = 'AZURE_BRENDA', @optname = 'rpc out', @optvalue = 'true';

EXEC sp_serveroption @server = 'AZURE-ALAN', @optname = 'rpc', @optvalue = 'true';
EXEC sp_serveroption @server = 'AZURE-ALAN', @optname = 'rpc out', @optvalue = 'true';

EXEC sp_serveroption @server = 'AZURE-MARIO', @optname = 'rpc', @optvalue = 'true';
EXEC sp_serveroption @server = 'AZURE-MARIO', @optname = 'rpc out', @optvalue = 'true';

EXEC sp_serveroption @server = 'MYSQL_ALAN2', @optname = 'rpc', @optvalue = 'true';
EXEC sp_serveroption @server = 'MYSQL_ALAN2', @optname = 'rpc out', @optvalue = 'true';

EXEC consultaDinamicaMorbilidad 
     @Conexion = N'AZURE_BRENDA', 
     @Tabla = N'datoscovid_oriente'

