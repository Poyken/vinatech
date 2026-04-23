
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-07-01
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrolyteMoistureMeasureHist_iud]
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
  DECLARE @OldMoistureMeasureHistNo VARCHAR(20)
  DECLARE @MoistureMeasureHistNo VARCHAR(20)
  DECLARE @ProductSizeCode VARCHAR(10)
  DECLARE @Temperature NUMERIC(10,2)
  DECLARE @DewPoint NUMERIC(10,2)
  DECLARE @ElectrolyteMoistureValue NUMERIC(10,2)
  DECLARE @IsPass BIT
  DECLARE @IsMaterial BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  Declare @LineCode VARCHAR(20)
  Declare @LineManualYn BIT

  -- 비고추가 2020.10.30 이미정 차장님 요청 By Jackaroe
  Declare @Remark NVARCHAR(MAX)
  -- 품목코드 추가 2021.03.26 이미정 차장님 요청 By Jackaroe
  Declare @MaterialCode VARCHAR(20)



	DECLARE @iDoc INT
        
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								ProductSizeCode,
								Temperature,
								DewPoint,
								ElectrolyteMoistureValue,
								IsPass,
								IsMaterial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark,
								MaterialCode
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											ProductSizeCode VARCHAR(10),
											Temperature NUMERIC(10,2),
											DewPoint NUMERIC(10,2),
											ElectrolyteMoistureValue NUMERIC(10,2),
											IsPass BIT,
											IsMaterial BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX),
											MaterialCode VARCHAR(20)
										)
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
									ELSE OldMoistureMeasureHistNo
								END AS OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								ProductSizeCode,
								Temperature,
								DewPoint,
								ElectrolyteMoistureValue,
								IsPass,
								IsMaterial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark,
								MaterialCode
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											ProductSizeCode VARCHAR(10),
											Temperature NUMERIC(10,2),
											DewPoint NUMERIC(10,2),
											ElectrolyteMoistureValue NUMERIC(10,2),
											IsPass BIT,
											IsMaterial BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX),
											MaterialCode VARCHAR(20)
										)
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
									ELSE OldMoistureMeasureHistNo
								END AS OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								ProductSizeCode,
								Temperature,
								DewPoint,
								ElectrolyteMoistureValue,
								IsPass,
								IsMaterial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark,
								MaterialCode
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											ProductSizeCode VARCHAR(10),
											Temperature NUMERIC(10,2),
											DewPoint NUMERIC(10,2),
											ElectrolyteMoistureValue NUMERIC(10,2),
											IsPass BIT,
											IsMaterial BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX),
											MaterialCode VARCHAR(20)
										) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldMoistureMeasureHistNo,
								@MoistureMeasureHistNo,
								@ProductSizeCode,
								@Temperature,
								@DewPoint,
								@ElectrolyteMoistureValue,
								@IsPass,
								@IsMaterial,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@Remark,
								@MaterialCode


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

            IF @IUD_FLAG = 'INSERT' BEGIN

                IF EXISTS (SELECT 1 FROM STB_ElectrolyteMoistureMeasureHist WHERE MoistureMeasureHistNo = @MoistureMeasureHistNo) BEGIN
					RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoistureMeasureHistNo)
				END

				SELECT @MoistureMeasureHistNo = MoistureMeasureHistNo 
					FROM #PRIMARYKEY_TEMP

				-- 생선된 번호에서 라인정보확인
				SELECT @LineCode = LineCode
				  FROM STB_MoistureMeasureHist
				 WHERE MoistureMeasureHistNo = @MoistureMeasureHistNo

				-- 라인의 자/수동 여부확인
				SELECT @LineManualYn = CASE WHEN LineType = 'Auto' THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END
				  FROM STB_LineInfo
				 WHERE LineCode = @LineCode

                INSERT INTO STB_ElectrolyteMoistureMeasureHist
					(
						MoistureMeasureHistNo,
						ProductSizeCode,
						Temperature,
						DewPoint,
						ElectrolyteMoistureValue,
						IsPass,
						IsMaterial,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID,
						Remark,
						MaterialCode
					)
					VALUES
					(
						@MoistureMeasureHistNo,
						@ProductSizeCode,
						@Temperature,
						@DewPoint,
						@ElectrolyteMoistureValue,
						CASE WHEN @LineManualYn = CONVERT(BIT, 1) AND @ElectrolyteMoistureValue > 300 THEN CONVERT(BIT, 0)
						     WHEN @LineManualYn = CONVERT(BIT, 0) AND @ElectrolyteMoistureValue > 200 THEN CONVERT(BIT, 0)
							 WHEN @IsMaterial = CONVERT(BIT, 1) AND @ElectrolyteMoistureValue > 20 THEN CONVERT(BIT, 0)
							 ELSE CONVERT(BIT, 1) END,
						@IsMaterial,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID,
						@Remark,
						@MaterialCode
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				-- 생선된 번호에서 라인정보확인
				SELECT @LineCode = LineCode
				  FROM STB_MoistureMeasureHist
				 WHERE MoistureMeasureHistNo = @MoistureMeasureHistNo

				-- 라인의 자/수동 여부확인
				SELECT @LineManualYn = CASE WHEN LineType = 'Auto' THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END
				  FROM STB_LineInfo
				 WHERE LineCode = @LineCode

                UPDATE STB_ElectrolyteMoistureMeasureHist
					SET
						MoistureMeasureHistNo =   ISNULL(@MoistureMeasureHistNo,MoistureMeasureHistNo),
						ProductSizeCode =   ISNULL(@ProductSizeCode,ProductSizeCode),
						Temperature =   ISNULL(@Temperature,Temperature),
						DewPoint =   ISNULL(@DewPoint,DewPoint),
						ElectrolyteMoistureValue =   ISNULL(@ElectrolyteMoistureValue,ElectrolyteMoistureValue),
						IsPass =   CASE WHEN @LineManualYn = CONVERT(BIT, 1) AND @ElectrolyteMoistureValue > 300 THEN CONVERT(BIT, 0)
										 WHEN @LineManualYn = CONVERT(BIT, 0) AND @ElectrolyteMoistureValue > 200 THEN CONVERT(BIT, 0)
										 WHEN @IsMaterial = CONVERT(BIT, 1) AND @ElectrolyteMoistureValue > 20 THEN CONVERT(BIT, 0)
										 ELSE CONVERT(BIT, 1) END,
						IsMaterial =   ISNULL(@IsMaterial,IsMaterial),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID,
						Remark = ISNULL(@Remark,Remark),
						MaterialCode = ISNULL(@MaterialCode,MaterialCode)
					WHERE
						MoistureMeasureHistNo = @OldMoistureMeasureHistNo
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_ElectrolyteMoistureMeasureHist
					WHERE
						MoistureMeasureHistNo = @OldMoistureMeasureHistNo
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
