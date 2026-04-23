-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-06-21
-- Browsable : true
-- Group : 비나에너솔
-- Description:	소지함 출력 정보를 입력 받아 처리합니다.
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_VINAEnesolBoxLabelPrint_iud]
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pLabelClassCode CHAR(1)
   ,@pMaterialCode VARCHAR(20)
   ,@pProdDate DATE
   ,@pProdWeek VARCHAR(50)
   ,@pLastLotNo VARCHAR(50)
   ,@pProdMachineCode VARCHAR(50)
   ,@pProdLocationCode VARCHAR(50)
   ,@pPackingQty NUMERIC(20,5)
   ,@pLabelQty NUMERIC(20,5)
   ,@pCustomerPartNo VARCHAR(20)
   ,@pLabelBarcode VARCHAR(50) = NULL
   ,@pLotNo VARCHAR(20) = NULL
   ,@pSmallBoxList VARCHAR(MAX) = NULL
AS
BEGIN
	Declare @LabelClassCode CHAR(1) = @pLabelClassCode
           ,@MaterialCode VARCHAR(20) = @pMaterialCode
           ,@ProdDate DATE = @pProdDate
           ,@ProdWeek VARCHAR(50) = @pProdWeek
           ,@LastLotNo VARCHAR(50) = @pLastLotNo
           ,@ProdMachineCode VARCHAR(50) = @pProdMachineCode
           ,@ProdLocationCode VARCHAR(50) = @pProdLocationCode
           ,@PackingQty NUMERIC(20,5) = @pPackingQty
           ,@LabelQty NUMERIC(20,5) = @pLabelQty
           ,@CustomerPartNo VARCHAR(20) = @pCustomerPartNo
           ,@LabelBarcode VARCHAR(50) = @pLabelBarcode
		   ,@VINAEnesolBoxLabelPrintHistNo VARCHAR(20)
		   ,@ModelSpec NVARCHAR(50)
		   ,@Header VARCHAR(20)
		   ,@SerialNo INT
		   ,@Cnt INT = 0
		   ,@LotNo VARCHAR(20) = @pLotNo
		   ,@SmallBoxList VARCHAR(MAX) = ISNULL(@pSmallBoxList, '')
		   
	Declare @HistNoTable TABLE (
				VINAEnesolBoxLabelPrintHistNo VARCHAR(20)
		   );

	---- Check SmallBoxList
	--RAISERROR (@SmallBoxList, -- Message text.
 --       16, -- Severity.
 --       1 -- State.
 --   );

	-- TO-DO Insert Data
	-- 일련번호 생성
	-- 라벨 수량만큼 반복
	WHILE @Cnt < @LabelQty BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VINAEnesolBoxLabelPrintHist', @VINAEnesolBoxLabelPrintHistNo OUTPUT

		INSERT INTO @HistNoTable VALUES (@VINAEnesolBoxLabelPrintHistNo)

		-- 스펙조립
		SELECT @ModelSpec = MBIExtText04 + 'V ' + MBIExtText05 + ' Ø' + CONVERT(VARCHAR, CONVERT(NUMERIC(10,1), MBISizeW)) + '*' + CONVERT(VARCHAR, CONVERT(NUMERIC(10,1), MBISizeH)) + 'L'
		  FROM VW_ModelBasicInfo
		 WHERE ModelCode = @MaterialCode

		-- 순번 채번
		SET @Header = @LabelClassCode + RIGHT(CONVERT(CHAR(8), @ProdDate, 112), 6) + @MaterialCode

		exec usp_GetNewSerialNoForBarcode @pProcessUserID, @MaterialCode, @Header, @SerialNo OUTPUT

		IF ISNULL(@LotNo, '') = '' BEGIN
			INSERT INTO STB_VINAEnesolBoxLabelPrintHist  (
				VINAEnesolBoxLabelPrintHistNo
			   ,MaterialCode
			   ,ProdDate
			   ,ProdWeek
			   ,LastLotNo
			   ,ProdMachineCode
			   ,ProdLocationCode
			   ,PackingQty
			   ,LabelQty
			   ,LotNo
			   ,CustomerPartNo
			   ,LabelClassCode
			   ,ModelSpec
			   ,SerialNo
			   ,Barcode
			)
				SELECT @VINAEnesolBoxLabelPrintHistNo
					  ,@MaterialCode
					  ,@ProdDate
					  ,@ProdWeek
					  ,@LastLotNo
					  ,@ProdMachineCode
					  ,@ProdLocationCode
					  ,@PackingQty
					  ,1 --@LabelQty
					  ,RIGHT(CONVERT(CHAR(4), @ProdDate, 121), 1) 
					   + CASE WHEN CONVERT(INT, RIGHT(CONVERT(CHAR(6), @ProdDate, 112), 2)) <= 8 
							  THEN CHAR(CONVERT(INT, RIGHT(CONVERT(CHAR(6), @ProdDate, 112), 2)) + 64)
							  ELSE CHAR(CONVERT(INT, RIGHT(CONVERT(CHAR(6), @ProdDate, 112), 2)) + 65) END
					   + @ProdWeek + CASE WHEN ISNULL(@LastLotNo, '') = 3 THEN '' ELSE @LastLotNo END
					  ,@CustomerPartNo
					  ,@LabelClassCode
					  ,@ModelSpec
					  ,RIGHT('000' + CONVERT(VARCHAR, @SerialNo), 3)
					  ,@LabelClassCode + RIGHT(CONVERT(CHAR(8), @ProdDate, 112), 6) + @MaterialCode + RIGHT('000' + CONVERT(VARCHAR, @SerialNo), 3)
		END ELSE BEGIN
			INSERT INTO STB_VINAEnesolBoxLabelPrintHist  (
				VINAEnesolBoxLabelPrintHistNo
			   ,MaterialCode
			   ,ProdDate
			   ,ProdWeek
			   ,LastLotNo
			   ,ProdMachineCode
			   ,ProdLocationCode
			   ,PackingQty
			   ,LabelQty
			   ,LotNo
			   ,CustomerPartNo
			   ,LabelClassCode
			   ,ModelSpec
			   ,SerialNo
			   ,Barcode
			)
				SELECT @VINAEnesolBoxLabelPrintHistNo
					  ,@MaterialCode
					  ,@ProdDate
					  ,@ProdWeek
					  ,@LastLotNo
					  ,@ProdMachineCode
					  ,@ProdLocationCode
					  ,@PackingQty
					  ,1 --@LabelQty
					  ,@LotNo
					  ,@CustomerPartNo
					  ,@LabelClassCode
					  ,@ModelSpec
					  ,RIGHT('000' + CONVERT(VARCHAR, @SerialNo), 3)
					  ,@LabelClassCode + RIGHT(CONVERT(CHAR(8), @ProdDate, 112), 6) + @MaterialCode + RIGHT('000' + CONVERT(VARCHAR, @SerialNo), 3)
		END

		SET @Cnt = @Cnt + 1
	END

	-- 소지함과 대지함 출력이 동일한 프로시저를 사용하므로 만약 소지함 목록이 넘어왔으면, 대지함번호와 소지함번호를 매핑하여 이력을 생성함.
	IF @SmallBoxList <> '' BEGIN
		INSERT INTO STB_VINAEnesolBoxMatchingHist 
			SELECT @VINAEnesolBoxLabelPrintHistNo, value, GETDATE(), 'eai'
			  FROM dbo.fn_split_string(@SmallBoxList, ',')
	END

	-- 결과 조회
	SELECT BLPH.VINAEnesolBoxLabelPrintHistNo
          ,BLPH.MaterialCode
		  ,MM.MaterialName
          ,BLPH.ProdDate
          ,BLPH.ProdWeek
		  ,BC1.Description AS ProdWeekName
          ,BLPH.LastLotNo
		  ,BC2.Description AS LastLotName
          ,BLPH.ProdMachineCode
		  ,BC3.Description AS ProdMachineName
          ,BLPH.ProdLocationCode
		  ,BC4.Description AS ProdLocationName
          ,BLPH.PackingQty
          ,BLPH.LabelQty
          ,BLPH.CustomerPartNo
          ,BLPH.LotNo
          ,BLPH.LabelClassCode
		  ,BC5.Description AS LabelClassName
          ,BLPH.ModelSpec
          ,BLPH.SerialNo
          ,BLPH.Barcode
          ,BLPH.CreateDateTime
          ,BLPH.CreateUserID
          ,BLPH.ChangeDateTime
          ,BLPH.ChangeUserID
		  ,'Report' AS Command
	  FROM STB_VINAEnesolBoxLabelPrintHist BLPH
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = BLPH.MaterialCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.CodeGroup = 'ProdWeek'
	   AND BC1.ItemCode = BLPH.ProdWeek
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'LastLotNo'
	   AND BC2.ItemCode = BLPH.LastLotNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON BC3.CodeGroup = 'ProdMachineCode'
	   AND BC3.ItemCode = BLPH.ProdMachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4
	    ON BC4.CodeGroup = 'ProdLocationCode'
	   AND BC4.ItemCode = BLPH.ProdLocationCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5
	    ON BC5.CodeGroup = 'LabelClassCode'
	   AND BC5.ItemCode = BLPH.LabelClassCode
	 WHERE VINAEnesolBoxLabelPrintHistNo IN (SELECT VINAEnesolBoxLabelPrintHistNo FROM @HistNoTable)
END