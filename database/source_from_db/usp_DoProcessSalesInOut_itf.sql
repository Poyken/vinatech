-- 고객납품의뢰/출하반품의뢰 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-26
-- Browsable : true
-- Group : 인터페이스
-- Source Table: NEOE.NEOE.MM_Z_VINA_QTIO_POP
-- Target Table: SmartFactoryV2.DBO.STB_MaterialDocInfo, SmartFactoryV2.DBO.STB_MaterialDocDetail
-- Description:	출하/반품 인터페이스
-- Modified:
-- =============================================
CREATE PROC usp_DoProcessSalesInOut_itf
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
   ,@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode
	       ,@MaterialDocNo VARCHAR(20) = @pMaterialDocNo

	-- Master Insert
	INSERT INTO NEOE.NEOE.MM_Z_VINA_QTIO_POP (
		CD_COMPANY, CD_PLANT, NO_POP, NO_POP_LINE, NO_REQ
       ,NO_LINE, YN_RETURN, CD_QTIOTP, CD_SL, DT_IO
       ,CD_ITEM, QT_IO, CD_PARTNER, DTS_INSERT, DTS_SEND
	   ,FG_IUD, FG_READ
	)
	SELECT @IUCompanyCode, '1000', MDI.MaterialDocNo,  MDD.ShipmentRequestLineNo, MDI.ShipmentRequestNo
	      ,MDD.ShipmentRequestLineNo, 'N', '200', dbo.fnConvertWarehouseCode('ERP', MDI.SourceMaterialWarehouseCode)
		  ,CONVERT(CHAR(8), GETDATE(), 112)
		  ,MDD.MaterialCode, MDD.RequestQty, MDI.TargetCustomerCode
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE())
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE())
		  ,'I', 'N'
	  FROM STB_MaterialDocInfo MDI
	  LEFT OUTER JOIN STB_MaterialDocDetail MDD
	    ON MDI.MaterialDocNo = MDD.MaterialDocNo
	 WHERE MDI.MaterialDocNo = @MaterialDocNo
END