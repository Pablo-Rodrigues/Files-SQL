USE [master]
GO

/****** Object:  StoredProcedure [dbo].[spBasesSemBackupFull]    Script Date: 20/06/2017 14:13:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[spBasesSemBackupFull]

AS
DECLARE @Date VARCHAR(30),
        @BaseName VARCHAR (100) --Declarando Variáveis
SET		@Date=CONVERT(VARCHAR(30), GETDATE(),104) -- Setando a variavel Data para pegar data atual e converter no formato Brasil

DECLARE BackupRoutine cursor -- Cria um cursor
FOR 
SELECT name 
FROM sys.databases
WHERE name NOT IN (SELECT DISTINCT database_name
FROM msdb.dbo.backupset
WHERE type = 'D')
AND name <> 'tempdb'

OPEN BackupRoutine -- Abre o cursor
FETCH BackupRoutine INTO @BaseName -- cada registro encontrado no cursor insere dentro da variavel @BaseName
WHILE @@FETCH_STATUS = 0 --Retorna o status do último cursor que a instrução FETCH emitiu, 0 significa que a instrução anterior foi bem sucedida


BEGIN 

DECLARE @Directory VARCHAR (100) -- Declarando variavel do diretorio 
SET @Directory='\\bkp03\P\Backups\Producao\FULL\'+@BaseName+'_'+ @Date + '_FULL_' +'.bak' -- Instanciando onde serão salvos os backups
/*************************************************/


/**********INICIO DO BACKUP DE BANCO DE DADOS**********/
BACKUP DATABASE @BaseName TO DISK=@Directory
WITH INIT, NOFORMAT,STOP_ON_ERROR,CHECKSUM; 
/**********FIM DO BACKUP DE BANCO DE DADOS**********/

fetch next from BackupRoutine into @BaseName -- Encontra o proximo registro dentro do Cursor e insere na variavel @BaseName

END -- Fecha as instruções de Backup
CLOSE BackupRoutine -- Fecha o cursor
DEALLOCATE BackupRoutine -- Retira o cursor da Memoria. IMPORTANTE sempre deixar esse comando






GO


