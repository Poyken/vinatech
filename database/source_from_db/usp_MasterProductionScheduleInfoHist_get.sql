-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2020-07-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_MasterProductionScheduleInfoHist_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pMasterProductionScheduleNo VARCHAR(20)
AS
BEGIN
	Declare @MasterProductionScheduleNo VARCHAR(20) = CASE WHEN ISNULL(@pMasterProductionScheduleNo, '') = '' THEN '*' ELSE @pMasterProductionScheduleNo END
	       
	SELECT MPSIH.ActionMethodCode
	      ,MPSIH.MasterProductionScheduleNo
	      ,MPSIH.BaseYearMonth
          ,MPSIH.SalesRegionCode
		  ,BC.Description AS SalesRegionName
		  ,MPSIH.CustomerCode 
		  ,CI.CustomerName
		  ,CONVERT(DATE, MPSIH.CreateDateTime) AS CreateDateTime
          ,MPSIH.SalesDate
          ,MPSIH.MaterialCode
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
		  ,MPSIH.MaterialOrderQty
		  ,CASE WHEN MBI.MaterialTypeCode = 'MDL' THEN MPSIH.MaterialOrderQty * ISNULL(MBI.MBIExtInt01, 1)
		        ELSE MPSIH.MaterialOrderQty END AS TotSingleCellQty
		  ,MPSIH.ContactWorkerCode
		  ,EI.EmployeeName AS ContactWorkerName
          ,MPSIH.CreateUserID
          ,MPSIH.ChangeDateTIme
          ,MPSIH.ChangeUserID
		  ,(SELECT COUNT(*) 
		      FROM STB_MasterProductionScheduleInfoHist 
			 WHERE MasterProductionScheduleNo = MPSIH.MasterProductionScheduleNo 
			   AND ActionMethodCode = 'UPDATE') AS IsUpdate
		  ,MPSIH.OrderTypeCode
		  ,BC2.Description AS OrderTypeName
	  FROM STB_MasterProductionScheduleInfoHist MPSIH
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = MPSIH.SalesRegionCode
	   AND BC.CodeGroup = 'SalesRegionCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.ItemCode = MPSIH.OrderTypeCode
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
	  ON MBI.ModelCode = MPSIH.MaterialCode
	LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	  ON EI.EmployeeNo = MPSIH.ContactWorkerCode
	LEFT OUTER JOIN STB_CustomerInfo CI
	  ON CI.CustomerCode = MPSIH.CustomerCode
   WHERE MPSIH.MasterProductionScheduleNo = @MasterProductionScheduleNo
   ORDER BY MPSIH.MasterProductionScheduleHistNo
END