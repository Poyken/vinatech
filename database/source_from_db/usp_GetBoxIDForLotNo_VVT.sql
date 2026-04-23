-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-31
-- Browsable : true
-- Group : 생산관리
-- Description: 베트남 바코드 정보 출력을 위한 정보를 가져옵니다
-- Modified:
--              2020.04.17  기종변경에 따른 바코드 조회쿼리 변경 (kilee)
-- usp_GetBoxIDForLotNo_VVT '','','VJKP163R025620',''
-- usp_GetBoxIDForLotNo_VVT '','','vvmp263R850605',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBoxIDForLotNo_VVT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL,
						@pLabelType NVARCHAR(30) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(30) = @pLabelType
	DECLARE @LotNo VARCHAR(100) = @pLotNo
	DECLARE @NewBarcode VARCHAR(100)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = @LotNo

	;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()
	)
	SELECT DISTINCT            -- 2020.08.24 추가
			SI.MaterialCode,
			MM.MaterialName,
			LI.LabelType,
			LI.FormatName,
			LI.CommandType,
			LI.Dpi,
			LI.PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			--REPLACE(SI.Barcode, 'VV', 'VJ') AS LotNo,
			CASE WHEN LEFT(SI.Barcode, 2) = 'VV' THEN  REPLACE(SI.Barcode, 'VV', 'VJ')
																  ELSE REPLACE(SI.Barcode, 'VJ', 'VV') END AS LotNo,			-- VV Then VJ,		VJ Then VV
			MBI.MBIExtText04 AS Voltage,
			MBI.MBIExtText05 AS Farad,
			'(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')' AS Rating,
			CASE WHEN MM.MMExtText05 IS NOT NULL THEN MM.MMExtText05
				 ELSE 
					RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END 
				 END AS PartNo,
			ISNULL(MLI.PackingID, '') AS PackingID,
			CONVERT(Date, GETDATE()) As Today

	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			  ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)			  ON MLBI.ModelCode = SI.MaterialCode 			 AND MLBI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LI													  ON LI.LabelType = MLBI.LabelType 			 AND LI.FormatName = MLBI.FormatName 			 AND LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI			  ON SI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_MaterialLotInfo MLI			  ON MLI.LotNo = SI.Barcode
	WHERE 1=1
	  AND  (
	           SI.Barcode = @LotNo OR SI.Barcode = @NewBarcode
		      )
     

END