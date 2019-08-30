--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect DB02

USE [master]

GO

ALTER AVAILABILITY GROUP [DB_ALWAYSON]
ADD DATABASE [ValeTesteDSV];

GO

:Connect DB02

BACKUP DATABASE [ValeTesteDSV] TO  DISK = N'\\Db01\Shared\ValeTesteDSV.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect DB01

RESTORE DATABASE [ValeTesteDSV] FROM  DISK = N'\\Db01\Shared\ValeTesteDSV.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect DB02

BACKUP LOG [ValeTesteDSV] TO  DISK = N'\\Db01\Shared\ValeTesteDSV_20160222185508.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect DB01

RESTORE LOG [ValeTesteDSV] FROM  DISK = N'\\Db01\Shared\ValeTesteDSV_20160222185508.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect DB01


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'DB_ALWAYSON'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [ValeTesteDSV] SET HADR AVAILABILITY GROUP = [DB_ALWAYSON];

GO


GO


