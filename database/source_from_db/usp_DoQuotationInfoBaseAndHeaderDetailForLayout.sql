
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-16
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 기준견적정보와 견적정보, 상세정보를 저장,수정,삭제한다. (레이아웃 버전)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoQuotationInfoBaseAndHeaderDetailForLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    --@pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    --DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
	
	-- Base and Header
	DECLARE @ProcessViewName VARCHAR(50) = 'QuotationInfoBaseAndHeaderForLayoutView'
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'

	-- Detail
	DECLARE @ProcessViewName2 VARCHAR(50) = 'QuotationDetailInfoForLayoutView'
    DECLARE @InsertTableName2 VARCHAR(100) = '/DataSet/' + @ProcessViewName2 + '_INSERT'
    DECLARE @UpdateTableName2 VARCHAR(100) = '/DataSet/' + @ProcessViewName2 + '_UPDATE'
    DECLARE @DeleteTableName2 VARCHAR(100) = '/DataSet/' + @ProcessViewName2 + '_DELETE'

    DECLARE @ERROR_MSG NVARCHAR(MAX) = ''
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

	-- Detail
	DECLARE @DetailOldQuotationDetailNo VARCHAR(20)
	DECLARE @DetailQuotationDetailNo VARCHAR(20)
	DECLARE @DetailQuotationNo VARCHAR(20)
	DECLARE @DetailQuotationDetailSeq INT
	DECLARE @DetailMaterialCode VARCHAR(50)
	DECLARE @DetailQuotationMaterialCode NVARCHAR(50)
	DECLARE @DetailQuotationMaterialName NVARCHAR(100)
	DECLARE @DetailQuotationMaterialSpec NVARCHAR(MAX)
	DECLARE @DetailQuotationQty NUMERIC(20,5)
	DECLARE @DetailQuotationUnitPrice NUMERIC(20,5)
	DECLARE @DetailQuotationItemDesc NVARCHAR(MAX)
	DECLARE @DetailCreateDateTime DATETIME
	DECLARE @DetailCreateUserID VARCHAR(20)
	DECLARE @DetailChangeDateTime DATETIME
	DECLARE @DetailChangeUserID VARCHAR(20)

	DECLARE @SumTotalAmount NUMERIC(20, 5) -- 추가
	DECLARE @MaxSeqNo INT -- 시퀀스번호 추가

	DECLARE @iDoc INT

	-- 문서시작
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	-- Base and Header
	BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								-- Base
								BaseOldOrgQuotationNo,
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
								HeaderOldQuotationNo,
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
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
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
								OPENXML(@idoc , @UpdateTableName , 2)
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
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
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
							@IUD_FLAG,

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
            IF @IUD_FLAG = 'INSERT' BEGIN

				-- 기준견적번호와 견적번호 NULL이 아니라면
				IF ISNULL(@BaseOrgQuotationNo, '') <> '' OR ISNULL(@HeaderQuotationNo, '') <> '' BEGIN
					RAISERROR('견적작성(신규)입니다. 기존 기준견적번호와 견적번호가 존재합니다. 기준견적번호 = %s, 견적번호 = %s', 16, 1, @BaseOrgQuotationNo, @HeaderQuotationNo)
				END

				-- 기준견적번호와 견적번호 각각 채번
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_OrgQuotationInfo',@BaseOrgQuotationNo OUTPUT
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QuotationInfo',@HeaderQuotationNo OUTPUT

				-- 기준견적번호 확인
				IF EXISTS (SELECT 1 FROM STB_OrgQuotationInfo WHERE OrgQuotationNo = @BaseOrgQuotationNo) BEGIN
					RAISERROR('STB_OrgQuotationInfo 테이블에서 해당 기준견적번호가 존재합니다. 기준견적번호 = %s', 16, 1, @BaseOrgQuotationNo)
				END

				-- 견적번호 확인
				IF EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE QuotationNo = @HeaderQuotationNo) BEGIN
					RAISERROR('STB_QuotationInfo 테이블에서 해당 견적번호가 존재합니다. 견적번호 = %s', 16, 1, @HeaderQuotationNo)
				END

				-- 기준견적관리번호의 시퀀스
				SELECT
						@MaxSeqNo = ISNULL(MAX(QuotationSeq),0) + 1
				FROM
						STB_QuotationInfo
				WHERE
						QuotationNo = @BaseOrgQuotationNo

				-- Base
				INSERT INTO STB_OrgQuotationInfo
					(
						OrgQuotationNo,
						CompanyCode,
						CustomerCode,
						QuotationCreateDate,
						QuotationUserID,
						QuotationToName,
						QuotationToTelNo,
						QuotationToEmail,
						OrgQuotationText,
						OrgQuotationDesc,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
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
						GETDATE(),
						@pProcessUserID,
						@BaseChangeDateTime,
						@BaseChangeUserID
					)

				-- Header
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
						@HeaderQuotationNo,
						--@HeaderOrgQuotationNo,
						@BaseOrgQuotationNo,
						--@HeaderQuotationSeq,
						@MaxSeqNo,
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

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					-- Base
					UPDATE STB_OrgQuotationInfo
						SET
							--OrgQuotationNo =   ISNULL(@BaseOldOrgQuotationNo,OrgQuotationNo),
							CompanyCode =   ISNULL(@BaseCompanyCode,CompanyCode),
							CustomerCode =   ISNULL(@BaseCustomerCode,CustomerCode),
							--QuotationCreateDate =   ISNULL(@BaseQuotationCreateDate,QuotationCreateDate),
							--QuotationUserID =   ISNULL(@BaseQuotationUserID,QuotationUserID),
							QuotationToName =   ISNULL(@BaseQuotationToName,QuotationToName),
							QuotationToTelNo =   ISNULL(@BaseQuotationToTelNo,QuotationToTelNo),
							QuotationToEmail =   ISNULL(@BaseQuotationToEmail,QuotationToEmail),
							OrgQuotationText =   ISNULL(@BaseOrgQuotationText,OrgQuotationText),
							OrgQuotationDesc =   ISNULL(@BaseOrgQuotationDesc,OrgQuotationDesc),
							--CreateDateTime =   ISNULL(@BaseCreateDateTime,CreateDateTime),
							--CreateUserID =   ISNULL(@BaseCreateUserID,CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID
						WHERE
							OrgQuotationNo = @BaseOldOrgQuotationNo

					-- Header
					UPDATE STB_QuotationInfo
						SET
							--QuotationNo =   ISNULL(@HeaderQuotationNo,QuotationNo),
							--OrgQuotationNo =   ISNULL(@HeaderOrgQuotationNo,OrgQuotationNo),
							--QuotationSeq =   ISNULL(@HeaderQuotationSeq,QuotationSeq),
							QuotationDate =   ISNULL(@HeaderQuotationDate,QuotationDate),
							QuotationVersionDesc =   ISNULL(@HeaderQuotationVersionDesc,QuotationVersionDesc),
							QuotationUserID =   ISNULL(@HeaderQuotationUserID,QuotationUserID),
							CurrencyUnit =   ISNULL(@HeaderCurrencyUnit,CurrencyUnit),
							ExchangeRate =   ISNULL(@HeaderExchangeRate,ExchangeRate),
							TotalAmount =   ISNULL(@HeaderTotalAmount,TotalAmount),
							TotalWonAmount =   ISNULL(@HeaderTotalWonAmount,TotalWonAmount),
							NegoTotalAmount =   ISNULL(@HeaderNegoTotalAmount,NegoTotalAmount),
							NegoTotalWonAmount =   ISNULL(@HeaderNegoTotalWonAmount,NegoTotalWonAmount),
							QuotationDetailDesc =   ISNULL(@HeaderQuotationDetailDesc,QuotationDetailDesc),
							RequestDeliveryDate =   ISNULL(@HeaderRequestDeliveryDate,RequestDeliveryDate),
							--IsApproval =   ISNULL(@HeaderIsApproval,IsApproval),
							--ApprovalUserID =   ISNULL(@HeaderApprovalUserID,ApprovalUserID),
							--ApprovalDateTime =   ISNULL(@HeaderApprovalDateTime,ApprovalDateTime),
							--CreateDateTime =   ISNULL(@HeaderCreateDateTime,CreateDateTime),
							--CreateUserID =   ISNULL(@HeaderCreateUserID,CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID
						WHERE
							QuotationNo = @HeaderOldQuotationNo

            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

				-- 역순삭제
				-- 견적상세정보
                DELETE FROM STB_QuotationDetailInfo
					WHERE
							QuotationNo IN (SELECT QuotationNo FROM STB_QuotationInfo WHERE OrgQuotationNo = @BaseOldOrgQuotationNo AND QuotationNo = @HeaderOldQuotationNo)

				-- 견적정보
                DELETE FROM STB_QuotationInfo
					WHERE
							OrgQuotationNo = @BaseOldOrgQuotationNo AND QuotationNo = @HeaderOldQuotationNo

				-- 견적상세정보
                DELETE FROM STB_OrgQuotationInfo
					WHERE
							OrgQuotationNo = @BaseOldOrgQuotationNo AND
							NOT EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE OrgQuotationNo = @BaseOldOrgQuotationNo)
            END
        END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH

	CLOSE SourceData;
	DEALLOCATE SourceData;

	IF @ERROR_MSG = '' BEGIN
		-- Detail
		BEGIN TRY
			DECLARE SourceData2 CURSOR FOR
				SELECT
						'INSERT' AS IUD_FLAG,
									OldQuotationDetailNo,
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
							FROM
									OPENXML(@idoc , @InsertTableName2 , 2)
									WITH  (
												OldQuotationDetailNo VARCHAR(20),
												QuotationDetailNo VARCHAR(20),
												QuotationNo VARCHAR(20),
												QuotationDetailSeq INT,
												MaterialCode VARCHAR(50),
												QuotationMaterialCode NVARCHAR(50),
												QuotationMaterialName NVARCHAR(100),
												QuotationMaterialSpec NVARCHAR(MAX),
												QuotationQty NUMERIC(20,5),
												QuotationUnitPrice NUMERIC(20,5),
												QuotationItemDesc NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,
												CreateUserID VARCHAR(20),
												ChangeDateTime DATETIMEOFFSET,
												ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldQuotationDetailNo IS NULL THEN QuotationDetailNo
										ELSE OldQuotationDetailNo
									END AS DetailOldQuotationDetailNo,
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
							FROM
									OPENXML(@idoc , @UpdateTableName2 , 2)
									WITH  (
												OldQuotationDetailNo VARCHAR(20),
												QuotationDetailNo VARCHAR(20),
												QuotationNo VARCHAR(20),
												QuotationDetailSeq INT,
												MaterialCode VARCHAR(50),
												QuotationMaterialCode NVARCHAR(50),
												QuotationMaterialName NVARCHAR(100),
												QuotationMaterialSpec NVARCHAR(MAX),
												QuotationQty NUMERIC(20,5),
												QuotationUnitPrice NUMERIC(20,5),
												QuotationItemDesc NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,
												CreateUserID VARCHAR(20),
												ChangeDateTime DATETIMEOFFSET,
												ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldQuotationDetailNo IS NULL THEN QuotationDetailNo
										ELSE OldQuotationDetailNo
									END AS OldQuotationDetailNo,
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
							FROM
									OPENXML(@idoc , @DeleteTableName2 , 2)
									WITH  (
												OldQuotationDetailNo VARCHAR(20),
												QuotationDetailNo VARCHAR(20),
												QuotationNo VARCHAR(20),
												QuotationDetailSeq INT,
												MaterialCode VARCHAR(50),
												QuotationMaterialCode NVARCHAR(50),
												QuotationMaterialName NVARCHAR(100),
												QuotationMaterialSpec NVARCHAR(MAX),
												QuotationQty NUMERIC(20,5),
												QuotationUnitPrice NUMERIC(20,5),
												QuotationItemDesc NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,
												CreateUserID VARCHAR(20),
												ChangeDateTime DATETIMEOFFSET,
												ChangeUserID VARCHAR(20)
											) 


			OPEN SourceData2

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData2 INTO
								@IUD_FLAG,
								@DetailOldQuotationDetailNo,
								@DetailQuotationDetailNo,
								@DetailQuotationNo,
								@DetailQuotationDetailSeq,
								@DetailMaterialCode,
								@DetailQuotationMaterialCode,
								@DetailQuotationMaterialName,
								@DetailQuotationMaterialSpec,
								@DetailQuotationQty,
								@DetailQuotationUnitPrice,
								@DetailQuotationItemDesc,
								@DetailCreateDateTime,
								@DetailCreateUserID,
								@DetailChangeDateTime,
								@DetailChangeUserID

				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN

					-- 견적상세번호 채번
					EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QuotationDetailInfo',@DetailQuotationDetailNo OUTPUT

					IF EXISTS (SELECT 1 FROM STB_QuotationDetailInfo WHERE QuotationDetailNo = @DetailQuotationDetailNo) BEGIN
						RAISERROR('STB_QuotationDetailInfo 테이블에서 해당 견적상세번호가 존재합니다. 견적상세번호 = %s', 16, 1, @DetailQuotationDetailNo)
					END

					-- 견적번호 확인
					IF NOT EXISTS (SELECT 1 FROM STB_QuotationInfo WHERE QuotationNo = @HeaderQuotationNo) BEGIN
						RAISERROR('STB_QuotationInfo 테이블에서 해당 견적번호가 존재하지 않습니다. 견적번호 = %s', 16, 1, @HeaderQuotationNo)
					END

					-- 견적관리번호의 시퀀스번호
					SELECT
							@MaxSeqNo = ISNULL(MAX(QuotationDetailSeq),0) + 1
					FROM
							STB_QuotationDetailInfo
					WHERE
							QuotationNo = @HeaderQuotationNo

					-- 픔목코드, 견적수량, 견적단가
					-- 프로그램에서 확인을 하지만 로직추가 테스트해봄
					--IF ISNULL(@DetailMaterialCode, '') = '' BEGIN
					--	RAISERROR('품목코드를 입력해주세요', 16, 1)
					--END

					IF ISNULL(@DetailQuotationQty, 0) = 0 BEGIN
						RAISERROR('[견적수량]은 0 보다 커야합니다. 다시 입력해주세요', 16, 1)
					END

					IF ISNULL(@DetailQuotationUnitPrice, 0) = 0 BEGIN
						RAISERROR('[견적단가]는 0 보다 커야합니다. 다시 입력해주세요', 16, 1)
					END

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
							@DetailQuotationDetailNo,
							@HeaderQuotationNo,
							--@QuotationDetailSeq,
							@MaxSeqNo,
							@DetailMaterialCode,
							@DetailQuotationMaterialCode,
							@DetailQuotationMaterialName,
							@DetailQuotationMaterialSpec,
							@DetailQuotationQty,
							@DetailQuotationUnitPrice,
							@DetailQuotationItemDesc,
							GETDATE(),
							@pProcessUserID,
							@DetailChangeDateTime,
							@DetailChangeUserID
						)

					-- 견적정보상세 합계
					SELECT
							@SumTotalAmount = SUM(ISNULL(QuotationQty,0) * ISNULL(QuotationUnitPrice,0))
					FROM
							STB_QuotationDetailInfo
					WHERE
							QuotationNo = @HeaderQuotationNo

					-- 견적정보헤더 합계반영
					UPDATE	STB_QuotationInfo
						SET
							TotalAmount = @SumTotalAmount
						WHERE
							QuotationNo = @HeaderQuotationNo

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

					IF ISNULL(@DetailQuotationQty, 0) = 0 BEGIN
						RAISERROR('[견적수량]은 0 보다 커야합니다. 다시 입력해주세요', 16, 1)
					END

					IF ISNULL(@DetailQuotationUnitPrice, 0) = 0 BEGIN
						RAISERROR('[견적단가]는 0 보다 커야합니다. 다시 입력해주세요', 16, 1)
					END

					-- 견적상세정보
					UPDATE STB_QuotationDetailInfo
						SET
							--QuotationDetailNo =   ISNULL(@DetailQuotationDetailNo,QuotationDetailNo),
							--QuotationNo =   ISNULL(@DetailQuotationNo,QuotationNo),
							--QuotationDetailSeq =   ISNULL(@DetailQuotationDetailSeq,QuotationDetailSeq),
							MaterialCode =   ISNULL(@DetailMaterialCode,MaterialCode),
							QuotationMaterialCode = ISNULL(@DetailQuotationMaterialCode, QuotationMaterialCode),
							QuotationMaterialName = ISNULL(@DetailQuotationMaterialName, QuotationMaterialName),
							QuotationMaterialSpec = ISNULL(@DetailQuotationMaterialSpec, QuotationMaterialSpec),
							QuotationQty =   ISNULL(@DetailQuotationQty,QuotationQty),
							QuotationUnitPrice =   ISNULL(@DetailQuotationUnitPrice,QuotationUnitPrice),
							QuotationItemDesc =   ISNULL(@DetailQuotationItemDesc,QuotationItemDesc),
							--CreateDateTime =   ISNULL(@DetailCreateDateTime,CreateDateTime),
							--CreateUserID =   ISNULL(@DetailCreateUserID,CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID
						WHERE
							QuotationDetailNo = @DetailOldQuotationDetailNo

					-- 견적정보상세 합계
					SELECT
							@SumTotalAmount = SUM(ISNULL(QuotationQty,0) * ISNULL(QuotationUnitPrice,0))
					FROM
							STB_QuotationDetailInfo
					WHERE
							QuotationNo = @DetailQuotationNo

					-- 견적정보헤더 합계반영
					UPDATE STB_QuotationInfo
						SET
							TotalAmount = @SumTotalAmount
						WHERE
							QuotationNo = @DetailQuotationNo

				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

					-- 견적상세정보
					DELETE FROM STB_QuotationDetailInfo
						WHERE
							QuotationDetailNo = @DetailOldQuotationDetailNo

					-- 견적정보상세 합계
					SELECT
							@SumTotalAmount = SUM(ISNULL(QuotationQty,0) * ISNULL(QuotationUnitPrice,0))
					FROM
							STB_QuotationDetailInfo
					WHERE
							QuotationNo = @DetailQuotationNo

					-- 견적정보 합계반영
					UPDATE STB_QuotationInfo
						SET
							TotalAmount = @SumTotalAmount
						WHERE
							QuotationNo = @DetailQuotationNo
				END
			END
		END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH

		CLOSE SourceData2;
		DEALLOCATE SourceData2;
	END

	EXEC sp_xml_removedocument @idoc	
END
