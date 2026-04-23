-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-03-04
-- Browsable : true
-- Group : 포장라벨 출력 횟수 누적 및 출력 가능여부 체크
-- Description: 
-- =============================================
CREATE Proc [dbo].[usp_PackingLabelPrintInfo]
     @pProcessLanguage VARCHAR(20)
	,@pProcessUserID VARCHAR(20)
	,@pPackingID VARCHAR(20)
AS
BEGIN
	Declare @PackingID VARCHAR(20) = @pPackingID
	       ,@CompanyCode VARCHAR(20) 
		   ,@workCenterCode VARCHAR(20) -- Mr.Duy check <> VVT_F3
	-- User's Company Code Check
	SELECT @CompanyCode = CompanyCode ,@workCenterCode=WorkCenterCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	--IF (@CompanyCode = 'VVT' and @workCenterCode <> 'VVT_F3') BEGIN	
	--	IF EXISTS (SELECT 1 FROM STB_PackingLabelPrintHist WHERE PackingID = @PackingID AND IsPrintAllow = CONVERT(BIT, 0)) BEGIN
	--		EXEC usp_RaiseLocalizedError @pProcessLanguage, '이 패킹ID는 더이상 출력할 수 없습니다. EA팀에 연락하세요.'
	--	END
	--END

	UPDATE STB_PackingLabelPrintHist
	   SET PrintCount = PrintCount + 1
	      ,ChangeDateTime = GETDATE()
		  ,ChangeUserID = @pProcessUserID
	 WHERE PackingID = @PackingID

	 IF @@ROWCOUNT = 0 BEGIN
		INSERT INTO STB_PackingLabelPrintHist (PackingID, CreateUserID)
			VALUES (@PackingID, @pProcessUserID)
	 END
END

