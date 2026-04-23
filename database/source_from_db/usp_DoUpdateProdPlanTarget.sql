-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-07-17
-- Description:	STB_ProdPlan테이블의 CurrentTargetQty를 Update하는 프로시저
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateProdPlanTarget]
	@pCompanyCode VARCHAR(20) = 'VNT',
	@pWorkCenterCode VARCHAR(20) = 'VNT_F1'
AS
BEGIN
		--RETURN
		-- 임시..
		DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
		DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		DECLARE @LineCode VARCHAR(20) = ''

		DECLARE @JobDateTime DATETIME = GETDATE()
		DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(@JobDateTime, @CompanyCode, @WorkCenterCode, NULL, NULL, NULL)
		DECLARE @JobDate DATE = SUBSTRING(@JobDateShift, 1, 8)
		--DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift, 9, 1)

		-- 라인정보 초기화 : 
		 --EXEC usp_DoInitializeLineLoss

		--생산계획에 현재 시간까지의 근무시간을 추가한 정보를 임시테이블에 넣는다.
		DECLARE @TargetTable TABLE
				(
					RowNumber INT IDENTITY,
					PlanType VARCHAR(10),
					ProdPlanNo VARCHAR(20),
					JobDate VARCHAR(10),
					LineCode VARCHAR(20),
					ShiftCode VARCHAR(1),
					PlanPriority VARCHAR(4),
					ModelCode VARCHAR(50),
					PlanQty INT,
					TactTime FLOAT,
					PlanTimeCost INT,
					ShiftWorkingTime INT
				)

		-- 잔여계획
		--금일계획
		INSERT INTO @TargetTable
		SELECT
				*
		FROM
				(
						--SELECT
						--		'REMAIN' AS PlanType,
						--		CONVERT(VARCHAR, PPI.RemainPlanNo) AS ProdPlanNo,
						--		CONVERT(VARCHAR(10), PPI.PlanJobDate, 120) AS JobDate,
						--		PPI.LineCode,
						--		PPI.PlanShiftCode AS ShiftCode,
						--		-1 AS PlanPriority,
						--		FPMP.MaterialCode AS ModelCode,
						--		PPI.RemainQty AS PlanQty,
						--		PPI.PlanCT AS TactTime,
						--		--PPI.PlanQty * ISNULL(PPI.PlanCT, 0) AS PlanTimeCost,
						--		PPI.RemainQty * PPI.PlanCT AS PlanTimeCost,
						--		(
						--			SELECT
						--					SUM(WorkingTime)
						--			FROM
						--					(
						--						SELECT
						--								TimeTemp.ShiftCode,
						--								CASE
						--									--현재 시간이 EndTime보다 크면 EndTime - StartTime
						--									WHEN TimeTemp.FixEndTime < @JobDateTime
						--										THEN DATEDIFF(SECOND, TimeTemp.FixStartTime, TimeTemp.FixEndTime)
						--									--현재 시간이 StartTime과 EndTime 사이이면 현재시간 - StartTime
						--									ELSE
						--										DATEDIFF(SECOND, TimeTemp.FixStartTime, @JobDateTime)
						--								END AS WorkingTime
						--						FROM
						--								(
						--									--시간만 있는 테이블에 날짜를 조합한 StartTime, EndTime으로 SELECT한다.		
						--									SELECT
						--											CD.ShiftCode,
						--											CD.StartDateTime AS FixStartTime,
						--											CD.EndDateTime AS FixEndTime
						--									FROM
						--											STB_DayWorkCalendarDetail CD WITH(NOLOCK)
						--									WHERE
						--											CD.IsWork = 1
						--											AND CD.DayWorkCalendarNo =	dbo.fnGetDayWorkCalendarNo(@JobDateTime, @CompanyCode,@WorkCenterCode,@LineCode,NULL,NULL)
						--																	--(
						--																	--	SELECT
						--																	--			CalendarCode
						--																	--	FROM 
						--																	--			STB_DayCalendar
						--																	--	WHERE 
						--																	--			JobDate = PPI.JobDate 
						--																	--			AND LineCode = PPI.LineCode 
						--																	--			AND ShiftCode = PPI.ShiftCode
						--																	--)
						--								) AS TimeTemp
						--						WHERE
						--								TimeTemp.FixStartTime <= @JobDateTime
										
						--					) AS TimeTable
						--			WHERE
						--					TimeTable.ShiftCode = PPI.PlanShiftCode
						--		) AS ShiftWorkingTime
						--FROM
						--		STB_RemainPlanInfo PPI WITH(NOLOCK)
						--		LEFT OUTER JOIN STB_FacilityProdMainPlan FPMP WITH (NOLOCK)
						--			ON (FPMP.FPMainPlanNo = PPI.FPMainPlanNo)
						--WHERE
						--		PPI.PlanJobDate = @JobDate
						--UNION ALL
						SELECT
								'CURRENT' AS PlanType,
								DPP.DayPlanNo AS ProdPlanNo,
								CONVERT(VARCHAR(10), DPP.PlanDate, 120) AS JobDate,
								DPP.LineCode,
								DPP.PlanShiftCode AS ShiftCode,
								ISNULL(DPP.ProdPrior, 1) AS PlanPriority,
								DPP.MaterialCode,
								DPP.PlanQty,
								DPP.PlanCT AS TactTime,
								--PPI.PlanQty * ISNULL(PPI.PlanCT, 0) AS PlanTimeCost,
								DPP.PlanQty * DPP.PlanCT AS PlanTimeCost,
								(
									SELECT
											SUM(WorkingTime)
									FROM
											(
												SELECT
														TimeTemp.ShiftCode,
														CASE
															--현재 시간이 EndTime보다 크면 EndTime - StartTime
															WHEN TimeTemp.FixEndTime < @JobDateTime
																THEN DATEDIFF(SECOND, TimeTemp.FixStartTime, TimeTemp.FixEndTime)
															--현재 시간이 StartTime과 EndTime 사이이면 현재시간 - StartTime
															ELSE
																DATEDIFF(SECOND, TimeTemp.FixStartTime, @JobDateTime)
														END AS WorkingTime
												FROM
														(
															--시간만 있는 테이블에 날짜를 조합한 StartTime, EndTime으로 SELECT한다.		
															SELECT
																	CD.ShiftCode,
																	CD.StartDateTime AS FixStartTime,
																	CD.EndDateTime AS FixEndTime
															FROM
																	STB_DayWorkCalendarDetail CD WITH(NOLOCK)
															WHERE
																	CD.IsWork = 1
																	AND CD.DayWorkCalendarNo =	dbo.fnGetDayWorkCalendarNo(@JobDateTime, @CompanyCode,@WorkCenterCode,@LineCode,NULL,NULL)
																							--(
																							--	SELECT
																							--			CalendarCode
																							--	FROM 
																							--			STB_DayCalendar
																							--	WHERE 
																							--			JobDate = PPI.JobDate 
																							--			AND LineCode = PPI.LineCode 
																							--			AND ShiftCode = PPI.ShiftCode
																							--)
														) AS TimeTemp
												WHERE
														TimeTemp.FixStartTime <= @JobDateTime
										
											) AS TimeTable
									WHERE
											TimeTable.ShiftCode = DPP.PlanShiftCode
								) AS ShiftWorkingTime
						FROM
								STB_DayProdPlan DPP WITH(NOLOCK)
						WHERE
								DPP.PlanDate = @JobDate AND
								ISNULL(DPP.IsFixed,0) = 1 AND
								ISNULL(DPP.IsCancel,0) = 0
		) PPI
		ORDER BY
				PPI.JobDate,
				PPI.LineCode,
				PPI.ShiftCode,
				PPI.PlanPriority
				
		DECLARE @RowCount INT = (SELECT MAX(RowNumber) FROM @TargetTable)
		--SET @RowCount = (SELECT MAX(RowNumber) FROM @TargetTable)
		DECLARE @CurrentRow INT = 1

		DECLARE @LeftWorkingTime INT = 0 --PlanPriority가 '0001' 인 경우는 교대조 시작 부터 지금까지의 근무시간. 
										--PlanPriority가 여러개인 경우, 루프를 돌면서 이전 루프에서 완료된 PlanPriority의 소요 시간을 제하고 남은 근무시간을 저장할 변수. 								

		DECLARE @CurrentJobDate DATE,
				@CurrentLineCode VARCHAR(20),
				@CurrentShiftCode VARCHAR(1),
				@CurrentPlanPriority VARCHAR(4),
				@CurrentPlanQty INT,
				@CurrentTactTime FLOAT,
				@CurrentPlanTimeCost INT,
				@CurrentShiftWorkingTime INT,
				@ModelCode VARCHAR(50),
				@ProdPlanNo VARCHAR(20),
				@PlanType VARCHAR(10)
				
		DECLARE @TempJobDate DATE,
				@TempLineCode VARCHAR(20),
				@TempShiftCode VARCHAR(1)
				
				

		WHILE @CurrentRow <= @RowCount
			BEGIN
					SELECT
							@PlanType = PlanType,
							@ProdPlanNo = ProdPlanNo,
							@CurrentJobDate = JobDate,
							@CurrentLineCode = LineCode,
							@CurrentShiftCode = ShiftCode,
							@CurrentPlanPriority = PlanPriority,
							@CurrentPlanQty = PlanQty,
							@CurrentTactTime = TactTime,
							@CurrentPlanTimeCost = PlanTimeCost,
							@CurrentShiftWorkingTime = ShiftWorkingTime
					FROM
							@TargetTable
					WHERE
							RowNumber = @CurrentRow

					--IF @CurrentShiftWorkingTime IS NULL BEGIN		-- 2018-05-31 JGH 수정 근무카렌더가 없을경우 다음으로
					--		--다음 루프를 돌 때 PlanPriority만 증가한 데이터를 처리해야 할 경우도 있으므로 현재 JobDate, LineCode, ShiftCode를 임시로 저장해 놓는다.
					--		SET @TempJobDate = @CurrentJobDate
					--		SET @TempLineCode = @CurrentLineCode
					--		SET @TempShiftCode = @CurrentShiftCode
					
					--		--루프를 돌면서 처리해야 하므로 현재 행을 1 증가 시킨다.
					--		SET @CurrentRow = @CurrentRow + 1
					--END
					
					IF @CurrentJobDate = @TempJobDate
						AND @CurrentLineCode = @TempLineCode
						AND @CurrentShiftCode = @TempShiftCode
						
							--JobDate, LineCode, ShiftCode는 같으나 PlanPriority는 다른 데이터를 처리하는 구문. 즉, 해당 일자, 라인, 교대조에 
							BEGIN
									
									--IF @PlanType = 'REMAIN'
									--BEGIN
									--		--나머지 시간이 계획을 완료하기 위해 필요한 시간보다 클 경우
									--		IF @CurrentPlanTimeCost <= @LeftWorkingTime
									--				BEGIN
									--					UPDATE
									--							STB_RemainPlanInfo
									--					SET
									--							CurrentTarget = @CurrentPlanQty
									--					WHERE
									--							RemainPlanNo = @ProdPlanNo
									--							--PlanInputDate = @CurrentJobDate
									--							--AND LineCode = @CurrentLineCode
									--							--AND PlanInputShiftCode = @CurrentShiftCode
									--							--AND PlanPrior = @CurrentPlanPriority
													
									--					SET @LeftWorkingTime = @LeftWorkingTime - @CurrentPlanTimeCost
									--				END
									--		--나머지 시간이 계획 완료 소요시간 보다 적을 경우
									--		ELSE IF @CurrentPlanTimeCost > @LeftWorkingTime
									--				BEGIN
									--					UPDATE
									--							STB_RemainPlanInfo
									--					SET
									--							CurrentTarget = ISNULL(@LeftWorkingTime / @CurrentTactTime, 0)
									--					WHERE
									--							RemainPlanNo = @ProdPlanNo
									--							--PlanInputDate = @CurrentJobDate
									--							--AND LineCode = @CurrentLineCode
									--							--AND PlanInputShiftCode = @CurrentShiftCode
									--							--AND PlanPrior = @CurrentPlanPriority
												
									--					SET @LeftWorkingTime = 0
									--				END
									--		--나머지 시간이 0이면 아직 생산 계획 실행 시간이 되지 않은 PlanPriority이므로 CurrentTargetQty에 0을 넣어준다.
									--		ELSE IF @LeftWorkingTime = 0
									--				BEGIN
									--					UPDATE
									--							STB_RemainPlanInfo
									--					SET
									--							CurrentTarget = 0
									--					WHERE
									--							RemainPlanNo = @ProdPlanNo
									--							--PlanInputDate = @CurrentJobDate
									--							--AND LineCode = @CurrentLineCode
									--							--AND PlanInputShiftCode = @CurrentShiftCode
									--							--AND PlanPrior = @CurrentPlanPriority
												
									--					SET @LeftWorkingTime = 0
									--				END
									--END ELSE BEGIN
											--나머지 시간이 계획을 완료하기 위해 필요한 시간보다 클 경우
											IF @CurrentPlanTimeCost <= @LeftWorkingTime
													BEGIN
														UPDATE
																STB_DayProdPlan
														SET
																CurrentTarget = @CurrentPlanQty
														WHERE
																DayPlanNo = @ProdPlanNo
																--PlanInputDate = @CurrentJobDate
																--AND LineCode = @CurrentLineCode
																--AND PlanInputShiftCode = @CurrentShiftCode
																--AND PlanPrior = @CurrentPlanPriority
													
														SET @LeftWorkingTime = @LeftWorkingTime - @CurrentPlanTimeCost
													END
											--나머지 시간이 계획 완료 소요시간 보다 적을 경우
											ELSE IF @CurrentPlanTimeCost > @LeftWorkingTime
													BEGIN
														UPDATE
																STB_DayProdPlan
														SET
																CurrentTarget = ISNULL(@LeftWorkingTime / @CurrentTactTime, 0)
														WHERE
																DayPlanNo = @ProdPlanNo
																--PlanInputDate = @CurrentJobDate
																--AND LineCode = @CurrentLineCode
																--AND PlanInputShiftCode = @CurrentShiftCode
																--AND PlanPrior = @CurrentPlanPriority
												
														SET @LeftWorkingTime = 0
													END
											--나머지 시간이 0이면 아직 생산 계획 실행 시간이 되지 않은 PlanPriority이므로 CurrentTargetQty에 0을 넣어준다.
											ELSE IF @LeftWorkingTime = 0
													BEGIN
														UPDATE
																STB_DayProdPlan
														SET
																CurrentTarget = 0
														WHERE
																DayPlanNo = @ProdPlanNo
																--PlanInputDate = @CurrentJobDate
																--AND LineCode = @CurrentLineCode
																--AND PlanInputShiftCode = @CurrentShiftCode
																--AND PlanPrior = @CurrentPlanPriority
												
														SET @LeftWorkingTime = 0
													END
									--END	--IF @PlanType = 'REMAIN'
							END
					ELSE
							--JobDate, LineCode, ShiftCode가 같은, PlanPriority만 증가하는 이어지는 데이터가 아닐 경우의 처리
							BEGIN
							
									SET @LeftWorkingTime = @CurrentShiftWorkingTime --이전에 루프를 돌면서 처리할 때 사용된 데이터가 들어있으므로 @CurrentShiftWorkingTime을 다시 넣어줌.
									

									--IF @PlanType = 'REMAIN'
									--BEGIN
									--		IF @CurrentPlanTimeCost <= @LeftWorkingTime 
									--				--지금까지의 근무시간이 계획을 완료하기 위해 필요한 시간보다 클 경우
									--				BEGIN
									--						UPDATE
									--							STB_RemainPlanInfo
									--						SET
									--							CurrentTarget = @CurrentPlanQty
									--						WHERE
									--							RemainPlanNo = @ProdPlanNo
									--							--PlanInputDate = @CurrentJobDate
									--							--AND LineCode = @CurrentLineCode
									--							--AND PlanInputShiftCode = @CurrentShiftCode
									--							--AND PlanPrior = @CurrentPlanPriority
													
									--						SET @LeftWorkingTime = @LeftWorkingTime - @CurrentPlanTimeCost
									--				END
									--		ELSE
									--				--지금까지의 근무시간이 계획을 완료하기 위해 필요한 시간보다 적을 경우
									--				BEGIN
									--						UPDATE
									--							STB_RemainPlanInfo
									--						SET
									--							CurrentTarget = ISNULL(@LeftWorkingTime / @CurrentTactTime, 0)
									--						WHERE
									--							RemainPlanNo = @ProdPlanNo
									--							--PlanInputDate = @CurrentJobDate
									--							--AND LineCode = @CurrentLineCode
									--							--AND PlanInputShiftCode = @CurrentShiftCode
									--							--AND PlanPrior = @CurrentPlanPriority
													
									--						SET @LeftWorkingTime = 0
									--				END
									--END ELSE BEGIN
											IF @CurrentPlanTimeCost <= @LeftWorkingTime 
													--지금까지의 근무시간이 계획을 완료하기 위해 필요한 시간보다 클 경우
													BEGIN
															UPDATE
																STB_DayProdPlan
															SET
																CurrentTarget = @CurrentPlanQty
															WHERE
																DayPlanNo = @ProdPlanNo
																--PlanInputDate = @CurrentJobDate
																--AND LineCode = @CurrentLineCode
																--AND PlanInputShiftCode = @CurrentShiftCode
																--AND PlanPrior = @CurrentPlanPriority
													
															SET @LeftWorkingTime = @LeftWorkingTime - @CurrentPlanTimeCost
													END
											ELSE
													--지금까지의 근무시간이 계획을 완료하기 위해 필요한 시간보다 적을 경우
													BEGIN
															UPDATE
																STB_DayProdPlan
															SET
																CurrentTarget = ISNULL(@LeftWorkingTime / @CurrentTactTime, 0)
															WHERE
																DayPlanNo = @ProdPlanNo
																--PlanInputDate = @CurrentJobDate
																--AND LineCode = @CurrentLineCode
																--AND PlanInputShiftCode = @CurrentShiftCode
																--AND PlanPrior = @CurrentPlanPriority
													
															SET @LeftWorkingTime = 0
													END
									--END	IF @PlanType = 'REMAIN'
							END	
					
					--다음 루프를 돌 때 PlanPriority만 증가한 데이터를 처리해야 할 경우도 있으므로 현재 JobDate, LineCode, ShiftCode를 임시로 저장해 놓는다.
					SET @TempJobDate = @CurrentJobDate
					SET @TempLineCode = @CurrentLineCode
					SET @TempShiftCode = @CurrentShiftCode
					
					--루프를 돌면서 처리해야 하므로 현재 행을 1 증가 시킨다.
					SET @CurrentRow = @CurrentRow + 1
			END		



END

