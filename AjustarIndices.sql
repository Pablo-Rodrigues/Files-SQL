DECLARE @objectName NVARCHAR(100); 
DECLARE @objectId INT; 
DECLARE @sql NVARCHAR(200); 
DECLARE @indexName NVARCHAR(100); 
DECLARE @indexId INT; 
DECLARE @indexCol NVARCHAR(100); 
DECLARE @isDesc BIT; 
DECLARE @indexCols NVARCHAR(1000); 
DECLARE @isIncludeCol SMALLINT; 
DECLARE @sqlCreate NVARCHAR(2000); 
DECLARE @sqlDrop NVARCHAR(200); 

DECLARE cur CURSOR STATIC LOCAL READ_ONLY FORWARD_ONLY FOR 
select obj.name, idx.name, idx.index_id, obj.object_id from sys.indexes idx 
join sys.objects obj on obj.object_id = idx.object_id 
where idx.is_primary_key = 0 --Não é chave primaria 
AND idx.type = 2 --Não clusterizado 
and obj.type  = 'U'; --UserTable 

OPEN cur; 
FETCH NEXT FROM cur INTO @objectName, @indexName, @indexId, @objectId; 

WHILE (@@FETCH_STATUS = 0) BEGIN               
      SET @isIncludeCol = 0; 
      SET @sqlCreate = 'CREATE NONCLUSTERED INDEX ' + @indexName + ' ON ' + @objectName; 

      WHILE (@isIncludeCol < 2) BEGIN 
             DECLARE curM CURSOR STATIC LOCAL READ_ONLY FORWARD_ONLY FOR 
             select col.name, idxc.is_descending_key from sys.index_columns idxc 
             join sys.columns col on idxc.column_id = col.column_id and 
             idxc.object_id = col.object_id 
             where idxc.index_id = @indexId and idxc.object_id = @objectId and 
             idxc.is_included_column = @isIncludeCol; 

             OPEN curM; FETCH NEXT FROM curM INTO @indexCol, @isDesc;               
             SET @indexCols = ''; 

             WHILE (@@FETCH_STATUS = 0) BEGIN 
                    IF (@indexCols <> '') BEGIN 
                           SET @indexCols += ',';               
                    END; 
              
                    SET @indexCols += @indexCol; 

                    IF (@isIncludeCol = 0 AND @isDesc = 1) BEGIN 
                           SET @indexCols += ' DESC'; 
                    END; 

                    FETCH NEXT FROM curM INTO @indexCol, @isDesc; 
             END; 
              
             CLOSE curM; DEALLOCATE curM;               

             IF (@isIncludeCol = 1) BEGIN 
                    IF (@indexCols <> '') BEGIN 
                           SET @sqlCreate += ' INCLUDE (' + @indexCols + ')'+ ' ON Indices '; 
                    END; 
             END 
             ELSE BEGIN 
                    SET @sqlCreate += '(' + @indexCols + ')'+ ' ON Indices '; 
             END; 

             SET @isIncludeCol += 1; 
      END; 
       
      SET @sqlDrop = 'DROP INDEX ' + @indexName + ' ON ' + @objectName;               
      PRINT @sqlDrop;               
      --EXEC sp_executeSQL @sqlDrop; 
      PRINT @sqlCreate; 
      --EXEC sp_executeSQL @sqlCreate; 
      FETCH NEXT FROM cur INTO @objectName, @indexName, @indexId, @objectId;               
END; 

CLOSE cur; DEALLOCATE cur;