-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021.05.28
-- Browsable : true
-- Group : 제품관리
-- Description: 포장잔량관리(입고)
-- ==================================================================================

CREATE PROCEDURE [dbo].[usp_DoCreatePackingRemainingQtyInfo]
						@pProcessUserID   Varchar(20),
						@pProcessLanguage Varchar(20),
						@pRackLocationCode CHAR(6) = NULL,
						@pBarcode VARCHAR(20) = NULL,
						@pPackingRemainingQty NUMERIC(20,5) = NULL
AS
BEGIN
	Declare @PackingRemainingQtyNo VARCHAR(20)
	       ,@CompanyCode VARCHAR(20)
		   ,@WorkCenterCode VARCHAR(20)
		   ,@Barcode VARCHAR(20) = @pBarcode
		   ,@RackLocationCode CHAR(6) = @pRackLocationCode
		   ,@PackingRemainingQty NUMERIC(20,5) = @pPackingRemainingQty

	-- 사용자 CompanyCode , WorkCenterCode 
	SELECT @CompanyCode = CompanyCode 
	      ,@WorkCenterCode = WorkCenterCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	 IF NOT EXISTS (SELECT 1 FROM STB_PackingRemainingQtyInfo WHERE Barcode = @Barcode) BEGIN
		RAISERROR('바코드가 존재하지 않습니다 = %s', 16, 1, @Barcode)
		RETURN
	END

	-- 일련번호 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingRemainingQtyInfo',@PackingRemainingQtyNo OUTPUT

	IF @PackingRemainingQty <= 0 BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage,'포장 잔량은 0보다 커야합니다.'
		RETURN
	END

	INSERT INTO STB_PackingRemainingQtyInfo (
		PackingRemainingQtyNo
	   ,CompanyCode
	   ,WorkCenterCode
	   ,Barcode
	   ,RackLocationCode
	   ,PackingRemainingQty
	   ,CreateDateTime
	   ,CreateUserID
	) VALUES (
		@PackingRemainingQtyNo
	   ,@CompanyCode
	   ,@WorkCenterCode
	   ,@Barcode
	   ,@RackLocationCode
	   ,@PackingRemainingQty
	   ,GETDATE()
	   ,@pProcessUserID
	)

	SELECT PRQI.PackingRemainingQtyNo
          ,PRQI.RackLocationCode
          ,SI.MaterialCode
		  ,MM.MaterialName
		  ,PRQI.Barcode
          ,PRQI.PackingRemainingQty
		  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) AS PartNo
		  ,'(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')' AS Rating
		  ,MBI.MBIExtText04 AS Voltage
		  ,MBI.MBIExtText05 AS Farad
		  ,'Report' AS CommandType
          ,PRQI.CreateDateTime
	  FROM STB_PackingRemainingQtyInfo PRQI
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON SI.Barcode = PRQI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = PRQI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = PRQI.WorkCenterCode 
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI 
	    ON MBI.ModelCode = SI.MaterialCode
	 WHERE 1=1
	   AND PackingRemainingQtyNo = @PackingRemainingQtyNo

END