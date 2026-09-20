
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2020-12-09
-- Browsable : true
-- Group : 생산관리
-- Description: 패킹공정 실적 입력을 위한 바코드 정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingReaminQtyLabelInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LotNo VARCHAR(100) = @pLotNo
	DECLARE @IsModule BIT = 0

	SELECT  TOP 1
			MLI.MaterialCode,
			MM.MaterialName,
			'Report' AS CommandType,
			0 AS LotQty,
			ISNULL(PLS.LotNo, MLI.LotNo) AS LotNo,
			ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
			ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
			ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
	WHERE
			MLI.LotNo = @LotNo
END