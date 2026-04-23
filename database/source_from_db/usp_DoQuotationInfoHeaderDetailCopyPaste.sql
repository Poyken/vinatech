
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-16
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 견적정보와 견적상세를 복사한다. (선택된 대상으로 참고하여 생성)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoQuotationInfoHeaderDetailCopyPaste]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)

	-- Declare Columns Variable
	-- Base
	DECLARE @BaseOldOrgQuotationNo	varchar(20)
	DECLARE @BaseOrgQuotationNo	varchar(20)
	DECLARE @BaseCompanyCode	varchar(20)
	DECLARE @BaseCustomerCode	varchar(20)
	DECLARE @BaseQuotationCreateDate	date
	DECLARE @BaseQuotationUserID	varchar(20)
	DECLARE @BaseQuotationToName	nvarchar(50)
	DECLARE @BaseQuotationToTelNo	nvarchar(50)
	DECLARE @BaseQuotationToEmail	nvarchar(50)
	DECLARE @BaseOrgQuotationText	nvarchar(100)
	DECLARE @BaseOrgQuotationDesc	nvarchar(MAX)
	DECLARE @BaseCreateDateTime	datetime
	DECLARE @BaseCreateUserID	varchar(20)
	DECLARE @BaseChangeDateTime	datetime
	DECLARE @BaseChangeUserID	varchar(20)

	-- Header
	DECLARE @HeaderOldQuotationNo VARCHAR(20)
	DECLARE @HeaderQuotationNo VARCHAR(20)
	DECLARE @HeaderOrgQuotationNo VARCHAR(20)
	DECLARE @HeaderQuotationSeq INT
	DECLARE @HeaderQuotationDate DATE
	DECLARE @HeaderQuotationVersionDesc NVARCHAR(100)
	DECLARE @HeaderQuotationUserID VARCHAR(20)
	DECLARE @HeaderCurrencyUnit VARCHAR(20)
	DECLARE @HeaderExchangeRate NUMERIC(20,5)
	DECLARE @HeaderTotalAmount NUMERIC(20,5)
	DECLARE @HeaderTotalWonAmount NUMERIC(20,5)
	DECLARE @HeaderNegoTotalAmount NUMERIC(20,5)
	DECLARE @HeaderNegoTotalWonAmount NUMERIC(20,5)
	DECLARE @HeaderQuotationDetailDesc NVARCHAR(MAX)
	DECLARE @HeaderRequestDeliveryDate DATE
	DECLARE @HeaderIsApproval BIT
	DECLARE @HeaderApprovalUserID VARCHAR(20)
	DECLARE @HeaderApprovalDateTime DATETIME
	DECLARE @HeaderCreateDateTime DATETIME
	DECLARE @HeaderCreateUserID VARCHAR(20)
	DECLARE @HeaderChangeDateTime DATETIME
	DECLARE @HeaderChangeUserID VARCHAR(20)

	-- 견적정보 신규 채번
	DECLARE @QuotationNoHeaderNew VARCHAR(20)

	-- 견적상세정보 신규 채번
	DECLARE @QuotationNoDetailNew VARCHAR(20)

	DECLARE @OldQuotationDetailNo VARCHAR(20)
	DECLARE @QuotationDetailNo VARCHAR(20)
	DECLARE @QuotationDetailSeq INT
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @QuotationMaterialCode NVARCHAR(50)
	DECLARE @QuotationMaterialName NVARCHAR(100)
	DECLARE @QuotationMaterialSpec NVARCHAR(MAX)
	DECLARE @QuotationQty NUMERIC(20,5)
	DECLARE @QuotationUnitPrice NUMERIC(20,5)
	DECLARE @QuotationItemDesc NVARCHAR(MAX)
	DECLARE @ChangeUserID VARCHAR(20)

	-- 반복문 변수
	DECLARE @LoopCnt INT
	DECLARE @LoopMaxNo INT

	-- 시퀀스번호
	DECLARE @MaxSeqNo INT

	DECLARE @iDoc INT

	-- 문서시작
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
					-- Base
					CASE
						WHEN BaseOldOrgQuotationNo IS NULL THEN BaseOrgQuotationNo
						ELSE BaseOldOrgQuotationNo
					END AS BaseOldOrgQuotationNo,
					BaseOrgQuotationNo,
					BaseCompanyCode,
					BaseCustomerCode,
					BaseQuotationCreateDate,
					BaseQuotationUserID,
					BaseQuotationToName,
					BaseQuotationToTelNo,
					BaseQuotationToEmail,
					BaseOrgQuotationText,
					BaseOrgQuotationDesc,
					BaseCreateDateTime,
					BaseCreateUserID,
					BaseChangeDateTime,
					BaseChangeUserID,
	
					-- Header
					CASE
						WHEN HeaderOldQuotationNo IS NULL THEN HeaderQuotationNo
						ELSE HeaderOldQuotationNo
					END AS HeaderOldQuotationNo,
					HeaderQuotationNo,
					HeaderOrgQuotationNo,
					HeaderQuotationSeq,
					HeaderQuotationDate,
					HeaderQuotationVersionDesc,
					HeaderQuotationUserID,
					HeaderCurrencyUnit,
					HeaderExchangeRate,
					HeaderTotalAmount,
					HeaderTotalWonAmount,
					HeaderNegoTotalAmount,
					HeaderNegoTotalWonAmount,
					HeaderQuotationDetailDesc,
					HeaderRequestDeliveryDate,
					HeaderIsApproval,
					HeaderApprovalUserID,
					HeaderApprovalDateTime,
					HeaderCreateDateTime,
					HeaderCreateUserID,
					HeaderChangeDateTime,
					HeaderChangeUserID
			FROM
					OPENXML(@idoc , @InsertTableName , 2)
					WITH  (
							-- Base
							BaseOldOrgQuotationNo	varchar(20),
							BaseOrgQuotationNo	varchar(20),
							BaseCompanyCode	varchar(20),
							BaseCustomerCode	varchar(20),
							BaseQuotationCreateDate	date,
							BaseQuotationUserID	varchar(20),
							BaseQuotationToName	nvarchar(50),
							BaseQuotationToTelNo	nvarchar(50),
							BaseQuotationToEmail	nvarchar(50),
							BaseOrgQuotationText	nvarchar(100),
							BaseOrgQuotationDesc	nvarchar(MAX),
							BaseCreateDateTime	datetime,
							BaseCreateUserID	varchar(20),
							BaseChangeDateTime	datetime,
							BaseChangeUserID	varchar(20),

							-- Header
							HeaderOldQuotationNo VARCHAR(20),
							HeaderQuotationNo VARCHAR(20),
							HeaderOrgQuotationNo VARCHAR(20),
							HeaderQuotationSeq INT,
							HeaderQuotationDate DATETIMEOFFSET,
							HeaderQuotationVersionDesc NVARCHAR(100),
							HeaderQuotationUserID VARCHAR(20),
							HeaderCurrencyUnit VARCHAR(20),
							HeaderExchangeRate NUMERIC(20,5),
							HeaderTotalAmount NUMERIC(20,5),
							HeaderTotalWonAmount NUMERIC(20,5),
							HeaderNegoTotalAmount NUMERIC(20,5),
							HeaderNegoTotalWonAmount NUMERIC(20,5),
							HeaderQuotationDetailDesc NVARCHAR(MAX),
							HeaderRequestDeliveryDate DATETIMEOFFSET,
							HeaderIsApproval BIT,
							HeaderApprovalUserID VARCHAR(20),
							HeaderApprovalDateTime DATETIMEOFFSET,
							HeaderCreateDateTime DATETIMEOFFSET,
							HeaderCreateUserID VARCHAR(20),
							HeaderChangeDateTime DATETIMEOFFSET,
							HeaderChangeUserID VARCHAR(20)
							)

        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
							-- Base
							@BaseOldOrgQuotationNo,
							@BaseOrgQuotationNo,
							@BaseCompanyCode,
							@BaseCustomerCode,
							@BaseQuotationCreateDate,
							@BaseQuotationUserID,
							@BaseQuotationToName,
							@BaseQuotationToTelNo,
							@BaseQuotationToEmail,
							@BaseOrgQuotationText,
							@BaseOrgQuotationDesc,
							@BaseCreateDateTime,
							@BaseCreateUserID,
							@BaseChangeDateTime,
							@BaseChangeUserID,

							-- Header
							@HeaderOldQuotationNo,
							@HeaderQuotationNo,
							@HeaderOrgQuotationNo,
							@HeaderQuotationSeq,
							@HeaderQuotationDate,
							@HeaderQuotationVersionDesc,
							@HeaderQuotationUserID,
							@HeaderCurrencyUnit,
							@HeaderExchangeRate,
							@HeaderTotalAmount,
							@HeaderTotalWonAmount,
							@HeaderNegoTotalAmount,
							@HeaderNegoTotalWonAmount,
							@HeaderQuotationDetailDesc,
							@HeaderRequestDeliveryDate,
							@HeaderIsApproval,
							@HeaderApprovalUserID,
							@HeaderApprovalDateTime,
							@HeaderCreateDateTime,
							@HeaderCreateUserID,
							@HeaderChangeDateTime,
							@HeaderChangeUserID

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- 기준견적번호 및 견적번호 NULL일 경우
			IF ISNULL(@BaseOrgQuotationNo, '') = '' BEGIN
				RAISERROR('기준견적번호 존재하지않습니다. 기준견적번호 = %s', 16, 1, @BaseOrgQuotationNo)
			END

			IF ISNULL(@HeaderQuotationNo, '') = '' BEGIN
				RAISERROR('견적번호가 존재하지않습니다. 견적번호 = %s', 16, 1, @HeaderQuotationNo)
			END

			-- 기준견적번호 확인
			IF NOT EXISTS (SELECT 1 FROM STB_OrgQuotationInfo WHERE OrgQuotationNo = @BaseOrgQuotationNo) BEGIN
				RAISERROR('STB_OrgQuotationInfo 테이블에서 해당 기준견적번호가 존재하지 않습니다. 기준견적번호 = %s', 16, 1, @BaseOrgQuotationNo)
			END

			-- 견적번호 확인
			IF NOT EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE QuotationNo = @HeaderQuotationNo) BEGIN
				RAISERROR('STB_QuotationInfo 테이블에서 해당 견적번호가 존재하지 않습니다. 견적번호 = %s', 16, 1, @HeaderQuotationNo)
			END

			-- 견적번호 채번
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QuotationInfo',@QuotationNoHeaderNew OUTPUT

			-- 테이블 키 중복확인
			IF EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE QuotationNo = @QuotationNoHeaderNew) BEGIN
				RAISERROR('STB_QuotationInfo 테이블에서 해당 견적번호가 중복되었습니다. 중복키 = %s', 16, 1, @QuotationNoHeaderNew)
			END

			-- 기준견적관리번호 시퀀스
			SELECT
					@MaxSeqNo = ISNULL(MAX(QuotationSeq),0) + 1
			FROM
					STB_QuotationInfo
			WHERE
					OrgQuotationNo = @BaseOrgQuotationNo

			-- 견적정보 헤더 넣기
            INSERT INTO STB_QuotationInfo
				(
					QuotationNo,
					OrgQuotationNo,
					QuotationSeq,
					QuotationDate,
					QuotationVersionDesc,
					QuotationUserID,
					CurrencyUnit,
					ExchangeRate,
					TotalAmount,
					TotalWonAmount,
					NegoTotalAmount,
					NegoTotalWonAmount,
					QuotationDetailDesc,
					RequestDeliveryDate,
					IsApproval,
					ApprovalUserID,
					ApprovalDateTime,
					CreateDateTime,
					CreateUserID,
					ChangeDateTime,
					ChangeUserID
				)
				VALUES
				(
					@QuotationNoHeaderNew,
					@BaseOrgQuotationNo,
					@MaxSeqNo, -- 기준견적관리번호 시퀀스
					@HeaderQuotationDate,
					@HeaderQuotationVersionDesc,
					@HeaderQuotationUserID,
					@HeaderCurrencyUnit,
					@HeaderExchangeRate,
					@HeaderTotalAmount,
					@HeaderTotalWonAmount,
					@HeaderNegoTotalAmount,
					@HeaderNegoTotalWonAmount,
					@HeaderQuotationDetailDesc,
					@HeaderRequestDeliveryDate,
					@HeaderIsApproval,
					@HeaderApprovalUserID,
					@HeaderApprovalDateTime,
					GETDATE(),
					@pProcessUserID,
					@HeaderChangeDateTime,
					@HeaderChangeUserID
				)

			-- 견적상세정보 넣기 위한 임시테이블 변수 사용
			DECLARE @TMPTABLE TABLE
			(
				Nid INT IDENTITY(1,1) NOT NULL,
				OldQuotationDetailNo VARCHAR(20),
				QuotationNo VARCHAR(20),
				QuotationDetailNo VARCHAR(20),
				QuotationDetailSeq INT,
				MaterialCode VARCHAR(50),
				QuotationMaterialCode NVARCHAR(50),
				QuotationMaterialName NVARCHAR(100),
				QuotationMaterialSpec NVARCHAR(MAX),
				QuotationQty NUMERIC(20,5),
				QuotationUnitPrice NUMERIC(20,5),
				QuotationItemDesc NVARCHAR(MAX)
			)

			-- 견적상세정보 임시테이블 데이터 넣기
			INSERT INTO @TMPTABLE
				(
					QuotationDetailNo,
					QuotationNo,
					QuotationDetailSeq,
					MaterialCode,
					QuotationMaterialCode,
					QuotationMaterialName,
					QuotationMaterialSpec,
					QuotationQty,
					QuotationUnitPrice,
					QuotationItemDesc
				)
					SELECT
							QuotationDetailNo,
							QuotationNo,
							QuotationDetailSeq,
							MaterialCode,
							QuotationMaterialCode,
							QuotationMaterialName,
							QuotationMaterialSpec,
							QuotationQty,
							QuotationUnitPrice,
							QuotationItemDesc
					FROM
							STB_QuotationDetailInfo
					WHERE
							QuotationNo = @HeaderQuotationNo -- 참고대상 견적번호



			-- 반복문 변수 초기화
			SELECT @LoopCnt = 1, @LoopMaxNo = MAX(Nid) FROM @TMPTABLE

			-- 반복문, 증가변수 비교
			WHILE @LoopCnt <= @LoopMaxNo
			BEGIN
				SELECT
						@QuotationDetailNo= QuotationDetailNo,
						@QuotationNoDetailNew = @QuotationNoHeaderNew,
						@QuotationDetailSeq = QuotationDetailSeq,
						@MaterialCode =	MaterialCode,
						@QuotationMaterialCode = QuotationMaterialCode,
						@QuotationMaterialName = QuotationMaterialName,
						@QuotationMaterialSpec = QuotationMaterialSpec,
						@QuotationQty = QuotationQty,
						@QuotationUnitPrice = QuotationUnitPrice,
						@QuotationItemDesc = QuotationItemDesc
				FROM
						@TMPTABLE
				WHERE
						Nid = @LoopCnt

				-- 견적상세번호 채번
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QuotationDetailInfo',@QuotationNoDetailNew OUTPUT

				-- 키 중복여부 확인
				IF EXISTS (SELECT 1 FROM STB_QuotationDetailInfo WHERE QuotationDetailNo = @QuotationNoDetailNew) BEGIN
					RAISERROR('STB_QuotationDetailInfo 테이블에서 해당 견적상세번호가 중복되었습니다. 중복키 = %s', 16, 1, @QuotationNoDetailNew)
				END

				-- 견적관리번호의 시퀀스번호
				SELECT
						@MaxSeqNo = ISNULL(MAX(QuotationDetailSeq),0) + 1
				FROM
						STB_QuotationDetailInfo
				WHERE
						QuotationNo = @QuotationNoHeaderNew

				INSERT INTO STB_QuotationDetailInfo
						(
							QuotationDetailNo,
							QuotationNo,
							QuotationDetailSeq,
							MaterialCode,
							QuotationMaterialCode,
							QuotationMaterialName,
							QuotationMaterialSpec,
							QuotationQty,
							QuotationUnitPrice,
							QuotationItemDesc,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@QuotationNoDetailNew,
							@QuotationNoHeaderNew,
							@MaxSeqNo,
							@MaterialCode,
							@QuotationMaterialCode,
							@QuotationMaterialName,
							@QuotationMaterialSpec,
							@QuotationQty,
							@QuotationUnitPrice,
							@QuotationItemDesc,
							GETDATE(),
							@pProcessUserID,
							GETDATE(),
							@ChangeUserID
						)
				-- 증가변수 갱신
				SET @LoopCnt = @LoopCnt + 1
			END
		END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH

	CLOSE SourceData;
	DEALLOCATE SourceData;

	-- 문서종료
	EXEC sp_xml_removedocument @idoc
END
