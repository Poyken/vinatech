-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-10
-- Description:	Add Measurement control remind mail
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddMeasurementControlRemindMail] 
	-- Add the parameters for the stored procedure here
						--@pProcessUserID VARCHAR(20),
						--@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
            @ToAddress VARCHAR(MAX) = 'vvqa01@vina.co.kr;vvqa02@vina.co.kr;vvqa07@vina.co.kr',       --vvqa01@vina.co.kr;vvqa02@vina.co.kr;vvqa07@vina.co.kr
			@CcAddress VARCHAR(MAX) = 'vvea02@vina.co.kr',
			@EmailBody NVARCHAR(MAX) = NULL,
			--@MailSubject NVARCHAR(500) = '[Reminder] Periodic Equipment Calibration Check'
			@MailSubject NVARCHAR(500) = '[Reminder] Equipment Calibration Check'

	
    -- Lấy danh sách những máy vẫn còn đang chạy và hạn sử dụng còn 30 ngày
    DECLARE @countCheck INT  = 0
    SELECT @countCheck = COUNT(*) 
            from STB_MeasurementControlList_VVT
            where [Status] NOT LIKE '폐기%'
            AND DATEDIFF(DAY, GETDATE(), ExpiredDate) <= 30   
            and DATEDIFF(DAY, GETDATE(), ExpiredDate) >= 0

    IF @countCheck > 0
        BEGIN
	        SET @EmailBody =
                            N'<style>
                                table {border-collapse: collapse; width: 100%; font-family: Arial, sans-serif;}
                                th {background-color: #4CAF50; color: white; padding: 8px; text-align: left;}
                                td {border: 1px solid #ddd; padding: 20px;}
                                tr:nth-child(even) {background-color: #f2f2f2;}
                             </style>' +
                            N'<h3>⚠️ Nhắc nhở: Danh sách thiết bị sắp đến hạn hiệu chuẩn</h3>' +
                            N'<p>Dưới đây là danh sách các thiết bị sắp đến hạn hiệu chuẩn (≤ 30 ngày):</p>' +
                            N'<table width="1100" cellspacing="1" cellpadding="1" border="1">' +
                            N'      <colgroup>' +
                            N'        <col width="10%"><col width="15%"><col width="15%"><col width="10%"><col width="15%"><col width="10%"><col width="15%"><col width="10%"> ' +
                            N'      </colgroup>' +
                            N'<tr>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>관리 번호 <br/>(Serial No.)</b></th>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>계측기명 <br/>(Measurement name)</b></th>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>자산 관리 번호<br/>(Management No)</b></th>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>모델명 <br/>(Model Name)</b></th>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>배정 위치<br/>(Set Location)</b></th>
                                <th valign="top" align="center" bgcolor="#ccccff"><b>담당<br/>(PIC)</b></th>
                                <th valign="middle" align="center" vertical-align="middle" bgcolor="#ccccff"><b>Factory</b></th>
                                <th valign="middle" align="center" vertical-align="middle" bgcolor="#ccccff"><b>Expired date</b></th>
                             </tr>' +

                            -- Nhúng dữ liệu từ bảng SQL vào HTML
                           
                            CAST ( (
                                SELECT
                                    'padding-left: 4px;' AS [td/@style],                                    
                                    td = SerialNo,       '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = MeasurementNameE,     '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = ManagementNo,     '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = ModelName,        '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = SetLocation,    '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = PIC,    '', 
                                    'padding-left: 4px;' AS [td/@style],
                                    td = WorkCenterName,    '', 
                                    'text-align: center;' AS [td/@style],
                                    td = ExpiredDate -- Cột 5
                                FROM (
                                    -- Dữ liệu 
                                    Select  MCL.SerialNo,
                                            MCL.MeasurementNameE,
                                            MCL.ManagementNo,
                                            MCL.ModelName,
                                            MCL.SetLocation,
                                            MCL.PIC,
                                            WCI.WorkCenterName,
                                            MCL.ExpiredDate
                                    FROM STB_MeasurementControlList_VVT MCL WITH(NOLOCK)
                                    LEFT JOIN STB_WorkCenterInfo WCI ON WCI.WorkCenterCode = MCL.WorkCenterCode
                                    where MCL.[Status] NOT LIKE '폐기%' AND
                                        DATEDIFF(DAY, GETDATE(), MCL.ExpiredDate) <= 30   and 
                                        DATEDIFF(DAY, GETDATE(), MCL.ExpiredDate) >= 0
                                    
                                ) AS List
                                ORDER BY ExpiredDate asc
                                FOR XML PATH('tr'), TYPE
                            ) AS NVARCHAR(MAX) ) +

                            N'</table>' +
                            N'<br><p>Vui lòng kiểm tra chi tiết tại màn hình H101.<br>Trân trọng,<br><b>MES System</b></p>';
            END
       
    IF (ISNULL(@EmailBody, '') <> '' )
        BEGIN
            INSERT INTO [110.11.27.5].SmartFactoryV2.dbo.STB_MeasurementControlRemindMail (ToAddress, CcAddress, MailSubject, MailContents)
						    SELECT @ToAddress
							      ,@CcAddress
							      ,@MailSubject
							      ,@EmailBody
        END
    
END
