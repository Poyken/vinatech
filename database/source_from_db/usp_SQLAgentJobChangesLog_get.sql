
-- 이력 생성 및 메일 전송 프로시저
CREATE PROC usp_SQLAgentJobChangesLog_get
AS
BEGIN
    Declare @Delimiter CHAR(1) = CHAR(9)
    Declare @Today DATE = CONVERT(DATE, GETDATE(), 121)
    Declare @Sql NVARCHAR(MAX)

    -- 비교쿼리
    ;WITH CTE AS (
        SELECT A.job_id
              ,C.step_id
              ,A.name
              ,A.owner_sid
              ,A.date_modified
              ,C.command
              ,A.enabled
          FROM msdb.dbo.sysjobs A 
          INNER JOIN msdb.dbo.sysjobsteps C
            ON A.job_id = C.job_id
    )
    INSERT INTO STB_SQLAgentJobChangesLog
    SELECT CONVERT(DATE, GETDATE(), 121)
          ,SJI.name AS name_before
          ,CTE.name AS name_after
          ,SJI.date_modified AS date_modified_before
          ,CTE.date_modified AS date_modified_after
          ,SJI.enabled AS enabled_before
          ,CTE.enabled AS enabled_after
          ,SJI.command AS command_before
          ,CTE.command AS command_after
      FROM CTE
      LEFT OUTER JOIN STB_SystemJobInfo SJI
        ON SJI.job_id = CTE.job_id
       AND SJI.step_id = CTE.step_id
       AND SJI.base_ymd = CONVERT(DATE, DATEADD(day, -1, GETDATE()), 121)
     WHERE (SJI.name <> CTE.name
            OR  SJI.date_modified <> CTE.date_modified
            OR  SJI.command <> CTE.command
            OR  SJI.enabled <> CTE.enabled)

    --IF EXISTS (SELECT 1 FROM STB_SQLAgentJobChangesLog WHERE base_ymd = CONVERT(DATE, GETDATE(), 121)) BEGIN
    --    SET @Sql = 'SELECT * FROM STB_SQLAgentJobChangesLog WHERE base_ymd = @Today'

    --    EXEC msdb.dbo.sp_send_dbmail
    --    @profile_name = 'CMS System',  
    --    @recipients = 'yjyu@vina.co.kr',  
    --    @body = 'SQL Agent변경 내역입니다.',
    --    @query = @Sql,
    --    @execute_query_database = 'SmartFactoryV2',
    --    @attach_query_result_as_file = 1,
    --    @query_result_separator = ',',
    --    @query_attachment_filename = 'result.csv',
    --    @query_result_no_padding = 1,
    --    @subject = 'SQL Agent변경 내역입니다.';
    --END

    -- 실행일 기준 SQL Agent 이력 생성
    INSERT INTO STB_SystemJobInfo
        SELECT GETDATE()
              ,A.job_id
              ,C.step_id
              ,A.name
              ,A.owner_sid
              ,A.date_modified
              ,C.command
              ,A.enabled
              ,GETDATE()
          FROM msdb.dbo.sysjobs A 
          INNER JOIN msdb.dbo.sysjobsteps C
            ON A.job_id = C.job_id
END
