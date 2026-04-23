-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-07-22
-- Browsable : true
-- Group : 생산관리
-- Description:	박스실적을 취소처리합니다.
-- Modified: 2021-July-23: by Mr.Tung on  due Vietnam Model is not setting IsUseLot in F110 Screen
--  exec usp_DoCancelProdPacking_LotNo '','','V-28','VVPR153R010507'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelProdPacking_LotNo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pBarcode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	




	DECLARE @RouteCode VARCHAR(20) = @pRouteCode,
			@LotNo VARCHAR(20) = @pBarcode

	print 'barocde'+@pBarcode

	DECLARE @PackingID VARCHAR(50),
			@MaterialDocNo VARCHAR(20),
			@ControlNo VARCHAR(20),
			@ProdRouteHistNo VARCHAR(20),
			@PONo VARCHAR(20)

	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @TimeCode VARCHAR(2)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @CurrentLotNo VARCHAR(50)

	
	 ---Mr.Triều add For the Ha Nam factory, cancellation of combined boxes is prohibited if the goods have already been successfully received into the warehouse.
	if(@LotNo like 'VE%' OR @LotNo like 'SP%' OR @LotNo like 'RW%')
	BEGIN
	   DECLARE @IsBarcoddeInWareHouse BIT;
	   IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE LotNo = @LotNo)
       BEGIN
          SET @IsBarcoddeInWareHouse = 1;
       END
	   IF(@IsBarcoddeInWareHouse=1)
	   BEGIN
	      RAISERROR(N'Lot này đã được nhập kho,không thể huỷ gộp box.Nếu muốn huỷ liên hệ Chị Xuân kho thành phẩm', 16, 1);
          RETURN;
	   END
	   

	END


	DECLARE @MaterialDocInfo TABLE
	(
		IDX INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		PONo VARCHAR(20),
		ControlNo VARCHAR(20),
		LotNo VARCHAR(50),
		StockQty NUMERIC(20,5)
	)

	-- 실적취소 대상이 된 Lot No를 이력 테이블에 입력한다. 2020.07.28 By Jackaroe
	INSERT INTO STB_ProdRouteHistCancelHist (LotNo, CreateUserID) VALUES (@LotNo, @pProcessUserID)

	-- select * from STB_MaterialLotInfo where LotNo in('VVPR133R038702','VVPR153R010507')
		--raiserror(@pBarcode,1,16)
			--	return;


		--  Add by Mr.Tung on 2021-July-23 due Vietnam Model is not setting IsUseLot in F110 Screen
		if(@pBarcode like 'V%' or @pBarcode like 'MV%') begin
				
				DELETE	STB_ProdRouteHist  
				where RouteCode in ('V-28','V-28_BG','VE10','E-28' ,'MV-05')
				and ControlNo in (select ControlNo from
									stb_setinfo si with(nolock) 
									where si.Barcode = @pBarcode
									and isnull((select count(*) from STB_MaterialLotInfo with(nolock)  where  lotno = @pBarcode),0)=0
									)
		end
		print 'barcode'+@pBarcode
	INSERT INTO @MaterialDocInfo
	(
		MaterialDocNo,
		PONo,
		ControlNo,
		LotNo,
		StockQty
	)
	SELECT
			MDPLI.MaterialDocNo,
			SI.PONo,
			SI.ControlNo,
			MDPLI.LotNo,
			MDPLI.StockQty
	FROM
			STB_MaterialDocLotInfo MDLI
			INNER JOIN STB_MaterialDocInfo MDI
				ON MDI.MaterialDocNo = MDLI.MaterialDocNo AND
				MDI.IsCancel = 0
			INNER JOIN STB_MaterialDocLotInfo MDPLI
				ON MDPLI.PackingID = MDLI.PackingID --and  MDLI.LotNo=MDPLI.LotNo Mr.Trieu add nếu mà trùng packing
			INNER JOIN STB_MaterialDocInfo MDPI
				ON MDPI.MaterialDocNo = MDPLI.MaterialDocNo AND
				MDPI.IsCancel = 0
			INNER JOIN STB_SetInfo SI
				ON SI.Barcode = MDPLI.LotNo
	WHERE
			MDLI.LotNo = @LotNo

	DECLARE @Count INT = (SELECT COUNT(*) FROM @MaterialDocInfo)
	DECLARE @Row INT = 1

	-- 실적 및 입고 취소
	WHILE @Count >= @Row
	BEGIN
		SELECT
				@MaterialDocNo = MDI.MaterialDocNo,
				@PONo = MDI.PONo,
				@ControlNo = MDI.ControlNo,
				@CurrentLotNo = MDI.LotNo,
				@ProdQty = MDI.StockQty
		FROM
				@MaterialDocInfo MDI
		WHERE
				IDX = @Row

		SET @ProdRouteHistNo = NULL
		
		--declare @fd varchar(50)= @ProdQty
		--if(@lotno like 'VE%')
		--RAISERROR(@RouteCode,16,1)
		SELECT
				TOP 1
				@ProdRouteHistNo = PRH.ProdRouteHistNo
		FROM
				STB_ProdRouteHist PRH
		WHERE
				PRH.RouteCode = @RouteCode AND
				PRH.ControlNo = @ControlNo AND
				PRH.ProdQty >= @ProdQty
		ORDER BY
				PRH.JobDate DESC,
				PRH.ProdQty

				
		--declare @fd varchar(50)= 'fdfss' +@ProdRouteHistNo + 'ddddđ'
		--RAISERROR(@ProdRouteHistNo,16,1)
		--return
		IF ISNULL(@ProdRouteHistNo,'') = ''
		BEGIN
				SET @ErrorMessage = '취소할 실적을 찾을수 없습니다 [' + @CurrentLotNo + ']'
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMessage
				RETURN
		END
		-- PO 완료수량 수정
		UPDATE STB_ProductionOrderInfo
		SET
				ProdFinishQty = ProdFinishQty - @ProdQty
		WHERE
				PONo = @PONo
		
		UPDATE STB_ProdRouteSummary
		SET
				OutputQty = OutputQty - @ProdQty
		FROM
				STB_ProdRouteSummary PRS
				INNER JOIN STB_ProdRouteHist PRH
					ON PRH.RouteCode = PRS.RouteCode AND
					PRH.PONo = PRS.PONo AND
					PRH.JobDate = PRS.JobDate AND
					PRH.ShiftCode = PRS.ShiftCode AND
					PRH.TimeCode = PRS.TimeCode
		WHERE
				PRH.ProdRouteHistNo = @ProdRouteHistNo

		-- 실적 차감
		UPDATE	STB_ProdRouteHist
		SET
				ProdQty = ProdQty - @ProdQty
		WHERE
				ProdRouteHistNo = @ProdRouteHistNo

		DELETE	FROM STB_ProdRouteHist
		WHERE
				ProdRouteHistNo = @ProdRouteHistNo AND
				ProdQty = 0

	

		IF @@ROWCOUNT > 0
		BEGIN
			-- 작업자이력 삭제
			DELETE FROM STB_ProdRouteWorkerHist
			WHERE
					ProdRouteHistNo = @ProdRouteHistNo
		END

		UPDATE	STB_SetInfo
		SET
				IsProdFinish = 0,
				ProdFinishDateTime = NULL,
				ProdFinishJobDate = NULL,
				ProdFinishShiftCode = NULL
		WHERE
				ControlNo = @ControlNo AND
				IsProdFinish = 1
		
		EXEC usp_DoCancelMaterialDoc	@pProcessLanguage = @pProcessLanguage,
										@pProcessUserID = @pProcessUserID,
										@pMaterialDocNo = @MaterialDocNo
		SET @Row = @Row + 1
	END

END

