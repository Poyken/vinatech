-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MeasurementControlCalibrateHistoryVVT_get]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
                @pManagementNo VARCHAR(50),
				@pSerialNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ManagementNo VARCHAR(50) = CASE WHEN ISNULL(@pManagementNo,'') = '' THEN '%' ELSE @pManagementNo END
	DECLARE @SerialNo VARCHAR(50) = CASE WHEN ISNULL(@pSerialNo,'') = '' THEN '%' ELSE @pSerialNo END


    SELECT 
        ID,
        ManagementNo,
        SerialNo,
        DayOfCalibration,
        DATEADD(day, 366, DayOfCalibration) AS ExpiredDate,
        Remark ,
        Note ,
        CreateDateTime ,
        CreateUserID ,
        ChangeDateTime ,
        ChangeUserID 
    FROM STB_MeasurementControlCalibrateHistory_VVT MCCH WITH(NOLOCK)
    WHERE SerialNo LIKE @SerialNo
    AND ManagementNo LIKE @ManagementNo

    ORDER BY CreateDateTime desc


END
