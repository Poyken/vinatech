-- 창고 입/출고 및 이동 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-26
-- Browsable : true
-- Group : 인터페이스
-- Source Table: NEOE.NEOE.MM_Z_VINA_QTIO_POP
-- Target Table: SmartFactoryV2.DBO.STB_MaterialDocInfo, SmartFactoryV2.DBO.STB_MaterialDocDetail
-- Description:	창고 입/출고 및 이동 인터페이스
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_DoProcessWarehouseInOut_itf]
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
   ,@pMaterialDocNo VARCHAR(20)
   ,@pDocTypeCode VARCHAR(20)
   ,@pFromWarehouseCode VARCHAR(20)
   ,@pToWarehouseCode VARCHAR(20)
   ,@pReplaceTypeCode VARCHAR(20)
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode
	       ,@MaterialDocNo VARCHAR(20) = @pMaterialDocNo
		   ,@DocTypeCode VARCHAR(20) = @pDocTypeCode
		   ,@FromWarehouseCode VARCHAR(20) = @pFromWarehouseCode -- 창고이동이나 출고의 경우 출고창고, 입고의 경우 입고창고
		   ,@ToWarehouseCode VARCHAR(20) = @pToWarehouseCode -- 창고이동의 경우 입고창고, 다른 경우는 입력되지 않음.
		   ,@ReplaceTypeCode VARCHAR(20) = @pReplaceTypeCode

	-- Master Insert
	INSERT INTO NEOE.NEOE.MM_Z_VINA_QTIO_POP (
		CD_COMPANY, CD_PLANT, NO_POP, NO_POP_LINE, NO_REQ
       ,NO_LINE, YN_RETURN, CD_QTIOTP, CD_SL, CD_SL_REF
	   ,DT_IO ,CD_ITEM, QT_IO, CD_PARTNER, DTS_INSERT
	   ,DTS_SEND, FG_IUD, FG_READ, FG_TPIO
	)
	SELECT @IUCompanyCode, '1000', MDI.MaterialDocNo,  ROW_NUMBER() OVER(ORDER BY MDI.MaterialDocNo ASC), NULL
	      ,NULL, NULL, @DocTypeCode, dbo.fnConvertWarehouseCode('ERP', @FromWarehouseCode), dbo.fnConvertWarehouseCode('ERP', @ToWarehouseCode)
		  ,CONVERT(CHAR(8), GETDATE(), 112), MDD.MaterialCode, MDD.RequestQty, NULL, dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', MDI.CreateDateTime)
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE()), 'I', 'N', @ReplaceTypeCode
	  FROM STB_MaterialDocInfo MDI
	  LEFT OUTER JOIN STB_MaterialDocDetail MDD
	    ON MDI.MaterialDocNo = MDD.MaterialDocNo
	 WHERE MDI.MaterialDocNo = @MaterialDocNo
END