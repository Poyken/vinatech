-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비제원정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSpecInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

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

    -- Declare Columns Variable
	DECLARE @OldMachineCode VARCHAR(20)
	DECLARE @OldMachineSpecSeq VARCHAR(4)
	DECLARE @MachineCode VARCHAR(20)
	DECLARE @MachineSpecSeq VARCHAR(4)
	DECLARE @SpecGroupName NVARCHAR(100)
	DECLARE @SpecName NVARCHAR(100)
	DECLARE @SpecText NVARCHAR(200)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineSpecInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachineSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldMachineSpecSeq IS NULL THEN XMLData.MachineSpecSeq
							    ELSE XMLData.OldMachineSpecSeq
							END AS OldMachineSpecSeq,
							XMLData.MachineCode,
							XMLData.MachineSpecSeq,
							XMLData.SpecGroupName,
							XMLData.SpecName,
							XMLData.SpecText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldMachineSpecSeq VARCHAR(4),
										MachineCode VARCHAR(20),
										MachineSpecSeq VARCHAR(4),
										SpecGroupName NVARCHAR(100),
										SpecName NVARCHAR(100),
										SpecText NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.MachineSpecSeq = SourceTable.MachineSpecSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = SourceTable.MachineCode,
					MachineSpecSeq = SourceTable.MachineSpecSeq,
					SpecGroupName = SourceTable.SpecGroupName,
					SpecName = SourceTable.SpecName,
					SpecText = SourceTable.SpecText,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						MachineSpecSeq,
						SpecGroupName,
						SpecName,
						SpecText,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.MachineSpecSeq,
							SourceTable.SpecGroupName,
							SourceTable.SpecName,
							SourceTable.SpecText,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MachineSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldMachineSpecSeq IS NULL THEN XMLData.MachineSpecSeq
							    ELSE XMLData.OldMachineSpecSeq
							END AS OldMachineSpecSeq,
							XMLData.MachineCode,
							XMLData.MachineSpecSeq,
							XMLData.SpecGroupName,
							XMLData.SpecName,
							XMLData.SpecText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldMachineSpecSeq VARCHAR(4),
										MachineCode VARCHAR(20),
										MachineSpecSeq VARCHAR(4),
										SpecGroupName NVARCHAR(100),
										SpecName NVARCHAR(100),
										SpecText NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode AND
					TargetTable.MachineSpecSeq = SourceTable.OldMachineSpecSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = SourceTable.MachineCode,
					MachineSpecSeq = SourceTable.MachineSpecSeq,
					SpecGroupName = SourceTable.SpecGroupName,
					SpecName = SourceTable.SpecName,
					SpecText = SourceTable.SpecText,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						MachineSpecSeq,
						SpecGroupName,
						SpecName,
						SpecText,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.MachineSpecSeq,
							SourceTable.SpecGroupName,
							SourceTable.SpecName,
							SourceTable.SpecText,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MachineSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldMachineSpecSeq IS NULL THEN XMLData.MachineSpecSeq
							    ELSE XMLData.OldMachineSpecSeq
							END AS OldMachineSpecSeq,
							XMLData.MachineCode,
							XMLData.MachineSpecSeq,
							XMLData.SpecGroupName,
							XMLData.SpecName,
							XMLData.SpecText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldMachineSpecSeq VARCHAR(4),
										MachineCode VARCHAR(20),
										MachineSpecSeq VARCHAR(4),
										SpecGroupName NVARCHAR(100),
										SpecName NVARCHAR(100),
										SpecText NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.MachineSpecSeq = SourceTable.MachineSpecSeq
				)

			WHEN MATCHED THEN
				DELETE;

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
									XMLData.OldMachineCode,
									XMLData.OldMachineSpecSeq,
									XMLData.MachineCode,
									XMLData.MachineSpecSeq,
									XMLData.SpecGroupName,
									XMLData.SpecName,
									XMLData.SpecText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldMachineSpecSeq VARCHAR(4),
											 MachineCode VARCHAR(20),
											 MachineSpecSeq VARCHAR(4),
											 SpecGroupName NVARCHAR(100),
											 SpecName NVARCHAR(100),
											 SpecText NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineSpecSeq
										ELSE XMLData.OldMachineCode
									END AS OldMachineSpecSeq,
									XMLData.MachineCode,
									XMLData.MachineSpecSeq,
									XMLData.SpecGroupName,
									XMLData.SpecName,
									XMLData.SpecText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldMachineSpecSeq VARCHAR(4),
											 MachineCode VARCHAR(20),
											 MachineSpecSeq VARCHAR(4),
											 SpecGroupName NVARCHAR(100),
											 SpecName NVARCHAR(100),
											 SpecText NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineSpecSeq
										ELSE XMLData.OldMachineCode
									END AS OldMachineSpecSeq,
									XMLData.MachineCode,
									XMLData.MachineSpecSeq,
									XMLData.SpecGroupName,
									XMLData.SpecName,
									XMLData.SpecText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldMachineSpecSeq VARCHAR(4),
											 MachineCode VARCHAR(20),
											 MachineSpecSeq VARCHAR(4),
											 SpecGroupName NVARCHAR(100),
											 SpecName NVARCHAR(100),
											 SpecText NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineCode,
								 @OldMachineSpecSeq,
								 @MachineCode,
								 @MachineSpecSeq,
								 @SpecGroupName,
								 @SpecName,
								 @SpecText,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineSpecInfo WHERE MachineCode = @MachineCode AND MachineSpecSeq = @MachineSpecSeq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s,%s', 16, 1, @MachineCode, @MachineSpecSeq)
					END

                    IF @IsAutoKey = 1 BEGIN
						
						SELECT
								@MachineSpecSeq = MAX(MSI.MachineSpecSeq)
						FROM
								STB_MachineSpecInfo MSI
						WHERE
								MachineCode  = @MachineCode
								
								
						SET @MachineSpecSeq = dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL(@MachineSpecSeq,0)) + 1,4)
                    END
					
					
                    INSERT INTO STB_MachineSpecInfo
						(
						    MachineCode,
						    MachineSpecSeq,
						    SpecGroupName,
						    SpecName,
						    SpecText,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineCode,
						    @MachineSpecSeq,
						    @SpecGroupName,
						    @SpecName,
						    @SpecText,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineSpecInfo
						SET
						    MachineCode =   CASE
						                WHEN @MachineCode IS NOT NULL THEN @MachineCode
						                ELSE MachineCode
						            END,
						    MachineSpecSeq =   CASE
						                WHEN @MachineSpecSeq IS NOT NULL THEN @MachineSpecSeq
						                ELSE MachineSpecSeq
						            END,
						    SpecGroupName =   CASE
						                WHEN @SpecGroupName IS NOT NULL THEN @SpecGroupName
						                ELSE SpecGroupName
						            END,
						    SpecName =   CASE
						                WHEN @SpecName IS NOT NULL THEN @SpecName
						                ELSE SpecName
						            END,
						    SpecText =   CASE
						                WHEN @SpecText IS NOT NULL THEN @SpecText
						                ELSE SpecText
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineCode = @OldMachineCode AND
						    MachineSpecSeq = @OldMachineSpecSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachineSpecInfo
						WHERE
						    MachineCode = @MachineCode AND
						    MachineSpecSeq = @MachineSpecSeq
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

