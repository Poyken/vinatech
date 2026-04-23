
-- ==================================================================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리 > [B520]제품박스실적입력 > Grid-3 BOX ID 정보
-- Description: 패킹공정 실적 입력을 위한 바코드 정보를 가져옵니다
-- Modified:
-- 2021.04.22 팅크웨어향 라벨 관련 (고객사)자재코드 추가 #21.04.22
-- 2021.11.04 삼성향포장라벨 PartNo부분 Case문 조건 추가 (Mr.Song)
-- 2022.03.21 작업일자 자동

-- 프로시저 실행 :    Exec usp_GetBoxIDForLotNo_VNT 'kilee','Korean','VJLS193R850606', ''
-- ====================================================================================
CREATE PROCEDURE usp_MEAGetBoxIDForLotNo_VNT                               
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL,
						@pLabelType NVARCHAR(30) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(30) = @pLabelType 
	DECLARE @LotNo VARCHAR(100) = @pLotNo 
	DECLARE @IsModule BIT = 0 
	
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
	SELECT
			MLI.LotID,
			MLI.PackingID,
			LI.LabelType,
			LI.FormatName,
			LI.CommandType,
			LI.Dpi,
			LI.PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			MLI.CurrentQty,
			ISNULL(PLS.LotNo, MLI.LotNo) AS LotNo, --edited by Mr.Tung on 27-March-2021 
		    CONVERT(CHAR(10), GetDate(), 121) AS Today,
			MLI.LotAttr08 AS CustomerName
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LI				                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)

			LEFT OUTER JOIN STB_PackingStandard SPS				     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
	WHERE
			MLI.LotNo = @LotNo

END