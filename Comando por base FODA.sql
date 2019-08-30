SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
select TOP 1000 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
DatabaseID, DB_Name(DatabaseID) AS [NomeBase],
qs.total_logical_reads as total_leitura_memoria, qs.last_logical_reads as ultima_leitura_memoria,
qs.total_logical_writes as total_escrita_memoria, qs.last_logical_writes as ultima_escrita_memoria,
qs.total_physical_reads as total_leitura_disco, qs.last_physical_reads as ultima_leitura_disco,
qs.total_worker_time as tempo_CPU_total, qs.last_worker_time as ultimo_tempo_CPU,
qs.total_elapsed_time/1000000 as tempo_total_execucao,
qs.last_elapsed_time/1000000 as ultimo_tempo_execucao,
qs.last_execution_time as data_ultima_execucao,
query_plan AS CompleteQueryPlan, n.query('.') AS ParallelSubTreeXML, 
n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel, 
--CAST (n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(MAX)') AS decimal(6,4)) AS StatementSubTreeCost
CONVERT (decimal(6,4), ISNULL(n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(MAX)'),0)) AS StatementSubTreeCost
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
FROM sys.dm_exec_plan_attributes(qs.plan_handle)
WHERE attribute = N'dbid') AS F_DB
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
WHERE DatabaseID = 36
--and qt.text like '%TaJ.09072%'
and qp.query_plan.exist('//MissingIndex')>0 --Precisa criar indices
--and n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1 --Utiliza paralelismo
--ORDER BY qs.total_logical_reads DESC -- ordenando por leituras em memória
--ORDER BY qs.total_logical_writes DESC -- escritas em memória
--ORDER BY qs.total_worker_time DESC -- tempo de CPU
--ORDER BY qs.total_physical_reads DESC -- leituras do disco
--ORDER BY qs.last_worker_time DESC -- Ultimo tempo de CPU
--ORDER BY qs.last_elapsed_time DESC -- Ultimo tempo de Execução
--ORDER BY qs.total_elapsed_time DESC
ORDER BY qs.execution_count desc
--order by StatementSubTreeCost desc
--select database_id from sys.databases where name = 'Grupomarista'

