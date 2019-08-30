select db_name(r.database_id), r.start_time, r.status, r.session_id, r.wait_time, r.last_wait_type, r.cpu_time, s.TEXT from sys.dm_exec_requests r with (nolock) 
cross apply sys.dm_exec_sql_text(r.sql_handle) s
where r.session_id != @@SPID
order by r.start_time

