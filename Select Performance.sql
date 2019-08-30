SELECT [ID]
	  ,[Comando]
      ,[execution_count]
      ,[DatabaseID]
      ,[NomeBase]
      ,[total_leitura_memoria]
      ,[ultima_leitura_memoria]
      ,[total_escrita_memoria]
      ,[ultima_escrita_memoria]
      ,[total_leitura_disco]
      ,[ultima_leitura_disco]
      ,[tempo_CPU_total]
      ,[ultimo_tempo_CPU]
      ,[tempo_total_execucao]
      ,[ultimo_tempo_execucao]
      ,[data_ultima_execucao]
  FROM [dbo].[Historico]
	GROUP by data_ultima_execucao
	  ,Comando
	  ,[execution_count]
      ,[DatabaseID]
      ,[NomeBase]
      ,[total_leitura_memoria]
      ,[ultima_leitura_memoria]
      ,[total_escrita_memoria]
      ,[ultima_escrita_memoria]
      ,[total_leitura_disco]
      ,[ultima_leitura_disco]
      ,[tempo_CPU_total]
      ,[ultimo_tempo_CPU]
      ,[tempo_total_execucao]
      ,[ultimo_tempo_execucao]
	  ,[ID]
order by [ultimo_tempo_execucao] desc
GO


--select * from Historico where ID = 1850
--Truncate table historico