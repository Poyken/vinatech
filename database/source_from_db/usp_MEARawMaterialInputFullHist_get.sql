-- ED-VJPMTR000000017
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : MEA
-- Browsable : true
-- Create date : 2022-09-21
-- Description : 원자재투입이력
-- =============================================
CREATE PROCEDURE [dbo].[usp_MEARawMaterialInputFullHist_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL,
						@pRawMaterialBarcode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pFromDate DATETIME,
						@pToDate DATETIME
AS

BEGIN
	Declare @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode, '') = '' THEN  '*' ELSE @pProductGroupCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN  '*' ELSE @pBarcode END
		   ,@RawMaterialBarcode VARCHAR(20) = CASE WHEN ISNULL(@pRawMaterialBarcode, '') = '' THEN  '*' ELSE @pRawMaterialBarcode END
		   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 00:00:00'
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN  '*' ELSE @pLineCode END 

	SELECT UPPER(RMIH.Barcode) AS Barcode
	      ,SI.InputLineCode AS LineCode
		  ,LI.LineName
		  ,RMIH.ProductGroupCode
		  ,RMBI.ProductGroupName
		  ,UPPER(RMIH.RawMaterialBarcode) AS RawMaterialBarcode
		  ,ISNULL(RMIH.ChangeDateTime, RMIH.CreateDateTime) AS CreateDateTime
		  ,LI.CompanyCode        -- 2020.02.19 추가  (kilee)
		  ,RMBI.DisplayIndex
		  ,mm.MaterialName       --2021.07.16 Mr.Tung
		  ,SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) as ModelSize --2021.07.16 Mr.Tung
		  ,si.ProdQty			--2021.07.16 Mr.Tung
		  ,si.DefectQty			--2021.07.16 Mr.Tung
		  ,SI.MaterialCode		--2022.05.06 Mr.Tung
		  ,RMIH.Qty
		  ,RMIH.Remark
		  ,RMIH.MEADefectDivCode
		  ,BC.Description AS MEADefectDivName
		  --,MLI.MaterialCode AS RawMaterialCode	--2023.07.25 SJC
		  ,(SELECT TOP 1 MaterialCode FROM STB_MaterialDocLotInfo WHERE (LotID = RMIH.RawMaterialBarcode OR LotNo = RMIH.RawMaterialBarcode)) AS RawMaterialCode
		  ,(SELECT TOP 1 LotNo FROM STB_MaterialDocLotInfo WHERE (LotID = RMIH.RawMaterialBarcode OR LotNo = RMIH.RawMaterialBarcode)) AS LotNo
		  ,ISNULL(RMIH.ChangeUserID, RMIH.CreateUserID) AS CreateUserID
		  ,(SELECT UserName FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = ISNULL(RMIH.ChangeUserID, RMIH.CreateUserID)) AS CreateUserName
		  ,RMIH.WorkerCode
		  ,ME.NM_KOR AS WorkerName
	  FROM STB_RawMaterialInputHist RMIH with(nolock)
			  LEFT OUTER JOIN STB_SetInfo SI  		 with(nolock)                 ON RMIH.Barcode = SI.Barcode
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock)		     ON MBI.ModelCode = SI.MaterialCode
			  LEFT OUTER JOIN (SELECT ProductGroupCode, ProductGroupName, MAX(DisplayIndex) AS DisplayIndex
			                     FROM STB_RawMaterialBaiscInfo 
								GROUP BY ProductGroupCode, ProductGroupName) RMBI
								  ON RMBI.ProductGroupCode = RMIH.ProductGroupCode	   
			  LEFT OUTER JOIN STB_LineInfo LI   with(nolock)                    ON LI.LineCode = SI.InputLineCode
			  LEFT OUTER JOIN STB_MaterialMaster mm  with(nolock) on si.MaterialCode = mm.MaterialCode
--			  LEFT OUTER JOIN (SELECT LotID, LotNo, MaterialCode FROM STB_MaterialDocLotInfo MLI with(nolock) GROUP BY LotID, LotNo, MaterialCode  ON (RMIH.RawMaterialBarcode = MLI.LotID OR RMIH.RawMaterialBarcode = MLI.LotNo)  --2023.07.25 SJC
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
			    ON BC.CodeGroup = 'MEADefectDivCode'
			   AND BC.ItemCode = RMIH.MEADefectDivCode
			  LEFT OUTER JOIN NEOE.NEOE.MA_EMP ME
			    ON ME.CD_COMPANY = '1000' -- 법인별로 법인코드를 넣어주는 것이 맞으나 MEA 원자재 투입 화면으로 본사(완주)에서만 사용하므로 고정
			   AND NO_EMP = RMIH.WorkerCode
	 WHERE (@ProductGroupCode ='*' OR RMIH.ProductGroupCode = @ProductGroupCode)
	   AND (@Barcode = '*' OR RMIH.Barcode = @Barcode)
	   AND (@RawMaterialBarcode = '*' OR RMIH.RawMaterialBarcode LIKE '%'+@RawMaterialBarcode+'%')
	   AND (@LineCode = '*' OR SI.InputLineCode = @LineCode)
	   AND ISNULL(RMIH.ChangeDateTime, RMIH.CreateDateTime) BETWEEN @FromDate AND @ToDate
	   AND RMIH.RawMaterialBarcode <> ''
END