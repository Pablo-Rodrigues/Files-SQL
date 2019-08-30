truncate table msdb.dbo.arquivo

BULK INSERT msdb.dbo.ARQUIVO
FROM 'F:\LogArquivo\LogMatutino.txt'
WITH
(
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n'
)
update msdb.dbo.arquivo set nome = '\\192.168.13.1\p\Backups\Producao\Matutino\'+nome
---------------------------------------------------------------------------------------------------
EXECUTE [VerificaBackupsFeitos] @DATA = '2017-06-28 10:24:00', @TIPO = 'I', @Path = '\\192.168.13.1\p\Backups\Producao\Matutino\';

-- @DATA Deve ser colocado a data e horário que o backup iniciou AA-MM-DD HH:MM:SS.
-- Tipo de Backups FULL = D, DIFF = I , TRN = L.
-- @Path Diretório que deve verificar se existe o backup feito.
-- Se ocorreu tudo certo, somente aparece uma quantidade de linha affected.
-- Se teve problemas, aparece uma menssagem alertando o que aconteceu.