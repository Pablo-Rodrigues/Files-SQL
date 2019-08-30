SELECT * 
FROM sys.dm_os_ring_buffers
WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY'
GO
 
SELECT CASE WHEN Parent_Connection_id IS NULL 
THEN 'Not MARS' 
ELSE 'MARS' END as IsMARS, * 
FROM sys.dm_exec_connections
ORDER BY 1
GO