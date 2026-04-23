-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2020-07-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_MasterProductionScheduleInfo_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pSalesRegionCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE,
	@pMaterialCode VARCHAR(20) = NULL,
	@pProductSizeCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @SalesRegionCode VARCHAR(20) = CASE WHEN ISNULL(@pSalesRegionCode, '') = '' THEN '*' ELSE @pSalesRegionCode END
	       ,@FromDate DATE = dbo.fnGetFirstDayOfMonth (@pFromDate)
		   ,@ToDate DATE = dbo.fnGetLastDayOfMonth (@pToDate)
		   ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@ProductSizeCode VARCHAR(20) = CASE WHEN ISNULL(@pProductSizeCode, '') = '' THEN '*' ELSE @pProductSizeCode END

	SELECT MPSI.MasterProductionScheduleNo
	      ,MPSI.BaseYearMonth
          ,MPSI.SalesRegionCode
		  ,BC.Description AS SalesRegionName
		  ,MPSI.CustomerCode 
		  ,CI.CustomerName
		  ,CONVERT(DATE, MPSI.CreateDateTime) AS CreateDateTime
          ,MPSI.SalesDate
          ,MPSI.MaterialCode
		  ,MBI.ModelName AS MaterialName
		  ,MBI.MaterialSpec
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MBI.MBIExtText06 
		        ELSE MBI.ModelCode END AS SingleCellMaterialCode
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MBI.SingleCellMaterialName 
		        ELSE MBI.ModelName END AS SingleCellMaterialName
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MBI.SingleCellMaterialSpec
		        ELSE MBI.MaterialSpec END AS SingleCellMaterialSpec
		  ,MBI.ProdSize
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN 'MODULE'
		        WHEN MBI.MaterialTypeCode <> 'MDL' AND MBI.MBISizeW IN (8, 10) THEN '소형'
				WHEN MBI.MaterialTypeCode <> 'MDL' AND MBI.MBISizeW IN (13, 16, 18) THEN '중형'
				WHEN MBI.MaterialTypeCode <> 'MDL' AND MBI.MBISizeW > 18 THEN '대형'
				ELSE '기타' END AS MaterialSizeType
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MBI.MBIExtInt01
		        ELSE 1 END AS UsedQty
		  ,MPSI.MaterialOrderQty
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MPSI.MaterialOrderQty * ISNULL(MBI.MBIExtInt01, 1)
		        ELSE MPSI.MaterialOrderQty END AS TotSingleCellQty
		  ,MPSI.ContactWorkerCode
		  ,EI.EmployeeName AS ContactWorkerName
          ,MPSI.CreateUserID
          ,MPSI.ChangeDateTIme
          ,MPSI.ChangeUserID
		  ,(SELECT COUNT(*) 
		      FROM STB_MasterProductionScheduleInfoHist 
			 WHERE MasterProductionScheduleNo = MPSI.MasterProductionScheduleNo 
			   AND ActionMethodCode = 'UPDATE') AS IsUpdate
		  ,MPSI.OrderTypeCode
		  ,BC2.Description AS OrderTypeName
	  FROM STB_MasterProductionScheduleInfo MPSI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = MPSI.SalesRegionCode
	   AND BC.CodeGroup = 'SalesRegionCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.ItemCode = MPSI.OrderTypeCode
	   AND BC2.CodeGroup = 'OrderTypeCode'
	  LEFT OUTER JOIN (
			SELECT
					MBI.ModelCode,
					MBI.ModelName, 
					dbo.fnGetMaterialSpec(MBI.ModelCode) AS MaterialSpec,
					MBI.MaterialTypeCode,
					MBI.MBIExtInt01,
					MBI.MBIExtText06,
					MM.MaterialName AS SingleCellMaterialName,
					dbo.fnGetMaterialSpec(MBI.MBIExtText06) AS SingleCellMaterialSpec,
					CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN 'MODULE'
					     ELSE  RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
									 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) 
									 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END 
					END AS ProdSize,
					MBI.MBISizeW
			FROM
					VW_ModelBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM
			  ON MBI.MBIExtText06 = MM.MaterialCode
	  ) MBI
	  ON MBI.ModelCode = MPSI.MaterialCode
	LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	  ON EI.EmployeeNo = MPSI.ContactWorkerCode
	LEFT OUTER JOIN STB_CustomerInfo CI
	  ON CI.CustomerCode = MPSI.CustomerCode
   WHERE (@SalesRegionCode = '*' OR MPSI.SalesRegionCode = @SalesRegionCode)
     AND (@MaterialCode = '*' OR MPSI.MaterialCode = @MaterialCode)
	 AND (@ProductSizeCode = '*' OR MBI.ProdSize LIKE '%' + @ProductSizeCode + '%')
	 AND MPSI.BaseYearMonth BETWEEN @FromDate AND @ToDate
	          
END