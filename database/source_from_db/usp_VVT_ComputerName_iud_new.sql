-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ComputerName_iud_new] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;
	--RAISERROR(@pXml, 16, 1)
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'

	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	DECLARE @EMPID VARCHAR(500)
    DECLARE @COMPUTERNAME NVARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @ChangeDateTime DATETIME

	DECLARE @iDoc INT

	    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'Stb_Vietnam_ControlPanel_test',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	DECLARE @IsAutoKey1 VARCHAR(10) = @IsAutoKey
	
	IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   	--RAISERROR(@IsAutoKey1, 16, 1)
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	    BEGIN TRY
			-- Process Insert Table
	
            MERGE Stb_Vietnam_ControlPanel_test AS TargetTable
			USING
				(
					SELECT
	
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET ,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ComputerName = SourceTable.ComputerName
				)
			WHEN MATCHED THEN
				UPDATE SET
					EmpID = SourceTable.EmpID,
					ComputerName = SourceTable.ComputerName,
					ChangeDateTime = SourceTable.ChangeDateTime

			WHEN NOT MATCHED THEN
				INSERT
					(
						EmpID,
						ComputerName,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.EmpID,
							SourceTable.ComputerName,
							SourceTable.CreateDateTime
					);


				-- Process Insert Table Stb_Vietnam_ControlPanel
	
            MERGE Stb_Vietnam_ControlPanel AS TargetTable
			USING
				(
					SELECT
	
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET ,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ComputerName = SourceTable.ComputerName
				)
			WHEN MATCHED THEN
				UPDATE SET
					EmpID = SourceTable.EmpID,
					ComputerName = SourceTable.ComputerName,
					ChangeDateTime = SourceTable.ChangeDateTime

			WHEN NOT MATCHED THEN
				INSERT
					(
						EmpID,
						ComputerName,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.EmpID,
							SourceTable.ComputerName,
							SourceTable.CreateDateTime
					);

		
			-- Process Update Table
            MERGE 	Stb_Vietnam_ControlPanel_test AS TargetTable
			USING
				(
					SELECT
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
						TargetTable.ComputerName = SourceTable.ComputerName
				)

			WHEN MATCHED THEN
				UPDATE SET
					EmpID = SourceTable.EmpID,
					ComputerName = SourceTable.ComputerName,
					ChangeDateTime = SourceTable.ChangeDateTime

			WHEN NOT MATCHED THEN
				INSERT
					(
						EmpID,
						ComputerName,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.EmpID,
							SourceTable.ComputerName,
							SourceTable.CreateDateTime
					);
		-- Process Update Table ké bảng
            MERGE 	Stb_Vietnam_ControlPanel AS TargetTable
			USING
				(
					SELECT
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
						TargetTable.ComputerName = SourceTable.ComputerName
				)

			WHEN MATCHED THEN
				UPDATE SET
					EmpID = SourceTable.EmpID,
					ComputerName = SourceTable.ComputerName,
					ChangeDateTime = SourceTable.ChangeDateTime

			WHEN NOT MATCHED THEN
				INSERT
					(
						EmpID,
						ComputerName,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.EmpID,
							SourceTable.ComputerName,
							SourceTable.CreateDateTime
					);


			-- Process Delete Table
            MERGE Stb_Vietnam_ControlPanel_test AS TargetTable
			USING
				(
					SELECT
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ComputerName = SourceTable.ComputerName
				)

			WHEN MATCHED THEN
				DELETE;
			-- xoas thif cap nhat truong status =1
            MERGE 	Stb_Vietnam_ControlPanel AS TargetTable
			USING
				(
					SELECT
							XMLData.EmpID,
							XMLData.ComputerName,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										EmpID VARCHAR(50),
										ComputerName NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										ChangeDateTime  DATETIMEOFFSET
									) XMLData
				) AS SourceTable
			ON
				(
						TargetTable.ComputerName = SourceTable.ComputerName
				)

			WHEN MATCHED THEN
				UPDATE SET
					status1='1'

			WHEN NOT MATCHED THEN
				INSERT
					(
						EmpID,
						ComputerName,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.EmpID,
							SourceTable.ComputerName,
							SourceTable.CreateDateTime
					);

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
	
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.EmpID,
									XMLData.ComputerName,
									XMLData.CreateDateTime,
									XMLData.ChangeDateTime

							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 EmpID NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 ComputerName NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 ChangeDateTime  DATETIMEOFFSET
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									XMLData.EmpID,
									XMLData.ComputerName,
									XMLData.CreateDateTime,
									XMLData.ChangeDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 EmpID NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 ComputerName NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 ChangeDateTime  DATETIMEOFFSET
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									XMLData.EmpID,
									XMLData.ComputerName,
									XMLData.CreateDateTime,
									XMLData.ChangeDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 EmpID NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 ComputerName NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 ChangeDateTime  DATETIMEOFFSET
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @EMPID,
								 @COMPUTERNAME,
								 @CreateDateTime,
								 @ChangeDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
				--RAISERROR('INSERT', 16, 1)
					/*
                    IF EXISTS (SELECT 1 FROM Stb_Vietnam_ControlPanel WHERE ComputerName = @COMPUTERNAME) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @COMPUTERNAME)
					END
					*/
                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'Stb_Vietnam_ControlPanel_test', @COMPUTERNAME OUTPUT

                        INSERT INTO Stb_Vietnam_ControlPanel_test
						(
						    EmpID,
						    EmpName,
						    CreateDateTime,
						    ChangeDateTime
						)
						VALUES
						(
						    @EMPID,
						    @COMPUTERNAME,
						    GETDATE(),
						    @ChangeDateTime
						)

					END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					--RAISERROR('UPDATE', 16, 1)
                        UPDATE Stb_Vietnam_ControlPanel_test
						SET
						    ComputerName =   CASE
						                WHEN @COMPUTERNAME IS NOT NULL THEN @COMPUTERNAME
						                ELSE ComputerName
						            END,
						    EmpID =   CASE
						                WHEN @EMPID IS NOT NULL THEN @EMPID
						                ELSE EmpID
						            END,
						  
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END
						   
						WHERE
						    ComputerName = @COMPUTERNAME
                    END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					--RAISERROR('DELETE', 16, 1)
                        DELETE FROM Stb_Vietnam_ControlPanel_test
						WHERE
						    ComputerName = @COMPUTERNAME
                    END
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
