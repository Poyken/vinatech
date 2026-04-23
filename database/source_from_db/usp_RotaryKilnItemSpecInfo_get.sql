-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-05-29
-- Browsable : true
-- Group : 지지체
-- Description:	로터리킬른 가동 항목 스펙 관리 내역 조회
-- Modified:
-- =============================================
CREATE proc [dbo].[usp_RotaryKilnItemSpecInfo_get]
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pMachineCode VARCHAR(20) = NULL
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END

	SELECT RKSI.RotaryKilnItemSpecNo
          ,RKSI.BaseDate
          ,RKSI.MachineCode
		  ,MM.MachineName
          ,RKSI.KilnTemperature
          ,RKSI.RunTime
          ,RKSI.SteamTemperature
          ,RKSI.SpinSpeed
          ,RKSI.WaterVaporPressure
          ,RKSI.CreateDateTime
          ,RKSI.CreateUserID
          ,RKSI.ChangeDateTime
          ,RKSI.ChangeUserID
	  FROM STB_RotaryKilnItemSpecInfo RKSI
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = RKSI.MachineCode
	 WHERE 1=1
	   AND RKSI.BaseDate BETWEEN @FromDate AND @ToDate
	   AND (@MachineCode = '*' OR RKSI.MachineCode = @MachineCode)
END