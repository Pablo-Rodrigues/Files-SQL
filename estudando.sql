select db_name(18)

select counter_name ,cntr_value,cast((cntr_value/1024.0)/1024.0 as numeric(8,2)) as Gb
from sys.dm_os_performance_counters
where counter_name like '%server_memory%';

SELECT object_name, counter_name, instance_name, cntr_value, cntr_type  
FROM sys.dm_os_performance_counters;  
  
SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Buffer Manager'
AND counter_name = 'Page life expectancy'

--Memória em cache por base
SELECT DB_NAME(database_id) AS [Database Name],
COUNT(*) * 8/1024.0 AS [Cached Size (MB)] FROM sys.dm_os_buffer_descriptors
WHERE database_id > 4 -- exclude system databases
AND database_id <> 32767 -- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC;


--quantidade de conexões por maquina
select hostname,program_Name, count(*) Qtd_Conexoes
from sysprocesses A
where spid > 50
group by hostname,program_Name
order by 3 desc

-- limpar conexões em espera
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)

SELECT *  FROM sys.tables

--Mostrar ClusteredIndex da base
USE Pipek
select SCHEMA_NAME (o.SCHEMA_ID) SchemaName
  ,o.name ObjectName,i.name IndexName
  ,i.type_desc
  ,LEFT(list, ISNULL(splitter-1,len(list)))Columns
  , SUBSTRING(list, indCol.splitter+1, 1000) includedColumns--len(name) - splitter-1) columns
  , COUNT(1)over (partition by o.object_id)
from sys.indexes i
join sys.objects o on i.object_id= o.object_id
cross apply (select NULLIF(charindex('|',indexCols.list),0) splitter , list
             from (select cast((
                          select case when sc.is_included_column = 1 and sc.ColPos= 1 then'|'else '' end +
                                 case when sc.ColPos > 1 then ', ' else ''end + name
                            from (select sc.is_included_column, index_column_id, name
                                       , ROW_NUMBER()over (partition by sc.is_included_column
                                                            order by sc.index_column_id)ColPos
                                   from sys.index_columns  sc
                                   join sys.columns        c on sc.object_id= c.object_id
                                                            and sc.column_id = c.column_id
                                  where sc.index_id= i.index_id
                                    and sc.object_id= i.object_id) sc
                   order by sc.is_included_column
                           ,ColPos
                     for xml path (''),type) as varchar(max)) list)indexCols) indCol
where indCol.splitter is not null
order by SchemaName, ObjectName, IndexName

-- Mostra tabelas sem índices clustered 
USE TRMFacil
SELECT *  FROM sys.tables
WHERE OBJECTPROPERTY(object_id,'TableHasClustIndex') = 0

--Tabelas que mais foram alteradas após uma atualização das estatisticas
Use TRMFACIL
select TOP 300 B.name,A.Name,A.rowmodctr,*
from sys.sysindexes A with(nolock)
	join sys.sysobjects B with(nolock) on A.id = B.id
WHERE A.name IS NOT null
order by A.rowmodctr desc

--Todas as estatísticas de uma tabela e suas colunas
SELECT OBJECT_NAME(sc2.object_id) AS TableName , s.name AS StatisticsName , s.stats_id , s.auto_created , 
	ColList = SUBSTRING((SELECT ( ', ' + c1.name )
						FROM sys.stats_columns sc1 JOIN sys.columns c1 
						ON sc1.object_id = c1.object_id
						AND sc1.column_id = c1.column_id 
						WHERE sc1.object_id = sc2.object_id 
						AND sc1.stats_id = s.stats_id 
						ORDER BY sc1.stats_id, sc1.stats_column_id, c1.name                          
						FOR XML PATH( '' ) ), 3, 4000 ) 
FROM sys.stats_columns sc2 
	JOIN sys.columns c2 ON sc2.object_id = c2.object_id AND sc2.column_id = c2.column_id  
	JOIN sys.stats s ON sc2.object_id = s.object_id AND sc2.stats_id = s.stats_id 
WHERE sc2.object_id = object_id('T00151') --substitute Tablename 
GROUP BY  sc2.object_id, s.name , s.stats_id , s.auto_created 
ORDER BY SUBSTRING((SELECT ( ', ' + c1.name )
						FROM sys.stats_columns sc1 JOIN sys.columns c1 
						ON sc1.object_id = c1.object_id
						AND sc1.column_id = c1.column_id 
						WHERE sc1.object_id = sc2.object_id 
						AND sc1.stats_id = s.stats_id 
						ORDER BY sc1.stats_id, sc1.stats_column_id, c1.name                          
						FOR XML PATH( '' ) ), 3, 4000 ) 

--Estatísticas com mais de 7 dias sem atualização
USE LTSA
SELECT  [LastUpdate] = STATS_DATE(object_id, stats_id), 
        [Table] = OBJECT_NAME(object_id), 
        [Statistic] = A.name ,C.rowmodctr, 'UPDATE STATISTICS ' + OBJECT_NAME(object_id) + ' ' + A.name+ ' WITH FULLSCAN'
FROM sys.stats A
	join sys.sysobjects B with(nolock) on A.object_id = B.id
	join sys.sysindexes C with(nolock) on C.id = B.id and A.name = C.Name
WHERE STATS_DATE(object_id, stats_id) < getdate()-2	
and OBJECT_NAME(object_id) = 'T00151' 
	and substring(OBJECT_NAME(object_id),1,3) not in ('sys','dtp')
	and substring( OBJECT_NAME(object_id) , 1,1) <> '_' -- elimina tabelas tepor�rias
order by C.rowmodctr desc

--Espaço utilizado por conexão no TempDB
USE tempdb
;with tab(session_id, host_name, login_name, totalalocadomb, text)
as(
SELECT a.session_id,
b.host_name,
b.login_name,
( user_objects_alloc_page_count + internal_objects_alloc_page_count ) * 1.0 / 128 AS totalalocadomb,
d.TEXT
FROM sys.dm_db_session_space_usage a
JOIN sys.dm_exec_sessions b ON a.session_id = b.session_id
JOIN sys.dm_exec_connections c ON c.session_id = b.session_id
CROSS APPLY sys.Dm_exec_sql_text(c.most_recent_sql_handle) AS d
WHERE a.session_id > 50
AND ( user_objects_alloc_page_count + internal_objects_alloc_page_count ) * 1.0 / 128 > 10 -- Ocupam mais de 10 MB
)
select * from tab
union all
select null,null,'TOTAL ALOCADO',sum(totalalocadomb),null from tab