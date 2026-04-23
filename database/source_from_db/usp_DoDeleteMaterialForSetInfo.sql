-- =============================================m
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2020-09-29
-- Description:	Lot 삭제 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteMaterialForSetInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(20) = @pBarcode
	       ,@ControlNo VARCHAR(20) 

	DECLARE @CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@ProdFinishQty NUMERIC(20,5),
			@BefMaterialCode VARCHAR(50),
			@BefDayPlanNo VARCHAR(20),
			@BefPONo VARCHAR(20),
			@OldBarcode VARCHAR(20)

	SELECT @CompanyCode = CompanyCode
	      ,@WorkCenterCode = WorkCenterCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	SELECT @ControlNo = ControlNo
      FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	IF @ControlNo IS NULL
	BEGIN
		EXEC usp_RaiseLocalizedError	@pProcessLanguage = @pProcessLanguage,
										@pMessage = 'Lot번호가 존재하지 않습니다.'
		RETURN
	END

	SELECT
			@ProdFinishQty = SUM(PRH.ProdQty)
	FROM
			STB_ProdRouteHist PRH
			INNER JOIN STB_ProductionOrderRouting POR
				ON POR.PONo = PRH.PONo AND
				POR.RouteCode = PRH.RouteCode AND
				POR.IsOutputRoute = 1
	WHERE
			PRH.ControlNo = @ControlNo

	IF ISNULL(@ProdFinishQty,0) > 0
	BEGIN
		EXEC usp_RaiseLocalizedError	@pProcessLanguage = @pProcessLanguage,
										@pMessage = '박스포장한 이력이 있는 LOT는 삭제가 불가합니다'
		RETURN
	END

	SELECT
			@BefDayPlanNo = SI.DayPlanNo,
			@BefMaterialCode = SI.MaterialCode,
			@BefPONo = SI.PONo,
			@OldBarcode = SI.Barcode
	FROM
			STB_SetInfo SI
	WHERE
			SI.ControlNo = @ControlNo


	DECLARE @Summary TABLE
	(
		IDX INT IDENTITY(1,1),
		LineCode VARCHAR(20),
		RouteCode VARCHAR(20),
		JobDate DATE,
		ShiftCode VARCHAR(1),
		TimeCode VARCHAR(2),
		ProdQty NUMERIC(20,5),
		DefectQty NUMERIC(20,5),
		RepairQty NUMERIC(20,5),
		LossQty NUMERIC(20,5)
	)
	
	;WITH ProdSummary AS
	(
		-- 실적
		SELECT
				PRH.LineCode,
				PRH.RouteCode,
				PRH.JobDate,
				PRH.ShiftCode,
				PRH.TimeCode,
				SUM(PRH.ProdQty) AS ProdQty,
				0 AS DefectQty,
				0 AS RepairQty,
				0 AS LossQty
		FROM
				STB_ProdRouteHist PRH
		WHERE
				PRH.ControlNo = @ControlNo
		GROUP BY
				PRH.LineCode,
				PRH.RouteCode,
				PRH.JobDate,
				PRH.ShiftCode,
				PRH.TimeCode
		UNION ALL
		-- 불량,수리수량
		SELECT
				DRI.FindLineCode,
				DRI.FindRouteCode,
				DRI.FindJobdate,
				DRI.FindShiftCode,
				DRI.FindTimeCode,
				0,
				SUM(DRI.DefectQty),
				SUM(DRI.RepairQty),
				SUM(DRI.LossQty)
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE
				DRI.ControlNo = @ControlNo
		GROUP BY
				DRI.FindLineCode,
				DRI.FindRouteCode,
				DRI.FindJobdate,
				DRI.FindShiftCode,
				DRI.FindTimeCode
	)
		-- -- Summary에서 기존 정보로 차감하고 변경될 품목으로 Summary 재계산을 위해 실적 및 불량 이력 집계 구하기
		INSERT INTO @Summary
		SELECT
				PS.LineCode,
				PS.RouteCode,
				PS.JobDate,
				PS.ShiftCode,
				PS.TimeCode,
				SUM(PS.ProdQty),
				SUM(PS.DefectQty),
				SUM(PS.RepairQty),
				SUM(PS.LossQty)
		FROM
				ProdSummary PS
		GROUP BY
				PS.LineCode,
				PS.RouteCode,
				PS.JobDate,
				PS.ShiftCode,
				PS.TimeCode
				
	--실적이력 삭제
	/*
	INSERT INTO STB_ProdRouteHistRemoveBackup
		SELECT *
		  FROM STB_ProdRouteHist
	     WHERE ControlNo = @ControlNo
	*/
	DELETE FROM STB_ProdRouteHist
	WHERE ControlNo = @ControlNo

	--불량이력 삭제
	/*
	INSERT INTO STB_DefectRepairInfoRemoveBackup
		SELECT *
		  FROM STB_DefectRepairInfo
	     WHERE ControlNo = @ControlNo
	*/
	DELETE FROM STB_DefectRepairInfo
	WHERE ControlNo = @ControlNo

	DECLARE @RowNo INT = 1,
			@Count INT = (SELECT COUNT(*) FROM @Summary),
			@LineCode VARCHAR(20),
			@RouteCode VARCHAR(20),
			@JobDate DATE,
			@ShiftCode VARCHAR(1),
			@TimeCode VARCHAR(2),
			@ProdQty NUMERIC(20,5),
			@DefectQty NUMERIC(20,5),
			@RepairQty NUMERIC(20,5),
			@LossQty NUMERIC(20,5)
	-- Summary 계산
	WHILE @Count >= @RowNo
	BEGIN
		SELECT
				@LineCode = SM.LineCode,
				@RouteCode = SM.RouteCode,
				@JobDate = SM.JobDate,
				@ShiftCode = SM.ShiftCode,
				@TimeCode = SM.TimeCode,
				@ProdQty = ISNULL(SM.ProdQty,0),
				@DefectQty = ISNULL(SM.DefectQty,0),
				@RepairQty = ISNULL(SM.RepairQty,0),
				@LossQty = ISNULL(SM.LossQty,0)
		FROM
				@Summary SM
		WHERE
				SM.IDX = @RowNo

		SET @ProdQty = @ProdQty * -1
		SET @DefectQty = @DefectQty * -1
		SET @RepairQty = @RepairQty * -1
		SET @LossQty = @LossQty * -1
		-- 이전 PO는 Summary 차감
		
		EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
											@pWorkCenterCode = @WorkCenterCode,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pPONo = @BefPONo,
											@pJobDate = @JobDate,
											@pShiftCode = @ShiftCode,
											@pTimeCode = @TimeCode,
											@pProdQty = @ProdQty,
											@pDefectQty = @DefectQty,
											@pRepairQty = @RepairQty,
											@pLossQty = @LossQty

		SET @RowNo = @RowNo + 1
	END

	-- SetInfo 삭제
	INSERT INTO STB_SetInfoRemoveBackup
	(
		ControlNo
       ,PONo
       ,DayPlanNo
       ,MaterialCode
       ,SetSeq
       ,IsLineInput
       ,IsLoss
       ,IsDefect
       ,CurrentRouteCode
       ,InternalProdNo
       ,OutSetNo
       ,OutSetNoSeq
       ,Barcode
       ,InputLineCode
       ,InputJobDate
       ,InputShiftCode
       ,InputDateTime
       ,DefectQty
       ,IsProdFinish
       ,ProdFinishJobDate
       ,ProdFinishShiftCode
       ,ProdFinishDateTime
       ,SalesOrderNo
       ,SOISequence
       ,IsOutboundFinalInspection
       ,IsFinalInspection
       ,FinalInspectionJobDate
       ,FinalInspectionShiftCode
       ,FinalInspectionDateTime
       ,LotNumber
       ,LotCreateDateTime
       ,LotDecisionResult
       ,GradeCode
       ,GradeChangeJobDate
       ,GradeChangeShiftCode
       ,GradeChangeDateTime
       ,GradeChangeUserID
       ,GradeModelCode
       ,GradeChangeSetNo
       ,PrintDate
       ,LineOutTactTime
       ,ProdQty
       ,BefDayPlanNo
       ,SIExtText01
       ,SIExtText02
       ,SIExtText03
       ,SIExtText04
       ,SIExtText05
       ,SIExtText06
       ,SIExtText07
       ,SIExtInt01
       ,SIExtInt02
       ,SIExtInt03
       ,SIExtInt04
       ,SIExtInt05
       ,SIExtReal01
       ,SIExtReal02
       ,SIExtReal03
       ,SIExtReal04
       ,SIExtReal05
       ,CreateDateTime
       ,CreateUserID
       ,ChangeDateTime
       ,ChangeUserID
       ,LotUniqueNumber
       ,ModuleLotNumber
       ,Remark
       ,ModuleBarcode
	)
	SELECT ControlNo
          ,PONo
          ,DayPlanNo
          ,MaterialCode
          ,SetSeq
          ,IsLineInput
          ,IsLoss
          ,IsDefect
          ,CurrentRouteCode
          ,InternalProdNo
          ,OutSetNo
          ,OutSetNoSeq
          ,Barcode
          ,InputLineCode
          ,InputJobDate
          ,InputShiftCode
          ,InputDateTime
          ,DefectQty
          ,IsProdFinish
          ,ProdFinishJobDate
          ,ProdFinishShiftCode
          ,ProdFinishDateTime
          ,SalesOrderNo
          ,SOISequence
          ,IsOutboundFinalInspection
          ,IsFinalInspection
          ,FinalInspectionJobDate
          ,FinalInspectionShiftCode
          ,FinalInspectionDateTime
          ,LotNumber
          ,LotCreateDateTime
          ,LotDecisionResult
          ,GradeCode
          ,GradeChangeJobDate
          ,GradeChangeShiftCode
          ,GradeChangeDateTime
          ,GradeChangeUserID
          ,GradeModelCode
          ,GradeChangeSetNo
          ,PrintDate
          ,LineOutTactTime
          ,ProdQty
          ,BefDayPlanNo
          ,SIExtText01
          ,SIExtText02
          ,SIExtText03
          ,SIExtText04
          ,SIExtText05
          ,SIExtText06
          ,SIExtText07
          ,SIExtInt01
          ,SIExtInt02
          ,SIExtInt03
          ,SIExtInt04
          ,SIExtInt05
          ,SIExtReal01
          ,SIExtReal02
          ,SIExtReal03
          ,SIExtReal04
          ,SIExtReal05
          ,CreateDateTime
          ,CreateUserID
          ,ChangeDateTime
          ,ChangeUserID
          ,LotUniqueNumber
          ,ModuleLotNumber
          ,Remark
          ,ModuleBarcode
		FROM STB_SetInfo
	    WHERE ControlNo = @ControlNo

	DELETE FROM STB_SetInfo WHERE ControlNo = @ControlNo

	-- 원자재 투입 정보 삭제
	INSERT INTO STB_RawMaterialInputHistRemoveBackup (RawMaterialInputHistNo
                                                     ,Barcode
                                                     ,ProductGroupCode
                                                     ,RawMaterialBarcode
                                                     ,CreateDateTime
                                                     ,CreateUserID
                                                     ,ChangeDateTime
                                                     ,ChangeUserID
                                                     ,LotMaterialCode)
		SELECT RawMaterialInputHistNo
			  ,Barcode
			  ,ProductGroupCode
			  ,RawMaterialBarcode
			  ,CreateDateTime
			  ,CreateUserID
			  ,ChangeDateTime
			  ,ChangeUserID
			  ,LotMaterialCode
		  FROM STB_RawMaterialInputHist
	     WHERE Barcode = @OldBarcode

	DELETE STB_RawMaterialInputHist WHERE Barcode = @OldBarcode

END