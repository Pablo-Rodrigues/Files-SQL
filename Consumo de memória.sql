SELECT
(physical_memory_in_use_kb/1024) AS Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1024) AS Locked_pages_used_Sqlserver_MB,
(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,
process_physical_memory_low,
process_virtual_memory_low
FROM sys.dm_os_process_memory;

with cteSizeDB as ( 
   SELECT 'DB:'+DB_NAME(database_id) AS cDBName , 
          cast(COUNT(*) * 8 / 1024.0 as decimal(7,2)) as nSizeInMemoryMB 
     FROM sys.dm_os_buffer_descriptors 
    GROUP BY DB_NAME(database_id) 
    union all 
    select 'Mem:'+type , sum(pages_kb)/1024 
      from sys.dm_os_memory_clerks 
  where type <> 'MEMORYCLERK_SQLBUFFERPOOL' 
          group by type 
)select * 
   from cteSizeDB 
   where nSizeInMemoryMB > 0 
  union 
 select 'Todos' , SUM(nSizeInMemoryMB) 
   from cteSizeDB 
   order by 2 desc;  