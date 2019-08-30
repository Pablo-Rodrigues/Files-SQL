Insert INTO Historico (Comando, 
execution_count, DatabaseID, NomeBase, total_leitura_memoria, ultima_leitura_memoria, total_escrita_memoria, ultima_escrita_memoria, total_leitura_disco, ultima_leitura_disco, tempo_CPU_total, ultimo_tempo_CPU, tempo_total_execucao, ultimo_tempo_execucao, data_ultima_execucao, plano_execucao)
SELECT TOP 100 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1) AS Comando,
qs.execution_count,
DatabaseID, DB_Name(DatabaseID) AS [NomeBase],
qs.total_logical_reads as total_leitura_memoria, qs.last_logical_reads as ultima_leitura_memoria,
qs.total_logical_writes as total_escrita_memoria, qs.last_logical_writes as ultima_escrita_memoria,
qs.total_physical_reads as total_leitura_disco, qs.last_physical_reads as ultima_leitura_disco,
qs.total_worker_time as tempo_CPU_total, qs.last_worker_time as ultimo_tempo_CPU,
qs.total_elapsed_time/1000000 as tempo_total_execucao,
qs.last_elapsed_time/1000000 as ultimo_tempo_execucao,
qs.last_execution_time as data_ultima_execucao,
qp.query_plan as plano_execucao
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
, CONVERT(nchar(255), value) AS [Comando]
, CONVERT(bigint, value) AS execution_count
, CONVERT(nvarchar(MAX), value) AS [NomeBase]
, CONVERT(bigint, value) AS total_leitura_memoria
, CONVERT(bigint, value) AS ultima_leitura_memoria
, CONVERT(bigint, value) AS total_escrita_memoria
, CONVERT(bigint, value) AS ultima_escrita_memoria
, CONVERT(bigint, value) AS total_leitura_disco
, CONVERT(bigint, value) AS ultima_leitura_disco
, CONVERT(bigint, value) AS tempo_CPU_total
, CONVERT(bigint, value) AS ultimo_tempo_CPU
, CONVERT(bigint, value) AS tempo_total_execucao
, CONVERT(bigint, value) AS ultimo_tempo_execucao
FROM sys.dm_exec_plan_attributes(qs.plan_handle)
WHERE attribute = N'dbid') AS F_DB
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE DatabaseID = 14
--ORDER BY qs.total_logical_reads DESC -- ordenando por leituras em memória
--ORDER BY qs.total_logical_writes DESC -- escritas em memória
--ORDER BY qs.total_worker_time DESC -- tempo de CPU
--ORDER BY qs.total_physical_reads DESC -- leituras do disco
--ORDER BY qs.last_worker_time DESC -- Ultimo tempo de CPU
--ORDER BY qs.last_elapsed_time DESC -- Ultimo tempo de Execução
--ORDER BY qs.total_elapsed_time DESC
ORDER BY execution_count DESC

--select * from sys.databases where name = 'Ejupes'