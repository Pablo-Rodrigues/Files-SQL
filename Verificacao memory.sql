SELECT  [text], cp.size_in_bytes,plan_handle,usecounts, DB_NAME(dbid)
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE cp.cacheobjtype = N'Compiled Plan'
AND cp.objtype = N'Adhoc'
--AND cp.usecounts > 10
ORDER BY cp.usecounts DESC;

SELECT DB_NAME(database_id) AS [Database Name],
	COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors
WHERE database_id > 4 --–- exclude system databases
    AND database_id <> 32767-- –- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC;

DBCC FREEPROCCACHE

SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Buffer Manager'
AND counter_name = 'Page life expectancy'