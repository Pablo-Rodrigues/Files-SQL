USE [master]
RESTORE DATABASE DELL FROM  DISK = N'\\bkp03\H\Backups Internos\Guilherme\dell_AntesRestaurar_28072016_2102.bak' WITH  FILE = 1,  MOVE N'Distribuicao50' TO N'G:\DATA\Dell.mdf',  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

RESTORE DATABASE DELL  
   WITH RECOVERY  