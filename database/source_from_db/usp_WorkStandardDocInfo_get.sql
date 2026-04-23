-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-12
-- Browsable : true
-- Group : 생산관리
-- Description:	작업표준서 조회
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_WorkStandardDocInfo_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pLineCode VARCHAR(20) = NULL
   ,@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END
	       ,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END

	SELECT WSDI.WorkStandardDocNo
          ,WSDI.LineCode 
		  ,LI.LineDesc AS LineName
		  ,WSDI.MachineCode
		  ,MM.MachineName
		  ,WSDI.DocFileNo
		  ,AFM.[FileName]
		  ,AFM.[FileContents] AS FileData
		  ,AFM.FileSize
		  ,AFM.FileExt
          ,WSDI.CreateDateTime
          ,WSDI.CreateUserID
          ,WSDI.ChangeDateTime
          ,WSDI.ChangeUserID
	  FROM STB_WorkStandardDocInfo WSDI
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON WSDI.LineCode = LI.LineCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON WSDI.MachineCode = MM.MachineCode
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	    ON AFM.FileID = WSDI.DocFileNo
	 WHERE 1=1
	   AND (@LineCode = '*' OR WSDI.LineCode = @LineCode)
	   AND (@MachineCode = '*' OR WSDI.MachineCode = @MachineCode)

END