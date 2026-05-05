-- Procedure: usp_GetLabelSpecInfoForLabelView



-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-04-12
-- Browsable : true
-- Group : 라벨스팩정보
-- Description:	라벨의 스펙정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLabelSpecInfoForLabelView]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL,
	@pFormatName NVARCHAR(30) = NULL,
	@pFormatVersion INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(30) = @pLabelType
	DECLARE @FormatName NVARCHAR(30) = @pFormatName
	DECLARE @FormatVersion INT = @pFormatVersion
	DECLARE @Barcode VARCHAR(50) = '000000000000000'
		
	SELECT
			LI.CommandType,
			LI.LabelType,
			LI.FormatName,
			LI.FormatVersion,
			LI.Format
	FROM
			STB_LabelInfo LI WITH(NOLOCK)
	WHERE
			LI.LabelType = @LabelType AND
			LI.FormatName = @FormatName AND
			LI.FormatVersion = @FormatVersion AND
			LI.CommandType = 'Report'
			
	SELECT
			LSI.LabelType,
			LTI.LabelTypeName,
			LSI.LabelSpecCode,
			LSI.LabelSpecName,
			'' AS LabelSpecValue
	FROM
			STB_LabelSpecInfo LSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LabelTypeInfo LTI WITH(NOLOCK)
				ON LTI.LabelType = LSI.LabelType
	WHERE
			LSI.LabelType = @LabelType
	UNION ALL
	SELECT
			'',
			'',
			'SerialNo',
			'SerialNo',
			@Barcode
	UNION ALL
	SELECT
			'',
			'',
			'BoxSerialNo',
			'BoxSerialno',
			@Barcode

END

GO

