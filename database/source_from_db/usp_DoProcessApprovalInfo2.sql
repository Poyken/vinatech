-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.06.12
-- Browsable : true
-- Group : 공통
-- Description: 결재처리
-- Modified:
-- ==================================================================================
CREATE PROC [dbo].[usp_DoProcessApprovalInfo2]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pProcessViewName VARCHAR(50)
   ,@pProcessTableName VARCHAR(50)
   ,@pProcessColumnName VARCHAR(50)
   ,@pDocIDColumnName VARCHAR(50)
   ,@pNextApprovalStepID INT = NULL
   ,@pDocID VARCHAR(50) = NULL
   ,@pIsCallBack BIT = NULL
AS
BEGIN
	Declare @ProcessTableName VARCHAR(50) = @pProcessTableName
	       ,@ProcessColumnName VARCHAR(50) = @pProcessColumnName
		   ,@DocIDColumnName VARCHAR(50) = @pDocIDColumnName
		   ,@DocID VARCHAR(50) = @pDocID
		   ,@PresentApprovalStepID INT 
		   ,@NextApprovalStepID INT = @pNextApprovalStepID
           ,@IsCallBack BIT = CASE WHEN ISNULL(@pIsCallBack, '') = '' THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END
		   ,@QueryString VARCHAR(MAX)

		   ,@CallBackID INT
		   ,@ApprovalStepName NVARCHAR(50)
		   ,@Email VARCHAR(200)
		   ,@PhoneNumber VARCHAR(20)
		   ,@Param VARCHAR(MAX)

	--exec 내에서 변수를 인식하지 못하는 상황
	--임시테이블을 생성하여 값을 넘겨본다.
	CREATE TABLE #PresentApprovalStepIDTemp (PresentApprovalStepID INT)

	SET @QueryString = 'INSERT INTO #PresentApprovalStepIDTemp '
	SET @QueryString = @queryString + '	SELECT ' + @ProcessColumnName
	SET @QueryString = @queryString + '	  FROM ' + @ProcessTableName
	SET @QueryString = @queryString + '	 WHERE ' + @DocIDColumnName + ' = ''' + @DocID + ''''

	exec (@QueryString)

	SELECT @PresentApprovalStepID = PresentApprovalStepID FROM #PresentApprovalStepIDTemp

	PRINT CONVERT(VARCHAR, @PresentApprovalStepID)

	IF @PresentApprovalStepID = @NextApprovalStepID BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '결재요청 단계가 이전 단계와 같습니다'
		RETURN
	END

	--IF NOT EXISTS (SELECT 3 FROM STB_ApprovalLineInfo WHERE ApprovalStepID = @NextApprovalStepID AND ProcessViewName = @pProcessViewName) 
	--BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, '결재요청 단계가 존재하지 않습니다'
	--	RETURN
	--END

	-- 문서 상태 업데이트
	SET @QueryString = ' UPDATE ' + @ProcessTableName
	SET @QueryString = @QueryString + '    SET ' + @ProcessColumnName + ' = ' + CONVERT(VARCHAR(10), @NextApprovalStepID)
	SET @QueryString = @QueryString + '  WHERE ' + @DocIDColumnName + ' = ''' + @DocID + ''''

	--select @QueryString
	exec (@QueryString)

	-- CallBackID 확인 및 처리
	IF @IsCallBack = CONVERT(BIT, 1) BEGIN
		SELECT @CallBackID = CallBackID
		      ,@ApprovalStepName = ApprovalStepName
		  FROM STB_ApprovalLineInfo
		 WHERE ProcessViewName = @pProcessViewName
		   AND ApprovalStepID = @NextApprovalStepID

		IF @CallBackID IS NOT NULL BEGIN
			SELECT @Email = Email 
			      ,@PhoneNumber = PhoneNumber
			  FROM STB_ApprovalLineInfo
			 WHERE ProcessViewName = @pProcessViewName
		       AND ApprovalStepID = @CallBackID

			 -- SMS 발송
			 SET @Param = @DocID + ',' + @ApprovalStepName
			 exec usp_DoSendSMS '', '', @PhoneNumber, '부적합 보고서 번호 {#1}가 {#2}되었습니다.', @Param
		END
	END
END