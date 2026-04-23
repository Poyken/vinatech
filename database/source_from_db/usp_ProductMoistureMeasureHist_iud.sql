
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-07-01
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductMoistureMeasureHist_iud]
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
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @IsAging BIT
  DECLARE @AgingCount INT
  DECLARE @ProductMoistureValue NUMERIC(10,2)
  DECLARE @ActionContents NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  --비고 추가 이미정 차장님 요청 2020.10.30 By Jackaroe
  DECLARE @Remark NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								MaterialCode,
								Barcode,
								IsAging,
								AgingCount,
								ProductMoistureValue,
								ActionContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											MaterialCode VARCHAR(20),
											Barcode VARCHAR(20),
											IsAging BIT,
											AgingCount INT,
											ProductMoistureValue NUMERIC(10,2),
											ActionContents NVARCHAR(MAX),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX)
										)
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
									ELSE OldMoistureMeasureHistNo
								END AS OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								MaterialCode,
								Barcode,
								IsAging,
								AgingCount,
								ProductMoistureValue,
								ActionContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											MaterialCode VARCHAR(20),
											Barcode VARCHAR(20),
											IsAging BIT,
											AgingCount INT,
											ProductMoistureValue NUMERIC(10,2),
											ActionContents NVARCHAR(MAX),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX)
										)
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
									ELSE OldMoistureMeasureHistNo
								END AS OldMoistureMeasureHistNo,
								MoistureMeasureHistNo,
								MaterialCode,
								Barcode,
								IsAging,
								AgingCount,
								ProductMoistureValue,
								ActionContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
											OldMoistureMeasureHistNo VARCHAR(20),
											MoistureMeasureHistNo VARCHAR(20),
											MaterialCode VARCHAR(20),
											Barcode VARCHAR(20),
											IsAging BIT,
											AgingCount INT,
											ProductMoistureValue NUMERIC(10,2),
											ActionContents NVARCHAR(MAX),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											Remark NVARCHAR(MAX)
										) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldMoistureMeasureHistNo,
								@MoistureMeasureHistNo,
								@MaterialCode,
								@Barcode,
								@IsAging,
								@AgingCount,
								@ProductMoistureValue,
								@ActionContents,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@Remark


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN

                IF EXISTS (SELECT 1 FROM STB_ProductMoistureMeasureHist WHERE MoistureMeasureHistNo = @MoistureMeasureHistNo) BEGIN
					RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoistureMeasureHistNo)
				END

				SELECT @MoistureMeasureHistNo = MoistureMeasureHistNo FROM #PRIMARYKEY_TEMP

                INSERT INTO STB_ProductMoistureMeasureHist
					(
						MoistureMeasureHistNo,
						MaterialCode,
						Barcode,
						IsAging,
						AgingCount,
						ProductMoistureValue,
						ActionContents,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID,
						Remark
					)
					VALUES
					(
						@MoistureMeasureHistNo,
						@MaterialCode,
						@Barcode,
						@IsAging,
						@AgingCount,
						@ProductMoistureValue,
						@ActionContents,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID,
						@Remark
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                UPDATE STB_ProductMoistureMeasureHist
					SET
						MoistureMeasureHistNo =   ISNULL(@MoistureMeasureHistNo,MoistureMeasureHistNo),
						MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						Barcode =   ISNULL(@Barcode,Barcode),
						IsAging =   ISNULL(@IsAging,IsAging),
						AgingCount =   ISNULL(@AgingCount,AgingCount),
						ProductMoistureValue =   ISNULL(@ProductMoistureValue,ProductMoistureValue),
						ActionContents =   ISNULL(@ActionContents,ActionContents),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID,
						Remark =   ISNULL(@Remark,Remark)
					WHERE
						MoistureMeasureHistNo = @OldMoistureMeasureHistNo
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_ProductMoistureMeasureHist
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
