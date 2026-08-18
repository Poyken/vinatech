-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-09
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getMeasurementControlListVVT_get]
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pSerialNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SerialNo VARCHAR(50) = CASE WHEN ISNULL(@pSerialNo,'') = '' THEN '%' ELSE @pSerialNo END

    ;WITH data1 AS (
		SELECT 
			SerialNo,
			MeasurementNameE,
			MeasurementNameV,
			ModelName,
			Maker,
			Specification,
			ManagementNo,
			[Status],
			SetLocation,
			Department,
			WorkCenterCode,
			--I.WorkCenterName,
			PIC,
			--DATEADD(day, 1, DayOfCalibration) AS DayOfCalibration,
			--DATEADD(day, 366, DayOfCalibration) AS ExpiredDate,

			CONVERT(varchar(10), DayOfCalibration, 23) AS DayOfCalibration,
			CONVERT(varchar(10), DATEADD(day, 365, DayOfCalibration), 23) AS ExpiredDate,

			TypeOfCalibration,
			CertificateNo,
			CertificationBody,
		
			CASE	WHEN [Status] NOT LIKE '폐기%'  THEN 366 - DATEDIFF(DAY,DayOfCalibration, getdate()) 
						ELSE 0					
			END AS RemainSchedule,

			Remark,
			Note,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID
		FROM STB_MeasurementControlList_VVT 
		--LEFT JOIN STB_WorkCenterInfo WCI ON WCI.WorkCenterCode = MCL.WorkCenterCode
		WHERE SerialNo LIKE @SerialNo
		and ManagementNo NOT IN ('DontDeleteThis')

	) 


	SELECT 
			d1.SerialNo,
			d1.MeasurementNameE,
			d1.MeasurementNameV,
			d1.ModelName,
			d1.Maker,
			d1.Specification,
			d1.ManagementNo,
			d1.Status,
			d1.SetLocation,
			d1.Department,
			d1.WorkCenterCode,
			WCI.WorkCenterName,
			d1.PIC,
			d1.DayOfCalibration,
			d1.ExpiredDate,
			d1.TypeOfCalibration,
			d1.CertificateNo,
			d1.CertificationBody,
			d1.RemainSchedule,

			CASE WHEN d1.Status NOT LIKE '폐기%' THEN (
				CASE	WHEN d1.RemainSchedule = 0  THEN 'Scrap'
						WHEN d1.RemainSchedule < 30 THEN 'Expired'
						ELSE 'OK'
					END
				)
				ELSE ''
				END AS StatusOfCalbration,
			d1.Remark,
			d1.Note,
			d1.CreateDateTime,
			d1.CreateUserID,
			d1.ChangeDateTime,
			d1.ChangeUserID

			FROM data1 d1 
			LEFT JOIN STB_WorkCenterInfo WCI ON WCI.WorkCenterCode = d1.WorkCenterCode
			ORDER BY 
			CASE WHEN d1.[Status] LIKE '운영중%' and d1.RemainSchedule >=0 then 1
				WHEN d1.[Status] LIKE '보관%' and d1.RemainSchedule >0 then 2
				WHEN d1.[Status] LIKE '폐기%' and d1.RemainSchedule >0 then 3
				ELSE 4
			END
			,abs(d1.RemainSchedule) asc
END
