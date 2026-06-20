
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-12
-- Browsable : true
-- Group : 생산관리
-- Description: 공정별 실적을 처리합니다 비나텍용
-- Modified: [B530] 제품생산실적입력
-- =============================================
-- EXEC [usp_GetProdRouteHistForBarcode_VNT] '','','','','','VVQK013R072701',''

CREATE PROCEDURE [dbo].[usp_GetProdRouteHistForBarcode_VNT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pRouteCode VARCHAR(20) = NULL,
						@pWorkerCode VARCHAR(200) = NULL,
						@pMachineCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(50) = NULL,
						@pMachineID VARCHAR(20) = NULL
	
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @RouteCode         VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode       VARCHAR(200) = @pWorkerCode
	DECLARE @Barcode            VARCHAR(50) = @pBarcode
	DECLARE @MachineID         VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @MachineCode     VARCHAR(20) = ISNULL(@pMachineCode,'')
	
	DECLARE @CompanyCode    VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @LineCode           VARCHAR(20)
	DECLARE @ProdQty            NUMERIC(20,5)
	DECLARE @ProcessDateTime  DateTime = GETDATE()
	DECLARE @DPPExtText01      NVARCHAR(100)
	DECLARE @NewBarcode VARCHAR(50)
	DECLARE @PoType VARCHAR(50)
	DECLARE @ErrorMsg NVARCHAR(200)
	DECLARE @ControlNo VARCHAR(20)
	--

	SELECT @NewBarcode = NewBarcode 
	  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	 WHERE OldBarcode = @Barcode	

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@LineCode = SI.InputLineCode,
			@DPPExtText01 = DPP.DPPExtText01,
			@PoType=POI.POType
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)		ON POI.PONo = SI.PONo                
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo    
	WHERE 
			SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
			-- Lấy ControlNo
			SELECT TOP 1	
			@ControlNo = ControlNo
	FROM
			STB_SetInfo
	WHERE
			Barcode = @Barcode
			--end
   -- Mr.Triều chặn nếu mà hàng Module thì không cần nhập
   -- Còn lại ở nhà máy Bắc Ninh và Bắc Giang ngoại trừ công đoạn ngoại quan đóng gói ra tất cả đều phải chọn máy
   -- Nếu với với con hàng Cutting thì k cần công đoạn V-33_BG


  
  IF(@WorkCenterCode in ('VVT_F1','VVT_F2') and @MachineCode='' and @PoType not in('MODULE') and @RouteCode not in('V-28','V-27', 'V-33', 'V-27_BG','V-28_BG','V-33_BG'))
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Bạn phải chọn thiết bị thực hiện !...' 
			return;
		END


	IF(@WorkCenterCode in ('VVT_F3') and @MachineCode='')
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Bạn phải chọn thiết bị thực hiện !...' 
			return;
		END

   --if(@WorkCenterCode in ('VVT_F4'))
   --BEGIN
   --    EXEC usp_MessgaeNotificationError @Barcode
	  -- RETURN;
   --END


	-- Thêm báo lỗi công đoạn ngay khi tìm kiếm cho Bắc giang 2 
	DECLARE @CompleteRoute int
	DECLARE @Count int
	DECLARE @IsInputRoute bit
	--select * from STB_PassOrFailRouteStatus where Barcode='K16418106262500679'
	DECLARE @PrevRouteCode VARCHAR(20)
	SET @PrevRouteCode = 
    CASE 
        WHEN @RouteCode LIKE 'VP%' 
        THEN 'VP' + RIGHT('00' + CAST(CAST(SUBSTRING(@RouteCode,3,10) AS INT) - 1 AS VARCHAR), 2)
        ELSE NULL
    END
	IF (@PrevRouteCode IS NOT NULL)
    BEGIN
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT 
                S.RouteCode,
                S.Status,
                ROW_NUMBER() OVER (
                    PARTITION BY S.Barcode, S.RouteCode 
                    ORDER BY S.CreatedDate DESC
                ) AS RN
            FROM STB_PassOrFailRouteStatus S WITH(NOLOCK)
            WHERE (S.Barcode = @Barcode)
        ) LATEST
        WHERE LATEST.RN = 1
          AND LATEST.RouteCode = @PrevRouteCode
          AND LATEST.Status = 'Fail'
    )
    BEGIN
        SET @ErrorMsg = N'Công đoạn trước (' + @PrevRouteCode + N') đã FAIL, không thể thực hiện công đoạn này!...'
        EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
        RETURN;
    END
   END
	/*
	IF (@RouteCode = 'VP05' and @WorkCenterCode = 'VVT_F4')
	BEGIN
		DECLARE @VP04Status VARCHAR(20) = ''

		SELECT TOP 1 @VP04Status = Status
		FROM STB_PassOrFailRouteStatus WITH(NOLOCK)
		WHERE (Barcode = @Barcode) 
		  AND RouteCode = 'VP04'
		ORDER BY CreatedDate DESC 

		IF (@VP04Status = 'Fail')
		BEGIN
			SET @ErrorMsg = N'Sản phẩm đã bị FAIL ở công đoạn VP04, không thể thực hiện ở VP05!...'
			EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
			RETURN;
		END
	END
	*/
	-- Chặn không cho chọn công đoạn nếu mà công đoạn đó
	IF(@WorkCenterCode='VVT_F4' AND @RouteCode NOT IN ('VP01','VP08','VP13'))
	BEGIN
	   IF NOT EXISTS (
        SELECT 1 
        FROM STB_ProdRouteHist rh
        INNER JOIN STB_SetInfo si ON rh.controlno = si.controlno
        WHERE si.Barcode = @Barcode 
          AND rh.RouteCode = @RouteCode
    )
    BEGIN
        SET @ErrorMsg = N'Công đoạn này chưa hề được sản xuất. Xin vui lòng vào màn B540 để xem lại!';
        EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg;
        RETURN;
    END
	END


	
	/*
	SELECT @count=count(*) from STB_PassOrFailRouteStatus where Barcode=@Barcode and Status='Fail' AND RouteCode=@RouteCode 

	IF (@WorkCenterCode = 'VVT_F4' AND @count > 0)
	BEGIN
		SET @ErrorMsg = N'Barcode này đã có trạng thái FAIL, không thể chốt dữ liệu!...'
		RAISERROR(@ErrorMsg,16,1)
		RETURN; 
	END
	*/
	 SELECT
			@Count = COUNT(*)
	FROM
			STB_ProdRouteHist PRH
	WHERE
			PRH.ControlNo = @ControlNo

	 SELECT @IsInputRoute = IsInputRoute
	 FROM STB_ProductionOrderRouting
	 WHERE PONo =(
	              SELECT  PONo
	              FROM Stb_setinfo
	              WHERE ControlNo = @ControlNo
				 )
           AND RouteCode = @RouteCode

	SELECT
			@ProdQty = PRH.ProdQty,
			@CompleteRoute = PRH.CompleteRoute
	FROM
			STB_ProdRouteHist PRH
	WHERE
			PRH.ControlNo = @ControlNo AND
			PRH.RouteCode = @RouteCode

   --    IF (ISNULL(@Count,0) = 0 AND ISNULL(@IsInputRoute,0) != 1 AND @WorkCenterCode = 'VVT_F4')
	  -- BEGIN
			--SET @ErrorMsg = N'Không đúng công đoạn hiện tại'
			--EXEC usp_RaiseLocalizedError @pProcessLanguage,@ErrorMsg
			--RETURN
	  -- END

   -- IF ((ISNULL(@ProdQty,0) <= 0 and @WorkCenterCode = 'VVT_F4') OR (@CompleteRoute = 1 AND @WorkCenterCode = 'VVT_F4'))
	  -- IF (@Count != 0 OR  @IsInputRoute = 0)
	  -- BEGIN
			--SET @ErrorMsg = N'Không đúng công đoạn hiện tại'
			--EXEC usp_RaiseLocalizedError @pProcessLanguage,@ErrorMsg
			--RETURN
	  -- END

    -- end

	IF ISNULL(@DPPExtText01,'') = '1' 
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	END

	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(@ProcessDateTime,@CompanyCode,@WorkCenterCode,@LineCode,@RouteCode,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)
	

	-- DefectInfo
	;WITH DefectInfo AS
	(
		SELECT
				DRI.ControlNo,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty) AS LossQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)  ON SI.ControlNo = DRI.ControlNo
		WHERE
				(SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode) AND
				DRI.FindRouteCode = @RouteCode AND
				(DRI.RepairType NOT IN ('MISSING'))
		GROUP BY
				DRI.ControlNo

	--  NextProd
	), NextProd AS

	(
		SELECT
				SI.ControlNo,
				SUM(PRH.ProdQty) AS AftProdQty
		FROM
				STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	 ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					         ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
		WHERE
				SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
		GROUP BY
				SI.ControlNo
	), DefectAll AS
	(
		SELECT
				DRI.ControlNo,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty) AS LossQty,
				SUM(DRI.RepairQty) AS RepairQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)  ON SI.ControlNo = DRI.ControlNo
		WHERE
				(SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode) AND
				(DRI.RepairType NOT IN ('MISSING'))
		GROUP BY
				DRI.ControlNo

	--  NextProd
	)

-- 최종 Select문
	SELECT
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.Barcode,
			SI.MaterialCode,
			SI.IsLoss,
			MM.MaterialName,
			DPP.PlanDate,
			DPP.PlanQty,
			SI.ProdQty AS LotQty,
			SUM(PRH.ProdQty) AS InputProdQty,
			ISNULL(DI.DefectQty,0) AS DefectQty,
			--SUM(PRH.ProdQty) - ISNULL(DI.DefectQty,0) AS ProdQty,
			SUM(PRH.ProdQty) AS ProdQty,
			DI.LossQty AS LossQty,
			SI.InputLineCode AS LineCode,
			@RouteCode AS RouteCode,
			@WorkerCode AS WorkerCode,
			@MachineCode AS MachineCode,
			@MachineID AS MachineID,
			NP.AftProdQty,
			replace(substring(ltrim(MAX(SI.SIExtText07)),1,5),'-','') AS MarkingLetter,
			replace(substring(ltrim(MAX(SI.SIExtText07)),6,45),'-','') AS VietnamMarking2,  --Add by Mr.Tung on 2023-Sep-15
			--CONVERT(BIT, MAX(CASE WHEN SI.MaterialCode = 'ECVT30-370' THEN CASE WHEN RMIH.RawBarcodeCount = 1 THEN 1 ELSE 0 END -- Mr.Trieu Added condition for worker 'ECVT30-370' (JangHai)
			                      --WHEN RMIH.RawBarcodeCount = RMIH.TotCount THEN 1 ELSE 0 END)) AS IsRawMaterialInputFinish,
			CONVERT(BIT, MAX(CASE WHEN RMIH.RawBarcodeCount = RMIH.TotCount THEN 1 ELSE 1 END)) AS IsRawMaterialInputFinish,
			CONVERT(BIT, MAX(CASE WHEN RMIHM.RawBarcodeCountModule = RMIHM.TotCount THEN 1 ELSE 0 END)) AS IsRawMaterialInputFinishModule,
			CONVERT(BIT,CASE 
							WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1
							WHEN PRH.CompleteRoute = '1' THEN 1  -- ★ 추가 2026-04-22 김형진 
							ELSE 0 END
						) AS IsHasNextProd,
           MAX(SIExtInt02)  AS IntrinsicQty,
		   VM.MBISizeW     AS ModelType,                   -- 추가
		   SI.ProdQty - DA.DefectQty + DA.RepairQty AS PackingExpectedQty,
		   '' AS DelayCode,
		   ISNULL(MAX(IPI.ProdQty), 0) AS InterimProdQty,
		   0 AS SplitAgingQty    -- Mr.Manh update 2025-08-07 for Ha Nam Factory

	FROM
								  STB_SetInfo SI			    WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)	ON PRH.ControlNo = SI.ControlNo AND				PRH.RouteCode = @RouteCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DayProdPlan DPP    WITH(NOLOCK)	ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN DefectInfo DI				WITH(NOLOCK)	ON DI.ControlNo = SI.ControlNo
			LEFT OUTER JOIN NextProd NP									ON NP.ControlNo = SI.ControlNo
			LEFT OUTER JOIN (
									SELECT Barcode
										  ,COUNT(*) AS TotCount
										  ,COUNT(RawMaterialBarcode) AS RawBarcodeCount
									  FROM STB_RawMaterialInputHist WITH(NOLOCK)
									 WHERE Barcode = @Barcode
									 GROUP BY Barcode
								) RMIH
			ON SI.Barcode = RMIH.Barcode
			LEFT OUTER JOIN (
									SELECT Barcode
										  ,COUNT(*) AS TotCount
										  ,COUNT(RawMaterialBarcode) AS RawBarcodeCountModule
									  FROM STB_RawMaterialInputHist WITH(NOLOCK)
									 WHERE Barcode = @Barcode and ProductGroupCode in ('SingleCell','ModuleSleeve','ModulePCB_Type','ModulePCB_Model','ModulePCB','ModuleWire')
									 GROUP BY Barcode
								) RMIHM
			ON SI.Barcode = RMIHM.Barcode

			LEFT OUTER JOIN VW_ModelBasicInfo VM WITH(NOLOCK)				ON SI.MaterialCode = VM.ModelCode
			LEFT OUTER JOIN DefectAll DA WITH(NOLOCK) ON DA.ControlNo = SI.ControlNo
			LEFT OUTER JOIN (SELECT ControlNo, RouteCode, SUM(ProdQty) AS ProdQty 
			                   FROM STB_InterimProdQtyInfo  WITH(NOLOCK)
							  GROUP BY ControlNo, RouteCode) IPI
			  ON IPI.ControlNo = SI.ControlNo
			 AND IPI.RouteCode = @RouteCode

		--		Select  VM.MBISizeW, SS.*
		--From VW_ModelBasicInfo VM 
		--        LEFT OUTER JOIN STB_SetInfo SS  ON SS.MaterialCode = VM.ModelCode
		--WHERE 1=1
		--   AND ControlNo = '20190207000006'		


	WHERE
			SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode--(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
	GROUP BY
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.Barcode,
			SI.InputLineCode, 
			SI.MaterialCode,
			SI.IsLoss,
			MM.MaterialName,
			DPP.PlanDate,
			DPP.PlanQty,
			SI.ProdQty,
			DI.DefectQty,
			DI.LossQty,
			NP.AftProdQty,
			PRH.CompleteRoute,
			VM.MBISizeW,         --- 추가
			DA.DefectQty,
			DA.RepairQty

END

