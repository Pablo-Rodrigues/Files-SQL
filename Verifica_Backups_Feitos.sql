USE [master]
GO
/****** Object:  StoredProcedure [dbo].[VerificaBackupsFeitos]    Script Date: 26/06/2017 08:33:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[VerificaBackupsFeitos] 
( @DATA nvarchar(max), @TIPO NVARCHAR(5), @Path Nvarchar(max))
AS 
BEGIN
 DECLARE @COUNTDB AS INT
 DECLARE @VERIFICAR AS INT  
 DECLARE @COUNT INT  
 DECLARE @NAME NVARCHAR(256)
 DECLARE @ARQUIVO NVARCHAR(256)
 DECLARE @VERIFICARPATH NVARCHAR(256)

 SELECT  @COUNTDB = MAX(DBID)
        FROM    SYSDATABASES  
		where name <> 'DBAdmin'  
		and name <> 'ValetesteDSV'
		and name <> 'TRMFacil'
		and name <> 'TRMFACIL_DOC'
		and name <> 'SGS'

        SELECT  @COUNT = 5  

        WHILE ( @COUNT <= @COUNTDB )
            BEGIN    
--------------------------------------------------------------------------------------------------------
Select @NAME = name FROM sys.databases 
		where @COUNT = database_id 		
		and name <> 'DBAdmin'  
		and name <> 'ValetesteDSV'
		and name <> 'TRMFacil'
		and name <> 'TRMFACIL_DOC'
		and name <> 'SGS'
select @VERIFICAR = count(*) from msdb.dbo.backupset where database_name = ''+@NAME+'' and type = ''+@TIPO+'' and backup_finish_date > @DATA

IF(@VERIFICAR > 0)	
	begin
		select @VERIFICARPATH = m.physical_device_name 
		FROM msdb.dbo.backupset s
		INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
		Where @NAME = s.database_name AND type = @TIPO And s.backup_start_date > @DATA  
		ORDER BY backup_start_date
		SELECT @ARQUIVO = NOME FROM msdb.dbo.ARQUIVO where NOME = @VERIFICARPATH

			IF(@VERIFICARPATH = @ARQUIVO)	
				begin
     				SELECT @COUNT = @COUNT + 1 
				CONTINUE
				END
			Else
				PRINT 'O Backup da base '+ @NAME + ' Foi realizado no SQL, mas não consta no diretório'+ @Path;
				SELECT @COUNT = @COUNT + 1  
				CONTINUE
				END
	Else
		PRINT 'O Backup da base '+ @NAME + ' Não foi feito no SQL';
		SELECT @COUNT = @COUNT + 1  
		CONTINUE
	END
END	
-------------------------------------------------------------------------------------------------------

