CREATE PROC [dbo].[usp_InsertInto_VN_DIVIDEMATERIALSMAL]         --- exec usp_InsertInto_VN_DIVIDEMATERIALSMAL'','','',''
@pProcessLanguage VARCHAR(20),
@pProcessUserID VARCHAR(20),
@pDIVIDESTOCKQTY NUMERIC(20,5),
@pLOTID VARCHAR(20)
AS
BEGIN
		SET NOCOUNT ON;

	DECLARE @WorkCenterCode NVARCHAR(20)='';
	SELECT @WorkCenterCode = WorkCenterCode 
	FROM STB_UserInfo
	WHERE UserID=@pProcessUserID


	--select * from STB_UserInfo


		 DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				 @ProcessUserID VARCHAR(20) = @pProcessUserID,
				 @LOTID NVARCHAR(50) = @pLOTID,
				 @DIVIDESTOCKQTY NUMERIC(20,5) = @pDIVIDESTOCKQTY

		 DECLARE @QTY NUMERIC(20,5),@IUE BIT, @LOTIDS NVARCHAR(50)

				 SELECT 
						--@QTY = T1.StockQty / @DIVIDESTOCKQTY,

						@QTY =	  CASE 
						WHEN CAST(ROUND(CAST(T1.StockQty AS FLOAT), 2) AS FLOAT) = CAST(ROUND(CAST(T1.StockQty AS FLOAT), 2) AS INT) /@DIVIDESTOCKQTY
						THEN CAST(ROUND(CAST(T1.StockQty AS FLOAT), 2) AS INT)/@DIVIDESTOCKQTY
						ELSE ROUND(CAST(T1.StockQty AS FLOAT), 2)/@DIVIDESTOCKQTY
						END  ,
						@LOTIDS = T1.LotID,
						@IUE = T1.Isused
				 FROM
						STB_MaterialDocLotInfo T1 WITH(NOLOCK)

				  WHERE 
						T1.LotID  = @LOTID AND T1.Isused IS NULL
-------------- add 08/10/2024
	DECLARE @Isd BIT
	DECLARE @IsSlpitLot BIT
	SELECT @Isd = Isused,@IsSlpitLot=IsSlpitLot
	FROM STB_MaterialDocLotInfo WITH(NOLOCK)
	WHERE LotID = @LotID

		IF @IsSlpitLot = 1
		BEGIN
				RAISERROR('LotID này đã được tách rồi không thể tách thêm nữa',16,1,@LotID)
				RETURN
		END


---------------------------------------------

    IF @LOTIDS IS NULL

		BEGIN
					RAISERROR('LotID chính rỗng không thể tạo được.',16,1)
					RETURN
		END

     IF @IUE = 1
		
		BEGIN
					RAISERROR('LotID này được được tạo rồi không thể tạo nữa.',16,1)
					RETURN
		END
		
DECLARE @Index INT = 1	
declare @MaterialDocDetailNo varchar (39)
EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT
--declare @test varchar (10) =@QTY
--raiserror (@test,16,1)
WHILE @Index <= @DIVIDESTOCKQTY

BEGIN

	 INSERT INTO STB_VN_DIVIDEMATERIALSMAL
	 (
			LOTID,
			DIVIDE_STOCKQTY,
			PACKINGIDSMALL,
			SEQNO,
			CREATEUSERID,
			CREATEDATETIME,
			WorkCenterCode,
			MaterialWarehouseCode
	 )
	 
	 SELECT

			@LOTIDS,
			@QTY,
			'ML'+@LOTIDS+CONVERT(NVARCHAR,@Index),
			@Index,
			@ProcessUserID,
			DATEADD(HH, -2, GETDATE()),
			@WorkCenterCode,
			REPLACE(MaterialLocationCode, '_01','')
	 FROM
			STB_MaterialDocLotInfo T1 WITH(NOLOCK)

	 WHERE

			T1.LotID =  @LOTID


-----------
INSERT INTO STB_MaterialDocLotInfo
	 (
			MaterialDocDetailNo,
			MDLISeqNo,
			LOTID,
			MaterialCode,
			MaterialStockAttribute,
			StockQty,
			IsChecked,
			MaterialLocationCode,
			MaterialDocNo,
			PackingID,
			Lotno,
			LotAttr10,
			CreateDateTime,
			CreateUserID
	 )
	 
	 SELECT
			@MaterialDocDetailNo,
			@Index,
			'ML'+@LOTIDS+CONVERT(NVARCHAR,@Index),
			MaterialCode,
			'NORMAL',
			@QTY,
			'1',
			MaterialLocationCode,
			MaterialDocNo,
			PackingID,
			Lotno,
			LotAttr10,
			getdate(),
			@ProcessUserID
			
	 FROM
			STB_MaterialDocLotInfo T1 WITH(NOLOCK)

	 WHERE

			T1.LotID =  @LOTID

--------------------
declare @MaterialLotNo varchar(20)
EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT


INSERT INTO STB_MaterialLotInfo
	 (
			MaterialLotNo,
			LotID,
			CompanyCode,
			WorkCenterCode,
			MaterialWarehouseCode,
			MaterialLocationCode,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			PackingID,
			GRDate,
			MaterialDeliveryNo,
			MaterialDeliveryDetailNo,
			InitialQty,
			CurrentQty,
			PickingQty,
			VendorLotNo,
			LifeBasicDate,
			ProductionDate,
			EndOfLifeDate,
			LotNo,
			IsSplitLot,
			BefMaterialLotNo,
			LotAttr01,
			LotAttr02,
			LotAttr03,
			LotAttr04,
			LotAttr05,
			LotAttr06,
			LotAttr07,
			LotAttr08,
			LotAttr09,
			LotAttr10,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID,
			DateConfirmEx,
			HoldError,
			Holddate,
			HoldPeriod
			)
	 
			SELECT
			@MaterialLotNo,
			'ML'+@LOTIDS+CONVERT(NVARCHAR,@Index),
			CompanyCode,
			WorkCenterCode,
			--'ROH_VN_WH',
			--'ROH_VN_WH',
			MaterialWarehouseCode,
			MaterialLocationCode,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			PackingID,
			GRDate,
			MaterialDeliveryNo,
			MaterialDeliveryDetailNo,
			@QTY,
			@QTY,
			PickingQty,
			VendorLotNo,
			LifeBasicDate,
			ProductionDate,
			EndOfLifeDate,
			LotNo,
			IsSplitLot,
			BefMaterialLotNo,
			LotAttr01,
			LotAttr02,
			LotAttr03,
			LotAttr04,
			LotAttr05,
			LotAttr06,
			LotAttr07,
			LotAttr08,
			LotAttr09,
			LotAttr10,
			getdate(),
			@ProcessUserID,
			'',
			'',
			DateConfirmEx,
			HoldError,
			Holddate,
			HoldPeriod
			
	 FROM
			STB_MaterialLotInfo  WITH(NOLOCK)

	 WHERE

			LotID =  @LOTID
--------------------
	SET @Index = @Index + 1
END

DECLARE @LOTIDEXITS NVARCHAR(50)

SELECT 
		@LOTIDEXITS = LOTID

FROM 
		STB_VN_DIVIDEMATERIALSMAL WITH(NOLOCK)

WHERE
		LOTID = @LOTIDS

IF @LOTIDEXITS IS NOT NULL

	BEGIN
			UPDATE STB_MaterialDocLotInfo

			SET
					Isused = 1,
					IsSlpitLot=1

			WHERE 
					LotID = @LOTIDS

			UPDATE STB_MaterialLotInfo

			SET
					CurrentQty=0

			WHERE 
					LotID = @LOTIDS
					
	END

END

--select * from STB_MaterialLotInfo where lotid like '%SP%'


-- ML20240217000257

 --SELECT distinct lotid  FROM  STB_VN_DIVIDEMATERIALSMAL

-- DELETE STB_VN_DIVIDEMATERIALSMAL

--ALTER TABLE STB_VN_DIVIDEMATERIALSMAL
--ADD
--	 WorkCenterCode NVARCHAR(50) NULL
-- select * from STB_MaterialDocLotInfo where LotID = 'VVWEC30-060NS2100002'

 -- select * from STB_MaterialDocLotInfo where Isused = 1

 -- update STB_MaterialDocLotInfo set Isused = null  where Isused = 1

 -- SELECT * FROM STB_VN_DIVIDEMATERIALSMAL


 --SELECT * FROM   STB_VN_DIVIDEMATERIALSMAL WHERE LotID = 'ECVT27-213KR1500008'


 --UPDATE STB_MaterialDocLotInfo SET Isused = NULL WHERE LotID = 'ML20240217000257'





