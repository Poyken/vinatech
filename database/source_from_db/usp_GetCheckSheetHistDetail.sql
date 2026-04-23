-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-10
-- Browsable : true
-- Group : 금형관리
-- Description:	금형점검이력상세 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCheckSheetHistDetail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CommInspDocNo VARCHAR(20) = CASE WHEN ISNULL(@pCommInspDocNo,'') = '' THEN '' ELSE @pCommInspDocNo END
    
    SELECT
			CIDI.CommInspDocItemNo AS OldCommInspDocItemNo,
			CIDI.CommInspDocItemNo,
			CIDI.CommInspDocNo AS OldCommInspDocNo,
			CIDI.CommInspDocNo,
			CIDI.CommInspItemCode,
			
			CIMH.MeasureSeq AS ItemNo,
			
			CASE WHEN CIMH.MeasureResult = 'OK' THEN CONVERT(BIT,1)
			ELSE CONVERT(BIT,0) END AS MeasureResult,
			
			CASE WHEN CIMH.ErrorField = 'Error' THEN CONVERT(BIT,1) 
			ELSE CONVERT(BIT,0) END AS ErrorField, 
			
			CIDI.CommInspRemark AS ErrorText,
			CIDI.ImageFileID,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			CIMH.TextMeasure AS RepairText,
			CII.DisplayIndex,
			
			CII.CommInspItemGroup1 AS CheckPointNo,
			CII.CommInspItemGroup2 AS CheckPointText,
			CII.CommInspItemGroup3 AS CheckSubNo,
			
			CII.CommInspItemName AS CheckItem,
			CII.CommInspItemDesc AS CheckText
	FROM
			STB_CommInspDocItem CIDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspMeasureHist CIMH WITH(NOLOCK)
				ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)
				ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = CIDI.ImageFileID
	WHERE
			((@CommInspDocNo = '*') OR (CIDI.CommInspDocNo = @CommInspDocNo))
			
END


