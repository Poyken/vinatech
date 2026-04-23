-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_MaterialQcSampleResult_iud_BendingCutting
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

    -- Declare Columns Variable
  DECLARE @OldMaterialQcNo VARCHAR(20)
  DECLARE @OldMaterialQcDetailNo INT
  DECLARE @OldMaterialQcSampleNo INT
  DECLARE @MaterialQcNo VARCHAR(20)
  DECLARE @MaterialQcDetailNo INT
  DECLARE @MaterialQcSampleNo INT
  DECLARE @SampleSerialNo VARCHAR(50)
  DECLARE @TestUserID VARCHAR(20)
  DECLARE @TestDateTime DATETIME
  DECLARE @TestValue NUMERIC(20,5)
  DECLARE @TestResult VARCHAR(10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @DocDecisionResult VARCHAR(20)

  -- 입력값 판단을 위한 LSL, USL 추가 2021.03.30 박진호 과장 요청 By Jackaroe
  DECLARE @USL NUMERIC(20,5)
  DECLARE @LSL NUMERIC(20,5)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcSampleResult_BendingCutting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcSampleResult_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							CASE
							    WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
							    ELSE OldMaterialQcDetailNo
							END AS OldMaterialQcDetailNo,
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.MaterialQcSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					MaterialQcSampleNo = ISNULL(SourceTable.MaterialQcSampleNo,TargetTable.MaterialQcSampleNo),
					SampleSerialNo = ISNULL(SourceTable.SampleSerialNo,TargetTable.SampleSerialNo),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					TestDateTime = ISNULL(SourceTable.TestDateTime,TargetTable.TestDateTime),
					TestValue = ISNULL(SourceTable.TestValue,TargetTable.TestValue),
					TestResult = ISNULL(SourceTable.TestResult,TargetTable.TestResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						SampleSerialNo,
						TestUserID,
						TestDateTime,
						TestValue,
						TestResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.MaterialQcSampleNo,
							SourceTable.SampleSerialNo,
							SourceTable.TestUserID,
							SourceTable.TestDateTime,
							SourceTable.TestValue,
							SourceTable.TestResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialQcSampleResult_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							CASE
							    WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
							    ELSE OldMaterialQcDetailNo
							END AS OldMaterialQcDetailNo,
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.OldMaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.OldMaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.OldMaterialQcSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					MaterialQcSampleNo = ISNULL(SourceTable.MaterialQcSampleNo,TargetTable.MaterialQcSampleNo),
					SampleSerialNo = ISNULL(SourceTable.SampleSerialNo,TargetTable.SampleSerialNo),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					TestDateTime = ISNULL(SourceTable.TestDateTime,TargetTable.TestDateTime),
					TestValue = ISNULL(SourceTable.TestValue,TargetTable.TestValue),
					TestResult = ISNULL(SourceTable.TestResult,TargetTable.TestResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						SampleSerialNo,
						TestUserID,
						TestDateTime,
						TestValue,
						TestResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.MaterialQcSampleNo,
							SourceTable.SampleSerialNo,
							SourceTable.TestUserID,
							SourceTable.TestDateTime,
							SourceTable.TestValue,
							SourceTable.TestResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialQcSampleResult_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							CASE
							    WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
							    ELSE OldMaterialQcDetailNo
							END AS OldMaterialQcDetailNo,
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.MaterialQcSampleNo
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
									OldMaterialQcNo,
									OldMaterialQcDetailNo,
									OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									CASE 
										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
										ELSE OldMaterialQcDetailNo
									END AS OldMaterialQcDetailNo,
									CASE 
										WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
										ELSE OldMaterialQcSampleNo
									END AS OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									CASE 
										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
										ELSE OldMaterialQcDetailNo
									END AS OldMaterialQcDetailNo,
									CASE 
										WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
										ELSE OldMaterialQcSampleNo
									END AS OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialQcNo,
								 @OldMaterialQcDetailNo,
								 @OldMaterialQcSampleNo,
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @MaterialQcSampleNo,
								 @SampleSerialNo,
								 @TestUserID,
								 @TestDateTime,
								 @TestValue,
								 @TestResult,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @LSL,
								 @USL


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				--SELECT
				--		@DocDecisionResult = MQI.DecisionResult
				--FROM
				--		STB_MaterialQcInfo MQI WITH (NOLOCK)
				--WHERE
				--		MQI.MaterialQcNo = @MaterialQcNo

				--IF ISNULL(@DocDecisionResult,'') IN ('P','S')
				--BEGIN
				--		RAISERROR('이미 처리된 수입검사 문서입니다', 16, 1)
				--		RETURN
				--END

				IF @TestValue > @USL * 5 OR @TestValue < @LSL / 5.0 BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '상/하한을 크게 벗어나는 값이 있습니다. 확인 바랍니다.'
					RETURN  --
				END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcSampleResult_BendingCutting WHERE MaterialQcNo = @MaterialQcNo AND MaterialQcDetailNo = @MaterialQcDetailNo AND MaterialQcSampleNo = @MaterialQcSampleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcSampleResult_BendingCutting',@MaterialQcNo OUTPUT
                    END

                    INSERT INTO STB_MaterialQcSampleResult_BendingCutting
						(
						    MaterialQcNo,
						    MaterialQcDetailNo,
						    MaterialQcSampleNo,
						    SampleSerialNo,
						    TestUserID,
						    TestDateTime,
						    TestValue,
						    TestResult,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialQcNo,
						    @MaterialQcDetailNo,
						    @MaterialQcSampleNo,
						    @SampleSerialNo,
						    @TestUserID,
						    @TestDateTime,
						    @TestValue,
						    @TestResult,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcSampleResult_BendingCutting
						SET
						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
						    MaterialQcDetailNo =   ISNULL(@MaterialQcDetailNo,MaterialQcDetailNo),
						    MaterialQcSampleNo =   ISNULL(@MaterialQcSampleNo,MaterialQcSampleNo),
						    SampleSerialNo =   ISNULL(@SampleSerialNo,SampleSerialNo),
						    TestUserID =   ISNULL(@TestUserID,TestUserID),
						    TestDateTime =   ISNULL(@TestDateTime,TestDateTime),
						    TestValue =   ISNULL(@TestValue,TestValue),
						    TestResult =   ISNULL(@TestResult,TestResult),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo AND
						    MaterialQcSampleNo = @OldMaterialQcSampleNo

					-- SampleResult 개수만큼 호출할 필요가 없음.
					-- 저장이 완료된 후(커서가 완료된 후) 한번만 호출하는 것으로 변경 2022.04.19 by Jackaroe
					---- QcDetail Update
					
					--	;WITH SampleResult AS
					--	(
					--		SELECT
					--				TestResult
					--		FROM
					--				STB_MaterialQcSampleResult WITH(NOLOCK)
					--		WHERE
					--				MaterialQcNo = @OldMaterialQcNo AND
					--				MaterialQcDetailNo = @OldMaterialQcDetailNo
					--	)
					
					--	UPDATE STB_MaterialQcDetail 
					--	SET
					--			PassedSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'P'),
					--			DefectSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'F'),
					--			SkipSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'S')
					--	WHERE
					--			MaterialQcNo = @OldMaterialQcNo AND
					--			MaterialQcDetailNo = @OldMaterialQcDetailNo

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcSampleResult_BendingCutting
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo AND
						    MaterialQcSampleNo = @OldMaterialQcSampleNo
                END
            END

			-- Insert, Update, Delete 가 끝난 후 업데이트 실행
			;WITH SampleResult AS
			(
				SELECT
						TestResult
				FROM
						STB_MaterialQcSampleResult_BendingCutting WITH(NOLOCK)
				WHERE
						MaterialQcNo = @OldMaterialQcNo AND
						MaterialQcDetailNo = @OldMaterialQcDetailNo
			)
					
			UPDATE STB_MaterialQcDetail_BendingCutting 
			SET
					PassedSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'P'),
					DefectSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'F'),
					SkipSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'S')
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					MaterialQcDetailNo = @OldMaterialQcDetailNo
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
