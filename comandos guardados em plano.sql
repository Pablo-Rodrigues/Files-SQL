SELECT count (*)
--DB_Name(DatabaseID) AS [NomeBase]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
FROM sys.dm_exec_plan_attributes(qs.plan_handle)
WHERE attribute = N'dbid') AS F_DB
--GROUP BY DB_Name(DatabaseID)
--order BY 1 DESC
