USE [master]
GO

/****** Object:  StoredProcedure [dbo].[spSendMail]    Script Date: 20/06/2017 14:14:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[spSendMail]
as

begin tran
truncate table LastJobs
commit

begin tran
insert into LastJobs (JobName,descricao,ultimaExecucao,[Status])
select job.name as nome, 
ISNULL(description,'No description available.') as descricao,
cast(isnull(NULLIF(SUBSTRING(cast(last_run_date as varchar(50)),1,4),'0') +'-'+
SUBSTRING(cast(last_run_date as varchar(50)),5,2) + '-'+
SUBSTRING(cast(last_run_date as varchar(50)),7,2),'2999-12-31') as datetime) as UltimaExecucao,
Status = 
case when cast(last_run_outcome as varchar(10)) = 0 then 'Falhou' 
     when cast(last_run_outcome as varchar(10)) = 1 then 'Completou com sucesso' 
     when cast(last_run_outcome as varchar(10))= 3 then 'Cancelado'
     when CAST(last_run_outcome as varchar(15)) = 5 then 'Nunca utilizado' 
else cast('Desconhecido' as varchar(15))
end
from msdb.dbo.sysjobs as job
left outer join msdb.dbo.sysjobservers as jobServer
on job.job_id = jobServer.job_id
where job.name not in ('syspolicy_purge_history','Output File Cleanup',
'sp_delete_backuphistory','sp_purge_jobhistory')
order by nome

commit


declare @tableHTML nvarchar(MAX);

SET @tableHTML =
    N'<H1>Relatorio de Backup - DB02 - PRODUCAO</H1>' +
    N'<table border="1">' +
    N'<tr><th>Nome do Job</th><th>Data de Execução</th>' +
    N'<th>Status</th>' +
    CAST ( ( SELECT td = JobName,       '',
                    td = ultimaExecucao, '',
                    td = Status, ''
                    from master..lastJobs
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;




exec msdb..sp_send_dbmail
@profile_name = 'SQL_Profile',
@recipients = 'pablo.rodrigues@quellon.com', 
@subject = 'Execução Backup - DB02 - PRODUCAO', 
@body = @tableHTML,
@body_format = 'HTML', 
@importance = 'High', 
@execute_query_database = 'master',
@attach_query_result_as_file  = 0









GO


