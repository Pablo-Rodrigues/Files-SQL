alter procedure ReduzirLogs as

-- Altera o Recovery mode para simple
DECLARE @TABCOMANDO TABLE (ID INT IDENTITY, COMANDO VARCHAR(250))
DECLARE @COMANDO VARCHAR(250)
DECLARE @ID INT

	INSERT INTO @TABCOMANDO
		select 'ALTER DATABASE [' + name + '] SET RECOVERY SIMPLE WITH NO_WAIT;' Comando
		from sys.databases 
		where name not in ('master','msdb','tempdb','model', 'DBAdmin')
		and state_desc = 'ONLINE'
	SELECT @ID = 1
	WHILE (@ID <= (SELECT COUNT(*) FROM @TABCOMANDO))
		BEGIN
			SELECT @COMANDO = COMANDO FROM @TABCOMANDO WHERE ID = @ID
			EXECUTE (@COMANDO)
			SELECT @ID = @ID + 1
		END

--Executa o Shirink nos logs
DECLARE @TABCOMANDO2 TABLE (ID INT IDENTITY, COMANDO VARCHAR(250))
	INSERT INTO @TABCOMANDO2
		select 'USE ['+d.name+ '];' + char(13)+char(10)+ 'DBCC SHRINKFILE (N''' + m.name+ ''' , 0, TRUNCATEONLY);'
		FROM sys.master_files m
		inner join sys.databases d
		on d.database_id = m.database_id
		where m.type='1'
		and d.name not in ('master','msdb','tempdb','model', 'DBAdmin','ReportServer$Temp','ReportServer$TempTempDB')
		and d.state_desc = 'ONLINE'
		order by d.name
	SELECT @ID = 1
	WHILE (@ID <= (SELECT COUNT(*) FROM @TABCOMANDO2))
		BEGIN
			SELECT @COMANDO = COMANDO FROM @TABCOMANDO2 WHERE ID = @ID
			EXECUTE (@COMANDO)
			SELECT @ID = @ID + 1
		END