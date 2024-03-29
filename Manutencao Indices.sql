USE [master]
GO
/****** Object:  StoredProcedure [dbo].[FragInideces]    Script Date: 09/09/2016 14:55:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[FragInideces] 
AS 

DECLARE @COUNTDB AS INT  
DECLARE @COUNT VARCHAR (5)  
SELECT  @COUNTDB = MAX(DBID)
        FROM    SYSDATABASES    
DECLARE @FragInideces VARCHAR(8000)
DECLARE @DBNAMEUSE VARCHAR(500)

        SELECT  @COUNT = 10  

        WHILE ( @COUNT <= @COUNTDB )
            BEGIN
  
Select @DBNAMEUSE = name from sys.databases where database_id = @COUNT
Select @FragInideces = 'use ' + @DBNAMEUSE + '
DECLARE @TableName VARCHAR(255)
DECLARE @sql NVARCHAR(500)
DECLARE @fillfactor INT
SET @fillfactor = 79
DECLARE TableCursor CURSOR FOR
SELECT OBJECT_SCHEMA_NAME([object_id])+''.''+name AS TableName
FROM sys.tables
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
SET @sql = ''ALTER INDEX ALL ON '' + @TableName +'' REBUILD WITH (FILLFACTOR = '' + CONVERT(VARCHAR(3),@fillfactor) + '')''
EXEC (@sql)
FETCH NEXT FROM TableCursor INTO @TableName
END
CLOSE TableCursor
DEALLOCATE TableCursor';
		SELECT @COUNT = @COUNT + 1  
		exec (@FragInideces);

		--Select @FragInideces
END
