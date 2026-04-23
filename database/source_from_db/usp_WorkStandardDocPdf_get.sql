-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-12
-- Browsable : true
-- Group : 생산관리
-- Description:	작업표준서 PDF 조회
-- Modified:
-- =============================================
CREATE PROC usp_WorkStandardDocPdf_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pWorkStandardDocNo VARCHAR(20) = NULL
AS
BEGIN
	Declare @WorkStandardDocNo VARCHAR(20) = @pWorkStandardDocNo

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
	   AND WSDI.WorkStandardDocNo = @WorkStandardDocNo

END