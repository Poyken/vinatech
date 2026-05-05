-- Procedure: us_VN_AttendanceTime
CREATE PROC us_VN_AttendanceTime -- EXEC us_VN_AttendanceTime '2021-05-10','2021-05-10'
@pFromDate DATE = NULL
,@pToDate  DATE = NULL
AS
BEGIN
		DECLARE @FromDate DATE = @pFromDate
		DECLARE @ToDate DATE = @pToDate

		SELECT
				EMPLOYEES_ID,
				EMPLOYEES_NAME,
				CODE_LINE,
				line.linename as NAME_LINE,
				CONVERT(DATE,WORK_DATE) AS  WORK_DATE,
				START_TIME,
				END_TIME,
				TOTAL_TIME
		FROM 
			    STB_VN_ATTENDANCE_TIME att WITH(NOLOCK) 
				left join STB_LineInfo line ON att.CODE_LINE = line.linecode
			WHERE 
			 ((@FromDate='' and @ToDate='') OR WORK_DATE between @FromDate and @ToDate)
				AND
				(start_time is not null or end_time is not null)
	
END
GO

