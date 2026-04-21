Text
----
-- =============================================

-- Author : Jackaroe(yjyu@vina.co.kr)

-- Group : ????

-- Browsable : true

-- Create date : 2019-11-06

-- Description : ???? > ?????????

-- =============================================

CREATE PROCEDURE [dbo].[usp_ElectrodeRawMaterialInputFullHist_get]

						@pFromDate DATETIME,

						@pToDate DATETIME,

						@pCompanyCode      VARCHAR(20) = NULL                          --2020.02.19 ????

AS



BEGIN

	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'

		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

		   ,@CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END



	SELECT SI.InputLineCode AS LineCode

		  ,LI.LineName

		  ,RMIH.ProductGroupCode

		  ,RMBI.ProductGroupName

		  ,SI2.MaterialCode

		  ,MM.MaterialName

		  ,UPPER(RMIH.RawMaterialBarcode) AS RawMaterialBarcode

		  ,MAX(RMIH.CreateDateTime) AS CreateDateTime

		  ,LI.CompanyCode

		  ,MAX(ESR.GoodQtyLength) AS GoodQtyLength

		  ,MAX(ESR.SlittingWidth) AS SlittingWidth

	  FROM STB_RawMaterialInputHist RMIH

			  LEFT OUTER JOIN STB_SetInfo SI  		                 

			    ON RMIH.Barcode = SI.Barcode

			  LEFT OUTER JOIN STB_ModelBasicInfo MBI		     

			    ON MBI.ModelCode = SI.MaterialCode

			  LEFT OUTER JOIN STB_RawMaterialBaiscInfo RMBI	 

			    ON RMBI.ProductGroupCode = RMIH.ProductGroupCode	   

			   AND RMBI.SizeCode = CASE WHEN MBI.MBISizeW IN (8,10) THEN 'Small'

								   WHEN MBI.MBISizeW IN (13, 16, 18) THEN 'Middle'		

								   ELSE 'Large' END

			  LEFT OUTER JOIN STB_LineInfo LI                      

			    ON LI.LineCode = SI.InputLineCode

			  LEFT OUTER JOIN STB_ElectrodeSlittingResult ESR

			    ON ESR.Barcode = RMIH.RawMaterialBarcode

			  LEFT OUTER JOIN STB_SetInfo SI2 

			    ON SI2.Barcode = ESR.ElectrodeLotNumber

			  LEFT OUTER JOIN STB_MaterialMaster MM

			    ON MM.MaterialCode = SI2.MaterialCode

	 WHERE RMIH.CreateDateTime BETWEEN @FromDate AND @ToDate

	  AND RMIH.RawMaterialBarcode <> ''

	  AND RMIH.ProductGroupCode IN ('ElectrodeP','ElectrodeM')

	  AND ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode))

	GROUP BY SI.InputLineCode, LI.LineName, RMIH.ProductGroupCode, RMBI.ProductGroupName, SI2.MaterialCode

	        ,MM.MaterialName, UPPER(RMIH.RawMaterialBarcode), LI.CompanyCode

END
