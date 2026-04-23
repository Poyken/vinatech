-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-07
-- Browsable : true
-- Group : 품질관리 > 제품검사(Lot No)
-- Description:	Vietnam FOQC 출하검사 관리 화면을 조회합니다.

--  exec  usp_Vietnam_GetMaterialFOQCInfo  '','','','','','','','2021-08-30','2021-09-15','e'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetMaterialAgingInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	--@pFromDate DATE = NULL,
	--@pToDate DATE = NULL,
	@pDecisionResult VARCHAR(10) = NULL,
	@pBarCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pProdInspWorkerCode VARCHAR(20) = NULL ,

	@pDecisionFromDate DATE = null,
	@pDecisionToDate DATE = null,
	@pNotPassOQC  VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%'          ELSE @pMaterialCode   END
	--DECLARE @FromDate DATE                = CASE WHEN @pFromDate IS NULL              THEN GETDATE() ELSE @pFromDate       END
	--DECLARE @ToDate DATE                   = CASE WHEN @pToDate IS NULL                 THEN GETDATE() ELSE @pToDate          END

	DECLARE @DecisionResult VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = ''   THEN '*'  ELSE @pDecisionResult END 
	DECLARE @BarCode        VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''        THEN '%'           ELSE @pBarCode        END 
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'            ELSE @pCompanyCode END  --2019.12.25 추가
	DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END

	--DECLARE @DecisionFromDate DATE = CASE WHEN @pDecisionFromDate IS NULL THEN GETDATE()-10 ELSE @pDecisionFromDate END   -- 판정일시 조건추가 (이미정, 2020-09-14)
	--DECLARE @DecisionToDate    DATE = CASE WHEN @pDecisionToDate     IS NULL THEN GETDATE() ELSE @pDecisionToDate    END
	
	DECLARE @DecisionFromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pDecisionFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @DecisionToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pDecisionToDate)), 121) + ' 23:59:59'     -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	
	if (@DecisionFromDate<'2020-04-07 00:00:00')
	begin
		select @DecisionFromDate = '2020-04-07 10:30:00' --this is the Date which FOQC beginning
	end


	DECLARE @CharFOQC VARCHAR(1)='A';


	if(@pNotPassOQC is not null and @pNotPassOQC<>'' and @pNotPassOQC<>'0')
	begin
			SELECT
				'' AS OldMaterialQcNo,
				'' as MaterialQcNo,
				MQI.MaterialQcNo as DisplayMaterialQcNo,
				'OQC' as WIP,
				si.InputDateTime,
				si.ProdFinishDateTime,
				MQI.CompanyCode,
				CI.CompanyName,
				MQI.WorkCenterCode,
				WCI.WorkCenterName,
				MQI.MaterialCode,
				MM.MaterialName,
				MM.MaterialTypeCode,
				MT.BasicMaterialType,
				MT.MaterialTypeName,
				MM.ProductGroupCode,
				PG.ProductGroupName,
				MM.MaterialUnit,
				MM.MaterialSpec,
				MM.MaterialSource,
				MM.BeforeMaterialCode 
			FROM
					STB_MaterialQcInfo MQI WITH(NOLOCK)
					LEFT OUTER JOIN stb_setinfo si  WITH(NOLOCK) on MQI.MaterialQcNo = si.Barcode
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON MQI.WorkCenterCode = WCI.WorkCenterCode
					--LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)	ON MDD.MaterialIqcNo = MQI.MaterialQcNo
					--LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
					--LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
					--LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
					LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
			   --   LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK) ON MVM.MaterialCode = MQI.MaterialCode AND MVM.CustomerCode = MDI.SourceCustomerCode
			WHERE 1=1
					AND (MQI.InspectionDocType = 'OQC') 
					and (MQI.DecisionResult ='None')		
		 return;
	end



----;with newbar as (
----	SELECT  NewBarcode,OldBarcode,AftMaterialCode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----	WHERE OldBarcode in (
----		select replace(MaterialQcNo,'AV','V')  
----		from	STB_MaterialQcInfo  WITH(NOLOCK) 
----		where DecisionResult='Pass' and InspectionDocType='AOQC'
----		and CreateDateTime>=DATEADD(DAY,-10,getdate())
----		)and CreateDateTime>=DATEADD(DAY,-10,getdate())
----	)
----	,
----newbar1 as (
----	select replace(MaterialQcNo,'AV','V') as MaterialQcNo
----	from	STB_MaterialQcInfo  WITH(NOLOCK) 
----	where   replace(MaterialQcNo,'AV','V') in (			
----			SELECT  NewBarcode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----			WHERE OldBarcode in (
----				select replace(MaterialQcNo,'AV','V')  
----				from	STB_MaterialQcInfo  WITH(NOLOCK) 
----				where DecisionResult='Pass' and InspectionDocType='AOQC'
----				and CreateDateTime>=DATEADD(DAY,-10,getdate())
----			)and CreateDateTime>=DATEADD(DAY,-10,getdate())
----		)
----		and MaterialQcNo like 'A%'
----	)
----	,
----newbar2 as (
----		SELECT  NewBarcode,OldBarcode,AftMaterialCode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----		WHERE newbarcode in (
----				select newbarcode from newbar
----				except
----				select MaterialQcNo from newbar1
----			)
----	)
----insert into STB_MaterialQcInfo
----select 
----		'A'+newbar2.NewBarcode as  MaterialQcNo, CompanyCode, WorkCenterCode, InspectionDocType, 
----					newbar2.AftMaterialCode as MaterialCode, 
----					QcQty, InspectionType,  BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty,  ProcessQty, 
----					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty,  DecisionResult,  DecisionDateTime,  DecisionUserID, 
----					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo,  MIIExtText01, MIIExtText02, MIIExtText03, 
----					MIIExtText04, MIIExtText05,  CreateDateTime,  CreateUserID,  ChangeDateTime,  ChangeUserID, IQCSampleLotList
----		from	STB_MaterialQcInfo mqi  WITH(NOLOCK)  
----		 join newbar2 on mqi.MaterialQcNo = 'A'+newbar2.OldBarcode
----		 where mqi.CreateDateTime>=DATEADD(DAY,-10,getdate())




	;with LotPassOQC as (
	SELECT
			@CharFOQC + MQI.MaterialQcNo AS OldMaterialQcNo,
			@CharFOQC + MQI.MaterialQcNo as MaterialQcNo,
			MQI.MaterialQcNo as DisplayMaterialQcNo,
			'AOQC' as WIP,
			si.InputDateTime,
			si.ProdFinishDateTime,
			MQI.CompanyCode,
			CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,
			MQI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			MM.MaterialSpec,
			MM.MaterialSource,
			MM.BeforeMaterialCode			
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			LEFT OUTER JOIN stb_setinfo si  WITH(NOLOCK) on MQI.MaterialQcNo = si.Barcode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON MQI.WorkCenterCode = WCI.WorkCenterCode
			--LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)	ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			--LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			--LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
			--LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
	   --   LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK) ON MVM.MaterialCode = MQI.MaterialCode AND MVM.CustomerCode = MDI.SourceCustomerCode
	WHERE 1=1
			AND (MQI.InspectionDocType = 'OQC') 
			and (MQI.DecisionResult ='Pass')
			--AND (MQI.DecisionResult LIKE @DecisionResult) 
			AND (MQI.MaterialCode LIKE @MaterialCode) 
		--  AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)			                                                                             -- 기존소스백업 From~To (2020.09.14)
			AND (MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND Dateadd(DAY,10,@DecisionToDate) )     

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                                                                                -- CompanyCode 추가 (2019.12.25)
		 -- AND (MQI.MaterialQcNo LIKE @BarCode OR MQI.MaterialQcNo IN (SELECT LotNumber FROM STB_SetInfo WHERE Barcode = @Barcode))   -- 대표Lot로 묶인 제품검사 Lot의 경우 내부 Lot로도 대표 Lot를 조회할 수 있도록 조회조건 수정. 품질부문. 2019.10.28. By Jackaroe (원본백업)
			AND (MQI.MaterialQcNo LIKE  @BarCode 
			  OR  MQI.MaterialQcNo IN (SELECT   LotNumber   FROM STB_SetInfo   WITH(NOLOCK)    WHERE Barcode = @Barcode) 
			  OR  MQI.MaterialQcNo =  (SELECT   NewBarcode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) WHERE OldBarcode = @Barcode ))  
		--AND (@ProdInspWorkerCode = '*' OR MQI.MIIExtText01 = @ProdInspWorkerCode) -- 일단 보류 작업자의 작업방식을 고려하여 수정할 필요가 있음. 2020.05.18 By Jackaroe
	
	UNION  ALL 
	SELECT  
			@CharFOQC + LOTNO AS OldMaterialQcNo, 
			@CharFOQC + LOTNO as MaterialQcNo, 
			LOTNO as DisplayMaterialQcNo, 
			'AOQC' as WIP,
			'' as InputDateTime,
			'' as ProdFinishDateTime,
			@CompanyCode as CompanyCode, 
			'비나텍(베트남)' as CompanyName, 
			'VVT_F1' as WorkCenterCode, 
			'비나텍 베트남공장' WorkCenterName, 
			PARTNO as MaterialCode, 
			PARTNO as MaterialName, 
			'MDL' as MaterialTypeCode, 
			'MODULE' as BasicMaterialType, 
			'모듈' as MaterialTypeName, 
			'HC-EDLC' as ProductGroupCode, 
			'Hy-Cap EDLC' as ProductGroupName, 
			'EA' as MaterialUnit, 
			Size +'-'+	Voltage +'-'+	Farad as MaterialSpec, 
			'' as MaterialSource, 
			'' as BeforeMaterialCode 
	FROM STB_QC_LOTNO_MODULE  QLM  WITH(NOLOCK) 
	where upper(statuspss)='PASS' and @CompanyCode='VVT' AND LOTNO IS NOT NULL
			and LOTNO LIKE  @BarCode 
		)
		select 
			DR.DecisionResultText,
			MQI.QcQty,
			ISNULL(MQI.InspectionType,'SAMPLE') as InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			ISNULL(MQI.DecisionResult,'None') as DecisionResult, 
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			MQI.SpecialAcceptDesc,
			MQI.DescText, 
			MQI.VendorQcReport, 
			MQI.VendorLotNo, 
			MQI.MIIExtText01, 
			MQI.MIIExtText02, 
			MQI.MIIExtText03, 
			MQI.MIIExtText04, 
			MQI.MIIExtText05, 
			MQI.CreateDateTime, 
			MQI.CreateUserID, 
			MQI.ChangeDateTime, 
			MQI.ChangeUserID, 
			--MQI.BasicDate,
			MQI.DecisionDateTime AS DecisionDate,          
			PWI.WorkerName ,
		LPO.*
		from LotPassOQC  LPO WITH(NOLOCK) 
		left outer join STB_MaterialQcInfo MQI WITH(NOLOCK)  on        LPO.MaterialQcNo =  MQI.MaterialQcNo
		LEFT OUTER JOIN VW_DecisionResult DR    WITH(NOLOCK)                  			ON DR.DecisionResult = MQI.DecisionResult
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)                           ON PWI.WorkerCode = MQI.MIIExtText01                 
		where  (@DecisionResult ='*' or (@DecisionResult = 'None' and MQI.DecisionResult is null) or MQI.DecisionResult = @DecisionResult)
END
