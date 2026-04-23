-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-11-08
-- Browsable : true
-- Group : 품질관리
-- Description:	제품검사 Cpk 계산
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdInspCpkCalc]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20),
	@pMaterialQcDetailNo VARCHAR(20),
	@pLSL NUMERIC(20,5),
	@pUSL NUMERIC(20,5),
	@pQcInspectionItemCode  VARCHAR(30)   -- 추가사항  (2022-04-25)        
AS

BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	        , @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo
		    , @DataAvg NUMERIC(20,5)
		    , @DataStdev NUMERIC(20,5)
		    , @DataLSL NUMERIC(20,5) = @pLSL
		    , @DataUSL NUMERIC(20,5) = @pUSL
		    , @Cpk NUMERIC(20,2)
		    , @QcInspectionItemCode VARCHAR(30)      =     @pQcInspectionItemCode                           -- 추가사항  (2022-04-25)        

	SELECT @DataAvg = AVG(TestValue)
	         ,@DataStdev = STDEV(TestValue)
	  FROM STB_MaterialQcSampleResult
	 WHERE MaterialQcNo = @MaterialQcNo
	   AND MaterialQcDetailNo = @MaterialQcDetailNo


	    IF @QcInspectionItemCode = 'PQC_V01_09' Begin		
			Select @Cpk = dbo.fnGetCpk(@DataAvg, @DataStdev, @DataLSL, @DataUSL )     -- 추가사항  (2022-04-25), 용량
        End Else IF @QcInspectionItemCode = 'PQC_V01_01' Begin
			Select @Cpk = dbo.fnGetCpk(@DataAvg, @DataStdev, @DataLSL, 8.4 )     -- 추가사항  (2022-05-09), D치수
        End Else Begin
			SELECT @Cpk = dbo.fnGetCpk(@DataAvg, @DataStdev, @DataLSL, @DataUSL)
		End

	UPDATE STB_MaterialQcDetail
	   SET Cpk = @Cpk
	 WHERE MaterialQcNo = @MaterialQcNo
	   AND MaterialQcDetailNo = @MaterialQcDetailNo

END