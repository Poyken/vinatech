-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-07
-- Browsable : true
-- Group : 생산관리
-- Description:	제품일련번호와 Lot No를 매핑하여 저장하고, 조회합니다.
-- Modified: 
-- =============================================
CREATE PROC usp_DoCreateProdSerialMappingInfo
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotNo VARCHAR(20) = NULL,
	@pProdSerialNo VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	Declare @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo, '') = '' THEN '*' ELSE @pLotNo END
	       ,@ProdSerialNo VARCHAR(20) = CASE WHEN ISNULL(@pProdSerialNo, '') = '' THEN '*' ELSE @pProdSerialNo END
		   ,@FromDate DATE = @pFromDate
		   ,@ToDate DATE = @pToDate

	IF @LotNo <> '*' AND @ProdSerialNo <> '*'  BEGIN
		-- Lot No와 ProdSerialNo를 입력하고 해당 LotNo 기준으로 조회한다.
		IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @LotNo) BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Lot번호가 존재하지 않습니다'
			RETURN
		END

		BEGIN TRY  
			INSERT INTO STB_ProdSerialMappingInfo (LotNo, ProdSerialNo, CreateUserID)
				SELECT @LotNo, @ProdSerialNo, @pProcessUserID
		END TRY  
		BEGIN CATCH  
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '제품 시리얼은 중복될 수 없습니다'
			RETURN
		END CATCH;  

		SELECT PSM.LotNo
		      ,PSM.ProdSerialNo
			  ,PSM.CreateDateTime
			  ,PSM.CreateUserID
		  FROM STB_ProdSerialMappingInfo PSM
		 WHERE PSM.LotNo = @LotNo
		 ORDER BY PSM.LotNo, PSM.ProdSerialNo
	END ELSE BEGIN
		--넘어오는 모든 값이 조회 조건이 된다.
		SELECT PSM.LotNo
		      ,PSM.ProdSerialNo
			  ,PSM.CreateDateTime
			  ,PSM.CreateUserID
		  FROM STB_ProdSerialMappingInfo PSM
		 WHERE (@ProdSerialNo = '*' OR PSM.ProdSerialNo LIKE @ProdSerialNo + '%')
		   AND (@LotNo = '*' OR PSM.LotNo LIKE @LotNo + '%')
		   AND PSM.CreateDateTime BETWEEN CONVERT(VARCHAR(10), @FromDate, 121) + ' 00:00:00' AND CONVERT(VARCHAR(10), @ToDate, 121) + ' 23:59:59'
		 ORDER BY PSM.LotNo, PSM.ProdSerialNo
	END
END