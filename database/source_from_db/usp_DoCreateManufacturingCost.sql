-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-09
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified: 
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoCreateManufacturingCost]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @ApplyDate DATE

	-- 현재의 적용일자 
	SELECT @ApplyDate = ApplyDate
	  FROM STB_ManufacturingCostApplyInfo
	 WHERE IsApply = CONVERT(BIT, 1)

	IF @ApplyDate = CONVERT(DATE, GETDATE(), 121) BEGIN -- 적용일자가 오늘과 같으면 생성 불가
		EXEC usp_RaiseLocalizedError @pProcessLanguage,'^이미 원가정보가 구성되어 있습니다.^'
		RETURN
	END

	-- 적용일자 기준 원가 데이터 생성
	INSERT INTO STB_ManufacturingCostByRoute (
			ApplyDate
           ,CompanyCode
           ,WorkCenterCode
           ,MaterialCode
           ,CostTypeCode
           ,IsManual
           ,RouteCode
           ,CostPrice
           ,CreateDateTime
           ,CreateUserID
           ,ChangeDateTime
           ,ChangeUserID
           ,IsUsed)
		SELECT CONVERT(DATE, GETDATE(), 121)
              ,CompanyCode
              ,WorkCenterCode
              ,MaterialCode
              ,CostTypeCode
              ,IsManual
              ,RouteCode
              ,CostPrice
              ,GETDATE()
              ,@pProcessUserID
              ,NULL
              ,NULL
			  ,CONVERT(BIT, 1) -- 사용여부 추가 # 220324
		  FROM STB_ManufacturingCostByRoute
		 WHERE ApplyDate = @ApplyDate

	-- 원가 적용일자 해제
	UPDATE STB_ManufacturingCostApplyInfo
	   SET IsApply = CONVERT(BIT, 0)
	 WHERE IsApply = CONVERT(BIT, 1)

	 -- 신규 적용일자 입력
	 INSERT INTO STB_ManufacturingCostApplyInfo (ApplyDate, IsApply, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
		VALUES (CONVERT(DATE, GETDATE(), 121), CONVERT(BIT, 1), GETDATE(), @pProcessUserID, NULL, NULL)
END