-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 기록물관리
-- Browsable : true
-- Create date : 2019-10-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocManagementInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFactoryCode VARCHAR(20) = NULL,
	@pProcessCode VARCHAR(20) = NULL,
	@pProductCode VARCHAR(20) = NULL,
	@pContentsCode VARCHAR(20) = NULL,
	@pDocSummaryContents VARCHAR(MAX) = NULL
AS

BEGIN
	Declare @FactoryCode VARCHAR(20)         = CASE WHEN ISNULL(@pFactoryCode , '') = '' THEN '%' ELSE @pFactoryCode END
		   ,@ProcessCode VARCHAR(20)         = CASE WHEN ISNULL(@pProcessCode , '') = '' THEN '%' ELSE @pProcessCode END
		   ,@ProductCode VARCHAR(20)         = CASE WHEN ISNULL(@pProductCode , '') = '' THEN '%' ELSE @pProductCode END
		   ,@ContentsCode VARCHAR(20)        = CASE WHEN ISNULL(@pContentsCode, '') = '' THEN '%' ELSE @pContentsCode END
		   ,@DocSummaryContents VARCHAR(MAX) = CASE WHEN ISNULL(@pDocSummaryContents, '') = '' THEN '%' ELSE @pDocSummaryContents END



	SELECT DMI.DocManagementCode
          ,DMI.FactoryCode
		  ,DFI.FactoryName
          ,DMI.ProcessCode
		  ,DPI.ProcessName
          ,DMI.ProductCode
		  ,DPI2.ProductName
          ,DMI.ContentsCode
		  ,DCI.ContentsName
--          ,DMI.DocFileName
          ,DMI.DocCreateWorkerCode
		  ,EI.EmployeeName AS DocCreateWorkerName
          ,DMI.DocSummaryContents
          ,DMI.CreateDateTime
          ,DMI.CreateUserID
          ,DMI.ChangeDateTime
          ,DMI.ChangeUserID
	  FROM STB_DocManagementInfo DMI
	  LEFT OUTER JOIN STB_DocFactoryInfo DFI
	    ON DMI.FactoryCode = DFI.FactoryCode
	  LEFT OUTER JOIN STB_DocProcessInfo DPI
	    ON DPI.ProcessCode = DMI.ProcessCode
	  LEFT OUTER JOIN STB_DocProductInfo DPI2
	    ON DPI2.ProductCode = DMI.ProductCode
	  LEFT OUTER JOIN STB_DocContentsInfo DCI
	    ON DCI.ContentsCode = DMI.ContentsCode
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	    ON DMI.DocCreateWorkerCode = EI.EmployeeNo
	 WHERE 1=1
	   AND DMI.FactoryCode LIKE @FactoryCode
	   AND DMI.ProcessCode LIKE @ProcessCode
	   AND DMI.ProductCode LIKE @ProductCode
	   AND DMI.ContentsCode LIKE @ContentsCode
	   AND (DMI.DocSummaryContents IS NULL OR  
	            DMI.DocSummaryContents LIKE '%' + @DocSummaryContents + '%')
	 ORDER BY DMI.CreateDateTime
END