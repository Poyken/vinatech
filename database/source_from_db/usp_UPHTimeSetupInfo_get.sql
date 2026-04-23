-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-06-18
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROC usp_UPHTimeSetupInfo_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pUtcOffset INT
   ,@pBaseDate DATE
   ,@pLineCode VARCHAR(20) = NULL
   ,@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate
	       ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END
		   ,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END

	SELECT dbo.fnGetLocalTime(UTSI.BaseDate, @pUtcOffset) AS BaseDate
	      ,dbo.fnGetLocalTime(UTSI.BaseDate, @pUtcOffset) AS OldBaseDate
		  ,UTSI.UPHItemCode
		  ,UTSI.UPHItemCode AS OldUPHItemCode
		  ,BC1.Description AS UPHItemName
		  ,UTSI.MachineCode
		  ,UTSI.MachineCode AS OldMachineCode
		  ,MM.MachineName
		  ,UTSI.LineCode
		  ,UTSI.LineCode AS OldLineCode
		  ,LI.LineName
		  ,UTSI.DayWorkTime
		  ,UTSI.RequiredTime
		  ,UTSI.CreateDateTime
		  ,UTSI.CreateUserID
		  ,UTSI.ChangeDateTime
		  ,UTSI.ChangeUserID
	  FROM STB_UPHTimeSetupInfo UTSI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.CodeGroup  = 'UPHItemCode'
	   AND BC1.ItemCode = UTSI.UPHItemCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = UTSI.MachineCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LI.LineCode = UTSI.LineCode
	 WHERE UTSI.BaseDate = @BaseDate
	   AND (@LineCode = '*' OR UTSI.LineCode = @LineCode)
	   AND (@MachineCode = '*' OR UTSI.MachineCode = @MachineCode)
END