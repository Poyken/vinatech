-- Procedure: usp_ChangeMaterialInputMaterialOfBOM
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-25
-- Description:	Thay đổi mã nguyên liệu đầu vào của lot hàng sản xuất
-- =============================================
CREATE PROCEDURE usp_ChangeMaterialInputMaterialOfBOM
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50),
		@pXml NVARCHAR(MAX) = NULL
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
	DECLARE @ID VARCHAR(max)
	DECLARE @OldMaterialCode VARCHAR(50)
	DECLARE @NewMaterialCode VARCHAR(50)
	DECLARE @IsUse bit
	DECLARE @LotID VARCHAR(50)        
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(50)
	DECLARE @Reason NVARCHAR(200)   
	DECLARE @UseQty numeric(20,10)

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							ID,
							OldMaterialCode,
							NewMaterialCode,
							IsUse,
							LotID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							Reason,
							UseQty

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
									
										ID int,
										OldMaterialCode VARCHAR(50),
										NewMaterialCode VARCHAR(50),
										IsUse bit,
										LotID VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(50),
										Reason NVARCHAR(200),
										UseQty numeric(20,10)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							 ID,
							OldMaterialCode,
							NewMaterialCode,
							IsUse,
							LotID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							Reason,
							UseQty
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
									
										ID int,
										OldMaterialCode VARCHAR(50),
										NewMaterialCode VARCHAR(50),
										IsUse bit,
										LotID VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(50),
										Reason NVARCHAR(200),
										UseQty numeric(20,10)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							 ID,
							OldMaterialCode,
							NewMaterialCode,
							IsUse,
							LotID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							Reason,
							UseQty
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
							
								ID int,
										OldMaterialCode VARCHAR(50),
										NewMaterialCode VARCHAR(50),
										IsUse bit,
										LotID VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(50),
										Reason NVARCHAR(200),
										UseQty numeric(20,10)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@ID,
								@OldMaterialCode,
								@NewMaterialCode,
								@IsUse,
								@LotID,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@Reason,
								@UseQty
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
						--RAISERROR( @IUD_FLAG ,16, 1)
						--	Return
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)



					INSERT INTO STB_HistoryChangeInputMaterialOfBOM
						(
							OldMaterialCode,
							NewMaterialCode,
							IsUse,
							LotID,
							CreateDateTime,
							CreateUserID,
							Reason,
							UseQty
						)
						VALUES
						(
							@OldMaterialCode,
							@NewMaterialCode,
							@IsUse,
							@LotID,
							GETDATE(),
							@pProcessUserID,
							@Reason,
							@UseQty
						)

							


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
					UPDATE STB_HistoryChangeInputMaterialOfBOM
						SET
							OldMaterialCode = ISNULL(@OldMaterialCode, OldMaterialCode),
							NewMaterialCode = ISNULL(@NewMaterialCode, NewMaterialCode),
							IsUse=@IsUse,
							Reason = ISNULL(@Reason, Reason),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID,
							UseQty = @UseQty

						WHERE
							ID = @ID

					
							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					/*DELETE FROM STB_HistoryChangeInputMaterialOfBOM
						WHERE
							MaterialCode = @MaterialCode*/
							RAISERROR( N'Bạn không được xóa' ,16, 1)
							Return

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
    --END


END

GO

