
SELECT a.index_id, b.name, o.name as tabela, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(DB_NAME()),
OBJECT_ID(N'dbo.OCR'), NULL, NULL, NULL) AS a
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id 
JOIN sys.Objects as o ON b.object_id = o.object_id
WHERE b.name <> '' and avg_fragmentation_in_percent > 60 ORDER BY avg_fragmentation_in_percent DESC;


--select database_id, name from sys.databases