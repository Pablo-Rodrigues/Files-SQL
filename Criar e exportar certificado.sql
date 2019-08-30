--Criar Certificado
USE Master;  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'qwe.123';  
GO

Use Master
go
CREATE CERTIFICATE Espaider
WITH
    SUBJECT = 'Certificado para segurança dos backups',
    EXPIRY_DATE = '20191231';
GO 

--Exportar certificado
BACKUP CERTIFICATE Espaider
TO FILE = 'C:\Ferramentas\Espaider_DOC.cer'
WITH PRIVATE KEY (FILE = 'C:\Ferramentas\Espaider_DOC.key',
ENCRYPTION BY PASSWORD = 'qwe.123')