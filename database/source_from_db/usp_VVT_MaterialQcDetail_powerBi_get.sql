
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
--   usp_VVT_MaterialQcDetail_powerBi_get '','','','2022-01-01','2022-01-31'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_MaterialQcDetail_powerBi_get]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = NULL,
								@pFromDate  DATETIME =null,
								@pToDate  DATETIME =null
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @Barcode         VARCHAR(20) 
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(60)  -- 2021.11.28
    
	SELECT  @Barcode = Barcode
	         , @MaterialCode = MaterialCode  -- 2021.11.28
	  FROM STB_SetInfo
	WHERE LotNumber  = @MaterialQcNo

	SELECT @CompanyCode = CompanyCode ,  
			@MaterialCode = isnull(MaterialCode,@MaterialCode)
	  FROM STB_MaterialQcInfo
	 WHERE MaterialQcNo = @MaterialQcNo

			--	SELECT   Barcode, LotNumber, *
			--  FROM STB_SetInfo
			--WHERE LotNumber  = '20092100004'




	     	SELECT
				MQD.MaterialQcNo AS OldMaterialIqcNo,
				MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
				MQD.MaterialQcNo,
				MQD.MaterialQcDetailNo,
				MQD.QcInspectionGroupCode,
				MQD.QcInspectionGroupName,
				MQD.QcInspectionGroupDesc,
				MQD.QcInspectionItemCode,
				MQD.QcInspectionItemName,
				MQD.QcInspectionItemDesc,
				MQD.GroupInspectionPrior,
				MQD.GroupReportPrior,
				MQD.ItemInspectionPrior,
				MQD.ItemReportPrior,
				MQD.QcSpecDesc,
				MQD.InspectionType,
				MQD.IsMaterialSpec,
				MQD.InspectionLevel,
				MQD.AQL,
				MQD.RequestSampleQty,
				MQD.MaxAcceptDefectQty,				
				MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
				MQD.PassedSampleQty,
				MQD.DefectSampleQty,
				MQD.SkipSampleQty,
				MQD.SpecValue,
				MQD.USL,
				--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
				MQD.LSL,
				MQD.UCL,
				MQD.LCL,
				MQD.TextSpecValue,
				MQD.DecisionResult,
				MQD.CreateDateTime,
				MQD.CreateUserID,
				MQD.ChangeDateTime,
				MQD.ChangeUserID
				,mqi.MaterialCode  --add by Mr.Tung on 18-Jan-2022
		FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
		join STB_MaterialQcInfo mqi WITH(NOLOCK) on MQD.MaterialQcNo=mqi.MaterialQcNo
		WHERE 1=1
			 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
			 and MQD.CreateDateTime between @pFromDate and @pToDate
			 and mqi.InspectionDocType='IQC'
			 and mqi.CompanyCode='VVT'
		--ORDER BY ItemReportPrior ASC

	
 
END
