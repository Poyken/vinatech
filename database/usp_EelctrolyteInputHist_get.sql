Text
----
-- =============================================

-- Author: Jackaroe(yjyu@vina.co.kr)

-- Create date: 2021-03-05

-- Browsable : true

-- Group : ????

-- Description:	??? ??? ???? ??

-- Modified:

-- =============================================

CREATE PROCEDURE [dbo].[usp_EelctrolyteInputHist_get]

						@pProcessUserID VARCHAR(20)

					   ,@pProcessLanguage VARCHAR(20)

					   ,@pFromDate DATE

					   ,@pToDate DATE

					   ,@pRawMaterialBarcode NVARCHAR(100) = NULL

AS



BEGIN

	Declare @FromDate DATE = @pFromDate

		   ,@ToDate DATE = @pToDate

		   ,@RawMaterialBarcode NVARCHAR(100) = CASE WHEN ISNULL(@pRawMaterialBarcode, '') = '' THEN '*' ELSE @pRawMaterialBarcode END



SELECT SI.InputJobDate

      ,SI.InputLineCode

	  ,LI.LineDesc AS LineName

	  ,SI.Barcode

	  ,SI.MaterialCode

	  ,MM1.MaterialName

	  ,RMIH.RawMaterialBarcode

	  ,MDLI.MaterialCode AS RawMaterialCode

	  ,MM2.MaterialName AS RawMaterialName

  FROM STB_SetInfo SI

  LEFT OUTER JOIN STB_RawMaterialInputHist RMIH

    ON SI.Barcode = RMIH.Barcode

   AND RMIH.ProductGroupCode = 'Eelctrolyte'

  LEFT OUTER JOIN (SELECT LotNo, MAX(MaterialCode) AS MaterialCode 

                     FROM STB_MaterialDocLotInfo

					GROUP BY LotNo

				   ) MDLI

    ON MDLI.LotNo = RMIH.RawMaterialBarcode

  LEFT OUTER JOIN STB_MaterialMaster MM1

    ON MM1.MaterialCode = SI.MaterialCode

  LEFT OUTER JOIN STB_MaterialMaster MM2

    ON MM2.MaterialCode = MDLI.MaterialCode

  LEFT OUTER JOIN STB_LineInfo LI

    ON LI.LineCode = SI.InputLineCode

 WHERE SI.InputJobDate Between @FromDate AND @ToDate

   AND MDLI.MaterialCode IS NOT NULL

   AND RMIH.RawMaterialBarcode <> ''

   AND (@RawMaterialBarcode = '*' OR RMIH.RawMaterialBarcode = @RawMaterialBarcode)

 ORDER BY SI.InputJobDate, LI.LineDesc

END
