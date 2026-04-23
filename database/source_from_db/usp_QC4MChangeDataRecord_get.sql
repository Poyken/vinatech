-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-27
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QC4MChangeDataRecord_get]		-- exec usp_QC4MChangeDataRecord_get 'DinhManh', 'vi', '2026-01-01', '2026-03-30', '', '' ,''
	-- Add the parameters for the stored procedure here			-- select * from STB_QC4MChangeDataRecord
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pFromDate DATETIME,
		@pToDate DATETIME,
		@pApprovalType NVARCHAR(100) = NULL,
		@pIssuingDepartment VARCHAR(10) = NULL,
		@pChangeType4M VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@ApprovalType NVARCHAR(100) = CASE WHEN ISNULL(@pApprovalType, '') = '' THEN '%' ELSE @pApprovalType END
		   ,@IssuingDepartment VARCHAR(10) = CASE WHEN ISNULL(@pIssuingDepartment, '') = '' THEN '%' ELSE @pIssuingDepartment END
		   ,@ChangeType4M VARCHAR(20) = CASE WHEN ISNULL(@pChangeType4M, '') = '' THEN '%' ELSE @pChangeType4M END
		   --,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '%' ELSE @pMachineCode END
		   --,@UserCompanyCode VARCHAR(20)


		   	SELECT 
				QC4M.QC4MNo,
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
				QC4M.ApprovalDate,
				QC4M.EffectiveDate,
				--QC4M.ApprovalDate,
				--QC4M.EffectiveDate,
				QC4M.Conclusion,
				QC4M.Inspector,
				QC4M.Change4MImage,
				QC4M.Change4MImageUrl,
				QC4M.ProdProcessResultFile,
				AFM.[FileName],
				AFM.FileSize,
				CONVERT(VARBINARY(MAX),NULL) AS FileData,
				QC4M.[Status],
				QC4M.Note,
				QC4M.ConnectString,
				QC4M.CreateDateTime,
				QC4M.CreateUserID,
				QC4M.ChangeDateTime,
				QC4M.ChangeUserID

				FROM STB_QC4MChangeDataRecord QC4M WITH (NOLOCK)
				LEFT OUTER JOIN STB_LineInfo LI ON LI.LineCode = QC4M.LineCode
				LEFT OUTER JOIN STB_RouteInfo RI ON RI.RouteCode = QC4M.RouteCode

				LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QC4M.ProdProcessResultFile

				WHERE 1=1
				AND		QC4M.CreateDateTime BETWEEN @FromDate AND @ToDate
				and 	QC4M.ApprovalType 	LIKE @ApprovalType 
				and		QC4M.IssuingDepartment LIKE 	@IssuingDepartment 
				and		QC4M.ChangeType4M LIKE	@ChangeType4M 
				--and		QC4M.QC4MNo NOT IN ('VN999999-99', 'VNAutomatic Numberin')
				and		ShowData = 1		-- điều kiện này để ẩn hiện các báo cáo

END
