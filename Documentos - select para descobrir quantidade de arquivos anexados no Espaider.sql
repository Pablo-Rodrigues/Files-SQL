select T00003.F00688 as usuario, count(F13622), sum(F00980s)/1024 as q 
FROM T00143 as a
INNER JOIN  T00003 ON a.F13622 = T00003.ID
where f13623 > '2018-11-29 11:45:00' and  f13623 < '2018-11-29 11:50:00' group by T00003.F00688 order by q desc

--Este comando deve ser executado\ na base de informações. Por exemplo: executar na base RFAA da instância DB02\PRD03 para descobrir a quantidade de documentos anexados.