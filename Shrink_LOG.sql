USE [master]
GO

/****** Object:  StoredProcedure [dbo].[Shrink_LOG]    Script Date: 20/06/2017 14:12:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Shrink_LOG] 
AS 

 Declare @shrink varchar(255)
 DECLARE @COUNTDB AS INT  
 DECLARE @COUNT INT  
 DECLARE @NAME NVARCHAR(256)
 SELECT  @COUNTDB = MAX(DBID)
        FROM    SYSDATABASES    

        SELECT  @COUNT = 5  

        WHILE ( @COUNT <= @COUNTDB )
            BEGIN    
				
Select @shrink = 'USE ['+ a.name + '] DBCC SHRINKFILE (N' + '''' + '' + b.name + '' + '''' + ', 0, TRUNCATEONLY);'
from sys.databases a, sys.master_files b
	where a.database_id > 4 
		and a.database_id = b.database_id 
		and b.physical_name like '%.ldf'
		and b.database_id = @COUNT;
			
		SELECT @COUNT = @COUNT + 1  
exec (@Shrink);
END

GO


