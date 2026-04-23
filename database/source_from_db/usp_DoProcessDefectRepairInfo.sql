-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 품질관리
-- Description:	불량정보를 등록합니다
-- Modified:
--             2020.04.13 같은불량코드로 중복입력 안되게 (채민수대리 요청사항)
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessDefectRepairInfo]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pCompanyCode VARCHAR(20),
					@pWorkCenterCode VARCHAR(20),
					@pPONo VARCHAR(20),
					@pDayPlanNo VARCHAR(20) = NULL,
					@pMaterialCode VARCHAR(50),
					@pBomVersion VARCHAR(20),
					@pLineCode VARCHAR(20),
					@pRouteCode VARCHAR(20),
					@pControlNo VARCHAR(20),
					@pDefectCode VARCHAR(20) = NULL,
					@pDefectQty NUMERIC(20,5) = NULL,
					@pProcessDateTime DATETIME,
					@pMarkingCode VARCHAR(20)= NULL,
					@pDefectCauseID VARCHAR(100)=NULL,
					@pDefectSummaryNo VARCHAR(20) = NULL OUTPUT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @ControlNo VARCHAR(20) = @pControlNo
	DECLARE @DefectCode VARCHAR(20) = @pDefectCode
	DECLARE @DefectQty NUMERIC(20,5) = @pDefectQty
	DECLARE @ProcessDateTime DATETIME = @pProcessDateTime
	DECLARE @MarkingCode VARCHAR(20) = @pMarkingCode
	DECLARE @DefectCauseID varchar(100)=@pDefectCauseID
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = ISNULL(@pDayPlanNo,'')
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @BomVersion VARCHAR(20) = @pBomVersion
	DECLARE @DefectSummaryNo VARCHAR(20)
	-- Mr.Triêu change for input PQC  qty for Ha Nam Factory
	-- 포장의 경우 불량수량을 마이너스로 등록할 수 있도록 예외처리함. 2019.09.03 By Jackaroe

	--RAISERROR(@WorkCenterCode ,16, 1)     
	--RETURN
	IF @WorkCenterCode <> 'VVT_F4'
	BEGIN
		IF @RouteCode not in ('E-28', 'V-28', 'E-33', 'EM-03', 'M-06','VE10','VE08')  
	
		 BEGIN
			IF @DefectQty <= 0 BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '불량수량은 0보다 커야합니다'
					RETURN
			END
		END
	END

	SELECT
			@DefectSummaryNo = DRI.DefectSummaryNo
	FROM
			STB_DefectRepairInfo DRI
	WHERE
			DRI.ControlNo = @ControlNo AND
			DRI.FindDateTime = @ProcessDateTime
	
	IF @DefectSummaryNo IS NULL BEGIN
			DECLARE @JobDateShift Varchar(20) = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
			DECLARE @JobDate      Date         = SUBSTRING(@JobDateShift,1,8)
			DECLARE @ShiftCode    Varchar(1)  = SUBSTRING(@JobDateShift,9,1)
			DECLARE @TimeCode    Varchar(2)  = SUBSTRING(@JobDateShift,10,2)
			DECLARE @CN            Varchar(2)                                                                    -- 2020.04.13 변수추가


			---- START  : 2020.04.13 (채민수대리 요청사항 - 같은 불량코드로 중복불량되지 않도록 개선)  --> TEST : VJKM102R710613
			--Select  @CN = SUM(AA.CN) 
   --          from (
			--			Select Distinct (DefectCode)
			--					, DefectQty
			--					, ControlNo
			--					, Count(DefectCode)         AS CN
			--			From STB_DefectRepairInfo
			--			Where  1=1 
			--               And ControlNo = @ControlNo
			--			   And FindRouteCode = @RouteCode
			--			   And  FindLineCode = @LineCode
			--		    Group by DefectCode, ControlNo, DefectQty
			--	   )  AA
   --            Having SUM(AA.CN) > 1
			
			--IF  @CN > 1
			--BEGIN
			--	 RAISERROR(' 이미 같은 불량코드로 등록되었습니다. 중복등록이 불가합니다.' ,16, 1)     
			--	 RETURN
			--END
			-- ---- END -----------------------------------------------------------------------------------------------------------------------------------------------------

			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectRepairInfo', @DefectSummaryNo OUTPUT
	

			-- 불량정보Table Insert부분
			INSERT INTO STB_DefectRepairInfo
			(
				DefectSummaryNo,
				CompanyCode,
				WorkCenterCode,
				ControlNo,
				PONo,
				DayPlanNo,
				FindJobdate,
				FindShiftCode,
				FindTimeCode,
				FindLineCode,
				FindRouteCode,
				FindSubRouteCode,
				FindFacilityRouteCode,
				MaterialCode,
				BomVersion,
				FindDateTime,
				DefectCode,
				DefectQty,
				RepairQty,
				LossQty,
				IsDelete,
				RepairType,
				CreateDateTime,
				CreateUserID,
				MarKingCode,
				DefectCauseID
			)
			VALUES
			(
				@DefectSummaryNo,
				@CompanyCode,
				@WorkCenterCode,
				@ControlNo,
				@PONo,
				@DayPlanNo,
				@JobDate,
				@ShiftCode,
				@TimeCode,
				@LineCode,
				@RouteCode,
				'',
				'',
				@MaterialCode,
				@BomVersion,
				@ProcessDateTime,
				@DefectCode,
				@DefectQty,
				0,
				0,
				0,
				'NONE',
				@ProcessDateTime,
				@pProcessUserID,
				@MarkingCode,
				@DefectCauseID

			)


					-- add redopping
				if(@DefectCode like 'V-29%' )
				begin
					INSERT INTO STB_ReDropping
						(
							DefectSummaryNo,
							CompanyCode,
							WorkCenterCode,
							ControlNo,
							PONo,
							DayPlanNo,
							FindJobdate,
							FindShiftCode,
							FindTimeCode,
							FindLineCode,
							FindRouteCode,
							FindSubRouteCode,
							FindFacilityRouteCode,
							MaterialCode,
							BomVersion,
							FindDateTime,
							DefectCode,
							DefectQty,
							RepairQty,
							LossQty,
							IsDelete,
							RepairType,
							CreateDateTime,
							CreateUserID,
							MarKingCode
						)
						VALUES
						(
							@DefectSummaryNo,
							@CompanyCode,
							@WorkCenterCode,
							@ControlNo,
							@PONo,
							@DayPlanNo,
							@JobDate,
							@ShiftCode,
							@TimeCode,
							@LineCode,
							@RouteCode,
							'',
							'',
							@MaterialCode,
							@BomVersion,
							@ProcessDateTime,
							@DefectCode,
							@DefectQty,
							0,
							0,
							0,
							'NONE',
							@ProcessDateTime,
							@pProcessUserID,
							@MarkingCode
						)
				end
				
			EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
																@pWorkCenterCode = @WorkCenterCode,
																@pLineCode = @LineCode,
																@pRouteCode = @RouteCode,
																@pPONo = @PONo,
																@pJobDate = @JobDate,
																@pShiftCode = @ShiftCode,
																@pTimeCode = @TimeCode,
																@pDefectQty = @DefectQty

			UPDATE	STB_SetInfo
			SET
					IsDefect = 1,
					DefectQty = DefectQty + @DefectQty
			WHERE
					ControlNo = @ControlNo
	END
		
	SET @pDefectSummaryNo = @DefectSummaryNo
END


