/*IDENTIFICAR DEADLOCK*/
DECLARE @Table TABLE(
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(MAX),
        ProgramName VARCHAR(MAX),
        SPID_1 INT,
        REQUESTID INT
)

INSERT INTO @Table EXEC sp_who2
SELECT  * FROM @Table where dbname = 'Sanchez' order by BlkBy desc


/* VERIFICAR COMANDO QUE ESTÁ PRESO
dbcc inputbuffer (131)

SELECT es.session_id, ib.event_info, status,
        cpu_time, memory_usage, logical_reads, writes, row_count
        total_elapsed_time, login_time, last_request_start_time, last_request_end_time
        host_name, program_name, login_name, open_transaction_count
FROM sys.dm_exec_sessions AS es
CROSS APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib
WHERE session_id = 131

LIMPAR DEADLOCK*/
--kill 473
