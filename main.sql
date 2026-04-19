-- Task 1

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + '
SELECT 
    ''' + name + ''' AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType
FROM [' + name + '].sys.tables t
JOIN [' + name + '].sys.schemas s ON t.schema_id = s.schema_id
JOIN [' + name + '].sys.columns c ON t.object_id = c.object_id
JOIN [' + name + '].sys.types ty ON c.user_type_id = ty.user_type_id
UNION ALL
'
FROM sys.databases
WHERE name NOT IN ('master','tempdb','model','msdb');

SET @sql = LEFT(@sql, LEN(@sql) - 10);

EXEC sp_executesql @sql;


-- Task 2

CREATE PROCEDURE usp_GetProceduresAndFunctions
    @DatabaseName SYSNAME = NULL
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';

    IF @DatabaseName IS NOT NULL
    BEGIN
        SET @sql = '
        SELECT 
            ''' + @DatabaseName + ''' AS DatabaseName,
            s.name AS SchemaName,
            o.name AS ObjectName,
            o.type_desc AS ObjectType,
            p.name AS ParameterName,
            t.name AS DataType,
            p.max_length
        FROM [' + @DatabaseName + '].sys.objects o
        JOIN [' + @DatabaseName + '].sys.schemas s ON o.schema_id = s.schema_id
        LEFT JOIN [' + @DatabaseName + '].sys.parameters p ON o.object_id = p.object_id
        LEFT JOIN [' + @DatabaseName + '].sys.types t ON p.user_type_id = t.user_type_id
        WHERE o.type IN (''P'', ''FN'', ''TF'', ''IF'')';
    END
    ELSE
    BEGIN
        SELECT @sql = @sql + '
        SELECT 
            ''' + name + ''' AS DatabaseName,
            s.name AS SchemaName,
            o.name AS ObjectName,
            o.type_desc AS ObjectType,
            p.name AS ParameterName,
            t.name AS DataType,
            p.max_length
        FROM [' + name + '].sys.objects o
        JOIN [' + name + '].sys.schemas s ON o.schema_id = s.schema_id
        LEFT JOIN [' + name + '].sys.parameters p ON o.object_id = p.object_id
        LEFT JOIN [' + name + '].sys.types t ON p.user_type_id = t.user_type_id
        WHERE o.type IN (''P'', ''FN'', ''TF'', ''IF'')
        UNION ALL
        '
        FROM sys.databases
        WHERE name NOT IN ('master','tempdb','model','msdb');

        SET @sql = LEFT(@sql, LEN(@sql) - 10);
    END

    EXEC sp_executesql @sql;
END;
