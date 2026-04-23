-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-22
-- Browsable : true
-- Group : 생산관리
-- Description: 제품재고정보입력
-- 2021.01.13  제품재고정보(Lot경과일) 추가

-- 프로시저 실행  :  usp_ProductStockInfoUpload_get_20210114 '','','VNT','VNT_F1',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfoUpload_get_20210114]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(20) = NULL
AS

BEGIN

	Declare @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode END
	         , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		     , @MaterialCode      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = ''      THEN '*' ELSE @pMaterialCode END


  	SELECT A.ProductStockNo
			,A.CompanyCode
			,A.CompanyName
			,A.WorkCenterCode
			,A.WorkCenterName
			,A.MaterialCode 
			,A.MaterialName  AS MaterialName
			,A.Barcode
            , Case When Len(A.Day) = 1 then CONCAT(A.Year, A.Month, '0',  A.Day)   
			        When Len(A.Day) = 2  then CONCAT(A.Year, A.Month, A.Day)        Else 0 End as  Lapse 
			--, CONCAT(A.Year, A.Month, A.Day) End as  Lapse

       --,  Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) as  StartDate
      --,  GETDATE()                                                         as EndDate
      -- , DATEDIFF(dd,  Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) , Getdate() )   as Diff

	 , Case When  LEN(Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, '0',  A.Day)  Else   CONCAT(A.Year, A.Month, A.Day) End)  =  8 Then    DATEDIFF(dd,  Convert(Datetime, Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, 0,  A.Day)  else   CONCAT(A.Year, A.Month, A.Day) End) , Getdate() )   
	          else 0 end as Diff
		,A.PackingID
			,A.MaterialWarehouseCode
			,A.MaterialWarehouseName
			,A.MaterialLocationCode
			,A.MaterialLocationName
			,A.PaletteNo
			,A.StockQty
			,A.ManufacturingUnitPrice
			,A.StockPrice
			,A.CreateDateTime
			,A.CreateUserID
			,A.ChangeDateTime
			,A.ChangeUserID

FROM (


-- 기존
					SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode
						
						--   2021.01.13 추가사항
						 ,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN  IsNull(Convert(Varchar(20), SY.Year ), 0 )
								     WHEN LEN(PSI.Barcode) = 15 THEN  IsNull(Convert(Varchar(20), SY.Year), 0 ) End AS Year
                        
						, CASE   WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2))  , 0) 
								   WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73), 2)) , 0)  ELSE null End  AS Month
                      

       --                      --SELECT right('0' + CONVERT(VARCHAR(10), ASCII('K') - 73),2)
							--, Right ('0' + CONVERT(VARCHAR(10), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2)

						--, CASE   WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), (select SM.Month from STB_MonthInfo SM where SM.MonthCode =  SubString(PSI.Barcode, 4, 1)) ), 0) 
						--		   WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), (select SM.Month from STB_MonthInfo SM where SM.MonthCode =  SubString(PSI.Barcode, 5, 1)) ), 0)  ELSE 01 END  AS Month
                      
					   , CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
								  WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE 01 END  AS Day

						  ,PSI.PackingID
						  ,PSI.MaterialWarehouseCode
						  ,MW.MaterialWarehouseName
						  ,PSI.MaterialLocationCode
						  ,ML.MaterialLocationName
						  ,PSI.PaletteNo
						  ,PSI.StockQty
						  ,PSI.ManufacturingUnitPrice
						  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
					 WHERE (@CompanyCode = '*' OR PSI.CompanyCode = @CompanyCode)
					   AND (@WorkCenterCode = '*' OR PSI.WorkCenterCode = @WorkCenterCode)
					   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND LEN(PSI.Barcode)  IN ('14' ,'15')

)   A


END