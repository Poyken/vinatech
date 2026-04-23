
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-16
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 기준견적정보와 견적정보 - 견적상세를 삭제한다. (선택된 대상으로 참고하여 삭제)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoQuotationInfoHeaderDetailDeleteAll]
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
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)

	-- Declare Columns Variable
	-- Base
	DECLARE @BaseOldOrgQuotationNo VARCHAR(20)
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
					OPENXML(@idoc , @DeleteTableName , 2)
					WITH  (
							-- Base
							BaseOldOrgQuotationNo VARCHAR(20),
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
			IF ISNULL(@BaseOldOrgQuotationNo, '') = '' BEGIN
				RAISERROR('기준견적번호 존재하지않습니다. 기준견적번호 = %s', 16, 1, @BaseOldOrgQuotationNo)
			END

			IF ISNULL(@HeaderOldQuotationNo, '') = '' BEGIN
				RAISERROR('견적번호가 존재하지않습니다. 견적번호 = %s', 16, 1, @HeaderOldQuotationNo)
			END

			-- 기준견적번호 확인
			IF NOT EXISTS (SELECT 1 FROM STB_OrgQuotationInfo WHERE OrgQuotationNo = @BaseOldOrgQuotationNo) BEGIN
				RAISERROR('STB_OrgQuotationInfo 테이블에서 해당 기준견적번호가 존재하지 않습니다. 기준견적번호 = %s', 16, 1, @BaseOldOrgQuotationNo)
			END

			-- 견적번호 확인
			IF NOT EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE QuotationNo = @HeaderOldQuotationNo) BEGIN
				RAISERROR('STB_QuotationInfo 테이블에서 해당 견적번호가 존재하지 않습니다. 견적번호 = %s', 16, 1, @HeaderOldQuotationNo)
			END

			-- 역순으로 삭제
			-- 견적상세정보
			DELETE FROM STB_QuotationDetailInfo
				WHERE
						QuotationNo IN (SELECT QuotationNo FROM STB_QuotationInfo WHERE OrgQuotationNo = @BaseOldOrgQuotationNo AND QuotationNo = @HeaderOldQuotationNo )

			-- 삭제수 확인 테스트
			--IF @@ROWCOUNT = 0 BEGIN
			--	RAISERROR('삭제대상 기준견적번호 = %s, 견적번호 = %s', 16, 1, @BaseOldOrgQuotationNo, @HeaderOldQuotationNo)
			--END

			-- 견적정보
			DELETE FROM STB_QuotationInfo
				WHERE
						OrgQuotationNo = @BaseOldOrgQuotationNo AND QuotationNo = @HeaderOldQuotationNo

			-- 삭제수 확인 테스트
			--IF @@ROWCOUNT = 0 BEGIN
			--	RAISERROR('삭제대상 기준견적번호 = %s, 견적번호 = %s', 16, 1, @BaseOldOrgQuotationNo, @HeaderOldQuotationNo)
			--END

			DELETE FROM STB_OrgQuotationInfo
				WHERE
						OrgQuotationNo = @BaseOldOrgQuotationNo AND
						NOT EXISTS (
										SELECT 1 FROM STB_QuotationInfo QI
										INNER JOIN STB_QuotationDetailInfo QDI
											ON
												(
													QDI.QuotationNo = QI.QuotationNo
												)
										WHERE
												QI.OrgQuotationNo = @BaseOldOrgQuotationNo
									)
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
