BACKUP LOG [Veirano] TO  DISK = N'G:\Backups\veiranolog.trn' WITH NOFORMAT, NOINIT,  NAME = N'Veirano-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO

USE [Veirano]
GO
DBCC SHRINKFILE (N'VeiranoCollation_log' , 0, TRUNCATEONLY)
GO
