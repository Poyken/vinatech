-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2021-11-01
-- Description : 
-- =============================================
CREATE PROCEDURE usp_LineInfo_Dashboard
AS
BEGIN
	SELECT LineCode
		  ,CASE WHEN LineName = '자동중형라인-1840' THEN '자동중형라인' ELSE LineName END AS LineName
		  ,CompanyCode AS COMPANYCODE
	  FROM STB_LineInfo
	 WHERE LineCode IN ('ASSYLINE-05'
					   ,'ASSYLINE-07'
					   ,'ASSYLINE-09'
					   ,'ASSYLINE-10'
					   ,'ASSYLINE-11'
					   ,'ASSYLINE-12'
					   ,'ASSYLINE-13'
					   ,'ELECTRODE LINE'
					   ,'VVC-01'
					   ,'VVC-02'
					   ,'VVC-03'
					   ,'VVC-04'
					   ,'VVC-05'
					   ,'VVC-06'
					   ,'VVC-07'
					   ,'VVC-08'
					   ,'VVC-10'
					   ,'VVC-11'
					   ,'VVC-12'
					   ,'VVC-13'
					   ,'VVC-14'
					   ,'VVC-15'
					   ,'VVC-16'
					   ,'VVC-17'
					   ,'VVC-18'
					   ,'VVC-19'
					   ,'VVMM-01'
					   ,'VVMM-02'
					   ,'VVMM-03'
					   ,'VVMM-04'
					   ,'VVMM-07'
					   ,'VVMM-08'
	)
END