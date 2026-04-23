CREATE PROC [dbo].[usp_VN_Add_ImportExcel_bg]
@LotNo NVARCHAR(50),
@PackQty INT,
@PartNo NVARCHAR(50),
@PublicCode NVARCHAR(50),
@IDCODE NVARCHAR(50),
@UserID NVARCHAR(50),
@SoPhieuNhapKho NVARCHAR(50),
@INPUTFROM NVARCHAR(50),
@LOCATIONS NVARCHAR(100),
@Level NVARCHAR(50)
AS
BEGIN

exec usp_VVT_checkHOLD_QC @pLotNo=@LotNo

						DECLARE @PackingID NVARCHAR(50)
						DECLARE @LotNos NVARCHAR(50)
						DECLARE @CreatePacked DATETIME
						DECLARE @MaterialCode NVARCHAR(50)
						DECLARE @MaterialName NVARCHAR(100)
						DECLARE @EmpNo NVARCHAR(50)
						--DECLARE @PartNo NVARCHAR(50)
						
						DECLARE @Year NVARCHAR(10)
						DECLARE @Moth  NVARCHAR(10)
						DECLARE @Days NVARCHAR(10)
						DECLARE @Text NVARCHAR(10)
						DECLARE @SPXK NVARCHAR(20)
						SET @Text = 'VNVINA'
						SET @Year= YEAR(GETDATE())
						SET @Moth = MONTH(GETDATE())
						SET @Days = DAY(GETDATE())
	    
		SET @SPXK = @Text + @Year + @Moth + @Days + 'I'
	
	CREATE TABLE #TBL
	(
						PackingID NVARCHAR(50) NULL,
						LotNos NVARCHAR(50) NULL,
						CreatePacked DATETIME NULL,
						MaterialCode NVARCHAR(50) NULL,
						MaterialName NVARCHAR(100) NULL,
						EmpNo NVARCHAR(50) NULL,
						PartNo NVARCHAR(50) NULL,
	)

	INSERT INTO #TBL (PackingID,LotNos,CreatePacked,MaterialCode,MaterialName,EmpNo)
	SELECT
			
			 PackingID,
			 SI.Barcode,
			 ProdFinishDateTime,
		     SI.MaterialCode,
	         MM.MaterialName,
		     SI.CreateUserID--,
		     --(RTRIM(LTRIM(SUBSTRING(MM.materialname, CHARINDEX(' ', MM.materialname), 12))) + CASE WHEN CHARINDEX('-L', MM.materialname) > 0 THEN '-L' ELSE '' END) AS PartNo
		
	  FROM STB_SetInfo SI

	          LEFT OUTER JOIN STB_MaterialMaster MM	   
			  ON SI.MaterialCode = MM.MaterialCode
			  LEFT OUTER JOIN STB_MaterialLotInfo MLI 
			  ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			  LEFT OUTER JOIN STB_PackingLabelSpec SP 
			  ON MLI.LotID = SP.LotID

	 WHERE 1=1

	   AND  (SI.Barcode = @LotNo OR SI.Barcode = (SELECT NewBarcode  FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo )) 

	 
				SELECT  
						 --TOP(1)			
						@PackingID = PackingID,
						@LotNos = LotNos,
						@CreatePacked = CreatePacked,
						@MaterialCode = MaterialCode,
						@MaterialName = MaterialName,
						@EmpNo = EmpNo
						--@PartNo = Partno

				FROM
						#TBL
			

								IF (@LotNos IS NOT NULL ) -- request in Mr.Luon  @LotNo IN ('VJPN073R018618','VJPN073R018620','VJPN073R018602','VJPN073R018615','VJPN073R018601','VJPN073R018605','VVPM263R036717') -- Mr.Trieu comment Code

									BEGIN
											INSERT INTO STB_VN_FINISHGOODS_BG
											(
												PackingID,
												LotNo,
												MaterialCode,
												MaterialName,
												PackQty,
												EmpNo,
												CreatDatePacked,
												TypeProduction,
												StatusSystem,
												ProductionSize,
												CreateDate,
												USERID,
												MethodActions,
												PartNo,
												PublicCode,
												IDCODE,
												SoPhieuNhapKho,
												INPUTFROM,
												LOCATIONS,
												Levels
											)
											VALUES
											(
												@PackingID,
												@LotNo,
												@MaterialCode,
												@MaterialName,
												@PackQty,
												@EmpNo,
												@CreatePacked,
												N'Hàng cell',
												N'Nhập',
												SUBSTRING(@MaterialName,19,14),
												DATEADD(HH, -2, GETDATE()),
												@UserID,
												N'Nhập bằng Excel',
												@PartNo,
												@PublicCode,
												@IDCODE,
												@SoPhieuNhapKho,
												@INPUTFROM,
												@LOCATIONS,
												@Level
											)
										--- Import excel for Audit QC
										/*
										INSERT INTO STB_VN_FINISHGOODS_forQCAudit
											(
												PackingID,
												LotNo,
												MaterialCode,
												MaterialName,
												PackQty,
												EmpNo,
												CreatDatePacked,
												TypeProduction,
												StatusSystem,
												ProductionSize,
												CreateDate,
												USERID,
												MethodActions,
												PartNo,
												PublicCode,
												IDCODE,
												SoPhieuNhapKho,
												INPUTFROM,
												LOCATIONS,
												Levels,
												FGLocation
											)
											VALUES
											(
												@PackingID,
												@LotNo,
												@MaterialCode,
												@MaterialName,
												@PackQty,
												@EmpNo,
												@CreatePacked,
												N'Hàng cell',
												N'Nhập',
												SUBSTRING(@MaterialName,19,14),
												DATEADD(HH, -2, GETDATE()),
												@UserID,
												N'Nhập bằng Excel',
												@PartNo,
												@PublicCode,
												@IDCODE,
												@SoPhieuNhapKho,
												@INPUTFROM,
												@LOCATIONS,
												@Level,
												N'Bắc Giang'
											)
											*/
									END

						--ELSE IF (@LotNos IS NULL)

						--		BEGIN
						--				DECLARE @BarcodeS NVARCHAR(50)
						--				DECLARE @MaterialNameS NVARCHAR(50)
						--				DECLARE @MaterialCodeS NVARCHAR(50)
						--				DECLARE @PackedCreate DATETIME
						--				DECLARE @CreateUserID NVARCHAR(50)
						--				DECLARE @IDPack NVARCHAR(50)

						--				SELECT
												
						--						@BarcodeS = LOTNO,
						--						@MaterialNameS = MARTERIALNAME,
						--						@MaterialCodeS = MATERIALCODE,
						--						@PackedCreate = CreateDateTime,
						--						@CreateUserID = CreateUserID,
						--						@IDPack = PackingID
						--				FROM
						--						STB_VN_MASTERMODULES WITH(NOLOCK)
						--				WHERE 
						--						LOTNO = @LotNo AND ISUSED = 1


						--			INSERT INTO STB_VN_FINISHGOODS
						--					(
												
						--						PackingID,
						--						LotNo,
						--						MaterialCode,
						--						MaterialName,
						--						PackQty,
						--						EmpNo,
						--						CreatDatePacked,
						--						TypeProduction,
						--						StatusSystem,
						--						ProductionSize,
						--						CreateDate,
						--						USERID,
						--						MethodActions,
						--						PartNo,
						--						PublicCode,
						--						IDCODE,
						--						SoPhieuNhapKho,
						--						INPUTFROM,
						--						LOCATIONS,
						--						Levels
						--					)
						--					VALUES
						--					(
						--						@IDPack,
						--						@LotNo,
						--						@MaterialCodeS,
						--						@MaterialNameS,
						--						@PackQty,
						--						@CreateUserID,
						--						@PackedCreate,
						--						N'Hàng module',
						--						N'Nhập',
						--						DATEADD(HH, -2, GETDATE()),
						--						@UserID,
						--						@IDPack,
						--						N'Nhập bằng Excel',
						--						@PartNo,
						--						@PublicCode,
						--						@IDCODE,
						--						@SoPhieuNhapKho,
						--						@INPUTFROM,
						--						@LOCATIONS,
						--						@Level
						--					)
						--	END

				--ELSE

				--	BEGIN
								
				--					INSERT INTO STB_VN_FINISHGOODS
				--							(
												
				--								LotNo,
				--								PackQty,
				--								PartNo,
				--								PublicCode,
				--								IDCODE,
				--								USERID,
				--								SoPhieuNhapKho,
				--								INPUTFROM,
				--								LOCATIONS,
				--								Levels,
				--								CreateDate,
				--								MethodActions
				--							)
				--							VALUES
				--							(
				--								@LotNo,
				--								@PackQty,
				--								@PartNo,
				--								@PublicCode,
				--								@IDCODE,
				--								@UserID,
				--								@SPXK,
				--								@INPUTFROM,
				--								@LOCATIONS,
				--								@Level,
				--								DATEADD(HH, -2, GETDATE()),
				--							    N'Nhập bằng Excel'
				--							)
				--	END


				DROP TABLE #TBL
						
END

--alter table STB_VN_FINISHGOODS
--add
--		INPUTFROM NVARCHAR(50) NULL,
--		LOCATION NVARCHAR(100) NULL

-- select * from STB_VN_FINISHGOODS where userid ='nguyennha'

--delete STB_VN_FINISHGOODS where userid ='nguyennha'

--alter table STB_VN_FINISHGOODS
--ADD
-- LOCATIONS NVARCHAR(50)