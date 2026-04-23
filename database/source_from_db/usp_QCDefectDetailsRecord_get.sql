-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCDefectDetailsRecord_get] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pFromDate DATETIME,
		@pToDate DATETIME,
		@pBarcode VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 00:00:00'
		   ,@Barcode NVARCHAR(30) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '%' ELSE @pBarcode END

	IF ISNULL(@pBarcode,'') <> ''

		BEGIN
			SELECT 
				QCD.Barcode,
				SI.ControlNo,
				SI.MaterialCode,
				MBI.ModelName,
				SI.InputLineCode,
				LI.LineName,
				CONVERT(varchar(10), QCD.InspectionDate, 23) AS InspectionDate,
				QCD.InspectionQty,
				QCD.DefectQty,
				QCD.DefectDivisionCode,
				BC1.Description AS DefectDivisionName,
				QCD.DefectCode,
				DI.BasicDefectName,
				QCD.InspWorkerCode,
				PWI.WorkerName,
				--QCD.DefectImage,
				--QCD.DefectImageUrl,
				--QCD.ProdProcessResultFile,
				--AFM.[FileName],
				--AFM.FileSize,
				--CONVERT(VARBINARY(MAX),NULL) AS FileData,
				QCD.Cause,
				QCD.Countermeasure,
				QCD.FollowUp,
				QCD.Note,
				QCD.CreateDateTime,
				QCD.CreateUserID,
				QCD.ChangeDateTime,
				QCD.ChangeUserID

			FROM STB_QCDefectDetailsRecord QCD WITH (NOLOCK)
			LEFT OUTER JOIN STB_SetInfo SI ON SI.Barcode = QCD.Barcode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI ON MBI.ModelCode = SI.MaterialCode
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QCD.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			LEFT OUTER JOIN STB_DefectInfo DI ON QCD.DefectCode = DI.DefectCode
			LEFT OUTER JOIN STB_LineInfo LI ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PWI.WorkerCode = QCD.InspWorkerCode

			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QCD.ProdProcessResultFile

			WHERE 1=1
			AND QCD.Barcode = @Barcode
		END


	ELSE 
		BEGIN
			SELECT 
				QCD.Barcode,
				SI.ControlNo,
				SI.MaterialCode,
				MBI.ModelName,
				SI.InputLineCode,
				LI.LineName,
				CONVERT(varchar(10), QCD.InspectionDate, 23) AS InspectionDate,
				QCD.InspectionQty,
				QCD.DefectQty,
				QCD.DefectDivisionCode,
				BC1.Description AS DefectDivisionName,
				QCD.DefectCode,
				DI.BasicDefectName,
				QCD.InspWorkerCode,
				PWI.WorkerName,
				--QCD.DefectImage,
				--QCD.DefectImageUrl,
				--QCD.ProdProcessResultFile,
				--AFM.[FileName],
				--AFM.FileSize,
				--CONVERT(VARBINARY(MAX),NULL) AS FileData,
				QCD.Cause,
				QCD.Countermeasure,
				QCD.FollowUp,
				QCD.Note,
				QCD.CreateDateTime,
				QCD.CreateUserID,
				QCD.ChangeDateTime,
				QCD.ChangeUserID

			FROM STB_QCDefectDetailsRecord QCD WITH (NOLOCK)
			LEFT OUTER JOIN STB_SetInfo SI ON SI.Barcode = QCD.Barcode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI ON MBI.ModelCode = SI.MaterialCode
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QCD.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			LEFT OUTER JOIN STB_DefectInfo DI ON QCD.DefectCode = DI.DefectCode
			LEFT OUTER JOIN STB_LineInfo LI ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PWI.WorkerCode = QCD.InspWorkerCode

			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QCD.ProdProcessResultFile

			WHERE 1=1
			AND InspectionDate <= @ToDate
			AND QCD.InspectionDate >= @FromDate

			ORDER BY InspectionDate

		END

	
END
