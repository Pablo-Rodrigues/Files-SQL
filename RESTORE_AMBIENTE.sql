USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Montacomandosrestore]    Script Date: 20/06/2017 11:40:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery15.sql|7|0|C:\Users\PABLO~1.ROD\AppData\Local\Temp\17\~vsBE26.sql
-- Batch submitted through debugger: SQLQuery15.sql|7|0|C:\Users\PABLO~1.ROD\AppData\Local\Temp\17\~vsBE26.sql
ALTER PROCEDURE [dbo].[Montacomandosrestore] 
AS 

 Declare @RestoreFULL varchar(255)
 Declare @RestoreDIFF varchar(255)
 Declare @RestoreTRN varchar(255)
 DECLARE @lasttimeDIFF datetimeoffset(4)
 DECLARE @COUNTDB AS INT  
 DECLARE @COUNT INT  
 DECLARE @NAME NVARCHAR(256)
 DECLARE @COUNTTRN INT
 DECLARE @COUNTMAXTRN INT
 SELECT  @COUNTDB = MAX(database_id)
        FROM sys.databases

        SELECT  @COUNT = 5  

        WHILE (@COUNT <= @COUNTDB )
            BEGIN    
Select @NAME = name FROM sys.databases where @COUNT = database_id;				
Select TOP 1 @RestoreFULL ='RESTORE DATABASE '+ @NAME +' FROM  DISK = N'''+ m.physical_device_name +''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5;'
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @NAME
and s.type = 'D'
AND is_copy_only = 0
ORDER BY backup_start_date DESC

Select TOP 1 @RestoreDIFF ='RESTORE DATABASE '+ @NAME +' FROM  DISK = N'''+ m.physical_device_name +''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5;', @lasttimeDIFF = s.backup_start_date
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @NAME
and s.type = 'I'
ORDER BY backup_start_date DESC
			
SELECT @COUNTMAXTRN = count(Database_name)
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @NAME
and s.type = 'L'
and backup_start_date > @lasttimeDIFF


		PRINT (@RestoreFULL);
		PRINT (@RestoreDIFF);

SELECT @COUNTTRN = 1

WHILE (@COUNTTRN <= @COUNTMAXTRN)
	BEGIN 

Select TOP 1 @RestoreTRN ='RESTORE LOG '+ @NAME +' FROM  DISK = N'''+ m.physical_device_name +''' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5;'
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @NAME
and s.type = 'L'
and backup_start_date > @lasttimeDIFF
ORDER BY backup_start_date 

		PRINT (@RestoreTRN)
Select top 1 @lasttimeDIFF = backup_start_date
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @NAME
and s.type = 'L'
and backup_start_date > @lasttimeDIFF

ORDER BY backup_start_date 
		SELECT @COUNTTRN = @COUNTTRN +1
	

END
		SELECT @COUNT = @COUNT + 1 

END

