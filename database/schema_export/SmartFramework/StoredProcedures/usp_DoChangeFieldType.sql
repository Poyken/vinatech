-- Procedure: usp_DoChangeFieldType




CREATE PROCEDURE [dbo].[usp_DoChangeFieldType]
AS
BEGIN
	DECLARE @ObjectID INT,
			@TableName VARCHAR(100),
			@ColCount INT,
			@ColName VARCHAR(100),
			@MaxIDX INT,
			@MinIDX INT,
			@IDX INT

	DECLARE @Tables TABLE
	(
		ObjectID INT,
		TableName VARCHAR(100),
		ColCount INT
	)

	DECLARE @Columns TABLE
	(
		IDX INT IDENTITY(1,1),
		ColName VARCHAR(100)
	)


	DECLARE @UpdateSQLScript NVARCHAR(MAX)
	DECLARE @AlterSQLScript NVARCHAR(MAX)


	INSERT INTO @Tables
		(ObjectID, TableName, ColCount)
	select 
		tb.object_id, tb.[name], count(*) as colcount
	from 
		sys.columns cm,
 		sys.tables tb
	where 
		(cm.[object_id] = tb.[object_id]) and
		((cm.name like 'Is%') or (cm.name like 'Has%') or (cm.name like 'Allow%') or (cm.name like 'Can%')  or (cm.name like 'Show%')) and cm.system_type_id = 175 and cm.max_length = 1
	group by
		tb.object_id,
		tb.[name]
		
	DECLARE CurTable CURSOR FOR
		SELECT ObjectID, TableName, ColCount FROM @Tables	
		
	OPEN CurTable

	FETCH NEXT FROM CurTable INTO @ObjectID, @TableName, @ColCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @UpdateSQLScript = ''
		
		
		SET @UpdateSQLScript = @UpdateSQLScript + 'UPDATE ' +  @TableName + ' SET ' 
		
		

		
		DELETE FROM @Columns
		
		INSERT INTO @Columns
			(ColName)
		SELECT name FROM sys.all_columns WHERE [object_id] = @ObjectID and ((name like 'Is%') or (name like 'Has%') or (name like 'Allow%') or (name like 'Can%')  or (name like 'Show%'))  and system_type_id = 175 and max_length = 1
		
		
		SELECT
				@MinIDX = MIN(IDX),
				@MaxIDX = MAX(IDX)
		FROM
				@Columns
		
		SET @IDX = @MinIDX
		
		WHILE @IDX <= @MaxIDX
		BEGIN
			SELECT @ColName = ColName FROM @Columns WHERE IDX = @IDX
		
			IF @IDX = @MaxIDX
			BEGIN
				SET @UpdateSQLScript = @UpdateSQLScript + '[' + @ColName + '] = CASE WHEN [' + @ColName + '] IN (''Y'', ''1'') THEN 1 ELSE 0 END '
			
			END ELSE BEGIN
				SET @UpdateSQLScript = @UpdateSQLScript + '[' + @ColName + '] = CASE WHEN [' + @ColName + '] IN (''Y'', ''1'') THEN 1 ELSE 0 END, '
			END
			
			SET @IDX = @IDX + 1

		END	
		
		--PRINT @UpdateSQLScript
		EXEC sys.sp_executesql @UpdateSQLScript
		
		SET @IDX = @MinIDX

		WHILE @IDX <= @MaxIDX
		BEGIN
			SELECT @ColName = ColName FROM @Columns WHERE IDX = @IDX
		
			SET @AlterSQLScript = ''
			SET @AlterSQLScript = @AlterSQLScript + 'ALTER TABLE ' + @TableName 
			SET @AlterSQLScript = @AlterSQLScript + ' ALTER COLUMN [' + @ColName + '] BIT '
			
			SET @IDX = @IDX + 1
			
			EXEC sys.sp_executesql @AlterSQLScript
			--PRINT @AlterSQLScript
		END
		
		

		FETCH NEXT FROM CurTable INTO @ObjectID, @TableName, @ColCount
	END


	CLOSE CurTable
	DEALLOCATE CurTable
END




GO

