Text
----
-- =============================================

-- Author:	    Anonymous()

-- Create date: 2016-02-17

-- Browsable : true

-- Group : ????>[C520] ??????? >[C210] ??????  /  [C220] ??? ???? > 1-Tab (??????????)

-- Description : ???? ?? ??? ?????.  Tab1



-- Modified:  2019.07.24 ???? ???? (kilee)

--               2020.07.14 DefectReportNo(???????)?? (kilee) 

--               2020.08.11 ?????? ?? (??? ??)      

--               2020.08.31 ??? ?? ??? ????                 

--               2020.10.21 ??? ?? ???? ? ???

--               2021.11.23 ????? ????? ??



-- ???? ??:  usp_MaterialQcInfo_get '','','','','','2021-03-01','2021-12-25', 'Reject' ,'IQC', 'VNT' ,'' ,'', '2021-03-20','2021-12-31'

--                      usp_MaterialQcInfo_get '','','','','','2021-03-01','2021-12-25', 'Reject' ,'IQC', 'VNT' ,'VNT_F1' ,'', ' ' , '2021-03-20','2021-12-31'

-- ====================================================================================================

CREATE PROCEDURE [dbo].[usp_MaterialQcInfo_get]

						@pProcessUserID VARCHAR(20),

						@pProcessLanguage VARCHAR(20),

						@pMaterialDocNo VARCHAR(20) = NULL,

						@pMaterialCode VARCHAR(50) = NULL,

						@pCustomerCode VARCHAR(20) = NULL,

						@pFromDate DATE = NULL,

						@pToDate DATE = NULL,

						@pDecisionResult VARCHAR(10) = NULL,

						@pInspectionDocType VARCHAR(20) = 'IQC',

						@pCompanyCode VARCHAR(20) = NULL,                                             -- ????? kilee ?? (2020.03.31)	

						@pWorkCenterCode VARCHAR(20) = NULL,                                             -- ????? kilee ?? (2021.11.23)	

						@pMaterialTypeCode  VARCHAR(20) = NULL,                                         -- 2020.06.29 ??						

						@pProductGroupCode VARCHAR(20) = NULL,

						@pDecisionFromDate DATE = NULL,

						@pDecisionToDate DATE = NULL,

						@pProdInspWorkerCode VARCHAR(20) = NULL              --2021.03.24 ??

						

AS



BEGIN

	SET NOCOUNT ON;

	

	DECLARE @MaterialDeliveryNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '%' ELSE @pMaterialDocNo END

	DECLARE @MaterialCode         VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%' ELSE @pMaterialCode   END



	DECLARE @FromDate DATE    = CASE WHEN @pFromDate IS NULL THEN GETDATE() ELSE @pFromDate END

	DECLARE @ToDate    DATE     = CASE WHEN @pToDate IS NULL    THEN GETDATE() ELSE DATEADD(day, 1, @pToDate)    END



	DECLARE @DecisionResult      VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '%' ELSE @pDecisionResult END 

	DECLARE @CustomerCode      VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END 

	DECLARE @InspectionDocType VARCHAR(10) = @pInspectionDocType

	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END              -- ????? kilee ?? (2020.03.31)

	DECLARE @WorkCenterCode    VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END        -- ????? kilee ?? (2021.11.23)



	DECLARE @MaterialTypeCode  VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END       -- ?? kilee ?? (2020.03.31)

	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END     -- ?? kilee ?? (2020.03.31)



	DECLARE @DecisionFromDate DATE = CASE WHEN @pDecisionFromDate IS NULL THEN GETDATE() ELSE @pDecisionFromDate END   -- ???? ???? (???, 2020-08-11)

	DECLARE @DecisionToDate    DATE = CASE WHEN @pDecisionToDate     IS NULL THEN GETDATE() ELSE DATEADD(day, 1, @pDecisionToDate)    END



	DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END





	--add by Mr.Tung 2022-Sep-22, 1840  Adit

	declare @tmpDefectReportNo VARCHAR(1)= (case when @CompanyCode='VVT' then '' else '*' end) 



	Declare @MaterialWarehouseCode VARCHAR(20)



	SELECT @MaterialWarehouseCode = MaterialWarehouseCode

	  FROM STB_UserInfo

	 WHERE UserID = @pProcessUserID



	IF @WorkCenterCode = 'VNT_F2' AND ISNULL(@MaterialWarehouseCode, '') <> '' AND ISNULL(@MaterialWarehouseCode, '') <> 'W02' BEGIN

		-- ???? VNT_F2??, ????? ???? MEA? ???

		--SET @ProductGroupCode = 'CATALYST SUPPORT'

		SELECT	       

			MQI.MaterialQcNo AS OldMaterialQcNo,

			MQI.MaterialQcNo,

			DR.DecisionResultText,

			MQI.CompanyCode,

			CI.CompanyName,

			MQI.WorkCenterCode,

			WCI.WorkCenterName,			

			MDI.MaterialDocNo,

	        MDI.TargetMaterialWarehouseCode,

	        MW.MaterialWarehouseName,

			MDI.SourceCustomerCode,

	        C.CustomerName,

			MQI.MaterialCode,

			MM.MaterialName,

			MM.MaterialTypeCode,

			MT.BasicMaterialType,

			MT.MaterialTypeName,

			MM.ProductGroupCode,

			PG.ProductGroupName,

			MM.MaterialUnit,

			MM.BasicGrQty,

			MM.MaterialSpec,

			MM.MaterialUnit,                            -- 2020.04.24 ?? (???????)

			MM.MaterialSource,

			MM.AvgGrDay,

			MM.IsPurchase,

			MM.IsOrder,

			MM.IsClosed,

			MM.BeforeMaterialCode,

			MQI.QcQty,

			CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27

			--MQI.InspectionType as aaa,

			MQI.TargetSampleQty,

			MQI.ActualSampleQty,                -- ?????

			MQI.DestoryInspectionQty,

			MQI.ProcessQty,

			MQI.MaxAcceptDefectQty,

			MQI.PassedSampleQty,

			MQI.DefectSampleQty,                                  -- ???????

			MDD2.ManufacturerCode,

			C2.CustomerName AS ManufacturerName,

			MDD2.WeekCode,

			MDD2.RevisionsVer,		-- add for BG2

			MQI.DecisionResult,

			MQI.DecisionDateTime,                                 -- ????

			MQI.DecisionUserID       AS DecisionUserID,      -- ????? ID                       			

			SUI.UserName              AS DecisionName,       -- ????? Name (2020.07.21 ??)

			MQI.SpecialAcceptDesc,			

			MQI.IQCSampleLotList AS IQCSampleLotList,   -- ?? Lot No  (???? ??)      

			MQI.VendorQcReport,

			MQI.VendorLotNo,

			MQI.MIIExtText01,     -- ???

			(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 ????



			MQI.MIIExtText02,		

		    CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) AS RequestDate,   -- ????? : ???+7? (2020.07.20 ?????)

			MQI.MIIExtText04,

		   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot???(%) ????? (20
20.12.09)

		   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- ???(PPM) ?????		

		   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot???(%) ????
? (2020.12.09)

		   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- ???(PPM) ????
?							

			MQI.MIIExtText05,

			MQI.CreateDateTime,

		    CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee ?? (??????, ????) 

			MQI.CreateUserID                                                                                                                                                            AS CreateUserID,

	    -- MQI.CreateUserID                                                                                                                                    AS TestUser,      -- 2019.07.24 kilee ?? (??????)			                                               
  

		   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee ?? (??????, ???)				

			CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee ?? (??????, ????)

			MQI.ChangeDateTime,

			MQI.ChangeUserID,

			MQI.BasicDate,

		    'Report' AS CommandType,

			0 as LabelQty

		-- , MDD.MaterialIqcNo                    -- 2020.04.24 ?? (????)

			, SIQ.DefectReportNo AS     DefectReportNo       -- ?????

			, MDD.LotNo_Qty                                           -- Lot??   (2020-09-06 ?? )

			

	

	FROM                        STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 



			LEFT OUTER JOIN STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode

			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			

			LEFT OUTER JOIN (

										 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH ?? DocDetail? ?? ??? 2? ????? ??? ???? ??? ????? ??? ?? Join?? n?? ??? ??? DISTINCT

													MDD.MaterialIqcNo,

													Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 ?? 	

											FROM

													STB_MaterialDocDetail MDD WITH(NOLOCK)

													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo

													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo

													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 ??

											WHERE

													MQI.InspectionDocType LIKE @InspectionDocType 

													AND	(MQI.DecisionResult LIKE @DecisionResult) 

													AND	(MQI.MaterialCode LIKE @MaterialCode) 

													AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

													AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 

													AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)

											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 ?? 	

									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo

			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode

			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode

			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode

			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode

			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode

			LEFT OUTER JOIN VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult

		    LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	

			LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						

		    LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID

			LEFT OUTER JOIN STB_MaterialDocDetail MDD2 WITH(NOLOCK) ON MDD2.MaterialIqcNo = MQI.MaterialQcNo

			LEFT OUTER JOIN STB_CustomerInfo C2 WITH(NOLOCK)				ON MDD2.ManufacturerCode = C2.CustomerCode	-- BG2

	WHERE 1=1

			AND MQI.InspectionDocType LIKE @InspectionDocType 

			AND (MQI.DecisionResult LIKE @DecisionResult) 

			AND (MQI.MaterialCode LIKE @MaterialCode) 

			AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

			AND (MDI.SourceCustomerCode LIKE @CustomerCode) 

			AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- ????? kilee ??   (2020.03.31)

			AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- ????? kilee ??   (2021.11.23)

			AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- ?????? kilee ?? (2020.06.29)

			--AND MM.ProductGroupCode LIKE 'CATALYST SUPPORT'                                        -- ?????? kilee ?? (2020.06.29)

		   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- ???? ???? (???, 2020.08.11)	



	END ELSE BEGIN

		IF @pProcessUserID = 'yjyu' BEGIN

			SELECT	       

				MQI.MaterialQcNo AS OldMaterialQcNo,

				MQI.MaterialQcNo,

				DR.DecisionResultText,

				MQI.CompanyCode,

				CI.CompanyName,

				MQI.WorkCenterCode,

				WCI.WorkCenterName,			

				MDI.MaterialDocNo,

				MDI.TargetMaterialWarehouseCode,

				MW.MaterialWarehouseName,

				MDI.SourceCustomerCode,

				C.CustomerName,

				MQI.MaterialCode,

				MM.MaterialName,

				MM.MaterialTypeCode,

				MT.BasicMaterialType,

				MT.MaterialTypeName,

				MM.ProductGroupCode,

				PG.ProductGroupName,

				MM.MaterialUnit,

				MM.BasicGrQty,

				MM.MaterialSpec,

				MM.MaterialUnit,                            -- 2020.04.24 ?? (???????)

				MM.MaterialSource,

				MM.AvgGrDay,

				MM.IsPurchase,

				MM.IsOrder,

				MM.IsClosed,

				MM.BeforeMaterialCode,

				MQI.QcQty,

				CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27

				--MQI.InspectionType as aaa,

				MQI.TargetSampleQty,

				MQI.ActualSampleQty,                -- ?????

				MQI.DestoryInspectionQty,

				MQI.ProcessQty,

				MQI.MaxAcceptDefectQty,

				MQI.PassedSampleQty,

				MQI.DefectSampleQty,                                  -- ???????

				--MQI.RevisionsVer,		-- add for BG2

				MQI.DecisionResult,

				MQI.DecisionDateTime,                                 -- ????

				MQI.DecisionUserID       AS DecisionUserID,      -- ????? ID                       			

				SUI.UserName              AS DecisionName,       -- ????? Name (2020.07.21 ??)

				MQI.SpecialAcceptDesc,			

				'' AS IQCSampleLotList,   -- ?? Lot No  (???? ??)      

				MQI.VendorQcReport,

				MQI.VendorLotNo,

				MQI.MIIExtText01,     -- ???

				(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 ????



				MQI.MIIExtText02,		

				CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) AS RequestDate,   -- ????? : ???+7? (2020.07.20 ?????)

				MQI.MIIExtText04,

			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot???(%) ????? (2
020.12.09)

			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- ???(PPM) ?????		


			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot???(%) ???
?? (2020.12.09)

			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- ???(PPM) ???
??							

				MQI.MIIExtText05,

				MQI.CreateDateTime,

				CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee ?? (??????, ????) 

				MQI.CreateUserID                                                                                                                                                            AS CreateUserID,

			-- MQI.CreateUserID                                                                                                                                                             AS TestUser,      -- 2019.07.24 kilee ?? (??????)			                        
                         

			   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee ?? (??????, ???)				

				CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee ?? (??????, ????)

				MQI.ChangeDateTime,

				MQI.ChangeUserID,

				MQI.BasicDate,

				'Report' AS CommandType,

				0 as LabelQty

			-- , MDD.MaterialIqcNo                    -- 2020.04.24 ?? (????)

				, '' AS     DefectReportNo       -- ?????

				, MDD.LotNo_Qty                                           -- Lot??   (2020-09-06 ?? )

			

	

		FROM                        [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 



				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			

				LEFT OUTER JOIN (

											 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH ?? DocDetail? ?? ??? 2? ????? ??? ???? ??? ????? ??? ?? Join?? n?? ??? ??? DISTINCT

														MDD.MaterialIqcNo,

														Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 ?? 	

												FROM

														[110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocDetail MDD WITH(NOLOCK)

														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo

														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo

														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 ??

												WHERE

														MQI.InspectionDocType LIKE @InspectionDocType 

														AND	(MQI.DecisionResult LIKE @DecisionResult) 

														AND	(MQI.MaterialCode LIKE @MaterialCode) 

														AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

														AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 

														AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)

												Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 ?? 	

										) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	

				LEFT OUTER JOIN  [110.11.27.5].SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID

		WHERE 1=1

				AND MQI.InspectionDocType LIKE @InspectionDocType 

				AND (MQI.DecisionResult LIKE @DecisionResult) 

				AND (MQI.MaterialCode LIKE @MaterialCode) 

				AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

				AND (MDI.SourceCustomerCode LIKE @CustomerCode) 

				AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        

				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- ????? kilee ??   (2020.03.31)

				AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- ????? kilee ??   (2021.11.23)

				AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- ?????? kilee ?? (2020.06.29)

				AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- ?????? kilee ?? (2020.06.29)

				--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'

			   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- ???? ???? (???, 2020.08.11)		

			   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202',
 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')

			   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 ??? ?? -- IQCSampleLotList? ???? ???? NOT NULL? ?? NULL? ?? ???? ???.



		END ELSE BEGIN



		--	raiserror(@DecisionResult,16,1)

		--	SELECT	       

		--		MQI.MaterialQcNo AS OldMaterialQcNo,

		--		MQI.MaterialQcNo,

		--		DR.DecisionResultText,

		--		MQI.CompanyCode,

		--		CI.CompanyName,

		--		MQI.WorkCenterCode,

		--		WCI.WorkCenterName,			

		--		MDI.MaterialDocNo,

		--		MDI.TargetMaterialWarehouseCode,

		--		MW.MaterialWarehouseName,

		--		MDI.SourceCustomerCode,

		--		C.CustomerName,

		--		MQI.MaterialCode,

		--		case when MQI.MaterialCode in ('GBCP00-S06')

		--		then N'??? 2.7 V  SPDBF4/ACN: SL=8:2'

		--		else MM.MaterialName

		--		end as MaterialName

		--		,

		--		MM.MaterialTypeCode,

		--		MT.BasicMaterialType,

		--		MT.MaterialTypeName,

		--		MM.ProductGroupCode,

		--		PG.ProductGroupName,

		--		MM.MaterialUnit,

		--		MM.BasicGrQty,

		--		MM.MaterialSpec,

		--		MM.MaterialUnit,                            -- 2020.04.24 ?? (???????)

		--		MM.MaterialSource,

		--		MM.AvgGrDay,

		--		MM.IsPurchase,

		--		MM.IsOrder,

		--		MM.IsClosed,

		--		MM.BeforeMaterialCode,

		--		MQI.QcQty,

		--		CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27

		--		--MQI.InspectionType as aaa,

		--		MQI.TargetSampleQty,

		--		MQI.ActualSampleQty,                -- ?????

		--		MQI.DestoryInspectionQty,

		--		MQI.ProcessQty,

		--		MQI.MaxAcceptDefectQty,

		--		MQI.PassedSampleQty,

		--		MQI.DefectSampleQty,                                  -- ???????

		--		MQI.DecisionResult,

		--		MQI.DecisionDateTime,                                 -- ????

		--		MQI.DecisionUserID       AS DecisionUserID,      -- ????? ID                       			

		--		SUI.UserName              AS DecisionName,       -- ????? Name (2020.07.21 ??)

		--		MQI.SpecialAcceptDesc,			

		--		MQI.IQCSampleLotList AS IQCSampleLotList,   -- ?? Lot No  (???? ??)      

		--		MQI.VendorQcReport,

		--		MQI.VendorLotNo,

		--		MQI.MIIExtText01,     -- ???

		--		(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 ????



		--		MQI.MIIExtText02,		

		--		CASE 

		--			WHEN MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016') THEN CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)  -- update 2025-08-27 for audit

		--			ELSE CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) 

		--		END	AS RequestDate,		   -- ????? : ???+7? (2020.07.20 ?????)

		--		MQI.MIIExtText04,

		--	   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot???(%) ????? 
(2020.12.09)

		--	   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- ???(PPM) ?????	
	

		--	   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot???(%) ?
???? (2020.12.09)

		--	   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- ???(PPM) ?
????							

		--		MQI.MIIExtText05,

		--		MQI.CreateDateTime,

		--		CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee ?? (??????, ????) 

		--		MQI.CreateUserID                                                                                                                                                            AS CreateUserID,

		--	-- MQI.CreateUserID                                                                                                                                                             AS TestUser,      -- 2019.07.24 kilee ?? (??????)			                      
                           

		--	   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee ?? (??????, ???)				

		--		CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee ?? (??????, ????)

		--		MQI.ChangeDateTime,

		--		MQI.ChangeUserID,

		--		MQI.BasicDate,

		--		'Report' AS CommandType,

		--		0 as LabelQty

		--	-- , MDD.MaterialIqcNo                    -- 2020.04.24 ?? (????)

		--		, SIQ.DefectReportNo AS     DefectReportNo       -- ?????

		--		, MDD.LotNo_Qty                                           -- Lot??   (2020-09-06 ?? )

			

	

		--FROM                        STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 



		--		LEFT OUTER JOIN STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode

		--		LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			

		--		LEFT OUTER JOIN (

		--									 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH ?? DocDetail? ?? ??? 2? ????? ??? ???? ??? ????? ??? ?? Join?? n?? ??? ??? DISTINCT

		--												MDD.MaterialIqcNo,

		--												Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 ?? 	

		--										FROM

		--												STB_MaterialDocDetail MDD WITH(NOLOCK)

		--												INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo

		--												INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo

		--												INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 ??

		--										WHERE

		--												MQI.InspectionDocType LIKE @InspectionDocType 

		--												AND	(MQI.DecisionResult LIKE @DecisionResult) 

		--												AND	(MQI.MaterialCode LIKE @MaterialCode) 

		--												AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

		--												AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 

		--												AND	(MQI.BasicDate BETWEEN @FromDate AND '2024-12-31')

		--										Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 ?? 	

		--								) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

		--		LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo

		--		LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode

		--		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode

		--		LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode

		--		LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode

		--		LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode

		--		LEFT OUTER JOIN VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult

		--		LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	

		--		LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						

		--		LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID

		--WHERE 1=1

		--		AND MQI.InspectionDocType LIKE @InspectionDocType 

		--		AND (MQI.DecisionResult LIKE @DecisionResult) 

		--		AND (MQI.MaterialCode LIKE @MaterialCode) 

		----		AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

		----		AND (MDI.SourceCustomerCode LIKE @CustomerCode) 

		--		AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        

		--		AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- ????? kilee ??   (2020.03.31)

		--		AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- ????? kilee ??   (2021.11.23)

		--		AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- ?????? kilee ?? (2020.06.29)

		--		AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- ?????? kilee ?? (2020.06.29)

		--		--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'

		--	   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- ???? ???? (???, 2020.08.11)		

		--	   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202
', 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')

		--	   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 ??? ?? -- IQCSampleLotList? ???? ???? NOT NULL? ?? NULL? ?? ???? ???.



		--	   --BEGIN  Remove comment when audit

		--	   AND	 (

		--	    (@DecisionResult <> 'Reject'  and  @FromDate >='2025-01-01' )

		--		OR MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016', '26012600010')) -- UPDATE 2025-08-27 because QC team want to change IQCSampleLotList

		--	    --END



		--	   AND (SIQ.DefectReportNo = 'VNI220614-01' OR SIQ.DefectReportNo IS NULL or @CompanyCode='VVT') 



		--	   union all



			   SELECT	       

				MQI.MaterialQcNo AS OldMaterialQcNo,

				MQI.MaterialQcNo,

				DR.DecisionResultText,

				MQI.CompanyCode,

				CI.CompanyName,

				MQI.WorkCenterCode,

				WCI.WorkCenterName,			

				MDI.MaterialDocNo,

				MDI.TargetMaterialWarehouseCode,

				MW.MaterialWarehouseName,

				MDI.SourceCustomerCode,

				C.CustomerName,

				MQI.MaterialCode,

				case when MQI.MaterialCode in ('GBCP00-S06')

				then N'??? 2.7 V  SPDBF4/ACN: SL=8:2'

				else MM.MaterialName

				end as MaterialName

				,

				MM.MaterialTypeCode,

				MT.BasicMaterialType,

				MT.MaterialTypeName,

				MM.ProductGroupCode,

				PG.ProductGroupName,

				MM.MaterialUnit,

				MM.BasicGrQty,

				MM.MaterialSpec,

				MM.MaterialUnit,                            -- 2020.04.24 ?? (???????)

				MM.MaterialSource,

				MM.AvgGrDay,

				MM.IsPurchase,

				MM.IsOrder,

				MM.IsClosed,

				MM.BeforeMaterialCode,

				MQI.QcQty,

				CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27

				--MQI.InspectionType as aaa,

				MQI.TargetSampleQty,

				MQI.ActualSampleQty,                -- ?????

				MQI.DestoryInspectionQty,

				MQI.ProcessQty,

				MQI.MaxAcceptDefectQty,

				MQI.PassedSampleQty,

				MQI.DefectSampleQty,                                  -- ???????

				MDD2.ManufacturerCode,

				C2.CustomerName AS ManufacturerName,

				MDD2.WeekCode,

				MDD2.RevisionsVer,		-- add for BG2

				--MQI.RevisionsVer,		-- add for BG2

				MQI.DecisionResult,

				MQI.DecisionDateTime,                                 -- ????

				MQI.DecisionUserID       AS DecisionUserID,      -- ????? ID                       			

				SUI.UserName              AS DecisionName,       -- ????? Name (2020.07.21 ??)

				MQI.SpecialAcceptDesc,			

				MQI.IQCSampleLotList AS IQCSampleLotList,   -- ?? Lot No  (???? ??)      

				MQI.VendorQcReport,

				MQI.VendorLotNo,

				MQI.MIIExtText01,     -- ???

				(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 ????



				MQI.MIIExtText02,		

				CASE 

					WHEN MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016') THEN CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)  -- update 2025-08-27 for audit

					ELSE CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) 

				END	AS RequestDate,   -- ????? : ???+7? (2020.07.20 ?????)

				MQI.MIIExtText04,

			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot???(%) ????? (2
020.12.09)

			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- ???(PPM) ?????		


			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot???(%) ???
?? (2020.12.09)

			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- ???(PPM) ???
??							

				MQI.MIIExtText05,

				MQI.CreateDateTime,

				CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee ?? (??????, ????) 

				MQI.CreateUserID                                                                                           AS CreateUserID,

			-- MQI.CreateUserID                                                                                                                                                             AS TestUser,      -- 2019.07.24 kilee ?? (??????)			                       
                          

			   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee ?? (??????, ???)				

				CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee ?? (??????, ????)

				MQI.ChangeDateTime,

				MQI.ChangeUserID,

				MQI.BasicDate,

				'Report' AS CommandType,

				0 as LabelQty

			-- , MDD.MaterialIqcNo                    -- 2020.04.24 ?? (????)

				, SIQ.DefectReportNo AS     DefectReportNo       -- ?????

				, MDD.LotNo_Qty                                           -- Lot??   (2020-09-06 ?? )

			

	

		FROM                        STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 



				LEFT OUTER JOIN STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode

				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			

				LEFT OUTER JOIN (

											 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH ?? DocDetail? ?? ??? 2? ????? ??? ???? ??? ????? ??? ?? Join?? n?? ??? ??? DISTINCT

														MDD.MaterialIqcNo,

														Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 ?? 	

												FROM

														STB_MaterialDocDetail MDD WITH(NOLOCK)

														INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo

														INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo

														INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 ??

												WHERE

														MQI.InspectionDocType LIKE @InspectionDocType 

														AND	(MQI.DecisionResult LIKE @DecisionResult) 

														AND	(MQI.MaterialCode LIKE @MaterialCode) 

														AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

														AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 

														AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)

												Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 ?? 	

										) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

				LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo

				LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode

				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode

				LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode

				LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode

				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode

				LEFT OUTER JOIN VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult

				LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	

				LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						

				LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID

				LEFT OUTER JOIN STB_MaterialDocDetail MDD2 WITH(NOLOCK) ON MDD2.MaterialIqcNo = MQI.MaterialQcNo

				LEFT OUTER JOIN STB_CustomerInfo C2 WITH(NOLOCK)				ON MDD2.ManufacturerCode = C2.CustomerCode	-- BG2

		WHERE 1=1

				AND MQI.InspectionDocType LIKE @InspectionDocType 

				AND (MQI.DecisionResult LIKE @DecisionResult)

				AND (MQI.MaterialCode LIKE @MaterialCode) 

				AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 

				AND (MDI.SourceCustomerCode LIKE @CustomerCode) 

				AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        

				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- ????? kilee ??   (2020.03.31)

				AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- ????? kilee ??   (2021.11.23)

				AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- ?????? kilee ?? (2020.06.29)

				AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- ?????? kilee ?? (2020.06.29)

				--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'

			   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- ???? ???? (???, 2020.08.11)		

			   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202',
 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')

			   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 ??? ?? -- IQCSampleLotList? ???? ???? NOT NULL? ?? NULL? ?? ???? ???.

			   

			   --BEGIN  Remove comment when audit

			   

			 --  AND	 (

			 --   (@DecisionResult <> 'Reject'  and @FromDate>='2025-01-01')

				--OR MQI.MaterialQcNo IN ('25031100001', '25040500010', '25072100002', '25102800016', '26020400009', '25012400007'))  -- UPDATE 2025-08-27 because QC team want to change IQCSampleLotList

				 --END																

				 

			   AND (SIQ.DefectReportNo = 'VNI220614-01' OR SIQ.DefectReportNo IS NULL or @CompanyCode='VVT') 



		END

	END

END





  --        usp_MaterialQcInfo_get '','','','','','2024-12-01','2024-12-25', '' ,'IQC', 'VVT' ,'VVT_F3' ,'', ' ' , '2024-12-01','2024-12-25'
