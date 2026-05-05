CREATE PROC [dbo].[ups_Add_Fg_BG]
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

	-- Declare Columns Variable
	  DECLARE @OldCompanyCode NVARCHAR(50)
	  DECLARE @SoPhieuNhapKho NVARCHAR(50)
	  DECLARE @SoPhieuXuatKho NVARCHAR(50)
	  DECLARE @SoInVoice NVARCHAR(50)
	  DECLARE @SoToKhaiHaiQuan NVARCHAR(50)
	  DECLARE @PublicCode NVARCHAR(50)
	  DECLARE @Country NVARCHAR(50)
	  DECLARE @PartNo NVARCHAR(50)
	  DECLARE @PackingID NVARCHAR(50)
	  DECLARE @StatusSystem NVARCHAR(50)
	  DECLARE @Statusout NVARCHAR(50)
	  DECLARE @LotNo NVARCHAR(50)
	  DECLARE @MaterialCode NVARCHAR(50)
	  DECLARE @PackQty INT
	  DECLARE @CreateDate DATETIME
	  DECLARE @USERID NVARCHAR(50)
	  DECLARE @CreateDateChange DATETIME 
	  DECLARE @USERIDChange NVARCHAR(50)
	  DECLARE @IDCODE  NVARCHAR(50)
	  DECLARE @Descrption NVARCHAR(500)
	  DECLARE @MaterialName nvarchar(100)
	  DECLARE @ProductionSize NVARCHAR(50)
	  DECLARE @INPUTFROM NVARCHAR(50)
	  DECLARE @TYPEEXPORT NVARCHAR(50)
	  DECLARE @TRANSPORT NVARCHAR(50)
	  DECLARE @CUSTOMERNAME NVARCHAR(50)
	  DECLARE @LOCATIONS NVARCHAR(50)
	  DECLARE @iDoc INT

	--select * from STB_VN_FINISHGOODS
	  --STB_VN_FINISHGOODS
	 
		 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_FINISHGOODS_BG',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT   

  IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY
   	-- Process Insert Table
			 MERGE STB_VN_FINISHGOODS_BG AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.SoPhieuNhapKho,
							XMLData.SoPhieuXuatKho,
							XMLData.SoInVoice,
							XMLData.SoToKhaiHaiQuan,
							XMLData.PublicCode,
							XMLData.Country,
							XMLData.PartNo,
							XMLData.IDCODE,
							XMLData.Descrption,
							XMLData.MaterialName,
							XMLData.PackingID,
							XMLData.StatusSystem,
							XMLData.Statusout,
							XMLData.LotNo,
							XMLData.MaterialCode,
							XMLData.PackQty,
							XMLData.ProductionSize,
							XMLData.INPUTFROM,
							XMLData.TYPEEXPORT,
							XMLData.TRANSPORT,
							XMLData.CUSTOMERNAME,
							XMLData.LOCATIONS,
							DATEADD(HH, -2, GETDATE()) AS CreateDate,
							@pProcessUserID AS USERID,
							DATEADD(HH, -2, GETDATE()) AS CreateDateChange,
							@pProcessUserID AS USERIDChange
							
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										SoPhieuNhapKho NVARCHAR(50),
										SoPhieuXuatKho NVARCHAR(50),
										SoInVoice NVARCHAR(50),
										SoToKhaiHaiQuan NVARCHAR(50),
										PublicCode NVARCHAR(50),
										Country NVARCHAR(50),
										PartNo NVARCHAR(50),
										IDCODE  NVARCHAR(50),
										Descrption NVARCHAR(500),
										MaterialName nvarchar(100),
										PackingID NVARCHAR(50),
										StatusSystem NVARCHAR(50),
										Statusout NVARCHAR(50),
										LotNo NVARCHAR(50),
										MaterialCode NVARCHAR(50),
										PackQty INT,
										ProductionSize NVARCHAR(50),
										INPUTFROM NVARCHAR(50),
										TYPEEXPORT NVARCHAR(50),
										TRANSPORT  NVARCHAR(50),
										CUSTOMERNAME  NVARCHAR(50),
										LOCATIONS NVARCHAR(50),
										CreateDate  DATETIMEOFFSET,
										USERID VARCHAR(20),
										CreateDateChange  DATETIMEOFFSET,
										USERIDChange VARCHAR(20)
										
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
			
				UPDATE SET
					SoPhieuNhapKho = SourceTable.SoPhieuNhapKho,
					SoPhieuXuatKho = SourceTable.SoPhieuXuatKho,
					SoInVoice = SourceTable.SoInVoice,
					SoToKhaiHaiQuan = SourceTable.SoToKhaiHaiQuan,
					PublicCode = SourceTable.PublicCode,
					Country = SourceTable.Country,
					PartNo = SourceTable.PartNo,
					IDCODE = SourceTable.IDCODE,
					Descrption = SourceTable.Descrption,
					MaterialName = SourceTable.MaterialName,
					PackingID = SourceTable.PackingID,
					StatusSystem = SourceTable.StatusSystem,
					Statusout = SourceTable.Statusout,
					LotNo = SourceTable.LotNo,
					MaterialCode = SourceTable.MaterialCode,
					PackQty= SourceTable.PackQty,
					ProductionSize =SourceTable.ProductionSize,
					INPUTFROM=SourceTable.INPUTFROM,
					TYPEEXPORT=SourceTable.TYPEEXPORT,
					TRANSPORT=SourceTable.TRANSPORT,
					CUSTOMERNAME=SourceTable.CUSTOMERNAME,
					LOCATIONS =SourceTable.LOCATIONS,
					CreateDateChange = SourceTable.CreateDateChange,
					USERIDChange = SourceTable.USERIDChange
					
WHEN NOT MATCHED THEN

				INSERT
					(
						SoPhieuNhapKho,
				        SoPhieuXuatKho,
						SoInVoice,
						SoToKhaiHaiQuan,
						PublicCode,
						Country,
						PartNo,
						IDCODE,
						Descrption,
						MaterialName,
						PackingID,
						StatusSystem,
						Statusout,
						LotNo,
						MaterialCode,
						PackQty,
						ProductionSize,
						 INPUTFROM,
						TYPEEXPORT,
						TRANSPORT,
						CUSTOMERNAME, 
						LOCATIONS,
						CreateDateChange,
						USERIDChange
					)
				VALUES
					(
							SourceTable.SoPhieuNhapKho,
				            SourceTable.SoPhieuXuatKho,
							SourceTable.SoInVoice,
							SourceTable.SoToKhaiHaiQuan,
							SourceTable.PublicCode,
							SourceTable.Country,
							SourceTable.PartNo,
							SourceTable.IDCODE,
							SourceTable.Descrption,
							SourceTable.MaterialName,
							SourceTable.PackingID,
							SourceTable.StatusSystem,
							SourceTable.Statusout,
							SourceTable.LotNo,
							SourceTable.MaterialCode,
							SourceTable.PackQty,
							SourceTable.ProductionSize,
							SourceTable.INPUTFROM,
							SourceTable.TYPEEXPORT,
							SourceTable.TRANSPORT,
							SourceTable.CUSTOMERNAME,
							SourceTable.LOCATIONS,
							SourceTable.CreateDateChange,
							SourceTable.USERIDChange
					);
-- Process Update Table
	 MERGE STB_VN_FINISHGOODS_BG AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.SoPhieuNhapKho,
							XMLData.SoPhieuXuatKho,
							XMLData.SoInVoice,
							XMLData.SoToKhaiHaiQuan,
							XMLData.PublicCode,
							XMLData.Country,
							XMLData.PartNo,
							XMLData.IDCODE,
							XMLData.Descrption,
							XMLData.MaterialName,
							XMLData.PackingID,
							XMLData.StatusSystem,
							XMLData.Statusout,
							XMLData.LotNo,
							XMLData.MaterialCode,
							XMLData.PackQty,
							XMLData.ProductionSize,
							XMLData.INPUTFROM,
							XMLData.TYPEEXPORT,
							XMLData.TRANSPORT,
							XMLData.CUSTOMERNAME,
							XMLData.LOCATIONS,
							 DATEADD(HH, -2, GETDATE()) AS CreateDate,
							@pProcessUserID AS USERID,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateChange,
							@pProcessUserID AS USERIDChange
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										SoPhieuNhapKho NVARCHAR(50),
										SoPhieuXuatKho NVARCHAR(50),
										SoInVoice NVARCHAR(50),
										SoToKhaiHaiQuan NVARCHAR(50),
										PublicCode NVARCHAR(30),
										Country NVARCHAR(50),
										PartNo NVARCHAR(50),
										IDCODE  NVARCHAR(50),
										Descrption NVARCHAR(500),
										MaterialName nvarchar(100),
										PackingID NVARCHAR(50),
										StatusSystem NVARCHAR(50),
										Statusout NVARCHAR(50),
										LotNo NVARCHAR(50),
										MaterialCode NVARCHAR(50),
										PackQty INT,
										ProductionSize NVARCHAR(50),
										INPUTFROM NVARCHAR(50),
										TYPEEXPORT NVARCHAR(50),
										TRANSPORT NVARCHAR(50),
										CUSTOMERNAME NVARCHAR(50),
										LOCATIONS NVARCHAR(50),
										CreateDate  DATETIMEOFFSET,
										USERID NVARCHAR(20),
										CreateDateChange  DATETIMEOFFSET,
										USERIDChange NVARCHAR(20)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)
	WHEN MATCHED THEN
				UPDATE SET
					SoPhieuNhapKho = SourceTable.SoPhieuNhapKho,
					SoPhieuXuatKho = SourceTable.SoPhieuXuatKho,
					SoInVoice = SourceTable.SoInVoice,
					SoToKhaiHaiQuan = SourceTable.SoToKhaiHaiQuan,
					PublicCode = SourceTable.PublicCode,
					Country = SourceTable.Country,
					PartNo = SourceTable.PartNo,
					IDCODE =  SourceTable.IDCODE,
					Descrption = SourceTable.Descrption,
					MaterialName = SourceTable.MaterialName,
					PackingID = SourceTable.PackingID,
					StatusSystem = SourceTable.StatusSystem,
					Statusout = SourceTable.Statusout,
					LotNo = SourceTable.LotNo,
					MaterialCode = SourceTable.MaterialCode,
					PackQty = SourceTable.PackQty,
					ProductionSize = SourceTable.ProductionSize,
					INPUTFROM = SourceTable.INPUTFROM,
					TYPEEXPORT = SourceTable.TYPEEXPORT,
					TRANSPORT = SourceTable.TRANSPORT,
					CUSTOMERNAME = SourceTable.CUSTOMERNAME,
					LOCATIONS = SourceTable.LOCATIONS,
					CreateDateChange = SourceTable.CreateDateChange,
					USERIDChange = SourceTable.USERIDChange
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						SoPhieuNhapKho,
				        SoPhieuXuatKho,
						SoInVoice,
						SoToKhaiHaiQuan,
						PublicCode,
						Country,
						PartNo,
						IDCODE,
						Descrption,
						MaterialName,
						PackingID,
						StatusSystem,
						Statusout,
						LotNo,
						MaterialCode,
						PackQty,
						ProductionSize,
						 INPUTFROM,
						TYPEEXPORT,
						TRANSPORT,
						CUSTOMERNAME, 
						LOCATIONS,
						CreateDate,
						USERID
					)
				VALUES
					(
							SourceTable.SoPhieuNhapKho,
				            SourceTable.SoPhieuXuatKho,
							SourceTable.SoInVoice,
							SourceTable.SoToKhaiHaiQuan,
							SourceTable.PublicCode,
							SourceTable.Country,
						    SourceTable.PartNo,
							SourceTable.IDCODE,
							SourceTable.Descrption,
							SourceTable.MaterialName,
							SourceTable.PackingID,
							SourceTable.StatusSystem,
							SourceTable.Statusout,
							SourceTable.LotNo,
							SourceTable.MaterialCode,
							SourceTable.PackQty,
							SourceTable.ProductionSize,
							SourceTable.INPUTFROM,
							SourceTable.TYPEEXPORT,
							SourceTable.TRANSPORT,
							SourceTable.CUSTOMERNAME,
							SourceTable.LOCATIONS,
							SourceTable.CreateDate,
							SourceTable.USERID
					);

-- Process Delete Table
            MERGE STB_VN_FINISHGOODS_BG AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.SoPhieuNhapKho,
							XMLData.SoPhieuXuatKho,
							XMLData.SoInVoice,
							XMLData.SoToKhaiHaiQuan,
							XMLData.PublicCode,
							XMLData.Country,
							XMLData.PartNo,
							XMLData.IDCODE,
							XMLData.Descrption,
							XMLData.MaterialName,
							XMLData.PackingID,
							XMLData.StatusSystem,
							XMLData.Statusout,
							XMLData.LotNo,
							XMLData.MaterialCode,
							XMLData.PackQty,
							XMLData.ProductionSize,
							XMLData.INPUTFROM,
							XMLData.TYPEEXPORT,
							XMLData.TRANSPORT,
							XMLData.CUSTOMERNAME,
							XMLData.LOCATIONS,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										SoPhieuNhapKho NVARCHAR(50),
										SoPhieuXuatKho NVARCHAR(50),
										SoInVoice NVARCHAR(50),
										SoToKhaiHaiQuan NVARCHAR(50),
										PublicCode VARCHAR(30),
										Country NVARCHAR(50),
										PartNo NVARCHAR(50),
										IDCODE NVARCHAR(50),
										Descrption NVARCHAR(500),
										MaterialName nvarchar(100),
										PackingID NVARCHAR(50),
										StatusSystem NVARCHAR(50),
										Statusout NVARCHAR(50),
										LotNo NVARCHAR(50),
										MaterialCode NVARCHAR(50),
										PackQty INT,
										ProductionSize NVARCHAR(50),
										INPUTFROM NVARCHAR(50),
										TYPEEXPORT NVARCHAR(50),
										TRANSPORT NVARCHAR(50),
										CUSTOMERNAME NVARCHAR(50),
										LOCATIONS NVARCHAR(50),
										CreateDate  DATETIMEOFFSET,
										USERID VARCHAR(20),
										CreateDateChange  DATETIMEOFFSET,
										USERIDChange VARCHAR(20)
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.ID = SourceTable.ID
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
									XMLData.OldCompanyCode,
									XMLData.ID,
									XMLData.SoPhieuNhapKho,
									XMLData.SoPhieuXuatKho,
									XMLData.SoInVoice,
									XMLData.SoToKhaiHaiQuan,
									XMLData.PublicCode,
									XMLData.Country,
								    XMLData.PartNo,
									XMLData.IDCODE,
									XMLData.Descrption,
									XMLData.MaterialName,
									XMLData.PackingID,
									XMLData.StatusSystem,
									XMLData.Statusout,
									XMLData.LotNo,
									XMLData.MaterialCode,
									XMLData.PackQty,
									XMLData.ProductionSize,
								    XMLData.INPUTFROM,
									XMLData.TYPEEXPORT,
									XMLData.TRANSPORT,
									XMLData.CUSTOMERNAME,
									XMLData.LOCATIONS,
									XMLData.CreateDate,
									XMLData.USERID,
									XMLData.CreateDateChange,
									XMLData.USERIDChange
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 SoPhieuNhapKho NVARCHAR(50),
											 SoPhieuXuatKho NVARCHAR(50),
											 SoInVoice NVARCHAR(50),
											 SoToKhaiHaiQuan NVARCHAR(50),
											 PublicCode VARCHAR(50),
											 Country NVARCHAR(50),
											 PartNo NVARCHAR(50),
											 IDCODE  NVARCHAR(50),
											 Descrption NVARCHAR(500), 
											 MaterialName nvarchar(100),
											 PackingID NVARCHAR(50),
											 StatusSystem NVARCHAR(50),
											 Statusout NVARCHAR(50),
											 LotNo NVARCHAR(50),
											 MaterialCode NVARCHAR(50),
											 PackQty INT,
											 ProductionSize NVARCHAR(50),
											  INPUTFROM NVARCHAR(50),
											  TYPEEXPORT NVARCHAR(50),
											  TRANSPORT NVARCHAR(50),
											  CUSTOMERNAME NVARCHAR(50),
											  LOCATIONS NVARCHAR(50),
											 CreateDate  DATETIMEOFFSET,
											 USERID VARCHAR(20),
											 CreateDateChange  DATETIMEOFFSET,
											 USERIDChange VARCHAR(20)
											
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.SoPhieuNhapKho,
									XMLData.SoPhieuXuatKho,
									XMLData.SoInVoice,
									XMLData.SoToKhaiHaiQuan,
									XMLData.PublicCode,
									XMLData.Country,
									XMLData.PartNo,
									XMLData.IDCODE,
									XMLData.Descrption,
									XMLData.MaterialName,
									XMLData.PackingID,
									XMLData.StatusSystem,
									XMLData.Statusout,
									XMLData.LotNo,
									XMLData.MaterialCode,
									XMLData.PackQty,
									XMLData.ProductionSize,
									XMLData.INPUTFROM,
									XMLData.TYPEEXPORT,
									XMLData.TRANSPORT,
									XMLData.CUSTOMERNAME,
									XMLData.LOCATIONS,
									XMLData.CreateDate,
									XMLData.USERID,
									XMLData.CreateDateChange,
									XMLData.USERIDChange
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 SoPhieuNhapKho NVARCHAR(50),
											 SoPhieuXuatKho NVARCHAR(50),
											 SoInVoice NVARCHAR(50),
											 SoToKhaiHaiQuan NVARCHAR(50),
											 PublicCode VARCHAR(50),
											 Country VARCHAR(50),
											 PartNo NVARCHAR(50),
											 IDCODE  NVARCHAR(50),
											 Descrption NVARCHAR(500), 
											 MaterialName nvarchar(100),
											 PackingID NVARCHAR(50),
											 StatusSystem NVARCHAR(50),
											 Statusout NVARCHAR(50),
											 LotNo NVARCHAR(50),
											 MaterialCode NVARCHAR(50),
											 PackQty INT,
											 ProductionSize NVARCHAR(50),
											 INPUTFROM NVARCHAR(50),
											 TYPEEXPORT NVARCHAR(50),
											 TRANSPORT NVARCHAR(50),
											 CUSTOMERNAME NVARCHAR(50),
											 LOCATIONS  NVARCHAR(50),
											 CreateDate  DATETIMEOFFSET,
											 USERID VARCHAR(20),
											 CreateDateChange  DATETIMEOFFSET,
											 USERIDChange VARCHAR(20)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.SoPhieuNhapKho,
									XMLData.SoPhieuXuatKho,
									XMLData.SoInVoice,
									XMLData.SoToKhaiHaiQuan,
									XMLData.PublicCode,
									XMLData.Country,
									XMLData.PartNo,
									XMLData.IDCODE,
									XMLData.Descrption,
									XMLData.MaterialName,
									XMLData.PackingID,
									XMLData.StatusSystem,
									XMLData.Statusout,
									XMLData.LotNo,
									XMLData.MaterialCode,
									XMLData.PackQty,
									XMLData.ProductionSize,
									XMLData.INPUTFROM,
									XMLData.TYPEEXPORT,
									XMLData.TRANSPORT,
									XMLData.CUSTOMERNAME,
									XMLData.LOCATIONS,
									XMLData.CreateDate,
									XMLData.USERID,
									XMLData.CreateDateChange,
									XMLData.USERIDChange
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 SoPhieuNhapKho NVARCHAR(50),
											 SoPhieuXuatKho NVARCHAR(50),
											 SoInVoice NVARCHAR(50),
											 SoToKhaiHaiQuan NVARCHAR(50),
											 PublicCode NVARCHAR(50),
											 Country NVARCHAR(50),
											 PartNo NVARCHAR(50),
											 IDCODE  NVARCHAR(50),
											 Descrption NVARCHAR(500), 
											 MaterialName nvarchar(100),
											 PackingID NVARCHAR(50),
											StatusSystem NVARCHAR(50),
											Statusout NVARCHAR(50),
											LotNo NVARCHAR(50),
											MaterialCode NVARCHAR(50),
											PackQty INT,
											ProductionSize NVARCHAR(50),
											 INPUTFROM NVARCHAR(50),
											 TYPEEXPORT NVARCHAR(50),
											 TRANSPORT NVARCHAR(50),
											 CUSTOMERNAME NVARCHAR(50),
											 LOCATIONS NVARCHAR(50),
											CreateDate  DATETIMEOFFSET,
											USERID VARCHAR(20),
											CreateDateChange  DATETIMEOFFSET,
											USERIDChange VARCHAR(20)
											) XMLData
					 OPEN SourceData

	   WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @SoPhieuNhapKho,
				                 @SoPhieuXuatKho,
								 @SoInVoice,
								 @SoToKhaiHaiQuan,
								 @PublicCode,
								 @Country,
								 @PartNo,
								 @IDCODE,
								 @Descrption,
								 @MaterialName,
								 @PackingID,
								 @StatusSystem,
								 @Statusout,
								 @LotNo,
								 @MaterialCode,
								 @PackQty,
								 @ProductionSize,
								 @INPUTFROM,
								 @TYPEEXPORT,
								 @TRANSPORT,
								 @CUSTOMERNAME,
								 @LOCATIONS,
								 @CreateDate,
								 @USERID,
								 @CreateDateChange,
								 @USERIDChange
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
		
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS', @OldCompanyCode OUTPUT


						INSERT INTO STB_VN_FINISHGOODS_BG
						(
							SoPhieuNhapKho,
				            SoPhieuXuatKho,
							SoInVoice,
							SoToKhaiHaiQuan,
						    PublicCode,
						    Country,
							PartNo,
							IDCODE,
							Descrption,
							MaterialName,
							PackingID,
							StatusSystem,
							Statusout,
							LotNo,
							MaterialCode,
							PackQty,
							ProductionSize,
							 INPUTFROM,
							 TYPEEXPORT,
							 TRANSPORT,
							 CUSTOMERNAME,
							 LOCATIONS,
						    CreateDate,
						    USERID,
						    CreateDateChange,
						    USERIDChange
							
						)
						VALUES
						(
							@SoPhieuNhapKho,
				            @SoPhieuXuatKho,
							@SoInVoice,
							@SoToKhaiHaiQuan,
						    @PublicCode,
						    @Country,
							@PartNo,
							@IDCODE,
							@Descrption,
							@MaterialName,
							@PackingID,
							@StatusSystem,
							@Statusout,
							@LotNo,
							@MaterialCode,
							@PackQty,
							@ProductionSize,
							 @INPUTFROM,
							 @TYPEEXPORT,
							 @TRANSPORT,
							 @CUSTOMERNAME ,
							 @LOCATIONS,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @CreateDateChange,
						    @USERIDChange
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
UPDATE STB_VN_FINISHGOODS_BG
						SET

						SoPhieuNhapKho =   CASE
						                WHEN @SoPhieuNhapKho IS NOT NULL THEN @SoPhieuNhapKho
						                ELSE SoPhieuNhapKho
										  END,

						SoPhieuXuatKho =   CASE
						                WHEN @SoPhieuXuatKho IS NOT NULL THEN @SoPhieuXuatKho
						                ELSE SoPhieuXuatKho
										  END,

						SoInVoice =   CASE
						                WHEN @SoInVoice IS NOT NULL THEN @SoInVoice
						                ELSE SoInVoice
										  END,

							SoToKhaiHaiQuan =   CASE
						                WHEN @SoToKhaiHaiQuan IS NOT NULL THEN @SoToKhaiHaiQuan
						                ELSE SoToKhaiHaiQuan
										  END,

							PublicCode =   CASE
						                WHEN @PublicCode IS NOT NULL THEN @PublicCode
						                ELSE PublicCode
						            END,
						Country =   CASE
						                WHEN @Country IS NOT NULL THEN @Country
						                ELSE Country
						            END,
			PartNo =   CASE
						                WHEN @PartNo IS NOT NULL THEN @PartNo
						                ELSE PartNo
						            END,
						
			IDCODE =   CASE
						                WHEN @IDCODE IS NOT NULL THEN @IDCODE
						                ELSE IDCODE
						            END,

			Descrption =   CASE
						                WHEN @Descrption IS NOT NULL THEN @Descrption
						                ELSE Descrption
						            END,

								MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,

					PackingID =   CASE
						                WHEN @PackingID IS NOT NULL THEN @PackingID
						                ELSE PackingID
						            END,

				
					StatusSystem =   CASE
						                WHEN @StatusSystem IS NOT NULL THEN @StatusSystem
						                ELSE StatusSystem
						            END,
					
						Statusout =   CASE
						                WHEN @Statusout IS NOT NULL THEN @Statusout
						                ELSE Statusout
						            END,

					
						LotNo =   CASE
						                WHEN @LotNo IS NOT NULL THEN @LotNo
						                ELSE LotNo
						            END,

					
						MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
									

							PackQty =   CASE
						                WHEN @PackQty IS NOT NULL THEN @PackQty
						                ELSE PackQty
						            END,

						
							ProductionSize =   CASE
						                WHEN @ProductionSize IS NOT NULL THEN @ProductionSize
						                ELSE ProductionSize
						            END,


									INPUTFROM =   CASE
						                WHEN @INPUTFROM IS NOT NULL THEN @INPUTFROM
						                ELSE INPUTFROM
						            END,


										TYPEEXPORT =   CASE
						                WHEN @TYPEEXPORT IS NOT NULL THEN @TYPEEXPORT
						                ELSE TYPEEXPORT
						            END,

									
										TRANSPORT =   CASE
						                WHEN @TRANSPORT IS NOT NULL THEN @TRANSPORT
						                ELSE TRANSPORT
						            END,
									
										CUSTOMERNAME =   CASE
						                WHEN @CUSTOMERNAME IS NOT NULL THEN @CUSTOMERNAME
						                ELSE CUSTOMERNAME
						            END,

									LOCATIONS =   CASE
						                WHEN @LOCATIONS IS NOT NULL THEN @LOCATIONS
						                ELSE LOCATIONS
						            END,

						    CreateDateChange = DATEADD(HH, -2, GETDATE()),
						    USERIDChange = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_FINISHGOODS_BG
						WHERE
						    ID = ''
                    END
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

