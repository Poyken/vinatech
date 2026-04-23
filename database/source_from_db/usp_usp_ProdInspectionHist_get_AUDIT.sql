
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가
--            2020-09-14 
--            2020-10-06 일괄업로드 데이터의 바코드 표시를 위해 변경 By Jackaroe #201006
--            2021-07-19 Mr.Tung change WHERE condition to  @CommInspTypeCode
--            2021-12-27 점도 추가 이미정 차장 요청 by Jackaroe


-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_usp_ProdInspectionHist_get_AUDIT]
					@pProcessUserID     VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pFromDate          DATETIME,
					@pToDate			  DATETIME,
					@pMaterialQcNo     VARCHAR(20) = NULL,
					@pQcInspectionItemCode VARCHAR(20) = NULL,
					@pBarcode			  VARCHAR(20) = NULL,
					@pCompanyCode    VARCHAR(20) = NULL,                                         -- 사업장 추가 (2019.12.22, kilee)
					@pSizeCode           VARCHAR(20) = NULL,                                         -- 사이즈 추가 (2020.01.07, kilee)
					@pDecisionResult      VARCHAR(20) = NULL                                        -- 판정결과 추가 -> 이미정님 요청 (2021.04.30, kilee)
AS

BEGIN
	SET NOCOUNT ON;
	   Declare @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
			Declare @FromDate               DATETIME     = @pFromDate
		     ,@ToDate                   DATETIME     = @pToDate
		     ,@MaterialQcNo           VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
		     ,@QcInspectionItemCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
		     ,@Barcode				    VARCHAR(20) = @pBarcode
		     ,@SizeCode				    VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '*' ELSE  @pSizeCode  END
			 --,@DecisionResult        VARCHAR(20) =  @pDecisionResult     --  kilee 추가 - 이미정추가 (2021.04.30)
			  ,@DecisionResult        VARCHAR(20) =  CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '*' ELSE @pDecisionResult END  --  kilee 추가 - 이미정추가 (2021.04.30)

 select * from STB_MaterialQcInfo_audit


  	--delete from STB_MaterialQcInfo_audit where id = 8581
END

