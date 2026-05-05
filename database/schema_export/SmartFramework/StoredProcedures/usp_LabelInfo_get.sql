-- Procedure: usp_LabelInfo_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨정보
-- Description:	CommandType 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL,
	@pCommandType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LabelType NVARCHAR(30) = CASE WHEN ISNULL(@pLabelType,'') = '' THEN '*' ELSE @pLabelType END
	DECLARE @CommandType VARCHAR(20) = CASE WHEN ISNULL(@pCommandType,'') = '' THEN '*' ELSE @pCommandType END
    
	SELECT
			LI.LabelType AS OldLabelType,
			LI.FormatName AS OldFormatName,
			LI.FormatVersion AS OldFormatVersion,
			LI.LabelType,
			LTI.LabelTypeName,
			LI.FormatName,
			LI.FormatVersion,
			LI.PaperType,
			PTI.PaperTypeName,
			LI.CommandType,
			LI.Dpi,
			LI.Format,
			LI.PartitionQty,
			LI.ProdSnType,
			LI.BarcodeModel,
			LI.LabelImageFileID,
			LI.ApplyDate,
			LI.IsApproval,
			LI.ApprovalUserID,
			LI.ApprovalDateTIme,
			LI.LabelRemark,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX), NULL) AS FileData,
			LI.DataSourceViewName,
			LI.PrinterName,
			LI.CreateDateTime,
			LI.CreateUserID,
			LI.ChangeDateTime,
			LI.ChangeUserID
	FROM
			STB_LabelInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LabelTypeInfo LTI WITH(NOLOCK)
				ON (LTI.LabelType = LI.LabelType)
			LEFT OUTER JOIN STB_PaperTypeInfo PTI WITH (NOLOCK)
				ON (PTI.PaperType = LI.PaperType) 
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = LI.LabelImageFileID)
	WHERE
			((@LabelType = '*') OR (LI.LabelType = @LabelType)) AND
			((@CommandType = '*') OR (LI.CommandType = @CommandType))

END



GO

