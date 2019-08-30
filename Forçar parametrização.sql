SELECT ('ALTER DATABASE [' + name+ '] SET PARAMETERIZATION FORCED WITH NO_WAIT') FROM sys.databases where database_id > 4 and is_parameterization_forced < 1

SELECT name, is_parameterization_forced FROM sys.databases where database_id > 4 and is_parameterization_forced < 1

