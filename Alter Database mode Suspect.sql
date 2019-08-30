EXEC sp_resetstatus 'veirano';
ALTER DATABASE veirano SET EMERGENCY
DBCC checkdb('veirano')
ALTER DATABASE
veirano SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
DBCC CheckDB ('veirano', REPAIR_ALLOW_DATA_LOSS)
ALTER DATABASE veirano SET MULTI_USER
--http://www.sql-server-performance.com/2015/recovery-sql-server-suspect-mode/2/