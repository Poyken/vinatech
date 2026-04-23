-- =============================================
-- Author: SONG JU CHOUL
-- Create date: 2021-09-15
-- Browsable : true
-- Group : 자재관리
-- Description: 생산라인에서 생산중인 제품코드 팝업
-- Modified:
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetProductOfLine_popup]
	@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
   ,@pLineCode VARCHAR(20) = NULL

AS
BEGIN
	
	DECLARE 
		@CompanyCode VARCHAR(20) = @pCompanyCode
	   ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	   ,@LineCode VARCHAR(20) = @pLineCode

	IF @LineCode NOT IN (SELECT LineCode FROM STB_LineInfo WHERE LineType = 'NoneBOM') BEGIN

		SELECT DPP.LineCode
			  --,CASE DPP.LineCode WHEN 'VIETNAMLINE-01' THEN 'VIETNAM' ELSE MM.MaterialCode END AS MaterialCode
			  --,CASE DPP.LineCode WHEN 'VIETNAMLINE-01' THEN 'VIETNAM' ELSE MM.MaterialName END AS MaterialName
			  ,MM.MaterialCode
			  ,MM.MaterialName
		   FROM STB_DayProdPlan DPP
			LEFT OUTER JOIN STB_SetInfo SI
				ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_LineInfo LI
				ON DPP.LineCode = LI.LineCode --And SI.InputLineCode = LI.LineCode
			LEFT OUTER JOIN STB_MaterialMaster MM
				ON DPP.MaterialCode = MM.MaterialCode
		WHERE SI.IsProdFinish = 0
			  AND DPP.LineCode = LI.LineCode
			  AND LI.IsUsed = 1
			  AND DPP.CompanyCode =@CompanyCode				-- 'VNT'
			  AND DPP.WorkCenterCode = @WorkCenterCode		-- 'VNT_F1'
			  AND DPP.LineCode = @LineCode					-- 'ASSYLINE-09'
			  AND MM.MaterialCode Is NOT NULL
		GROUP BY DPP.LineCode, MM.MaterialCode, MM.MaterialName
		ORDER BY MM.MaterialCode

	END ELSE BEGIN

		SELECT @LineCode AS LineCode
			  ,@LineCode AS MaterialCode
			  ,@LineCode AS MaterialName

	END

	IF @@ROWCOUNT = 0
		
		BEGIN

			SELECT  NULL AS CompanyCode
				  ,NULL AS WorkCenterCode
				  ,NULL AS MaterialWarehouseCode
				  ,NULL AS MaterialCode
				  ,NULL AS LotID

			RAISERROR('해당 라인에 작업지시가 존재하지 않아 품목코드를 선택할 수 없습니다.',16,1)

			RETURN
		END
		
END