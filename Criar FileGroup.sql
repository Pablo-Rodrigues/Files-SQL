USE [master]
GO
ALTER DATABASE FacilCorp_Doc_TestePablo ADD FILEGROUP [FG00]
GO
ALTER DATABASE FacilCorp_Doc_TestePablo 
ADD FILE ( NAME = N'FacilCorp_Doc_TestePablo_FG00', FILENAME = N'X:\DATA\FacilCorp_Doc_TestePablo_FG00.ndf' , SIZE = 5120KB , FILEGROWTH = 65536KB ) 
TO FILEGROUP [FG00]
GO

ALTER DATABASE FacilCorp_Doc_TestePablo ADD FILEGROUP [FG01]
GO
ALTER DATABASE FacilCorp_Doc_TestePablo 
ADD FILE ( NAME = N'FacilCorp_Doc_TestePablo_FG01', FILENAME = N'X:\DATA\FacilCorp_Doc_TestePablo_FG01.ndf' , SIZE = 5120KB , FILEGROWTH = 65536KB ) 
TO FILEGROUP [FG01]
GO

ALTER DATABASE FacilCorp_Doc_TestePablo ADD FILEGROUP [FG02]
GO
ALTER DATABASE FacilCorp_Doc_TestePablo 
ADD FILE ( NAME = N'FacilCorp_Doc_TestePablo_FG02', FILENAME = N'X:\DATA\FacilCorp_Doc_TestePablo_FG02.ndf' , SIZE = 5120KB , FILEGROWTH = 65536KB ) 
TO FILEGROUP [FG02]
GO

ALTER DATABASE FacilCorp_Doc_TestePablo ADD FILEGROUP [FG03]
GO
ALTER DATABASE FacilCorp_Doc_TestePablo 
ADD FILE ( NAME = N'FacilCorp_Doc_TestePablo_FG03', FILENAME = N'X:\DATA\FacilCorp_Doc_TestePablo_FG03.ndf' , SIZE = 5120KB , FILEGROWTH = 65536KB ) 
TO FILEGROUP [FG03]
GO
-------------------------------------------------------------------------------------------------