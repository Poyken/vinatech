-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-03
-- Browsable : true
-- Group : 품질관리 / 제품관리 
-- Description:	베트남 제품 입고 현황 / [C560] 법인제품 입/출고 이력 
-- Modified:
--              2021.01.26 인보이스 조회조건 추가
--  usp_ProductsReceiptHist_get '','','','','2024-02-01','2024-03-25','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductsReceiptHist_get]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pBarcode VARCHAR(20) = NULL,
					@pMaterialCode VARCHAR(20) = NULL,
					@pFromDate DATE,
					@pToDate DATE,
					@pInvoiceNo VARCHAR(20) = NULL,
					@pHeadOfficeQcStatusCode VARCHAR(10) = NULL
AS

BEGIN
	Declare @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
			   ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
			   ,@FromDate DATE = @pFromDate
			   ,@ToDate DATE = @pToDate
			   ,@InvoiceNo VARCHAR(20) = CASE WHEN ISNULL(@pInvoiceNo, '') = '' THEN '*' ELSE @pInvoiceNo END
			   ,@HeadOfficeQcStatusCode VARCHAR(10) = CASE WHEN ISNULL(@pHeadOfficeQcStatusCode, '') = '' THEN '*' ELSE @pHeadOfficeQcStatusCode END

	SELECT
	PRH.CODEID
		  ,PRH.Barcode
		  ,PRH.InvoiceNo
		  ,PRH.BLNo
		  ,convert(varchar, PRH.PackingDate, 111) as PackingDate
		  ,convert(varchar, PRH.ShipmentDate, 111) as ShipmentDate
		 -- ,PRH.PackingDate
		 -- ,PRH.ShipmentDate
		  ,PRH.TransportationMethodCode
		  ,BC.Description AS TransportationMethodName
		  ,PRH.MaterialCode
		  ,MM.MaterialName
		  ,PRH.ProdQty
		  ,PRH.IsHeadOfficeConfirm
		  ,PRH.HeadOfficeConfirmDate
		  ,PRH.IsHeadOfficeQcConfirm
		  ,PRH.HeadOfficeQcConfirmDate
		  ,PRH.HeadOfficeQcStatusCode
		  ,PRH.Remark
		  ,PRH.Nation
		  ,PRH.Customer
		  ,PRH.Size
		  ,PRH.CreateDateTime
		  ,PRH.CreateUserID
		  ,PRH.ChangeDateTime
		  ,PRH.ChangeUserID
		  ,MQI.MaterialQcNo
		  ,UI.CompanyCode
		  ,PRH.VNNameProduct
		  ,ID
	  FROM STB_ProductsReceiptHist PRH
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON BC.CodeGroup = 'TransportationMethodCode'	   AND BC.ItemCode = PRH.TransportationMethodCode
			  LEFT OUTER JOIN STB_MaterialMaster MM							ON MM.MaterialCode = PRH.MaterialCode
			  LEFT OUTER JOIN STB_SetInfo SI										ON SI.Barcode = PRH.Barcode
			  LEFT OUTER JOIN STB_MaterialQcInfo MQI							ON SI.LotNumber = MQI.MaterialQcNo 	   AND MQI.InspectionDocType = 'OQC'
			  LEFT OUTER JOIN STB_UserInfo UI										ON UI.UserID = @pProcessUserID
     WHERE 1=1
	   AND (@Barcode = '*' OR PRH.Barcode = @Barcode)
	   AND (@MaterialCode = '*' OR PRH.MaterialCode = @MaterialCode)
	   AND CONVERT(DATE,PRH.createdatetime) BETWEEN @FromDate AND @ToDate
	   AND (@InvoiceNo = '*' OR PRH.InvoiceNo = @InvoiceNo)
	   AND (@HeadOfficeQcStatusCode = '*' OR PRH.HeadOfficeQcStatusCode = @HeadOfficeQcStatusCode)
END

-- select * from SmartFramework.dbo.STB_BaseCode where CodeGroup = 'TransportationMethodCode'

-- exec usp_ProductsReceiptHist_get '','','','','2024-02-01','2024-03-25','',''

-- select * from STB_ProductsReceiptHist where createdatetime >= '2024-03-01'


-- select * from STB_ProductsReceiptHist where codeid  is not null