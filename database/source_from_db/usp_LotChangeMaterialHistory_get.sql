-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-16
-- Browsable : true
-- Group : 생산관리
-- Description:	기종변경 이력을 조회합니다.
-- Modified:
-- ============================================= exec [usp_LotChangeMaterialHistory_get] '','','2025-05-12','2025-05-13'
CREATE PROCEDURE [dbo].[usp_LotChangeMaterialHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS

BEGIN
		DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
		DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

		--raiserror(@ToDate, 16, 1)
		--return

SELECT LCMH.JobDate
		  ,LCMH.ControlNo
		  ,isnull(LCMH.BefMaterialCode,MM.MaterialCode) as BefMaterialCode
		  ,isnull(MM1.MaterialName,MM.MaterialName) AS BefMaterialName
		  ,LCMH.BefPONo
		  ,LCMH.BefDayPlanNo
		  ,LCMH.OldBarcode
		  ,LCMH.AftMaterialCode
		  ,MM2.MaterialName AS AftMaterialName
		  ,LCMH.AftPONo
		  ,LCMH.AftDayPlanNo
		  ,LCMH.NewBarcode
		  ,CPLN.oldLotid as oldLotid
		  ,CPLN.NewLotid as ChangeLotid
		  ,isnull(LCMH.CreateDateTime,CPLN.CreateDateTime) as CreateDateTime
		  ,isnull(LCMH.CreateUserID,CPLN.CreateUserID) as CreateUserID
		  --,SI.Barcode
		  , '' as Barcode
		  ,MM2.MaterialName AS MaterialName
		  ,LI.LineName AS LineNameDPP
		  --,SI.ProdQty
		  ,'1' as ProdQty
		  ,'Report' AS CommandType 
	FROM STB_LotChangeMaterialHistory LCMH
	Full JOIN 
		STB_ChangePartNoAndLotNo CPLN 		ON CPLN.oldLotID = LCMH.OldBarcode -- and LCMH.CreateDatetime BETWEEN '2025-01-01' AND '2025-05-13'
		LEFT OUTER JOIN STB_MaterialMaster MM1
		ON MM1.MaterialCode = BefMaterialCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
		ON MM2.MaterialCode = AftMaterialCode
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON (LCMH.NewBarcode = SI.Barcode or CPLN.oldLotID = SI.Barcode 
		--OR SI.Barcode IN ('VVPR033R010791', 'VVPR033R010798')
		)
	  LEFT OUTER JOIN  STB_MaterialMaster MM  
	  on SI.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON SI.InputLineCode = LI.LineCode
	WHERE 
	
		(LCMH.JobDate BETWEEN @FromDate AND @ToDate)
		or
		(CPLN.CreateDateTime BETWEEN @FromDate AND @ToDate)
	
	/*
	 --Mr.Duy thay đổi cho màn hình B360
	 SELECT LCMH.JobDate
		  ,LCMH.ControlNo
		  ,isnull(LCMH.BefMaterialCode,MM.MaterialCode) as BefMaterialCode
		  ,isnull(MM1.MaterialName,MM.MaterialName) AS BefMaterialName
		  ,LCMH.BefPONo
		  ,LCMH.BefDayPlanNo
		  ,LCMH.OldBarcode
		  ,LCMH.AftMaterialCode
		  ,MM2.MaterialName AS AftMaterialName
		  ,LCMH.AftPONo
		  ,LCMH.AftDayPlanNo
		  ,LCMH.NewBarcode
		  ,CPLN.oldLotid as oldLotid
		  ,CPLN.NewLotid as ChangeLotid
		  ,isnull(LCMH.CreateDateTime,CPLN.CreateDateTime) as CreateDateTime
		  ,isnull(LCMH.CreateUserID,CPLN.CreateUserID) as CreateUserID
		  ,SI.Barcode
		  ,MM2.MaterialName AS MaterialName
		  ,LI.LineName AS LineNameDPP
		  ,SI.ProdQty
		  ,'Report' AS CommandType 
	FROM STB_LotChangeMaterialHistory LCMH
	 left OUTER JOIN 
		STB_ChangePartNoAndLotNo CPLN 		ON CPLN.oldLotID = LCMH.OldBarcode --and LCMH.JobDate BETWEEN @FromDate AND @ToDate
		LEFT OUTER JOIN STB_MaterialMaster MM1
		ON MM1.MaterialCode = BefMaterialCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
		ON MM2.MaterialCode = AftMaterialCode
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON (LCMH.NewBarcode = SI.Barcode or CPLN.oldLotID = SI.Barcode)
	  LEFT OUTER JOIN  STB_MaterialMaster MM  
	  on SI.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON SI.InputLineCode = LI.LineCode
	WHERE 
	(LCMH.JobDate BETWEEN @FromDate AND @ToDate)
		or
		(CPLN.CreateDateTime BETWEEN @FromDate AND @ToDate)
--ORDER BY JobDate DESC;
*/
END

--select * from  STB_LotChangeMaterialHistory WHERE OldBarcode='VVOT213R850602' 