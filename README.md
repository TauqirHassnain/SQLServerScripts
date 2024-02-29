# SQLServerScripts
Useful script for day to day task in SQL Server administration. 


# Script : IndexDefragScript_Dynamic.sql

Script that reorganizes or rebuilds all indexes having an average fragmentation percentage above a given threshold. It also works in the case where Availability Groups are enabled as it determines if the relevant databases are the primary replicas.

# Script : IndexDefrag_SingleDatabase.sql

Script that generates the reorganize or rebuild command for the selected database based on their fragmentation.

# Script : FindErrorInSQLLogs.sql

Script to read / check the errors in the SQL Server error logs.

# Script : LogShippingStatusCheck.sql

[Script](https://github.com/TauqirHassnain/SQLServerScripts/blob/main/LogShippingStatusCheck.sql) to check the Logshipping status on secondary server.
