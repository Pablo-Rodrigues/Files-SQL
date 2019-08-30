 DECLARE @tabelaFinal table (name varchar(200))
 DECLARE @tabela table (name varchar(200))
 DECLARE @NAME NVARCHAR(256)
 DECLARE @COMANDO NVARCHAR(256) 
 DECLARE @COMANDORESULT NVARCHAR(256)
 DECLARE @COUNTDB AS INT
 DECLARE @COUNT INT 
   
  SELECT  @COUNTDB = MAX(DBID)
        FROM    SYSDATABASES    

        SELECT  @COUNT = 1    

        WHILE ( @COUNT <= @COUNTDB )
		BEGIN
			SELECT @NAME = ''    
			SELECT @NAME = NAME FROM  SYSDATABASES WHERE DBid = @COUNT
			SELECT @COMANDO = ''
			SELECT @COMANDO = 'select name from ' +@Name+ '.sys.fulltext_catalogs'
			insert into @tabelaFinal EXECUTE(@COMANDO)
			SELECT @COMANDORESULT = ''
			SELECT @COMANDORESULT = NAME FROM @tabelaFinal
			IF (@COMANDORESULT IS NOT NULL AND @COMANDORESULT <> '')
				BEGIN
					EXECUTE ('USE ' +  @Name + ' ALTER FULLTEXT CATALOG ' + @COMANDORESULT + ' REBUILD;')
					INSERT INTO @tabela (NAME) VALUES ('USE ' +  @Name + ' ALTER FULLTEXT CATALOG ' + @COMANDORESULT + ' REBUILD;')
					DELETE FROM @tabelaFinal
				END
				SELECT  @COUNT = @COUNT + 1 
		END
		select * from @tabela -- apresenta os comandos que foram executados