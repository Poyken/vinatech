CREATE proc [dbo].[usp_vn_checkatt_time] -- exec usp_vn_checkatt_time '32009001'
@EMPLOYEES_ID nvarchar(50)
as
begin

SELECT
			ID,
			EMPLOYEES_ID,
			EMPLOYEES_NAME,
			NAME_LINE,
			WORK_DATE,
			START_TIME,
			CREATEDATETIME,
			CREATEBY
			
		FROM
				STB_VN_ATTENDANCE_TIME WITH(NOLOCK)

		WHERE
				EMPLOYEES_ID = @EMPLOYEES_ID AND   END_TIME IS NULL  AND ENDSTATUS IS NULL

	
end

--   select * from STB_VN_ATTENDANCE_TIME where EMPLOYEES_ID = '32009001'
 -- select * from STB_VN_ATTENDANCE_TIME where employees_id = '32009001' and STARTSTATUS = N'Thời gian bắt đầu'
--	delete STB_VN_ATTENDANCE_TIME   where employees_id = '32009001' and STARTSTATUS = N'Thời gian bắt đầu'

