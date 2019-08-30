SELECT spid, kpid, login_time, last_batch, status, hostname, nt_username, loginame 
FROM sys.sysprocesses 
WHERE cmd = 'KILLED/ROLLBACK'

--KILL 66 WITH STATUSONLY