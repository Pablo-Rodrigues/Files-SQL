exec [dbo].[spFailoverDatabase] 'trmcontingencia', 1


select 'exec spFailoverDatabase ' + '''' + name + '''' + ', ' + cast(0 as varchar(100))    from sys.databases
where database_id > 4