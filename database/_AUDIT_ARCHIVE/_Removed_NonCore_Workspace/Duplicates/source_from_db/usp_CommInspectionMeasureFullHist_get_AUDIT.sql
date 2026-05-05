-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리/생산관리
-- Browsable : true
-- Create date : 2019-11-06
-- Description : 
-- Modified :

-- Test : usp_CommInspectionMeasureFullHist_get 'kilee','Korean','VNT','VNT_F1','ROUTE_QUALITY,ROUTE_QUALITY2','2020-04-01 00:00:00','2020-08-04 00:00:00',default,default,'VJKM253R033501',''
--        usp_CommInspectionMeasureFullHist_get @pProcessUserID='kilee2',@pProcessLanguage='Korean',@pCompanyCode='VNT',@pWorkCenterCode=default,@pCommInspTypeCode='ROUTE_QUALITY,ROUTE_QUALITY2',@pFromDate='2020-04-23 00:00:00',@pToDate='2020-05-06 00:00:00',@pMaterialCode=default,@pCommInspItemCode=default,@pBarcode='VJKM253r033501',@pLineCode=default
--        usp_CommInspectionMeasureFullHist_get 'kilee','Korean','VNT','VNT_F1', 'ROUTE_QUALITY,ROUTE_QUALITY2' ,'2020-04-01 00:00:00','2020-08-04 00:00:00',default,default,'',''

--       exec usp_CommInspectionMeasureFullHist_get 'kilee', 'Korean', 'VVT' , 'VVT_F1', 'ROUTE_TEST'     ,'2020-04-01 00:00:00','2020-08-04 00:00:00', default, default,'',''

-- exec usp_CommInspectionMeasureFullHist_get 'kilee','Korean','VVT','VVT_F1','ROUTE_QUALITY','2020-04-01 00:00:00','2020-08-04 00:00:00','','','','',''

-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_CommInspectionMeasureFullHist_get_AUDIT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pCommInspTypeCode VARCHAR(100) = NULL,
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pMaterialCode VARCHAR(20) = NULL,
						@pCommInspItemCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL, 
						@pLineCode VARCHAR(20) = NULL,
						@pSizeCode VARCHAR(20) = NULL

		
AS

BEGIN
select * from STB_CommInspMeasureHist_audit 
END