-- Procedure: usp_CostGroupWorkerMappingHist_get_210727
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020-01-23
-- Description : 
-- Modified : 
--                 2021.07.23 근무조코드랑 명칭 문제 (채민수님)
-- usp_CostGroupWorkerMappingHist_get '','','VNT','VNT_F1','2021-07-16 00:00:00','2021-07-16 23:59:59'
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupWorkerMappingHist_get_210727]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE,
	@pWorkerCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@WorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkerCode, '') = '' THEN '*' ELSE @pWorkerCode END

	SELECT A.JobDate AS OldJobDate
	      ,A.WorkerCode AS OldWorkerCode
		  ,A.CostGroupSeq AS OldCostGroupSeq
		  ,A.CostGroupCode AS OldCostGroupCode
	      ,A.JobDate
	      ,A.WorkerCode
		  ,A.WorkerName
		  ,A.CostGroupSeq
		  ,A.CostGroupCode
		  ,A.CostGroupName
		  ,CASE WHEN RTRIM(ISNULL(A.SupportCostGroupCode, '')) = '' THEN A.CostGroupCode ELSE A.SupportCostGroupCode END AS SupportCostGroupCode
		  ,CASE WHEN RTRIM(ISNULL(A.SupportCostGroupName, '')) = '' THEN A.CostGroupName ELSE A.SupportCostGroupName END AS SupportCostGroupName
		  ,A.WorkGroupCode
		  ,A.WorkGroupName
		  ,A.ShiftCode
		  ,A.ShiftName
		  ,A.WorkTypeCode
		  ,A.WorkTypeName
		  ,A.ApplyTime
		  ,A.LineCode
		  ,A.JobStartDateTime
		  ,A.LineName
		  ,A.JobEndDateTime
		  ,A.WeekdayName
		  ,A.AbnormalContents
		  ,A.Late
		  ,A.LeaveEarly
		  ,A.Extend
		  ,A.Night
		  ,A.SpecialWork
		  ,A.SpecialWorkExtend
		  ,CASE WHEN A.BasicWorkTime IS NULL AND A.AbnormalContents = '정상' AND MinSeq = 1  THEN 8 - ISNULL(A.Late,0) - ISNULL(A.LeaveEarly,0)
		        WHEN A.BasicWorkTime IS NULL AND A.AbnormalContents <> '정상' THEN 0
		        ELSE A.BasicWorkTime END  AS BasicWorkTime
		  ,CASE WHEN (A.ApplyTime = 0 OR A.ApplyTime IS NULL) AND A.MinSeq = 1 THEN 
				  CASE WHEN A.SpecialWork > 0 THEN A.SpecialWork + A.SpecialWorkExtend 
						ELSE CASE WHEN A.BasicWorkTime IS NULL AND A.AbnormalContents = '정상'  THEN 8 - ISNULL(A.Late,0) - ISNULL(A.LeaveEarly,0)
								  WHEN A.BasicWorkTime IS NULL AND A.AbnormalContents <> '정상' THEN 0
								  ELSE A.BasicWorkTime END + A.Extend
						END 
				 WHEN (A.ApplyTime = 0 OR A.ApplyTime IS NULL) AND A.MinSeq <> 1  THEN 0
				 WHEN A.ShiftCode = 3 OR ISNULL(A.JobStartDateTime, '') = '' THEN 0 
				 ELSE A.ApplyTime END
			AS WorkTimeHour
		  ,A.CreateDateTime
		  ,A.CreateUserID
		  ,A.ChangeDateTime
		  ,A.ChangeUserID
		  ,A.Remark
		  ,A.CostGroupRemark
	  FROM (
		SELECT CGWMH.JobDate
			  ,CGWMH.WorkerCode
			  ,PWI.WorkerName
			  ,CGWMH.CostGroupSeq
			  ,CGWMH.CostGroupCode
			  ,CGI.CostGroupName
			  ,DWG.WorkGroupCode    -- 원본백업
			 -- ,DWG.WorkGroupName  -- 원본수정 (2021.07.23 kangs)
			 , BC3.Description AS WorkGroupName
			  ,DWG.ShiftCode
			  ,BC.Description AS ShiftName
			  ,CGI.LineCode
			  ,LI.LineDesc AS LineName
			  ,CASE WHEN RTRIM(DailyWorkData.출근시) <> '' AND RTRIM(DailyWorkData.출근분) <> ''
				       THEN CONVERT(VARCHAR(10), DailyWorkData.출근일자, 121) + ' ' + DailyWorkData.출근시 + ':' + DailyWorkData.출근분 + ':00' END AS JobStartDateTime
			  ,CASE WHEN RTRIM(DailyWorkData.퇴근시) <> '' AND RTRIM(DailyWorkData.퇴근분) <> ''
				        THEN CONVERT(VARCHAR(10), DailyWorkData.퇴근일자, 121) + ' ' + DailyWorkData.퇴근시 + ':' + DailyWorkData.퇴근분 + ':00' END AS JobEndDateTime
			  ,DATENAME (WEEKDAY, CGWMH.JobDate) AS WeekdayName
			  ,RTRIM(CASE WHEN ISNULL(DailyWorkData.사고내용,'') = '' THEN 
						(CASE WHEN (DailyWorkData.지각>0)AND(DailyWorkData.조퇴=0) THEN '지각' 
							  WHEN (DailyWorkData.조퇴>0) THEN '조퇴' ELSE '' END)
					ELSE (SELECT X.[NAME] FROM ERPSVR.ERPDB.DBO.NAMEREF X WHERE X.NMGBN = '사고내용' AND X.NMCD = DailyWorkData.사고내용)
					END) AS AbnormalContents
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.지각 ELSE 0 END AS Late
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.조퇴 ELSE 0 END AS LeaveEarly
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.연장 ELSE 0 END AS Extend
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.야간 ELSE 0 END AS Night
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.특근 ELSE 0 END AS SpecialWork
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN DailyWorkData.특근연장 ELSE 0 END  AS SpecialWorkExtend
			  ,CGWMH.CreateDateTime
			  ,CGWMH.CreateUserID
			  ,CGWMH.ChangeDateTime
			  ,CGWMH.ChangeUserID
			  ,DailyWorkData.비고 AS Remark
			  ,CGWMH.BasicWorkTime
			  ,CGWMH.SupportCostGroupCode
			  ,CGI2.CostGroupName AS SupportCostGroupName
			  ,CGWMH.WorkTypeCode
			  ,BC2.Description AS WorkTypeName
			  ,CGWMH.ApplyTime
			  ,CGWMH.CostGroupRemark
			  ,CASE WHEN CGWMH.CostGroupSeq = CGWMHMIN.CostGroupSeq THEN 1 ELSE 0 END AS MinSeq
			  ,CGWMHMIN.TotApplyTime
		  FROM STB_CostGroupWorkerMappingHist CGWMH
		  INNER JOIN STB_CostGroupInfo CGI			ON CGI.CostGroupCode = CGWMH.CostGroupCode
		  LEFT OUTER JOIN STB_CostGroupInfo CGI2		    ON CGI2.CostGroupCode = CGWMH.SupportCostGroupCode
		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			ON PWI.WorkerCode = CGWMH.WorkerCode
		  LEFT OUTER JOIN ERPSVR.ERPDB.DBO.일일근태자료 DailyWorkData			ON DailyWorkData.일자 = CGWMH.JobDate		   AND DailyWorkData.사원번호 = CGWMH.WorkerCode
		  LEFT OUTER JOIN STB_DayWorkGroup DWG			ON CGWMH.WorkerCode = DWG.WorkerCode		   AND CGWMH.JobDate = DWG.JobDate
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		    ON BC.ItemCode = DWG.ShiftCode		   AND BC.CodeGroup = 'TimeShiftCode'
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2		    ON BC2.ItemCode = CGWMH.WorkTypeCode		   AND BC2.codeGroup = 'WorkTypeCode'
		  LEFT OUTER JOIN STB_LineInfo LI 		    ON CGI.LineCode = LI.LineCode
		  LEFT OUTER JOIN (SELECT JobDate
											 ,WorkerCode
											 ,MIN(CostGroupSeq) AS CostGroupSeq
											 ,SUM(ApplyTime) AS TotApplyTime
									FROM STB_CostGroupWorkerMappingHist
								   GROUP BY JobDate, WorkerCode
									) CGWMHMIN
		                                     ON CGWMHMIN.JobDate = CGWMH.JobDate		   AND CGWMHMIN.WorkerCode = CGWMH.WorkerCode

		    LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	     ON BC3.ItemCode = DWG.WorkGroupCode    AND BC3.CodeGroup = 'WorkGroupCode'  -- 2021.07.23 추가
		 WHERE (@CompanyCode = '*' OR CGI.CompanyCode = @CompanyCode)
		   AND (@WorkCenterCode = '*' OR CGI.WorkCenterCode = @WorkCenterCode)
		   AND CGWMH.JobDate BETWEEN @FromDate AND @ToDate
		   AND (@WorkerCode = '*' OR CGWMH.WorkerCode = @WorkerCode)
		   AND CGWMH.IsAssigned = 1
		   AND PWI.IsUsed = 1
	) A
	ORDER BY A.JobDate, A.WorkerCode, A.CostGroupSeq
END
GO

