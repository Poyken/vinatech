CREATE PROC [dbo].[usp_VN_Upload_Plan_PowerBI] -- EXEC usp_VN_Upload_Plan_PowerBI '2024-01-31','2024-03-01',''
@pFrom DATETIME = NULL,
@pTo DATETIME = NULL,
@pProcessUserID VARCHAR(20) = NULL
AS


BEGIN

		SELECT
				ID,
				DATEPLAN,
				DATEPLANS,
				MONTHPLAN,
				MODEL,
				GROUPSIZE,
				(SUM(CONVERT(FLOAT, DAILYTARGET))) AS DAILYTARGET,
				REMARK,
				TYPEDATA,
				ISUSED,
				CompanyCode, 
				WorkCenterCode,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID
		FROM

			STB_PLAN_VN WITH(NOLOCK)

		WHERE
				DATEPLANS  BETWEEN @pFrom AND @pTo
				 --AND MONTHPLAN = '12'
				
		GROUP BY ID,
				DATEPLAN,
				DATEPLANS,
				MONTHPLAN,
				MODEL,
				GROUPSIZE,
				REMARK,
				TYPEDATA,
				ISUSED,
				CompanyCode, 
				WorkCenterCode,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID


UPDATE STB_PLAN_VN SET WorkCenterCode = N'Bắc Ninh' WHERE CompanyCode = 'VVT_F1'
UPDATE STB_PLAN_VN SET WorkCenterCode = N'Bắc Giang' WHERE CompanyCode = 'VVT_F2'
END

--alter table STB_PLAN_VN
--add
--	CompanyCode NVARCHAR(50) NULL,
--	WorkCenterCode NVARCHAR(50) NULL

--	SELECT * FROM STB_VN_FINISHGOODS_CAPTURE

-- delete STB_PLAN_VN

--select  (SUM(CONVERT(FLOAT, DAILYTARGET))) AS TOTAL from STB_PLAN_VN where monthplan ='12'

-- select * from  STB_PLAN_VN where monthplan ='1'

-- select * from   STB_PLAN_VN where createuserid ='phuongnt'

-- select *  from   STB_PLAN_VN 

	