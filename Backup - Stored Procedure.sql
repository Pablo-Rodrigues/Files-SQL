USE master
GO

CREATE PROCEDURE [dbo].[USP_BACKUP]
    (
      @PATH NVARCHAR(256) ,
      @TIPO VARCHAR(30)
    )
AS
    BEGIN    



        SET NOCOUNT ON    
        DECLARE @NAME NVARCHAR(256)    
        DECLARE @COUNT INT    
        DECLARE @COUNTDB AS INT    
        DECLARE @FILENAME AS NVARCHAR(256)  
        DECLARE @RECOVERYMODEL AS NVARCHAR(256) 
		DECLARE @STATE AS INT 

        SELECT  @COUNTDB = MAX(DBID)
        FROM    SYSDATABASES    

        SELECT  @COUNT = 1    

        WHILE ( @COUNT <= @COUNTDB )
            BEGIN    

                SELECT  @NAME = ''    

                SELECT  @NAME = NAME ,
						@STATE = status,
                        @RECOVERYMODEL = CONVERT(VARCHAR(256), DATABASEPROPERTYEX(name,'Recovery'))
                FROM    SYSDATABASES
                WHERE   DBid = @COUNT


                IF ( @NAME <> ''
                     AND @NAME <> 'tempdb'
					 AND @STATE <> 528
					 --AND @NAME <> 'userdatabase'
                   )
                    BEGIN    
                        SELECT  @FILENAME = @PATH
                                + CAST(DATEPART(DW, GETDATE()) AS VARCHAR)
                                + '_' + @NAME + '.BKP'    

                        IF @TIPO = 'COMPLETO'
                            BACKUP DATABASE @NAME TO DISK = @FILENAME WITH INIT  

                        IF ( @TIPO = 'TRANSACIONAL'
                            AND @NAME <> 'MASTER'
                            AND @NAME <> 'MODEL'
                            AND @NAME <> 'MSDB'

                             --AND @NAME <> 'userdatabase'
                           )
                            AND @RECOVERYMODEL <> 'SIMPLE'
                            BACKUP LOG @NAME TO DISK = @FILENAME WITH NOINIT  

                        IF @TIPO = 'DIFERENCIAL'
                            AND @NAME <> 'MASTER'
                            AND @NAME <> 'MODEL'
                            AND @NAME <> 'MSDB'
                            --AND @NAME <> 'userdatabase'
                            BACKUP DATABASE @NAME TO DISK = @FILENAME WITH DIFFERENTIAL    

                    END    
                SELECT  @COUNT = @COUNT + 1    

            END    

        SET NOCOUNT OFF    
    END 