-- Find Errors in SQL Server Error Log
	
DROP TABLE IF EXISTS #errorLog; -- Use for SQL Server 2016 and later
	
-- IF OBJECT_ID('tempdb..#errorLog', 'U') IS NOT NULL DROP TABLE #errorLog 
-- Use for Pre SQL Server 2016

CREATE TABLE #errorLog (LogDate DATETIME, ProcessInfo VARCHAR(64), [Text] VARCHAR(MAX));

INSERT INTO #errorLog
EXEC sp_readerrorlog 0 -- specify log number - 0 is active log, 1 is archive log 1, etc.

SELECT * 
FROM #errorLog a
WHERE EXISTS (SELECT * 
              FROM #errorLog b
              WHERE [Text] like 'Error:%'
                AND a.LogDate = b.LogDate
                AND a.ProcessInfo = b.ProcessInfo)
				Order by LogDate desc;
