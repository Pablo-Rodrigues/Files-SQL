DECLARE @MB decimal(19,3)
        , @Count bigint
        , @StrMB nvarchar(20)


SELECT @MB = sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 
        , @Count = sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END)
        , @StrMB = convert(nvarchar(20), @MB)
FROM sys.dm_exec_cached_plans

IF @MB > 1
        DBCC FREEPROCCACHE
ELSE
        RAISERROR ('Only %s MB is allocated to single-use plan cache – no need to clear cache now.', 10, 1, @StrMB)
go