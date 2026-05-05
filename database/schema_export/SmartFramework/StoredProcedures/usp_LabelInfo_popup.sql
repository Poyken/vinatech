-- Procedure: usp_LabelInfo_popup

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-06-22
-- Browsable : true
-- Group : 팝업
-- Description:	라벨정보 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelInfo_popup]
	@pLabelType NVARCHAR(60) = NULL,
	@pCommandType VARCHAR(20) = NULL,
	@pPaperType NVARCHAR(60) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(60) = CASE WHEN ISNULL(@pLabelType,'') = '' THEN '*' ELSE @pLabelType END
	DECLARE @CommandType VARCHAR(20) = CASE WHEN ISNULL(@pCommandType,'') = '' THEN '*' ELSE @pCommandType END
	DECLARE @PaperType NVARCHAR(60) = CASE WHEN ISNULL(@pPaperType,'') = '' THEN '*' ELSE @pPaperType END
    
	;WITH ApprovalLabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.FormatVersion,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName,
				LI.PaperType
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE() AND
				((@LabelType = '*') OR (LI.LabelType = @LabelType)) AND
				((@CommandType = '*') OR (LI.CommandType = @CommandType)) AND
				((@PaperType = '*') OR (LI.PaperType = @PaperType))
	)
		SELECT
				ALI.LabelType,
				ALI.FormatName,
				ALI.FormatVersion,
				ALI.CommandType,
				ALI.PaperType,
				ALI.Dpi
		FROM
				ApprovalLabelInfo ALI
		WHERE
				ALI.RankIndex = 1
END



GO

