USE [master]
GO

/****** Object:  StoredProcedure [dbo].[USP_BACKUP]    Script Date: 20/06/2017 14:14:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
		DECLARE @FILENAMELOG AS NVARCHAR(256)
		DECLARE @FILENAMEFULL AS NVARCHAR(256)
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
                                + @NAME 
								+ '_DIFF_'+ REPLACE(convert(nvarchar(20),GetDate(),103),'/','')
                                + '.BKP' 
						SELECT  @FILENAMELOG = @PATH
                                + @NAME 
								+ '_'+ REPLACE(convert(varchar(20),GetDate(),108),':','')
                                + '.trn'   
						SELECT  @FILENAMEFULL = @PATH
                                + @NAME 
								+ '_FULL_'+ REPLACE(convert(nvarchar(20),GetDate(),103),'/','')
                                + '.BKP'  

                        IF @TIPO = 'COMPLETO'
						AND @NAME <> 'ABBVIE'
						AND @NAME <> 'TRMFacil'
						AND @NAME <> 'TRMFacil_DOC'
						AND @NAME <> 'SGS'
						AND @NAME <> 'DBADMIN'
                            BACKUP DATABASE @NAME TO DISK = @FILENAMEFULL WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10  
						IF ( @TIPO = 'TRANSACIONAL'
                            AND @NAME <> 'MASTER'
                            AND @NAME <> 'MODEL'
                            AND @NAME <> 'MSDB'
							AND @NAME <> 'TRMFacil'
							AND @NAME <> 'TRMFacil_DOC'
							AND @NAME <> 'SGS'
							AND @NAME <> 'DBADMIN'

                             --AND @NAME <> 'userdatabase'
                           )

                            AND @RECOVERYMODEL <> 'SIMPLE'
                            BACKUP LOG @NAME TO DISK = @FILENAMELOG WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10  

                        IF @TIPO = 'DIFERENCIAL'
                            AND @NAME <> 'MASTER'
                            AND @NAME <> 'MODEL'
                            AND @NAME <> 'MSDB'
							AND @NAME <> 'ABBVIE'
							AND @NAME <> 'TRMFacil'
						    AND @NAME <> 'TRMFacil_DOC'
						    AND @NAME <> 'SGS'
						    AND @NAME <> 'DBADMIN'

                            --AND @NAME <> 'userdatabase'
                            BACKUP DATABASE @NAME TO DISK = @FILENAME WITH  DIFFERENTIAL , NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10     

                    END    
                SELECT  @COUNT = @COUNT + 1    

            END    

        SET NOCOUNT OFF    
    END 
GO


