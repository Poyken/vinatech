-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-11-06
-- Description : 생산관리 > 원자재투입이력정보
-- Modified : 2020.02.19 사업장코드 추가 (kilee)
			--2021.07.16 Mr.Tung , adding MaterialName, ProdQty, DefectQty

-- 실행문 : usp_RawMaterialInputFullHist_get '','','','','','','2022-02-10 00:00:00','2022-02-11 23:30:30','VVT'
-- =============================================
CREATE PROCEDURE [dbo].[usp_RawMaterialInputFullHist_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL,
						@pRawMaterialBarcode VARCHAR(100) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pCompanyCode      VARCHAR(20) = NULL                          --2020.02.19 추가사항
AS

BEGIN
	Declare @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode, '') = '' THEN  '*' ELSE @pProductGroupCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN  '*' ELSE @pBarcode END
		   ,@RawMaterialBarcode VARCHAR(100) = CASE WHEN ISNULL(@pRawMaterialBarcode, '') = '' THEN  '*' ELSE @pRawMaterialBarcode END
		   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN  '*' ELSE @pLineCode END
		   ,@CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END                          --2020.02.19 추가사항        

	SELECT UPPER(RMIH.Barcode) AS Barcode
	      ,SI.InputLineCode AS LineCode
		  ,LI.LineName
		  ,RMIH.ProductGroupCode
		  ,RMBI.ProductGroupName
		  ,UPPER(RMIH.RawMaterialBarcode) AS RawMaterialBarcode
		  ,RMIH.CreateDateTime
		  ,LI.CompanyCode        -- 2020.02.19 추가  (kilee)
		  ,RMBI.DisplayIndex
		  ,mm.MaterialName       --2021.07.16 Mr.Tung
		  ,SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) as ModelSize --2021.07.16 Mr.Tung
		  ,si.ProdQty			--2021.07.16 Mr.Tung
		  ,si.DefectQty			--2021.07.16 Mr.Tung
		  ,SI.MaterialCode		--2022.05.06 Mr.Tung
	  FROM STB_RawMaterialInputHist RMIH with(nolock)
			  LEFT OUTER JOIN STB_SetInfo SI  		 with(nolock)                 ON RMIH.Barcode = SI.Barcode
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock)		     ON MBI.ModelCode = SI.MaterialCode
			  LEFT OUTER JOIN STB_RawMaterialBaiscInfo RMBI with(nolock)	 ON RMBI.ProductGroupCode = RMIH.ProductGroupCode	   AND RMBI.SizeCode = CASE WHEN MBI.MBISizeW IN (8,10) THEN 'Small'
																																														 WHEN MBI.MBISizeW IN (13, 16, 18) THEN 'Middle'		ELSE 'Large' END
			  LEFT OUTER JOIN STB_LineInfo LI   with(nolock)                    ON LI.LineCode = SI.InputLineCode
			  LEFT OUTER JOIN STB_MaterialMaster mm  with(nolock) on si.MaterialCode = mm.MaterialCode

	 WHERE (@ProductGroupCode ='*' OR RMIH.ProductGroupCode = @ProductGroupCode)
	   AND (@Barcode = '*' OR RMIH.Barcode = @Barcode)
	   AND (@RawMaterialBarcode = '*' OR RMIH.RawMaterialBarcode LIKE '%'+@RawMaterialBarcode+'%')
	   AND (@LineCode = '*' OR SI.InputLineCode = @LineCode)
	   AND RMIH.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND RMIH.RawMaterialBarcode <> ''
	  AND ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode))                                           -- 2020.02.19 추가  (kilee)
	UNION ALL

	SELECT EMSI.ElectrodeLotNumber
	      ,'ELECTRODE LINE'
		  ,'전극라인'
		  ,'EROH'
		  ,'전극원자재'
		  ,UPPER(EMSI.MaterialLotNumber)
		  ,EMSI.CreateDateTime
		  ,CASE WHEN EMSI.ElectrodeLotNumber LIKE 'VJ%' THEN 'VNT' ELSE 'VVT' END
		  ,0
		  ,mm.MaterialName
		  ,null
		  ,null
		  ,null
		  ,emsi.ElectrodeMaterialCode		--2022.05.06 Mr.Tung
	  FROM STB_ElectrodeMixStepInfo EMSI with(nolock)
	    LEFT OUTER JOIN STB_MaterialMaster mm  with(nolock) on EMSI.ElectrodeMaterialCode = mm.MaterialCode
	 WHERE (@ProductGroupCode ='*' OR @ProductGroupCode = 'EROH')
	   AND (@Barcode = '*' OR EMSI.ElectrodeLotNumber = @Barcode)
	   AND (@RawMaterialBarcode = '*' OR EMSI.MaterialLotNumber LIKE '%'+@RawMaterialBarcode+'%')
	   AND (@LineCode = '*' OR @LineCode = 'ELECTRODE LINE')
	   AND EMSI.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND ISNULL(EMSI.MaterialLotNumber, '') <> ''
	  AND ((@CompanyCode = '*') OR (CASE WHEN EMSI.ElectrodeLotNumber LIKE 'VJ%' THEN 'VNT' ELSE 'VVT' END = @CompanyCode))   
	ORDER BY UPPER(RMIH.Barcode), RMBI.DisplayIndex
END