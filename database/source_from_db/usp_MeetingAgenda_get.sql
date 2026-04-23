-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_MeetingAgenda_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pDate_Meeting date = null,
	@pYears int = null,
	@pMonths int = null,
	@pDays int = null,
	@pMeetingAgenda nvarchar(200) = null,
	@pCustomer nvarchar(50) = null,
	@pSize nvarchar(50) = null,
	@pStatus nvarchar(20) = null,
    @pID int  = null
AS
BEGIN
	SET NOCOUNT ON;
     
	 DECLARE @ID INT
	 DECLARE @date_meeting date
	 DECLARE @cnt int
	 --insert no

	select @cnt=count(*) from Stb_MeetingAgenda where no is null
	Declare c Cursor For Select id,date_meeting from Stb_MeetingAgenda where no is null order by CreateDateTime asc
	Open c
	Fetch next From c into @ID,@date_meeting
	While @@Fetch_Status=0 Begin

		select @cnt = (case when max(no) > 0 then max(no)+1  else 1 end) from Stb_MeetingAgenda where date_meeting =@date_meeting
		update Stb_MeetingAgenda set no = @cnt where id =@ID

    Fetch next From c into @ID,@date_meeting
	End
	Close c
	DEALLOCATE  c

	    
	SELECT
	        QIG.ID AS OldID,
	        QIG.ID,
			--convert(varchar,  QIG.Date_Meeting, 120) as Date_Meeting,
			--Dateadd(HOUR, 2 , convert(datetime,QIG.Date_Meeting,120) ) as Date_Meeting,
			dbo.fnGetLocalTime(QIG.Date_Meeting, @pUtcOffset) AS Date_Meeting, -- The varchar type is not controlled by the screen. It must be delivered in date format.
	        QIG.Years,
	        QIG.Months,
	        QIG.Days,
	        QIG.No,
	        QIG.Meeting_Agenda,
			QIG.Customer,
			QIG.Size,
			QIG.RespPlant,
			QIG.RestTeam,
			dbo.fnGetLocalTime(QIG.CompleteDate, @pUtcOffset) AS CompleteDate ,
			QIG.Status,
			QIG.CreateDateTime,
	        QIG.CreateUserID,
	        QIG.ChangeDateTime,
	        QIG.ChangeUserID
	FROM
	        Stb_MeetingAgenda QIG WITH(NOLOCK)
	WHERE
	        --((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
			(@pYears is null or QIG.years = @pYears)
			and (@pDate_Meeting is null or QIG.Date_Meeting between @pDate_Meeting and GETDATE())
			and (@pMonths is null or QIG.months = @pMonths)
			and (@pDays is null or QIG.days =@pdays)
			and (@pMeetingAgenda is null or @pMeetingAgenda='' or QIG.meeting_agenda like  '%'+@pMeetingAgenda+'%')
			and (@pCustomer is null or @pCustomer='' or QIG.Customer = @pCustomer)
			and (@pSize is null or QIG.Size = @pSize)
			and (@pStatus is null or QIG.Status = @pStatus)
			and (@pID is null or QIG.ID = @pID)
			order by Date_Meeting, no
END


