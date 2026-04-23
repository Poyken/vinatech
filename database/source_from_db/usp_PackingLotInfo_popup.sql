-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-07-22
-- Description : 패킹정보 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingLotInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PackingID VARCHAR(20) = @pPackingID

	SELECT PackingID
	      ,LotNo
		  ,CASE WHEN MaterialLotNo = (SELECT MAX(MaterialLotNo) FROM STB_MaterialLotInfo WHERE PackingID = @PackingID) THEN '대표 Lot' ELSE '' END AS LabelLotNo
	  FROM STB_MaterialLotInfo
	 WHERE PackingID = @PackingID
	 ORDER BY LotNo ASC
END