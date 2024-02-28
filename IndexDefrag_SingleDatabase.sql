Declare @DatabaseName varchar(100)='SQLPlanner' --Database name which indexes need to be rebuilt / reorganize
Declare @TableName varchar(1000),
@IndexName varchar(1000),
@IndexLastExecutedDate varchar(1000),
@TableIndexName varchar(1000), 
@avg_Fragmentation decimal(18,4),
@IndexId int,
@sql varchar(max)


declare CR_AllTablesIndexes CURSOR FOR
SELECT 
--SCHEMA_NAME(schema_id) AS SchemaName
   OBJECT_NAME(o.object_id)  AS ObjectName 
--type  AS ObjectType,
, s.name AS StatsName
, STATS_DATE(o.object_id, stats_id)  AS StatsDate
FROM sys.stats s INNER JOIN sys.objects o ON o.object_id=s.object_id
WHERE OBJECTPROPERTY(o.object_id, N'ISMSShipped') = 0
AND LEFT(s.Name, 4) != '_WA_'
--And OBJECT_NAME(o.object_id) ='CustomerPoolPriority'
ORDER BY ObjectName, StatsName;


Declare @IndexTable Table(
  SqlCommand varchar(Max)
)




OPEN CR_AllTablesIndexes
		FETCH NEXT FROM CR_AllTablesIndexes INTO  @TableName , @IndexName,@IndexLastExecutedDate
		if(@@FETCH_STATUS<>-1)
		begin
			 WHILE @@FETCH_STATUS=0
			 BEGIN
			   declare CR_SpecificTablesIndexes CURSOR FOR
			   SELECT a.index_id, name, avg_fragmentation_in_percent  
                  FROM sys.dm_db_index_physical_stats (DB_ID(@DatabaseName), 
                     OBJECT_ID(@TableName), NULL, NULL, NULL) AS a  
                     JOIN sys.indexes AS b 
                      ON a.object_id = b.object_id AND a.index_id = b.index_id;

					  
				      OPEN CR_SpecificTablesIndexes
		                  FETCH NEXT FROM CR_SpecificTablesIndexes INTO @IndexId, @TableIndexName , @avg_Fragmentation
					      if(@@FETCH_STATUS<>-1)
		                  begin
							 WHILE @@FETCH_STATUS=0
							   BEGIN
				      --            Declare @IndexTunned int=0
								  --select @IndexTunned=count(*) from @IndexTable where IndexName=@TableIndexName
								  --print @IndexTunned
								  if( @avg_Fragmentation>5 and @avg_Fragmentation<30)
								 begin
								      --print '======================='   
								     -- print @TableName
								     -- Print @TableIndexName
								     -- print @avg_Fragmentation
								      SET @sql = 'ALTER INDEX  '+ @TableIndexName +  ' ON [' + @TableName +'] REORGANIZE'
                                      print @sql
									  Insert into @IndexTable  Values(@sql)
									  Set @sql=''
									 -- print 'Reorganize Successful'
									 -- print '======================='   
								  end
								 else if (@avg_Fragmentation>30)
								  Begin
								    --  print '======================='   
								    --  print @TableName
								    --  Print @TableIndexName
								    --  print @avg_Fragmentation
								      SET @sql = 'ALTER INDEX  '+ @TableIndexName +  ' ON ['+ @TableName +'] REBUILD'
									  print @sql
									  Insert into @IndexTable  Values(@sql)
									  Set @sql=''
									 -- print 'ReBuild Successful'
									--  print '======================='   
								  End

								 
								  
							   FETCH NEXT FROM CR_SpecificTablesIndexes INTO @IndexId, @TableIndexName , @avg_Fragmentation
							End
                         End
                  CLOSE CR_SpecificTablesIndexes
	              DEALLOCATE CR_SpecificTablesIndexes	  
				  	 
				--  delete from  @IndexTable
					
			
			 FETCH NEXT FROM CR_AllTablesIndexes INTO @TableName , @IndexName,@IndexLastExecutedDate
			End
       End
    CLOSE CR_AllTablesIndexes
	DEALLOCATE CR_AllTablesIndexes



	select distinct(SqlCommand) from @IndexTable where SqlCommand is not Null and SqlCommand not like '%PK_%'
