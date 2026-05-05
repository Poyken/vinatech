-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Thêm sửa xoá việc thay đổi và cấu hình nguyên vật liệu
-- =============================================
CREATE PROCEDURE [dbo].[usp_ChangeMaterialCodeConfig_uid] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID varchar(20)= NULL,
    @pProcessLanguage varchar(20)= NULL,
    @pXml NVARCHAR(MAX) = null,
	@pProcessViewName VARCHAR(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from

    -- Insert statements for procedure here
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
  DECLARE @oldMaterialCode VARCHAR(50)
  DECLARE @NewMaterialCode VARCHAR(50)
  DECLARE @Voltage DECIMAL(18,2)
  DECLARE @Farad DECIMAL(18,2)
  DECLARE @MBISizeW DECIMAL(5,2)
  DECLARE @MBISizeH DECIMAL(5,2)
  DECLARE @CreatedBy VARCHAR(50) = @ProcessUserID -- Thêm trưởng hợp người sửa xoá

  
  DECLARE @iDoc INT
  -- check xem ai có quyền để thêm sửa xóa 
  if(@CreatedBy not in ('HaiTrieu','doannam','hoangxuan'))
  begin
			raiserror(N'Bạn không có quyền vui lòng liên hệ EA !',16,1)
			return;
	end

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ChangeMaterialCode_Config',
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
									oldMaterialCode,
									NewMaterialCode,
									Voltage,
									Farad,
									MBISizeW,
									MBISizeH

							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 ID bigint,
											 oldMaterialCode VARCHAR(50),
											 NewMaterialCode VARCHAR(50),
											 Voltage DECIMAL(18,2),
											 Farad DECIMAL(18,2),
											 MBISizeW DECIMAL(5,2),
											 MBISizeH DECIMAL(5,2)
                                             
											
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									ID,
									oldMaterialCode,
									NewMaterialCode,
									Voltage,
									Farad,
									MBISizeW,
									MBISizeH
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											ID bigint,
											 oldMaterialCode VARCHAR(50),
											 NewMaterialCode VARCHAR(50),
											 Voltage DECIMAL(18,2),
											 Farad DECIMAL(18,2),
											 MBISizeW DECIMAL(5,2),
											 MBISizeH DECIMAL(5,2)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									ID,
									oldMaterialCode,
									NewMaterialCode,
									Voltage,
									Farad,
									MBISizeW,
									MBISizeH

							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											ID bigint,
											 oldMaterialCode VARCHAR(50),
											 NewMaterialCode VARCHAR(50),
											 Voltage DECIMAL(18,2),
											 Farad DECIMAL(18,2),
											 MBISizeW DECIMAL(5,2),
											 MBISizeH DECIMAL(5,2)
											) 
		


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								
								 @IUD_FLAG,
								 @ID,
								 @oldMaterialCode,
								 @NewMaterialCode,
								 @Voltage,
								 @Farad,
								 @MBISizeW,
								 @MBISizeH
							


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
				   -- select * from STB_ChangeMaterialCode_HN

					 --IF EXISTS (SELECT 1 FROM STB_ChangeMaterialCode_HN WHERE (PackingID = @PackingID)) BEGIN
						--RAISERROR(N'Mã packing này đã được thêm rồi : KeyField = %s', 16, 1, @PackingID)
					--END
					--declare @isLotID1 varchar(1)=@isLotID 
			  --- select * from 
			 		 --DECLARE @ID1 int=@ID
					--raiserror(@ID1,16,1)
                    INSERT INTO STB_ChangeMaterialCode_Config
						(
						    oldMaterialCode,
						    NewMaterialCode,
						    Voltage,
						    Farad,
							MBISizeW,
							MBISizeH,
							CreatedBy


						)
						VALUES
						(
						    @oldMaterialCode,
						    @NewMaterialCode,
							@Voltage,
							@Farad,
							@MBISizeW,
							@MBISizeH,
							 @CreatedBy
						)

						
				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
						UPDATE STB_ChangeMaterialCode_Config
				SET 
					oldMaterialCode = ISNULL(@oldMaterialCode, oldMaterialCode),
					NewMaterialCode = ISNULL(@NewMaterialCode, NewMaterialCode),
					Voltage = ISNULL(@Voltage, Voltage),
					Farad = ISNULL(@Farad, Farad),
					MBISizeW = ISNULL(@MBISizeW, MBISizeW),
					MBISizeH = ISNULL(@MBISizeH, MBISizeH),
					CreatedBy = @CreatedBy
				WHERE ID = @ID;

					
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ChangeMaterialCode_Config
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
