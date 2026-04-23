CREATE PROC [dbo].[usp_CustomerInfo_interface]
AS
BEGIN
	/*
	1. ERP에만 추가된 경우 
		1.1 SELECT * FROM ERPSVR.ERPDB.DBO.VENDREF WHERE 입력일시 > '2019-02-22'
		1.2 NAIS Insert
		1.3 처리완료 메일 발송
	2. NAIS에만 추가된 경우
		2.1 SELECT * FROM STB_CustomerInfo WHERE CIExtText02 IS NULL
		2.2 ERP Insert
		2.3 ERP거래처코드 UPDATE
		2.4 처리완료 메일 발송
	*/

	Declare @CustomerName VARCHAR(100)
	Declare @CustomerNameL VARCHAR(100)
	Declare @CIExtText02 VARCHAR(100)
	Declare @IsCustomer BIT
	Declare @IsVendor BIT
	Declare @IsSourcing BIT
	Declare @BusinessCondition VARCHAR(100)
	Declare @BusinessType VARCHAR(100)
	Declare @BusinessNo VARCHAR(20)
	Declare @ZipCode VARCHAR(10)
	Declare @AddressText VARCHAR(200)
	Declare @CeoName NVARCHAR(60)
	Declare @TelNo VARCHAR(20)
	Declare @FaxNo VARCHAR(20)
	Declare @IsUsed BIT
	Declare @MailContents NVARCHAR(1000)
	Declare @RegEmpCd VARCHAR(20)

	-- 1
	Declare @CustomerCode VARCHAR(20)
	Declare @Seq INT = 1

	-- 쿼리 완성 후 맨 뒤로 옮길 것.
	SELECT @CustomerCode = 'V' + RIGHT('0000' + CONVERT(VARCHAR(10), CONVERT(INT, RIGHT(MAX(CustomerCode), 4)) + @Seq), 4) FROM STB_CustomerInfo

	-- 1.1
	DECLARE ERPDATA_CUR CURSOR FOR
		SELECT VENDFN AS 거래선명, VENDSN AS 거래선명타언어, VENDCD AS ERP거래처코드, CASE WHEN VENDGB1 = 1 THEN 'TRUE' ELSE 'FALSE' END AS 고객사여부
		      ,CASE WHEN VENDGB2 = 1 THEN 'TRUE' ELSE 'FALSE' END AS 공급사여부, 'FALSE' AS 외주사여부, BNKIND AS 업태, BNITEM AS 업종, BNSSNO AS 사업자번호
			  ,POSTCD AS  우편번호, ADDRES AS 주소, OWNER AS 대표자, TELNO AS 대표번호, FAXNO AS 팩스번호
			  ,'TRUE' AS 사용여부, 입력자
		  FROM ERPSVR.ERPDB.DBO.VENDREF 
		 WHERE USEGBN = 'Y'
		   AND VENDCD NOT IN (SELECT CIExtText02 FROM STB_CustomerInfo WHERE IsUsed = 1 AND CIExtText02 IS NOT NULL)
		   AND 입력일시 > '2019-02-22'

		OPEN ERPDATA_CUR
		FETCH NEXT FROM ERPDATA_CUR INTO  @CustomerName, @CustomerNameL, @CIExtText02, @IsCustomer
										 ,@IsVendor, @IsSourcing, @BusinessCondition, @BusinessType, @BusinessNo
										 ,@ZipCode, @AddressText, @CeoName, @TelNo, @FaxNo
										 ,@IsUsed, @RegEmpCd

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- NAIS 입력
			INSERT INTO STB_CustomerInfo (CustomerCode, CustomerName, CustomerNameL, CIExtText02, IsCustomer
										 ,IsVendor, IsSourcing, BusinessCondition, BusinessType, BusinessNo
										 ,ZipCode, AddressText, CeoName, TelNo, FaxNo
										 ,IsUsed)
					SELECT @CustomerCode, @CustomerName, @CustomerNameL, @CIExtText02, @IsCustomer
										 ,@IsVendor, @IsSourcing, @BusinessCondition, @BusinessType, @BusinessNo
										 ,@ZipCode, @AddressText, @CeoName, @TelNo, @FaxNo
										 ,@IsUsed
			-- 메일발송
			SET @MailContents = '거래처 정보가 인터페이스 되었습니다. 

			거래처명 : ' + @CustomerName + '
			거래처코드 : ' + @CustomerCode + '
			ERP거래처코드 : ' + @CIExtText02 + '
			입력자 사번 : ' + @RegEmpCd
			

			INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
				SELECT 'yjyu@vina.co.kr', '거래처정보가 인터페이스 되었습니다.(ERP->NAIS)', @MailContents

			-- Next
			SET @Seq = @Seq + 1
			SELECT @CustomerCode = 'V' + RIGHT('0000' + CONVERT(VARCHAR(10), CONVERT(INT, RIGHT(MAX(CustomerCode), 4)) + @Seq), 4) FROM STB_CustomerInfo

			FETCH NEXT FROM ERPDATA_CUR INTO  @CustomerName, @CustomerNameL, @CIExtText02, @IsCustomer
											 ,@IsVendor, @IsSourcing, @BusinessCondition, @BusinessType, @BusinessNo
											 ,@ZipCode, @AddressText, @CeoName, @TelNo, @FaxNo
											 ,@IsUsed, @RegEmpCd
		END

	CLOSE ERPDATA_CUR
	DEALLOCATE ERPDATA_CUR

	--2
	DECLARE NAISDATA_CUR CURSOR FOR
		SELECT CustomerCode, CustomerName, CustomerNameL, IsCustomer, IsVendor
		      ,IsSourcing, BusinessCondition, BusinessType, BusinessNo, ZipCode
			  ,AddressText, CeoName, TelNo, FaxNo, IsUsed
		  FROM STB_CustomerInfo WHERE CIExtText02 IS NULL

		OPEN NAISDATA_CUR
		FETCH NEXT FROM NAISDATA_CUR INTO  @CustomerCode, @CustomerName, @CustomerNameL, @IsCustomer, @IsVendor
										  ,@IsSourcing, @BusinessCondition, @BusinessType, @BusinessNo, @ZipCode
										  ,@AddressText, @CeoName, @TelNo, @FaxNo, @IsUsed

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			-- ERP거래처코드 채번
			exec ERPSVR.ERPDB.DBO.BA0203_MAX_OUT '1', @CIExtText02 OUTPUT
			-- ERP 입력
			INSERT INTO ERPSVR.ERPDB.DBO.VENDREF (VENDCD, VENDFN, VENDSN, VENDGB1
										 ,VENDGB2, BNKIND, BNITEM, BNSSNO
										 ,POSTCD, ADDRES, OWNER, TELNO
										 ,FAXNO, USEGBN)
					SELECT @CIExtText02, @CustomerName, @CustomerNameL, CASE WHEN @IsCustomer = 1 THEN 1 ELSE 0 END
										 ,CASE WHEN @IsVendor = 1 THEN 1 ELSE 0 END, @BusinessCondition, @BusinessType, @BusinessNo
										 ,@ZipCode, @AddressText, @CeoName, @TelNo
										 ,@FaxNo, @IsUsed
			-- ERP거래처코드 업데이트
			UPDATE STB_CustomerInfo
			   SET CIExtText02 = @CIExtText02
			 WHERE CustomerCode = @CustomerCode

			-- 메일발송
			SET @MailContents = '거래처 정보가 인터페이스 되었습니다. 

			거래처명 : ' + @CustomerName + '
			거래처코드 : ' + @CustomerCode + '
			ERP거래처코드 : ' + @CIExtText02
			

			INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
				SELECT 'yjyu@vina.co.kr', '거래처정보가 인터페이스 되었습니다.(NAIS->ERP)', @MailContents

			FETCH NEXT FROM NAISDATA_CUR INTO  @CustomerCode, @CustomerName, @CustomerNameL, @IsCustomer, @IsVendor
										  ,@IsSourcing, @BusinessCondition, @BusinessType, @BusinessNo, @ZipCode
										  ,@AddressText, @CeoName, @TelNo, @FaxNo, @IsUsed
		END

	CLOSE NAISDATA_CUR
	DEALLOCATE NAISDATA_CUR
END 