-- 고객납품의뢰/출하반품의뢰 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-26
-- Browsable : true
-- Group : 인터페이스
-- Source Table: NEOE.NEOE.SA_Z_VINA_GIR_IF
-- Target Table: SmartFactoryV2.DBO.STB_MaterialDocInfo, SmartFactoryV2.DBO.STB_MaterialDocDetail
-- Description:	출하/반품 인터페이스
-- Modified:
-- =============================================
CREATE PROC usp_SalesInOutRequest_itf
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode

	Declare @MaterialDocNo VARCHAR(20)
	Declare @MaterialDocDetailNo VARCHAR(20)

	-- 인터페이스 할 대상 변수 선언
	Declare @ShipmentRequestNo	NUMERIC(12,0)
		   ,@CompanyCode	NVARCHAR(7)
		   ,@WorkCenterCode	NVARCHAR(7)
		   ,@RequestDate	NVARCHAR(8)
		   ,@RequestNo	NVARCHAR(20)
		   ,@LineSeq	NUMERIC(5)
		   ,@EmpCode	NVARCHAR(10)
		   ,@DueDate	NVARCHAR(8)
		   ,@ShipmentDate	NVARCHAR(8)
		   ,@MaterialCode	NVARCHAR(50)
		   ,@WarehouseCode	NVARCHAR(7)
		   ,@IsReturn	NCHAR(1)
		   ,@PaymentTypeCode	NVARCHAR(4)
		   ,@PaymentTypeName	NVARCHAR(100)
		   ,@ShipmentQty	NUMERIC(17,4)
		   ,@ShipmentUnit	NVARCHAR(3)
		   ,@ShipmentStockQty	NUMERIC(17,4)
		   ,@ShipmentStockUnit	NVARCHAR(3)
		   ,@OrderCustomerCode	NVARCHAR(7)
		   ,@ShipmentCustomerCode	NVARCHAR(7)
		   ,@ShipmentRequestHeaderRemark	NVARCHAR(500)
		   ,@ShipmentRequestHeaderRemark1	NVARCHAR(500)
		   ,@ShipmentRequestLineRemark	NVARCHAR(500)
		   ,@ShipmentRequestLineRemark1	NVARCHAR(500)
		   ,@CreateDateTimeERP	NVARCHAR(14)
		   ,@ChangeDateTImeERP	NVARCHAR(14)
		   ,@SendDateTimeERP	NVARCHAR(14)
		   ,@IUDFlag	NVARCHAR(1)
		   ,@ReceiveFlag	NVARCHAR(1)
		   ,@ProcessFlag	NVARCHAR(14)
		   ,@ErrorFlag	NVARCHAR(1)
		   ,@ErrorMsg	NVARCHAR(1000)

	-- Cursor 선언
	Declare icur CURSOR FOR
		-- Query
		SELECT NO_SEQ
              ,CD_COMPANY 
              ,CD_PLANT
              ,DT_REQ
              ,NO_REQ
              ,NO_LINE
              ,NO_EMP
              ,DT_DUEDATE
              ,DT_REQGI
              ,CD_ITEM
              ,CD_SL
              ,YN_RETURN
              ,CD_QTIOTP
              ,NM_QTIOTP
              ,QT_REQ
              ,UNIT
              ,QT_REQ_IM
              ,UNIT_IM
              ,CD_PARTNER
              ,CD_GIPARTNER
              ,DC_RMKH
              ,DC_RMKH1
              ,DC_RMK
              ,DC_RMK1
              ,DTS_INSERT
              ,DTS_UPDATE
              ,DTS_SEND
              ,FG_IUD
              ,FG_READ
              ,DTS_READ
              ,FG_ERR
              ,ERR_MSG
		  FROM NEOE.NEOE.SA_Z_VINA_GIR_IF
		 WHERE CD_COMPANY = @IUCompanyCode
		   AND ISNULL(FG_READ, 'N') = 'N'
		   AND NO_REQ NOT IN (SELECT ShipmentRequestNo FROM STB_MaterialDocInfo WHERE ShipmentRequestNo IS NOT NULL)
		 ORDER BY NO_REQ, NO_LINE

	OPEN icur
		WHILE 1 = 1 BEGIN
			FETCH NEXT FROM icur INTO
				-- 변수
				@ShipmentRequestNo
		       ,@CompanyCode
		       ,@WorkCenterCode
		       ,@RequestDate
		       ,@RequestNo
		       ,@LineSeq
		       ,@EmpCode
		       ,@DueDate
		       ,@ShipmentDate
		       ,@MaterialCode
		       ,@WarehouseCode
		       ,@IsReturn
		       ,@PaymentTypeCode
		       ,@PaymentTypeName
		       ,@ShipmentQty
		       ,@ShipmentUnit
		       ,@ShipmentStockQty
		       ,@ShipmentStockUnit
		       ,@OrderCustomerCode
		       ,@ShipmentCustomerCode
		       ,@ShipmentRequestHeaderRemark
		       ,@ShipmentRequestHeaderRemark1
		       ,@ShipmentRequestLineRemark
		       ,@ShipmentRequestLineRemark1
		       ,@CreateDateTimeERP
		       ,@ChangeDateTImeERP
		       ,@SendDateTimeERP
		       ,@IUDFlag
		       ,@ReceiveFlag
		       ,@ProcessFlag
		       ,@ErrorFlag
		       ,@ErrorMsg
            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- 미수신 건이므로 무조건 Insert 한다.
			-- @LineSeq = 1 이면, 헤더 입력 후 라인을 입력하고,
			IF @LineSeq = 1 BEGIN
				-- DocInfo PK Get
				EXEC Smartframework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo', @MaterialDocNo OUTPUT

				-- Insert STB_MaterialDocInfo
				INSERT INTO STB_MaterialDocInfo
						(
						    MaterialDocNo,
						    BasicDate,
						    MaterialDocType,
						    MaterialDocTypeCode,
						    DocStatus,
						    SourceCompanyCode,
						    SourceWorkCenterCode,
						    SourceMaterialWarehouseCode,
						    TargetCustomerCode,
						    RequestDateTime,
						    RequestUserID,
						    RequestPlanDate,
							IsCancel,
							ShipmentRequestNo
						)
						VALUES
						(
						    @MaterialDocNo,
						    GETDATE(),
						    'GI',
						    'GI_SALES',
						    'CREATE',
						    CASE WHEN @IUCompanyCode = 'TEST' THEN 'VNT' 
							     WHEN @IUCompanyCode = 'TESTV' THEN 'VVT' 
								 ELSE '' END,
							CASE WHEN @IUCompanyCode = 'TEST' THEN 'VNT_F1' 
							     WHEN @IUCompanyCode = 'TESTV' THEN 'VVT_F1' 
								 ELSE '' END,
						    'PROD_WH',
						    @OrderCustomerCode,
						    GETDATE(), --@RequestDateTime,
						    @EmpCode,
						    @DueDate,
							CONVERT(BIT, 0),
							@RequestNo
						)
			END
			
			-- 헤더 입력 후 상세정보를 입력한다.
			-- 상세테이블 PK Get
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT

			INSERT INTO STB_MaterialDocDetail
					(
					    MaterialDocDetailNo,
					    MaterialDocNo,
					    MaterialCode,
					    MaterialStockAttribute,
					    RequestQty,
					    AllowQty,
					    PickingAssignQty,
					    PickingQty,
					    ProcessFixQty,
						InspectionType,
						CreateDateTime,
						ShipmentRequestLineNo
					)
					VALUES
					(
					    @MaterialDocDetailNo,
					    @MaterialDocNo,
					    @MaterialCode,
					    'NORMAL',
					    @ShipmentQty,
					    @ShipmentQty,
					    @ShipmentQty,
					    0,
					    0,
						'NONE',
						GETDATE(),
						@LineSeq
					)
			
			
			-- Read Flag Update
			UPDATE NEOE.NEOE.SA_Z_VINA_GIR_IF
			   SET FG_READ = 'Y'
			      ,DTS_READ = dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE())
			 WHERE NO_REQ = @RequestNo
			   AND NO_LINE = @LineSeq
		END


		CLOSE icur;
		DEALLOCATE icur;

END