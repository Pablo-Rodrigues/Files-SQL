USE [master]
GO
/****** Object:  StoredProcedure [dbo].[stpCarga_Tamanhos_Tabelas]    Script Date: 04/04/2019 20:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery10.sql|7|0|C:\Users\PABLO~1.ROD\AppData\Local\Temp\18\~vs9F07.sql

ALTER proc [dbo].[stpCarga_Tamanhos_Tabelas]
as
	declare @Databases table(Id_Database int identity(1,1), Nm_Database varchar(MAX))

	declare @Total int, @i int, @Database varchar(120), @cmd varchar(MAX);
	insert into @Databases(Nm_Database)
	select name
	from sys.databases
	where name not in ('master','model','tempdb','msdb') 
	and state_desc = 'online'	

	select @Total = max(Id_Database)
	from @Databases

	set @i = 0
	SELECT NULL from @Databases  where Id_Database = @i
	if object_id('tempdb..##Tamanho_Tabelas') is not null 
				drop table ##Tamanho_Tabelas
				
	CREATE TABLE ##Tamanho_Tabelas(
		Nm_Servidor VARCHAR(MAX),
		Nm_Database varchar(MAX),
		[Nm_Schema] [varchar](MAX) NULL,
		[Nm_Tabela] [varchar](MAX) NULL,
		[Nm_Index] [varchar](MAX) NULL,
		Nm_Drive CHAR(1),
		[Used_in_kb] [bigint] NULL,
		[Reserved_in_kb] [bigint] NULL,
		[Tbl_Rows] [bigint] NULL,
		[Type_Desc] [varchar](20) NULL
	) ON [PRIMARY]

	while (@i <= @Total)
	begin

		IF EXISTS (SELECT NULL from @Databases  where Id_Database = @i) -- caso a database foi deletada da tabela @databases, não faz nada.
		BEGIN 
			select @Database = Nm_Database
			from @Databases
			where Id_Database = @i

			set @cmd = '
				insert into ##Tamanho_Tabelas
				select @@SERVERNAME 
					, '''+@Database + ''' Nm_Database, t.schema_name, t.table_Name, t.Index_name,
					(SELECT SUBSTRING(filename,1,1) 
					FROM [' + @Database + '].sys.sysfiles 
					WHERE fileid = 1),
				sum(t.used) as used_in_kb,
				sum(t.reserved) as Reserved_in_kb,
				--case grouping (t.Index_name) when 0 then sum(t.ind_rows) else sum(t.tbl_rows) end as rows,
				 max(t.tbl_rows)  as rows,
				type_Desc
				from (
					select s.name as schema_name, 
							o.name as table_Name,
							coalesce(i.name,''heap'') as Index_name,
							p.used_page_Count*8 as used,
							p.reserved_page_count*8 as reserved, 
							p.row_count as ind_rows,
							(case when i.index_id in (0,1) then p.row_count else 0 end) as tbl_rows, 
							i.type_Desc as type_Desc
					from 
						[' + @Database + '].sys.dm_db_partition_stats p
						join [' + @Database + '].sys.objects o on o.object_id = p.object_id
						join [' + @Database + '].sys.schemas s on s.schema_id = o.schema_id
						left join [' + @Database + '].sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
					where o.type_desc = ''user_Table'' and o.is_Ms_shipped = 0
				) as t
				group by t.schema_name, t.table_Name,t.Index_name,type_Desc
				--with rollup -- no sql server 2005, essa linha deve ser habilitada **********************************************
				--order by grouping(t.schema_name),t.schema_name,grouping(t.table_Name),t.table_Name,	grouping(t.Index_name),t.Index_name
				'

			EXEC(@cmd);
			/*print @cmd; -- para debbug
			print '
				##################################################################################
			'; -- para debbug*/
			END
	set @i = @i + 1
end 

	INSERT INTO TRMFacil.dbo.T00624(F05944)
	SELECT DISTINCT A.Nm_Database 
	FROM ##Tamanho_Tabelas A
		LEFT JOIN TRMFacil.dbo.T00624 B ON A.Nm_Database COLLATE Latin1_General_CI_AI = B.F05944
	WHERE B.F05944 IS null
	
	INSERT INTO TRMFacil.dbo.Tabelahistorico(Nm_Tabela)
	SELECT DISTINCT A.Nm_Tabela 
	FROM ##Tamanho_Tabelas A
		LEFT JOIN TRMFacil.dbo.Tabelahistorico B ON A.Nm_Tabela COLLATE Latin1_General_CI_AI = B.Nm_Tabela
	WHERE B.Nm_Tabela IS null	

--------------------------------------------------------------
	
	insert into TRMFacil.dbo.T00623(F05937,F05940,F05941,
				F05942,F05939,F05938)
	select D.Id, C.Nm_Tabela,
			sum(Reserved_in_kb)/1024.00 [Reservado (KB)], 
			sum(case when Type_Desc in ('NONCLUSTERED') then A.Reserved_in_kb else 0 end)/1024.00 [Indices (KB)],
			max(Tbl_Rows) Qtd_Linhas,
			CONVERT(VARCHAR, GETDATE() ,112)						 
	from ##Tamanho_Tabelas A
		JOIN TRMFacil.dbo.Tabelahistorico C ON A.Nm_Tabela COLLATE Latin1_General_CI_AI = C.Nm_Tabela
		JOIN TRMFacil.dbo.T00624 D ON A.Nm_Database COLLATE Latin1_General_CI_AI = D.F05944
			LEFT JOIN TRMFacil.dbo.T00623 E ON D.ID = E.F05937 
								AND C.Id = E.ID 
								AND E.F05938 = CONVERT(VARCHAR, GETDATE() ,112)    
	where Nm_Index is not null	and Type_Desc is not NULL
		AND E.F05941 IS NULL 
	group by D.Id, C.Nm_Tabela,E.F05938
	
	-----------------------------------------------------------------------

declare @TamanhoBases table (Base varchar(100), Tamanho int)
insert into @tamanhoBases 	
SELECT DB.name as Base, (SUM(sys.master_files.size) * 8/1024) AS Tamanho 
FROM sys.databases DB
INNER JOIN sys.master_files
ON DB.database_id = sys.master_files.database_id
GROUP BY DB.name

	insert into TRMFacil.dbo.T00625(F05946,F05948,F05947, F05958)	
	select D.Id, sum(Used_in_kb)/1024 as EmUsoMB, CONVERT(VARCHAR, GETDATE() ,112) as DATA, TB.Tamanho AS Reservado  
	from ##Tamanho_Tabelas A
		JOIN TRMFacil.dbo.T00624 D ON A.Nm_Database COLLATE Latin1_General_CI_AI = D.F05944
		JOIN TRMFacil.dbo.T00625 F ON D.ID = F.F05946
		JOIN  @TamanhoBases TB on TB.Base = A.Nm_Database
	where 
		Nm_Index is not null	
		and A.Type_Desc is not NULL
	group by D.Id, TB.Tamanho

-----------------------------------------------------------------------------------------------------------

update TRMFacil.dbo.T00624 set F05945 = A.F05948, F05959 = A.F05958
from TRMFacil.dbo.T00624 B, TRMFacil.dbo.T00625 A
where A.F05946 = B.ID
and A.F05947 = (select max(F05947) from  TRMFacil.dbo.T00625);


update TRMFacil.dbo.T00624
set TRMFacil.dbo.T00624.F05943 = TRMFacil.dbo.T00623.F05940
from (
select A.F05944 base, max(B.F05941)TamanhoMaiorTabela
from TRMFacil.dbo.T00624 A, TRMFacil.dbo.T00623 B
where B.F05937 = A.ID
and B.F05938 = (select max(F05938) from TRMFacil.dbo.T00623)
group by A.F05944
)tamanho,TRMFacil.dbo.T00624, TRMFacil.dbo.T00623
where TRMFacil.dbo.T00623.F05937 = TRMFacil.dbo.T00624.ID
and TRMFacil.dbo.T00623.F05938 = (select max(F05938)MD from TRMFacil.dbo.T00623)
and TRMFacil.dbo.T00623.F05941 = tamanho.TamanhoMaiorTabela
and TRMFacil.dbo.T00624.F05944 = tamanho.base
