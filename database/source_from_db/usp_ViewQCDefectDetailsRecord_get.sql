-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ViewQCDefectDetailsRecord_get] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pBarcode VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @Barcode VARCHAR(30) = @pBarcode,
			@DummyBarcode VARCHAR(30) = @pBarcode,
			@checkLotNumber VARCHAR(30) = NULL

	IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @Barcode)
		BEGIN
			RAISERROR(N'Không tồn tại LotNo trên hệ thống! Vui lòng kiểm tra lại!', 16, 1)
			return;
		END

	-- Kiểm tra xem Lot đã nhập đã được tạo Lot ktra OQC chưa
	SELECT @checkLotNumber = LotNumber FROM STB_SetInfo where Barcode = @Barcode
	IF ISNULL(@checkLotNumber, '') = ''
		BEGIN
			RAISERROR(N'LotNo chưa được tạo lot kiểm tra OQC tại C512!', 16, 1)
			return;
		END
	
	--IF EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @pBarcode) BEGIN 
	--	SET @DummyBarcode = 'DontDeleteThis'
	--END

	--IF NOT EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @pBarcode) BEGIN 

		SET @DummyBarcode = 'DontDeleteThis'
	--END


	SELECT 
		    @Barcode AS Barcode,
			SI.ControlNo,
			SI.MaterialCode,
			MBI.ModelName,
			SI.InputLineCode,
			LI.LineName,
			CONVERT(varchar(10), GETDATE(), 23) AS InspectionDate,
			QCD.InspectionQty,
			QCD.DefectQty,
			QCD.DefectDivisionCode,
			BC1.Description AS DefectDivisionName,
			QCD.DefectCode,
			DI.BasicDefectName,
			QCD.InspWorkerCode,
			PWI.WorkerName,
			QCD.DefectImage,
			QCD.DefectImageUrl,
			QCD.ProdProcessResultFile,
			AFM.[FileName],
			AFM.FileSize,
			ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData,
			QCD.Cause,
			QCD.Countermeasure,
			QCD.FollowUp,
			QCD.Note

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
