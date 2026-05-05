-- Procedure: usp_Add_ProductionError
CREATE PROC [dbo].[usp_Add_ProductionError]
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
			

	SET @TimeServer=CONVERT(VARCHAR(8), DATEADD(HH, -2, GETDATE()),108)

	SELECT @TimeFromShiftS01=CONVERT(VARCHAR(8),FromTime,108),@TiemToShiftS01=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS01'

	IF @TimeFromShiftS01 <=@TimeServer AND @TiemToShiftS01 >=@TimeServer

	BEGIN
	    SELECT @ShiftName=NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS01'
	END

	SELECT @TimeFromShiftS02=CONVERT(VARCHAR(8),FromTime,108),@TimeToShiftS02=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS02'

	IF @TimeFromShiftS02 <= @TimeServer AND @TimeToShiftS02 >=@TimeServer

	BEGIN
	    SELECT @ShiftName=NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS02'
	END

	 ------------------------------------------------------
	 --- select * from STB_VN_PRODUCTION_ERROR

	 -- Declare Columns Variable
	 DECLARE @OldCompanyCode INT
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
	 DECLARE @NAMEFACTORY NVARCHAR(50)
	 DECLARE @iDoc INT

	 DECLARE		@MaLotCapThu VARCHAR(50) 
	 DECLARE		@MaLotNguyenLieu VARCHAR(50) 

	
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_PRODUCTION_ERROR',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 1 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_PRODUCTION_ERROR AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDPE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDPE,
							--XMLData.Line,
							XMLData.Model,
							XMLData.Item,
							XMLData.NG,
							XMLData.NameError,
							XMLData.Weights,
							XMLData.StatusError,
							XMLData.NameShift,
							XMLData.Decs,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.UNIT,
							XMLData.LINENAME,
							XMLData.MaLotCapThu ,
							XMLData.MaLotNguyenLieu,
							XMLData.WorkCenterCode,
							XMLData.NAMEFACTORY
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDPE INT,
										--Line NVARCHAR(30),
										Model NVARCHAR(50),
										Item NVARCHAR(120),
										NG NVARCHAR(50),
										NameError NVARCHAR(50),
										Weights NVARCHAR(20),
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
										NAMEFACTORY VARCHAR(50)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.IDPE = SourceTable.IDPE
				)
			WHEN MATCHED THEN
				UPDATE SET
					--Line = SourceTable.Line,
					Model = SourceTable.Model,
					Item = SourceTable.Item,
					NG = SourceTable.NG,
					NameError = SourceTable.NameError,
					Weights = SourceTable.Weights,
					StatusError = N'Chờ phế',
					NameShift = @ShiftName,
					Decs = SourceTable.Decs,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					UNIT =  SourceTable.UNIT, 
					LINENAME = SourceTable.LINENAME,
					MaLotCapThu =SourceTable.MaLotCapThu,
					MaLotNguyenLieu =SourceTable.MaLotNguyenLieu
WHEN NOT MATCHED THEN
				INSERT
					(
						--Line,
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
						UNIT,
						LINENAME,
						MaLotCapThu,
						MaLotNguyenLieu,
						WorkCenterCode,
						NAMEFACTORY
					)
				VALUES
					(
							--SourceTable.Line,
							SourceTable.Model,
							SourceTable.Item,
							SourceTable.NG,
							SourceTable.NameError,
							SourceTable.Weights,
							N'Chờ phế',
							---SourceTable.StatusError,
							--SourceTable.NameShift,
							@ShiftName,
							SourceTable.Decs,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.UNIT,
							SourceTable.LINENAME,
							SourceTable.MaLotCapThu ,
							SourceTable.MaLotNguyenLieu,
							SourceTable.WorkCenterCode,
						    SourceTable.NAMEFACTORY
					);


if  (@existsUPDATE>0 or @existsDELETE>0) begin
	if( @pProcessUserID   in ('sieusao','transao','nguyennha','phuongnt') ) begin

		-- Process Update Table
	 MERGE STB_VN_PRODUCTION_ERROR AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDPE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDPE,
							--XMLData.Line,
							XMLData.Model,
							XMLData.Item,
							XMLData.NG,
							XMLData.NameError,
							XMLData.Weights,
							XMLData.StatusError,
							XMLData.NameShift,
							XMLData.Decs,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.UNIT,
							XMLData.LINENAME,
							XMLData.MaLotCapThu ,
							XMLData.MaLotNguyenLieu,
							XMLData.WorkCenterCode,
							XMLData.NAMEFACTORY
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDPE INT,
										--Line NVARCHAR(30),
										Model NVARCHAR(50),
										Item NVARCHAR(120),
										NG NVARCHAR(50),
										NameError NVARCHAR(50),
										Weights NVARCHAR(20),
										StatusError NVARCHAR(50),
										NameShift NVARCHAR(50),
										Decs NVARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										UNIT NVARCHAR(20),
										LINENAME NVARCHAR(50),
										MaLotCapThu VARCHAR(50), 
										MaLotNguyenLieu VARCHAR(50),
										WorkCenterCode VARCHAR(50),
										NAMEFACTORY VARCHAR(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.IDPE = SourceTable.IDPE
				)
	WHEN MATCHED THEN 
				UPDATE SET
					--Line = SourceTable.Line,
					Model = SourceTable.Model,
					Item = SourceTable.Item,
					NG = SourceTable.NG,
					NameError = SourceTable.NameError,
					Weights = SourceTable.Weights,
					StatusError = N'Chờ phế', --SourceTable.StatusError,
					NameShift =@ShiftName, --SourceTable.NameShift,
					Decs = SourceTable.Decs,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					UNIT =  SourceTable.UNIT,
					LINENAME = SourceTable.LINENAME,
					MaLotCapThu = SourceTable.MaLotCapThu,
					MaLotNguyenLieu = SourceTable.MaLotNguyenLieu
			
			WHEN NOT MATCHED THEN
		INSERT
					(
						--Line,
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
						UNIT,
						LINENAME,
						MaLotCapThu,
						MaLotNguyenLieu,
						WorkCenterCode,
						NAMEFACTORY
					)
				VALUES
					(
							--SourceTable.Line,
							SourceTable.Model,
							SourceTable.Item,
							SourceTable.NG,
							SourceTable.NameError,
							SourceTable.Weights,
							N'Chờ phế',
							--SourceTable.StatusError,
							--SourceTable.NameShift,
							@ShiftName,
							SourceTable.Decs,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.UNIT,
							SourceTable.LINENAME,
							SourceTable.MaLotCapThu,
							SourceTable.MaLotNguyenLieu,
							SourceTable.WorkCenterCode,
							SourceTable.NAMEFACTORY
					);

			-- Process Delete Table
            MERGE STB_VN_PRODUCTION_ERROR AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDPE
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.IDPE,
							--XMLData.Line,
							XMLData.Model,
							XMLData.Item,
							XMLData.NG,
							XMLData.NameError,
							XMLData.Weights,
							XMLData.StatusError,
							XMLData.NameShift,
							XMLData.Decs,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.UNIT,
							XMLData.LINENAME,
							XMLData.MaLotCapThu,
							XMLData.MaLotNguyenLieu,
							XMLData.WorkCenterCode,
							XMLData.NAMEFACTORY
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										IDPE INT,
										--Line VARCHAR(30),
										Model NVARCHAR(50),
										Item NVARCHAR(120),
										NG NVARCHAR(50),
										NameError NVARCHAR(50),
										Weights NVARCHAR(20),
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
										NAMEFACTORY VARCHAR(50)
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.IDPE = SourceTable.IDPE
				)

			WHEN MATCHED THEN
				DELETE;
	end
	else 
	begin
		set @errrr = @errrr +' - '+convert(varchar(10),@existsUPDATE) +' - '+convert(varchar(10),@existsDELETE)
		raiserror (@errrr,16,1);
		return;
	end
 end

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
									XMLData.OldCompanyCode,
									XMLData.IDPE,
									--XMLData.Line,
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
									XMLData.NAMEFACTORY
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDPE INT,
											 --Line VARCHAR(30),
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
											 NAMEFACTORY VARCHAR(50)
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDPE
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDPE,
									--XMLData.Line,
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
									XMLData.NAMEFACTORY
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 IDPE INT,
											 --Line VARCHAR(30),
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
											 NAMEFACTORY VARCHAR(50)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.IDPE
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.IDPE,
									--XMLData.Line,
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
									XMLData.NAMEFACTORY
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 IDPE INT,
											 --Line NVARCHAR(30),
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
											 NAMEFACTORY VARCHAR(50)
											) XMLData
					 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 --@Line,
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
								 @NAMEFACTORY

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_PRODUCTION_ERROR WHERE IDPE = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			/* IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_PRODUCTION_ERROR', @OldCompanyCode OUTPUT
						*/
		INSERT INTO STB_VN_PRODUCTION_ERROR
						(
						    --Line,
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
							NAMEFACTORY
						)
						VALUES
						(
						    --@Line,
						    @Model,
						    @Item,
						    @NG,
						    @NameError,
						    @Weights,
							N'Chờ phế',
							@ShiftName,
							--@NameShift,
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
							@NAMEFACTORY
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								raiserror (@errrr,16,1);
								break;
								return;
							end

 UPDATE STB_VN_PRODUCTION_ERROR
						SET

						LINENAME = CASE
									WHEN @LINENAME IS NOT NULL THEN @LINENAME
									ELSE LINENAME
									END,
							--Line =   CASE
						 --               WHEN @Line IS NOT NULL THEN @Line
						 --               ELSE Line
						 --           END,
						Model =   CASE
						                WHEN @Model IS NOT NULL THEN @Model
						                ELSE Model
						            END,

							 Item =   CASE
						                WHEN @Item IS NOT NULL THEN @Item
						                ELSE Item
						            END,

							 NG =   CASE
						                WHEN @NG IS NOT NULL THEN @NG
						                ELSE NG
						            END,
							 NameError =   CASE
						                WHEN @NameError IS NOT NULL THEN @NameError
						                ELSE NameError
						            END,
						 Weights =   CASE
						                WHEN @Weights IS NOT NULL THEN @Weights
						                ELSE Weights
						            END,
						 StatusError =   CASE
						                WHEN @StatusError IS NOT NULL THEN @StatusError
						                ELSE StatusError
						            END,
						 NameShift =   CASE
						                WHEN @NameShift IS NOT NULL THEN @NameShift
						                ELSE NameShift
						            END,
						 Decs =   CASE
						                WHEN @Decs IS NOT NULL THEN @Decs
						                ELSE Decs
						            END,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID,
						MaLotCapThu =			 isnull(@MaLotCapThu,MaLotCapThu),
						MaLotNguyenLieu =		 isnull(@MaLotNguyenLieu,MaLotNguyenLieu)
						--UNIT = CASE
						--				WHEN @UNIT IS NOT NULL THEN @UNIT
						--				ELSE UNIT
						--		END
					WHERE
						    IDPE = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								raiserror (@errrr,16,1);
								break;
								return;
							end


                        DELETE FROM STB_VN_PRODUCTION_ERROR
						WHERE
						    IDPE = @OldCompanyCode
                    --END
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


GO

