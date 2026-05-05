CREATE PROC [dbo].[usp_VN_DaiFuku_Temp] -- exec usp_VN_DaiFuku_Temp '','','','',''
@pFromdateinput DATE = NULL,
@pTodateinput DATE = NULL,
@pTypeInput NVARCHAR(50) = NULL,
@pFromdateExp DATE = NULL,
@pTodateExp DATE = NULL
AS
BEGIN

		DECLARE @FromDate DATE = @pFromdateinput
		DECLARE @ToDate DATE = @pTodateinput
		DECLARE @FromDateExp DATE = @pFromdateExp
		DECLARE @ToDateExp DATE = @pTodateExp
		DECLARE @Input NVARCHAR(50) = @pTypeInput

IF OBJECT_ID(N'tempdb..#STB_VN_DaiFuku_Temp') IS NOT NULL
BEGIN
	DROP TABLE #STB_VN_DaiFuku_Temp
END

CREATE TABLE #STB_VN_DaiFuku_Temp
(
	WorkDate_Receipt DATETIME NULL,
	Item_CD_Receipt NVARCHAR(50) NULL,
	Item_Nm_Receipt NVARCHAR(50) NULL,
	PackingID_Receipt NVARCHAR(50) NULL,
	EnterQty_Receipt INT NULL,
	EnterStatus_Receipt BIT NULL,
	WorkDate_Delivery DATETIME NULL,
	Item_Cd_Delivery NVARCHAR(50) NULL,
	Item_Nm_Delivery NVARCHAR(50) NULL,
	PackingID_Delivery NVARCHAR(50) NULL,
	ShipQty_Delivery INT NULL,
	ShipStatus_Delivery BIT NULL
)

IF OBJECT_ID(N'tempdb..#T1_Delivery') IS NOT NULL
BEGIN
	DROP TABLE #T1_Delivery
END
IF OBJECT_ID(N'tempdb..#T1_Delivery1') IS NOT NULL
BEGIN
	DROP TABLE #T1_Delivery1
END

IF OBJECT_ID(N'tempdb..#T1_Delivery2') IS NOT NULL
BEGIN
	DROP TABLE #T1_Delivery2
END

IF @Input = N'Nhập'
BEGIN
INSERT INTO #STB_VN_DaiFuku_Temp
SELECT  RR.CRT_DT AS WorkDate_Receipt		
			    , RR.ITM_CD  AS Item_Cd_Receipt
			    , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Receipt
			    , RR.PACK_ID  AS PackingID_Receipt
			    , RR.ITM_QTY  AS EnterQty_Receipt
			    , CONVERT(BIT, 1) AS EnterStatus_Receipt
				,'' AS WorkDate_Delivery
				,'' AS Item_Cd_Delivery
				,'' AS Item_Nm_Delivery
				,'' AS PackingID_Delivery
				,'' AS ShipQty_Delivery
				,'' AS ShipStatus_Delivery
				
		FROM SmartFactoryIncubator.dbo.RCV_RSLT RR    
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.RCV_ASN RA ON RR.PACK_ID = RA.PACK_ID     
		SELECT  RR.CRT_DT AS WorkDate_Delivery
			  , RR.ITM_CD  AS Item_Cd_Delivery
			  , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Delivery
			  , RR.PACK_ID   AS PackingID_Delivery
			  , RR.ITM_QTY  AS ShipQty_Delivery			  			  
			  , CONVERT(BIT, 1) AS ShipStatus_Delivery
			INTO  #T1_Delivery
		FROM SmartFactoryIncubator.dbo.OUT_RSLT RR   
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.OUT_ASN RA ON RR.PACK_ID = RA.PACK_ID  
		UPDATE #STB_VN_DaiFuku_Temp 
				SET
				#STB_VN_DaiFuku_Temp.WorkDate_Delivery = #T1_Delivery.WorkDate_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Cd_Delivery = #T1_Delivery.Item_Cd_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Nm_Delivery = #T1_Delivery.Item_Nm_Delivery,
				#STB_VN_DaiFuku_Temp.PackingID_Delivery = #T1_Delivery.PackingID_Delivery,
				#STB_VN_DaiFuku_Temp.ShipQty_Delivery = #T1_Delivery.ShipQty_Delivery,
				#STB_VN_DaiFuku_Temp.ShipStatus_Delivery = #T1_Delivery.ShipStatus_Delivery

		 FROM #STB_VN_DaiFuku_Temp
		 INNER JOIN #T1_Delivery
		 ON #STB_VN_DaiFuku_Temp.PackingID_Receipt = #T1_Delivery.PackingID_Delivery

		SELECT   
		DISTINCT
		WorkDate_Receipt,
		Item_CD_Receipt,
		Item_Nm_Receipt,
		PackingID_Receipt,
		EnterQty_Receipt,
		WorkDate_Delivery,
		Item_Cd_Delivery,
		Item_Nm_Delivery,
		PackingID_Delivery,
		ShipQty_Delivery,
		
		CASE 
			WHEN EnterStatus_Receipt = 1 THEN N'Nhập'
			ELSE ''
		END AS IMPORT

		FROM 
				#STB_VN_DaiFuku_Temp	
		WHERE
		(
							((@FromDate IS NULL) OR CONVERT(DATE,WorkDate_Receipt) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(DATE,WorkDate_Receipt) <= @ToDate)
		)
				
END
ELSE IF  @Input = N'Xuất'
BEGIN
INSERT INTO #STB_VN_DaiFuku_Temp
SELECT  RR.CRT_DT AS WorkDate_Receipt		
			    , RR.ITM_CD  AS Item_Cd_Receipt
			    , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Receipt
			    , RR.PACK_ID  AS PackingID_Receipt
			    , RR.ITM_QTY  AS EnterQty_Receipt
			    , CONVERT(BIT, 1) AS EnterStatus_Receipt
				,'' AS WorkDate_Delivery
				,'' AS Item_Cd_Delivery
				,'' AS Item_Nm_Delivery
				,'' AS PackingID_Delivery
				,'' AS ShipQty_Delivery
				,'' AS ShipStatus_Delivery
				
		FROM SmartFactoryIncubator.dbo.RCV_RSLT RR    
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.RCV_ASN RA ON RR.PACK_ID = RA.PACK_ID     
	
	
	SELECT  RR.CRT_DT AS WorkDate_Delivery
			  , RR.ITM_CD  AS Item_Cd_Delivery
			  , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Delivery
			  , RR.PACK_ID   AS PackingID_Delivery
			  , RR.ITM_QTY  AS ShipQty_Delivery			  			  
			  , CONVERT(BIT, 1) AS ShipStatus_Delivery
			INTO  #T1_Delivery1
		FROM SmartFactoryIncubator.dbo.OUT_RSLT RR   
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.OUT_ASN RA ON RR.PACK_ID = RA.PACK_ID  

		--MERGE 
		UPDATE #STB_VN_DaiFuku_Temp 
				SET
				#STB_VN_DaiFuku_Temp.WorkDate_Delivery = #T1_Delivery1.WorkDate_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Cd_Delivery = #T1_Delivery1.Item_Cd_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Nm_Delivery = #T1_Delivery1.Item_Nm_Delivery,
				#STB_VN_DaiFuku_Temp.PackingID_Delivery = #T1_Delivery1.PackingID_Delivery,
				#STB_VN_DaiFuku_Temp.ShipQty_Delivery = #T1_Delivery1.ShipQty_Delivery,
				#STB_VN_DaiFuku_Temp.ShipStatus_Delivery = #T1_Delivery1.ShipStatus_Delivery

		 FROM #STB_VN_DaiFuku_Temp
		 INNER JOIN #T1_Delivery1
		 ON #STB_VN_DaiFuku_Temp.PackingID_Receipt = #T1_Delivery1.PackingID_Delivery

		SELECT 
		DISTINCT
		WorkDate_Receipt,
		Item_CD_Receipt,
		Item_Nm_Receipt,
		PackingID_Receipt,
		EnterQty_Receipt,
		WorkDate_Delivery,
		Item_Cd_Delivery,
		Item_Nm_Delivery,
		PackingID_Delivery,
		ShipQty_Delivery,
		
		CASE
			WHEN ShipStatus_Delivery = 0  THEN N'Chưa xuất'
			WHEN ShipStatus_Delivery = 1 THEN N'Đã xuất'
		ELSE ''
		END AS EXPORTS

		FROM 
				#STB_VN_DaiFuku_Temp

				WHERE 1 = 1
					AND
					(
							((@FromDateExp IS NULL) OR CONVERT(DATE,WorkDate_Delivery) >= @FromDateExp)
						AND
							((@ToDateExp IS NULL) OR CONVERT(DATE,WorkDate_Delivery) <= @ToDateExp)
					)
END
ELSE
BEGIN
INSERT INTO #STB_VN_DaiFuku_Temp
SELECT  RR.CRT_DT AS WorkDate_Receipt		
			    , RR.ITM_CD  AS Item_Cd_Receipt
			    , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Receipt
			    , RR.PACK_ID  AS PackingID_Receipt
			    , RR.ITM_QTY  AS EnterQty_Receipt
			    , CONVERT(BIT, 1) AS EnterStatus_Receipt
				,'' AS WorkDate_Delivery
				,'' AS Item_Cd_Delivery
				,'' AS Item_Nm_Delivery
				,'' AS PackingID_Delivery
				,'' AS ShipQty_Delivery
				,'' AS ShipStatus_Delivery
				
		FROM SmartFactoryIncubator.dbo.RCV_RSLT RR    
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.RCV_ASN RA ON RR.PACK_ID = RA.PACK_ID     
		SELECT  RR.CRT_DT AS WorkDate_Delivery
			  , RR.ITM_CD  AS Item_Cd_Delivery
			  , (SELECT SM.MaterialName FROM SmartFactoryV2.dbo.STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm_Delivery
			  , RR.PACK_ID   AS PackingID_Delivery
			  , RR.ITM_QTY  AS ShipQty_Delivery			  			  
			  , CONVERT(BIT, 1) AS ShipStatus_Delivery
			INTO  #T1_Delivery2
		FROM SmartFactoryIncubator.dbo.OUT_RSLT RR   
				 LEFT OUTER JOIN SmartFactoryIncubator.dbo.OUT_ASN RA ON RR.PACK_ID = RA.PACK_ID  
		UPDATE #STB_VN_DaiFuku_Temp 
				SET
				#STB_VN_DaiFuku_Temp.WorkDate_Delivery = #T1_Delivery2.WorkDate_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Cd_Delivery = #T1_Delivery2.Item_Cd_Delivery,
				#STB_VN_DaiFuku_Temp.Item_Nm_Delivery = #T1_Delivery2.Item_Nm_Delivery,
				#STB_VN_DaiFuku_Temp.PackingID_Delivery = #T1_Delivery2.PackingID_Delivery,
				#STB_VN_DaiFuku_Temp.ShipQty_Delivery = #T1_Delivery2.ShipQty_Delivery,
				#STB_VN_DaiFuku_Temp.ShipStatus_Delivery = #T1_Delivery2.ShipStatus_Delivery

		 FROM #STB_VN_DaiFuku_Temp
		 INNER JOIN #T1_Delivery2
		 ON #STB_VN_DaiFuku_Temp.PackingID_Receipt = #T1_Delivery2.PackingID_Delivery
		SELECT   
		DISTINCT
		WorkDate_Receipt,
		Item_CD_Receipt,
		Item_Nm_Receipt,
		PackingID_Receipt,
		EnterQty_Receipt,
		WorkDate_Delivery,
		Item_Cd_Delivery,
		Item_Nm_Delivery,
		PackingID_Delivery,
		ShipQty_Delivery,
		--Tm1.Lotno,
		CASE
			WHEN ShipStatus_Delivery = 0  THEN N'Chưa xuất'
			WHEN ShipStatus_Delivery = 1 THEN N'Đã xuất'
		ELSE ''
		END AS EXPORTS,

		CASE 
			WHEN EnterStatus_Receipt = 1 THEN N'Nhập'
			ELSE ''
		END AS IMPORT
		--INTO #Public
		FROM 
				#STB_VN_DaiFuku_Temp	
     --  LEFT JOIN STB_MaterialDocLotInfo Tm1
	    --ON Tm1.PackingID = #STB_VN_DaiFuku_Temp.PackingID_Receipt
	--SELECT
	--		*
	--FROM
	--	#Public
	--   LEFT JOIN STB_MaterialDocLotInfo Tm1
	--   ON Tm1.PackingID = #Public.PackingID_Receipt
END

  --DROP TABLE #T1_Delivery
  --DROP TABLE #T1_Delivery1
  --DROP TABLE #T1_Delivery2
  DROP TABLE #STB_VN_DaiFuku_Temp

END