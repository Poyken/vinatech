-- =============================================
-- Author:		Mr.Duy	
-- Create date: 2024-12-18
-- Description:	đổi lot no và lưu lại lịch sử đổi lot no ở màn hình B523 màn hình để chạy store này là B353
-- =============================================
CREATE PROCEDURE [dbo].[usp_ChangeLotnoPrintTem]
								@pProcessUserID varchar(20)= NULL,
								@pProcessLanguage varchar(20)= NULL,
								@pXml NVARCHAR(MAX) = null,
								@pProcessViewName VARCHAR(50)=null

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


  DECLARE @ID bigint
  DECLARE @oldLotID VARCHAR(50)
  DECLARE @NewLotID VARCHAR(50)
  DECLARE @CreateUserID VARCHAR(50)
  DECLARE @isLotID BIT

  DECLARE @iDoc INT
  -- check xem ai có quyền để thêm sửa xóa 
  if(@pProcessUserID not in ('duonghoa','dangchinh','anhduy157','punthao','hant-1998', 'DinhManh','32205024'))
	begin
			raiserror(N'Bạn không có quyền vui lòng liên hệ EA !',16,1)
			return;
	end

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ChangePartNoAndLotNo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									ID,
									oldLotID,
									NewLotID,
									CreateUserID,
									isLotID

							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											ID bigint,
											 oldLotID VARCHAR(50),
											 NewLotID VARCHAR(50),
											 CreateUserID VARCHAR(50),
											 isLotID BIT
											
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									ID,
									oldLotID,
									NewLotID,
									CreateUserID,
									isLotID

							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											ID bigint,
											 oldLotID VARCHAR(50),
											 NewLotID VARCHAR(50),
											 CreateUserID VARCHAR(50),
											 isLotID BIT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									ID,
									oldLotID,
									NewLotID,
									CreateUserID,
									isLotID

							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											ID bigint,
											 oldLotID VARCHAR(50),
											 NewLotID VARCHAR(50),
											 CreateUserID VARCHAR(50),
											 isLotID BIT
											) 
		


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								
								 @IUD_FLAG,
								  @ID,
								 @oldLotID,
								 @NewLotID,
								 @CreateUserID,
								 @isLotID
							


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

					 IF EXISTS (SELECT 1 FROM STB_ChangePartNoAndLotNo WHERE (oldLotID = @oldLotID or NewLotID = @NewLotID)) BEGIN
						RAISERROR(N'Lot này đã được thêm rồi  : KeyField = %s', 16, 1, @oldLotID)
					END
					--declare @isLotID1 varchar(1)=@isLotID 
			
			 		 --DECLARE @ID1 int=@ID
					--raiserror(@ID1,16,1)
                    INSERT INTO STB_ChangePartNoAndLotNo
						(
						    oldLotID,
						    NewLotID,
						    CreateUserID,
						    isLotID

						)
						VALUES
						(
						    @oldLotID,
						    @NewLotID,
						    @ProcessUserID,
						    @isLotID
						)

						
				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ChangePartNoAndLotNo
						SET
						    oldLotID =   CASE
						                WHEN @oldLotID IS NOT NULL THEN @oldLotID
						                ELSE oldLotID
						            END,
						    NewLotID =   CASE
						                WHEN @NewLotID IS NOT NULL THEN @NewLotID
						                ELSE NewLotID
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    isLotID =   CASE
						                WHEN @isLotID IS NOT NULL THEN @isLotID
						                ELSE isLotID
						            END

						WHERE
						    ID = @ID


					
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ChangePartNoAndLotNo
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
