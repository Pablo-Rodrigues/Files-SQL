
SELECT  
        ar.replica_server_name,  
        adc.database_name,  
        ag.name AS ag_name,
		drs.last_commit_time,  
        drs.is_local,  
        drs.is_primary_replica,
        drs.log_send_queue_size,
		drs.redo_rate,
		drs.log_send_queue_size / drs.redo_rate / 60  AS tempo_minutos,
        drs.synchronization_state_desc,  
        drs.is_commit_participant,  
        drs.synchronization_health_desc,  
        drs.recovery_lsn,  
        drs.truncation_lsn,  
        drs.last_sent_lsn,  
        drs.last_sent_time,  
        drs.last_received_lsn,  
        drs.last_received_time,  
        drs.last_hardened_lsn,  
        drs.last_hardened_time,  
        drs.last_redone_lsn,  
        drs.last_redone_time,  
        drs.redo_queue_size,
		drs.log_send_rate, 
        drs.filestream_send_rate,  
        drs.end_of_log_lsn,  
        drs.last_commit_lsn
        --drs.last_commit_time
		 FROM sys.dm_hadr_database_replica_states AS drs INNER JOIN sys.availability_databases_cluster AS adc  
        ON drs.group_id = adc.group_id AND  
        drs.group_database_id = adc.group_database_id INNER JOIN sys.availability_groups AS ag 
        ON ag.group_id = drs.group_id INNER JOIN sys.availability_replicas AS ar  
        ON drs.group_id = ar.group_id AND  
        drs.replica_id = ar.replica_id 
		where is_primary_replica = 0
		and log_send_queue_size > 0
		--where synchronization_state_desc = 'SYNCHRONIZING' and is_primary_replica = 0
		--where synchronization_state_desc = 'NOT SYNCHRONIZING' and is_primary_replica = 1
		--database_name = 'ernstyoung'		
		ORDER BY  
        --ag.name,  
        --ar.replica_server_name,  
        --adc.database_name;
		log_send_queue_size desc