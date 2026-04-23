-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-06
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetIOQCDefectDetail_iud]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50) = null,
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
	DECLARE @ID INT
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @InspectionDocType VARCHAR(10)
	DECLARE @MaterialQcDetailNo INT
	DECLARE @QcInspectionItemCode VARCHAR(20)
	DECLARE @DefectCode VARCHAR(20)
	DECLARE @DefectQty INT
	DECLARE @DefectDesc NVARCHAR(MAX)

	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT



	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							ID,
							MaterialQcNo,
							InspectionDocType,
							MaterialQcDetailNo,
							QcInspectionItemCode,
							DefectCode,
							DefectQty,
							DefectDesc,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										ID INT,
										MaterialQcNo VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialQcDetailNo INT,
										QcInspectionItemCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectQty INT,
										DefectDesc NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							ID,
							MaterialQcNo,
							InspectionDocType,
							MaterialQcDetailNo,
							QcInspectionItemCode,
							DefectCode,
							DefectQty,
							DefectDesc,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										ID INT,
										MaterialQcNo VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialQcDetailNo INT,
										QcInspectionItemCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectQty INT,
										DefectDesc NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							ID,
							MaterialQcNo,
							InspectionDocType,
							MaterialQcDetailNo,
							QcInspectionItemCode,
							DefectCode,
							DefectQty,
							DefectDesc,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										ID INT,
										MaterialQcNo VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialQcDetailNo INT,
										QcInspectionItemCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectQty INT,
										DefectDesc NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@ID,
								@MaterialQcNo,
								@InspectionDocType,
								@MaterialQcDetailNo,
								@QcInspectionItemCode,
								@DefectCode,
								@DefectQty,
								@DefectDesc,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					--IF EXISTS (SELECT 1 FROM STB_IOQCDefectDetail WHERE ID = @ID)
					--BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					--END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_IOQCDefectDetail',@ID OUTPUT
     --               END
					
					IF (ISNULL(@DefectQty,'') = '' OR @DefectQty <= 0) 
						BEGIN
							RAISERROR(N'Số lượng phải lớn hơn 0. Vui lòng kiểm tra lại!!!', 16, 1)
							RETURN
						END
					

					INSERT INTO STB_IOQCDefectDetail
						(
							MaterialQcNo,
							InspectionDocType,
							MaterialQcDetailNo,
							QcInspectionItemCode,
							DefectCode,
							DefectQty,
							DefectDesc,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@MaterialQcNo,
							@InspectionDocType,
							@MaterialQcDetailNo,
							@QcInspectionItemCode,
							@DefectCode,
							@DefectQty,
							@DefectDesc,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

					IF (ISNULL(@DefectQty,'') = '' OR @DefectQty <= 0) 
						BEGIN
							RAISERROR(N'Số lượng phải lớn hơn 0. Vui lòng kiểm tra lại!!!', 16, 1)
							RETURN
						END

					UPDATE STB_IOQCDefectDetail
						SET
							--MaterialQcNo = ISNULL(@ModelCode, ModelCode),
							--ModelName = ISNULL(@ModelName, ModelName),
							--Qty = ISNULL(@Qty, Qty),
							DefectCode = ISNULL(@DefectCode, DefectCode),
							DefectQty = ISNULL(@DefectQty, DefectQty),
							DefectDesc = ISNULL(@DefectDesc, DefectDesc),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							ID = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_IOQCDefectDetail
						WHERE
							ID = @ID

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
