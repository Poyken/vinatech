-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-23
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QC4MChangeDataRecodeDummy_get]		
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pQC4MNo VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @QC4MNo VARCHAR(20) = @pQC4MNo
	         , @DummyQC4MNo VARCHAR(20) = @pQC4MNo

	IF @pQC4MNo IS NULL BEGIN 
		-- @DefectReportNo 채번
		SELECT @QC4MNo = 'Automatic Numbering'

		SET @DummyQC4MNo = 'VN999999-99'
	END

	SELECT 
		@QC4MNo AS QC4MNo,
		QC4M.ApprovalType,
		QC4M.IssuingDepartment,
		QC4M.ChangeType4M,
		QC4M.[Level],
		QC4M.Factory,
		QC4M.[Model],
		QC4M.LineCode,
		LI.LineName,
		QC4M.RouteCode,
		RI.RouteName,
		QC4M.LotNo1,
		QC4M.LotNo2,
		QC4M.LotNo3,
		QC4M.DetailedChangeCategories,
		QC4M.ReasonForChange,
		QC4M.ConditionsBefChange,
		QC4M.ConditionsAftChange,
		QC4M.QualityAssuranceContent,
		--QC4M.ApprovalDate,
		--QC4M.EffectiveDate,
		CASE WHEN ISNULL(QC4M.ApprovalDate, '') = '' THEN CONVERT(varchar(10), GETDATE(), 23)
			ELSE QC4M.ApprovalDate 
		END AS ApprovalDate,
		CASE WHEN ISNULL(QC4M.EffectiveDate, '') = '' THEN CONVERT(varchar(10), GETDATE(), 23)
			ELSE QC4M.EffectiveDate 
		END AS EffectiveDate,

		QC4M.Conclusion,
		QC4M.Inspector,
		QC4M.Change4MImage,
		QC4M.Change4MImageUrl,
		QC4M.ProdProcessResultFile,
		AFM.[FileName],
		AFM.FileSize,
		ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData,
		QC4M.[Status],
		QC4M.Note,
		QC4M.ConnectString

		FROM STB_QC4MChangeDataRecord QC4M WITH (NOLOCK)
		LEFT OUTER JOIN STB_LineInfo LI ON LI.LineCode = QC4M.LineCode
		LEFT OUTER JOIN STB_RouteInfo RI ON RI.RouteCode = QC4M.RouteCode

		LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QC4M.ProdProcessResultFile

		WHERE 1=1
		AND QC4M.QC4MNo = @DummyQC4MNo
END
