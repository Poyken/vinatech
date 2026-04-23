-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================

--exec usp_MeetingAgenda543_get '','', 1,'Sum Meeting open'
CREATE  PROCEDURE [dbo].[usp_MeetingAgenda543_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pYearsD nvarchar(6) = null,
	@pMonthsD int = null,
	@pStatus nvarchar(100) = NULL


AS
BEGIN
	SET NOCOUNT ON;
    -- RAISERROR(@pStatus,16,1)

    if CHARINDEX('Open',@pStatus) > 0   
	BEGIN
		SELECT
				QIG.ID AS OldID,
				QIG.ID,
				--convert(varchar,  QIG.Date_Meeting, 111) as Date_Meeting,
				dbo.fnGetLocalTime(QIG.Date_Meeting, @pUtcOffset) AS Date_Meeting, -- The varchar type is not controlled by the screen. It must be delivered in date format
				QIG.No,
				QIG.Meeting_Agenda,
				QIG.Customer,
				QIG.Size,
				QIG.RespPlant,
				QIG.RestTeam,
				QIG.CompleteDate,
				QIG.Status,
				QIG.CreateDateTime,
				QIG.CreateUserID,
				QIG.ChangeDateTime,
				QIG.ChangeUserID
		FROM
				Stb_MeetingAgenda QIG WITH(NOLOCK)
		WHERE
				--((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
				(@pYearsD is null or Year(Date_Meeting) = @pYearsD)
				AND (@pMonthsD is null or Month(Date_Meeting) =@pMonthsD)  
				AND (Status = 'OPEN' )
				order by Date_Meeting, no
	END
	
    if CHARINDEX('close',@pStatus) > 0   
	BEGIN
		SELECT
				QIG.ID AS OldID,
				QIG.ID,
				--convert(varchar,  QIG.Date_Meeting, 111) as Date_Meeting,
				dbo.fnGetLocalTime(QIG.Date_Meeting, @pUtcOffset) AS Date_Meeting, -- The varchar type is not controlled by the screen. It must be delivered in date format
				QIG.No,
				QIG.Meeting_Agenda,
				QIG.Customer,
				QIG.Size,
				QIG.RespPlant,
				QIG.RestTeam,
				QIG.CompleteDate,
				QIG.Status,
				QIG.CreateDateTime,
				QIG.CreateUserID,
				QIG.ChangeDateTime,
				QIG.ChangeUserID
		FROM
				Stb_MeetingAgenda QIG WITH(NOLOCK)
		WHERE
				--((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
				(@pYearsD is null or Year(Date_Meeting) = @pYearsD)
				AND (@pMonthsD is null or Month(Date_Meeting) =@pMonthsD)
				AND 
				(Status = 'close' )
				order by Date_Meeting, no
	END
	
	ELSE
	BEGIN
		SELECT
				QIG.ID AS OldID,
				QIG.ID,
				--convert(varchar,  QIG.Date_Meeting, 111) as Date_Meeting,
				dbo.fnGetLocalTime(QIG.Date_Meeting, @pUtcOffset) AS Date_Meeting, -- The varchar type is not controlled by the screen. It must be delivered in date format
				QIG.No,
				QIG.Meeting_Agenda,
				QIG.Customer,
				QIG.Size,
				QIG.RespPlant,
				QIG.RestTeam,
				QIG.CompleteDate,
				QIG.Status,
				QIG.CreateDateTime,
				QIG.CreateUserID,
				QIG.ChangeDateTime,
				QIG.ChangeUserID
		FROM
				Stb_MeetingAgenda QIG WITH(NOLOCK)
		WHERE 
				--((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
				(@pYearsD is null or Year(Date_Meeting) = @pYearsD)
				AND (@pMonthsD is null or Month(Date_Meeting) =@pMonthsD)
				--AND 
				----(Status = 'close' )
				order by Date_Meeting, no
	END
	
END
