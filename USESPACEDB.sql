SELECT DB.Name, SUM(CAST(size AS bigint) * 8/1000) AS Tamanho_MB FROM sys.databases DB
INNER JOIN sys.master_files
ON DB.database_id = sys.master_files.database_id
GROUP BY DB.name order by DB.name asc