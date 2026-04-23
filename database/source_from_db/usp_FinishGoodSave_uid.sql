-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-15
-- Description: Lưu lại dữ liệu
-- =============================================
CREATE PROCEDURE [dbo].[usp_FinishGoodSave_uid]
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
	DECLARE @Id INT
	DECLARE @LotNo VARCHAR(50)
	DECLARE @Qty int
	DECLARE @Position nvarchar(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	

	DECLARE @iDoc INT


	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							Id, LotNo,Qty,Position, 
                       CreateDateTime, CreateUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
					Id INT,
                    LotNo NVARCHAR(50),
                    Qty INT,
                    Position NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20)
                   
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							Id, LotNo,Qty,Position, 
                       CreateDateTime, CreateUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
											Id INT,
                    LotNo NVARCHAR(50),
                    Qty INT,
                    Position NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							Id, LotNo,Qty,Position, 
                       CreateDateTime, CreateUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										Id INT,
                    LotNo NVARCHAR(50),
                    Qty INT,
                    Position NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								  @IUD_FLAG, @Id, @LotNo, @Qty,@Position,
               @CreateDateTime, @CreateUserID
                
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_ConfigPosition WHERE Id = @ID)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_ConfigPosition',@ID OUTPUT
                    END

					INSERT INTO STB_VN_FINISHGOODS_ConfigPosition
						(
					   LotNo, 
                       Qty,
					   Position,
                       CreateDateTime, CreatedBy
						)
						VALUES
						(
							  @LotNo,
							  @Qty,
							  @Position,
                            GETDATE(), @pProcessUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_VN_FINISHGOODS_ConfigPosition
						SET
							LotNo = ISNULL(@LotNo, LotNo),
                    Qty = ISNULL(@Qty, Qty),
                    Position = ISNULL(@Position, Position)
						WHERE
							Id = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_VN_FINISHGOODS_ConfigPosition
						WHERE
							Id = @ID

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
--GO
