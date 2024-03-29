create database PabloReplicacao
on primary
(name = N'PabloReplicacaoF', filename = N'G:\DATA\PabloReplicacao.mdf'), 
filegroup [Information] 
(name = N'PabloReplicacaoNDF', filename = N'G:\DATA\PabloReplicacao.ndf'), 
filegroup [FG02] 
(name = N'PabloReplicacaoFG02', filename = N'J:\DATA\PabloReplicacaoFG02.ndf'), 
filegroup [FG01] 
(name = N'PabloReplicacaoFG01', filename = N'K:\DATA\PabloReplicacaoFG01.ndf')
log on
(name = N'PabloReplicacaoLDF', filename = N'F:\Log\PabloReplicacaoLDF.ldf')

----------------------------------------------------------------------------------------------------
USE PabloReplicacao
create table dbo.Customers
(
    CustomerId int not null,
    CustomerName nvarchar(64) not null,
)
on [Information];

create table dbo.Articless
(
 ArticlesId int not null,
 ArticleName nvarchar(64) not null,
)
on [Information];

create partition function pfOrders(smalldatetime)
as range right
for values('2014-01-01');

create partition scheme psOrders
as partition pfOrders
to (FG01,FG02)
go

create table dbo.Orders
(
    OrderId int not null,
    OrderDate smalldatetime not null,
    OrderNum varchar(32) not null,
    constraint PK_Orders
    primary key clustered(OrderDate, OrderId)
    on psOrders(OrderDate)
)
go

insert into dbo.Customers(CustomerId, CustomerName) values(1,'Customer 1');
insert into dbo.Orders(OrderDate, OrderId, OrderNum)
values
    ('2013-01-01',1,'Order 1'),
    ('2013-02-02',2,'Order 2'),
    ('2014-01-01',3,'Order 3'),
    ('2014-02-02',4,'Order 4')

--------------------------------------------------------------------------------------------------------
--Backup FULL INFORMATION
backup database PabloReplicacao 
FILEGROUP = N'PRIMARY',  FILEGROUP = N'Information', FILEGROUP = N'FG01'
to disk = N'\\bkp03\P\Backups\Producao\FULL\PabloReplicacaoFG01.bak' 
with noformat, init, name = N'PabloReplicacao-Full Database Backup', 
    compression, stats = 2
go

--Backup FULL FG02
backup database PabloReplicacao 
FILEGROUP = N'FG02' 
to disk = N'\\bkp03\P\Backups\Producao\FULL\PabloReplicacaoFG02.bak' 
with noformat, init, name = N'PabloReplicacao-Full Database Backup', 
    compression, stats = 2
go

-- Differential backup Information
backup database PabloReplicacao 
FILEGROUP = N'PRIMARY',  FILEGROUP = N'Information', FILEGROUP = N'FG01'
to disk = N'\\BKP03\p\Backups\Producao\Matutino\PabloReplicacao_DIFFFG01.bak' 
with differential, noformat, init, 
    name = N'PabloReplicacao-Differential Database Backup', 
    compression, stats = 2
go

-- Differential backup FG02
backup database PabloReplicacao 
FILEGROUP = N'FG02'
to disk = N'\\BKP03\p\Backups\Producao\Matutino\PabloReplicacao_DIFFFG02.bak' 
with differential, noformat, init, 
    name = N'PabloReplicacao-Differential Database Backup', 
    compression, stats = 2
go

-- Transaction log
backup log PabloReplicacao 
to disk = N'\\BKP03\p\Backups\Producao\TRN\PabloReplicacao_TRN.trn' 
with noformat, init, name = N'PabloReplicacao-Tran Log', 
    compression, stats = 2
go

--backup log [MyBigOrderDb] 
--to disk = N'c:\db\MyBigOrderDb_TailLog.trn' 
--with no_truncate, noformat, init, name = N'MyBigOrderDb-Tail Log', 
-- compression, norecovery, stats = 2

 ----------------------------------------------------------------------------

 --Restaurar Ambiente

-- Full Backup INF
restore database PabloReplicacao 
FILEGROUP = 'primary', FILEGROUP = 'Information', FILEGROUP = 'FG01'
from disk = N'\\bkp03\P\Backups\Producao\FULL\PabloReplicacaoFG01.bak' with file = 1,
move N'PabloReplicacaoF' to N'G:\DATA\PabloReplicacao.mdf', 
move N'PabloReplicacaoNDF' to N'G:\DATA\PabloReplicacao.ndf', 
move N'PabloReplicacaoFG01' to N'K:\DATA\PabloReplicacaoFG01.ndf', 
move N'PabloReplicacaoLDF' to N'F:\Log\PabloReplicacaoLDF.ldf', 
NORECOVERY, partial, stats = 2;

-- Diff Backup
restore database PabloReplicacao 
from disk = N'\\BKP03\p\Backups\Producao\Matutino\PabloReplicacao_DIFFFG01.bak' with file = 1,
NORECOVERY, stats = 2;

-- Tran Log
restore database PabloReplicacao 
from disk = N'\\BKP03\p\Backups\Producao\TRN\PabloReplicacao_TRN.trn' with file = 1,
NORECOVERY, stats = 2;

---- Tail-log
--restore database [MyBigOrderDb] 
--from disk = N'C:\DB\MyBigOrderDb_TailLog.trn' with file = 1,
--NORECOVERY, stats = 2;

-- Recovery
restore database PabloReplicacao with RECOVERY;

-------------------------------------------------------------------------------------------------------

--Consultar banco parcialmente ONLINE
USE PabloReplicacao
select * from PabloReplicacao.dbo.Customers
select * from PabloReplicacao.dbo.Orders where OrderDate >= '2014-01-01'
Update PabloReplicacao.dbo.Customers set CustomerName = 'Customer 2'

--Consultar status dos FG

select file_id, name, state_desc, physical_name
from PabloReplicacao.sys.database_files
--------------------------------------------------------------------------------------------------------

-- Restaurar o resto da base enquanto o cliente trabalha

-- Full Backup (restoring individual filegroup)

USE master
restore database PabloReplicacao 
FILEGROUP = 'FG02'
from disk = N'\\bkp03\P\Backups\Producao\FULL\PabloReplicacaoFG02.bak' with file = 1,
move N'PabloReplicacaoFG02' to N'J:\DATA\PabloReplicacaoFG02.ndf',  
stats = 2;

-- Diff Backup
restore database PabloReplicacao 
from disk = N'\\BKP03\p\Backups\Producao\Matutino\PabloReplicacao_DIFFFG02.bak' with file = 1,
stats = 2;

-- Tran Log
restore database PabloReplicacao 
from disk = N'\\BKP03\p\Backups\Producao\TRN\PabloReplicacao_TRN.trn' with file = 1,
stats = 2;



---- Tail-log
--restore database PabloReplicacao 
--from disk = N'C:\DB\MyBigOrderDb_TailLog.trn' with file = 1,
--stats = 2;

restore database PabloReplicacao with RECOVERY;