-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-20
-- Description:	Thêm dữ liệu báo phế lên hệ thống
-- =============================================
CREATE PROCEDURE [dbo].[usp_AddWasteMaterialOfProduction]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL
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

	declare @errrr NVARCHAR(500)=N'Bạn không được phép SỬA(XÓA) dữ liệu màn hình này. Liên hệ  Ms.Sao  của Kế hoạch SX!';
	declare @XXMMLL NVARCHAR(MAX) = convert(NVARCHAR(MAX),@pXml);
	declare @existsUPDATE INT = charindex(@ProcessViewName +'_UPDATE',@XXMMLL);
	declare @existsDELETE INT = charindex(@ProcessViewName +'_DELETE',@XXMMLL);
	 ------- Get time follow shift------------------------


    DECLARE @TimeServer NVARCHAR(50),
	        @TimeFromShiftS02 NVARCHAR(50),
			@TimeToShiftS02 NVARCHAR(50),
			@TimeFromShiftS01 NVARCHAR(50),
			@TiemToShiftS01 NVARCHAR(50),
			@ShiftName NVARCHAR(50)
			
			
	SET @TimeServer= CONVERT(VARCHAR(8), DATEADD(HH, 0, GETDATE()),108)

	SELECT @TimeFromShiftS01=CONVERT(VARCHAR(8),FromTime,108),@TiemToShiftS01=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS01'
		
	

	IF @TimeFromShiftS01 <=CAST(@TimeServer AS TIME) or @TiemToShiftS01 >=CAST(@TimeServer AS TIME)

	BEGIN

	    SELECT @ShiftName=NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS01'
	END

	SELECT @TimeFromShiftS02=CONVERT(VARCHAR(8),FromTime,108),@TimeToShiftS02=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS02'

	IF @TimeFromShiftS02 <= CAST(@TimeServer AS TIME) or @TimeToShiftS02 >=CAST(@TimeServer AS TIME)

	BEGIN
	    SELECT @ShiftName=NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS02'
	END
	--raiserror (@TimeFromShiftS01,16,1);
								
						--		return;
	 ------------------------------------------------------
	 --- select * from STB_VN_PRODUCTION_ERROR

	-- alter table STB_VN_PRODUCTION_ERROR
	-- add MachineCode varchar(20)

	 -- Declare Columns Variable
	 DECLARE @IDPE INT
	 DECLARE @Line NVARCHAR(30)
	 DECLARE @Model NVARCHAR(50)
	 DECLARE @Item  NVARCHAR(120)
	 DECLARE @NG    NVARCHAR(50)
	 DECLARE @NameError NVARCHAR(50)
	 DECLARE @Weights NVARCHAR(20)
	 DECLARE @StatusError NVARCHAR(50)
	 DECLARE @NameShift NVARCHAR(50)
	 DECLARE @Decs  NVARCHAR(20)
	 DECLARE @CreateDateTime DATETIME
     DECLARE @CreateUserID NVARCHAR(20)
     DECLARE @ChangeDateTime DATETIME
     DECLARE @ChangeUserID NVARCHAR(20)
	 DECLARE @UNIT NVARCHAR(20)
	 DECLARE @LINENAME NVARCHAR(50)
	 DECLARE @WorkCenterCode NVARCHAR(50)
	 DECLARE @iDoc INT
	 DECLARE @MachineCode VARCHAR(20)
	 DECLARE @LotNo VARCHAR(50)
	 DECLARE @MaLotCapThu VARCHAR(50) 
	 DECLARE @MaLotNguyenLieu VARCHAR(50) 

	 	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_PRODUCTION_ERROR',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
  EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
			
				  DECLARE SourceData CURSOR FOR
				   SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.IDPE,
									XMLData.Model,
									XMLData.Item,
									XMLData.NG,
									XMLData.NameError,
									XMLData.Weights,
									XMLData.StatusError,
									XMLData.NameShift,
									XMLData.Decs,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UNIT,
									XMLData.LINENAME,
									XMLData.MaLotCapThu ,
									XMLData.MaLotNguyenLieu,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.LotNo
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 IDPE INT,
											 Model NVARCHAR(50),
											 Item NVARCHAR(120),
											 NG NVARCHAR(50),
											 NameError NVARCHAR(50),
											 Weights NVARCHAR(50),
											 StatusError NVARCHAR(50),
											 NameShift NVARCHAR(50),
											 Decs NVARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UNIT NVARCHAR(20),
											 LINENAME NVARCHAR(50),
											 MaLotCapThu VARCHAR(50) ,
											 MaLotNguyenLieu VARCHAR(50),
											 WorkCenterCode VARCHAR(50),
											 MachineCode VARCHAR(20),
											 LotNo VARCHAR(50)
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									XMLData.IDPE,
									XMLData.Model,
									XMLData.Item,
									XMLData.NG,
									XMLData.NameError,
									XMLData.Weights,
									XMLData.StatusError,
									XMLData.NameShift,
									XMLData.Decs,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UNIT,
									XMLData.LINENAME,
									XMLData.MaLotCapThu,
									XMLData.MaLotNguyenLieu,
									XMLData.WorkCenterCode,
										XMLData.MachineCode,
										XMLData.LotNo
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 IDPE INT,
											 Model NVARCHAR(50),
											 Item NVARCHAR(120),
											 NG NVARCHAR(50),
											 NameError NVARCHAR(50),
											 Weights NVARCHAR(50),
											 StatusError NVARCHAR(50),
											 NameShift NVARCHAR(50),
											 Decs NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UNIT NVARCHAR(20),
											 LINENAME NVARCHAR(50),
											 MaLotCapThu VARCHAR(50) ,
											 MaLotNguyenLieu VARCHAR(50),
											 WorkCenterCode VARCHAR(50),
											  MachineCode VARCHAR(20),
											   LotNo VARCHAR(50)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									XMLData.IDPE,
									XMLData.Model,
									XMLData.Item,
									XMLData.NG,
									XMLData.NameError,
									XMLData.Weights,
									XMLData.StatusError,
									XMLData.NameShift,
									XMLData.Decs,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UNIT,
									XMLData.LINENAME,
									XMLData.MaLotCapThu ,
									XMLData.MaLotNguyenLieu,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.LotNo
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 IDPE INT,
											 Model NVARCHAR(50),
											 Item NVARCHAR(120),
											 NG NVARCHAR(50),
											 NameError NVARCHAR(50),
											 Weights NVARCHAR(50),
											 StatusError NVARCHAR(50),
											 NameShift NVARCHAR(50),
											 Decs NVARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UNIT NVARCHAR(20),
											 LINENAME NVARCHAR(50),
											 MaLotCapThu VARCHAR(50) ,
											 MaLotNguyenLieu VARCHAR(50), 
											 WorkCenterCode VARCHAR(50),
											  MachineCode VARCHAR(20),
											   LotNo VARCHAR(50)
											) XMLData
					 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @IDPE,
								 @Model,
								 @Item,
								 @NG,
								 @NameError,
								 @Weights,
								 @StatusError,
								 @NameShift,
								 @Decs,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @UNIT,
								 @LINENAME,
								 @MaLotCapThu,
								 @MaLotNguyenLieu,
								 @WorkCenterCode,
								 @MachineCode,
								 @LotNo

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
		  IF @IUD_FLAG = 'INSERT' BEGIN
		
                   /*   IF EXISTS (SELECT 1 FROM STB_VN_PRODUCTION_ERROR WHERE IDPE = @IDPE) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IDPE)
					END
							
					declare @fdf varchar(2)=@IsAutoKey
					raiserror(@fdf,16,1)
					return;
					*/
		
						--EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_PRODUCTION_ERROR', @IDPE OUTPUT
						declare @CodeInputWarehouse varchar(50)
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_PRODUCTION_ERROR', @CodeInputWarehouse OUTPUT

		INSERT INTO STB_VN_PRODUCTION_ERROR
						(
						 
						    Model,
						    Item,
						    NG,
						    NameError,
						    Weights,
							StatusError,
							NameShift,
							Decs,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							UNIT,
							LINENAME,
							MaLotCapThu,
							MaLotNguyenLieu,
							WorkCenterCode,
							MachineCode,
							CodeInputWarehouse,
							LotNo
						)
						VALUES
						(
						
						    @Model,
						    @Item,
						    @NG,
						    @NameError,
						    @Weights,
							N'Báo phế',
							@ShiftName,
							@Decs,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@UNIT,
							@LINENAME,
							@MaLotCapThu,
							@MaLotNguyenLieu,
							@WorkCenterCode,
							@MachineCode,
							@CodeInputWarehouse,
							@LotNo
						)
						END ELSE IF @IUD_FLAG = 'UPDATE' and (@Decs is not null or @Decs <>'')   BEGIN
						/*
						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								raiserror (@errrr,16,1);
								break;
								return;
							end
							*/
						UPDATE STB_VN_PRODUCTION_ERROR
						SET
							StatusError=N'Hủy phế',
							Decs =@Decs,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID

						--UNIT = CASE
						--				WHEN @UNIT IS NOT NULL THEN @UNIT
						--				ELSE UNIT
						--		END
					WHERE
						    IDPE = @IDPE
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								raiserror (@errrr,16,1);
								break;
								return;
							end


                        DELETE FROM STB_VN_PRODUCTION_ERROR
						WHERE
						    IDPE = @IDPE
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

