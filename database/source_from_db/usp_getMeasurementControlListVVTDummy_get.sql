-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getMeasurementControlListVVTDummy_get]		-- usp_getMeasurementControlListVVTDummy_get '', '', NULL, NULL
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSerialNo VARCHAR(50) = NULL,
		@pManagementNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @SerialNoDummy VARCHAR(50) = @pSerialNo
	         , @ManagementNoDummy VARCHAR(50) = @pManagementNo

	IF @pSerialNo IS NULL and @pManagementNo IS NULL BEGIN 
		SET @ManagementNoDummy = 'DontDeleteThis'
		SET @SerialNoDummy = 'DontDeleteThis'
	END

	SELECT 
		@pManagementNo AS ManagementNo,
		@pSerialNo AS SerialNo,
		MCL.MeasurementNameE,
		MCL.MeasurementNameV,
		MCL.ModelName,
		MCL.Maker,
		MCL.Specification,
		MCL.[Status],
		MCL.SetLocation,
		MCL.Department,
		MCL.WorkCenterCode,
		WCI.WorkCenterName,
		MCL.PIC,
		CASE WHEN ISNULL(MCL.DayOfCalibration, '') = '' THEN GETDATE()
		ELSE DATEADD(day, 1, DayOfCalibration) END AS DayOfCalibration,

		CASE WHEN ISNULL(MCL.DayOfCalibration, '') = '' THEN ''
		ELSE DATEADD(day, 366, DayOfCalibration) END AS ExpiredDate,
		MCL.TypeOfCalibration,
		MCL.CertificateNo,
		MCL.ProdProcessResultFile,
		AFM.[FileName],
		AFM.FileSize,
		ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData,
		MCL.CertificationBody,
		MCL.Remark,
		MCL.Note

		FROM	
			STB_MeasurementControlList_VVT MCL WITH(NOLOCK)
		LEFT OUTER JOIN STB_WorkCenterInfo WCI	    ON WCI.WorkCenterCode = MCL.WorkCenterCode
		LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = MCL.ProdProcessResultFile

		WHERE
			MCL.ManagementNo = @ManagementNoDummy
			AND MCL.SerialNo = @SerialNoDummy
			
END
