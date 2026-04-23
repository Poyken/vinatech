CREATE PROCEDURE [dbo].[usp_viewfinalproduct]
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pDocNo nvarchar(20) = null,
	@pProductCode nvarchar(20) = null,
	@pInvoiceNo nvarchar(20) = null
AS

BEGIN

	declare @TABLETEMP as table (PRODUCTCODE VARCHAR(50), INVENTORY NUMERIC)
	INSERT INTO @TABLETEMP 
					SELECT T1.ProductCode, COALESCE(SUM(
					CASE WHEN T4.TYPEINOUT ='INPUT' THEN T1.Quantity
						 WHEN T4.TYPEINOUT='OUTPUT' THEN -T1.Quantity
						 ELSE 0
						 END),0) AS INVENTORY
						 --, T1.ProductCode, T4.MaterialUnit
					FROM
							STB_FinalProductDetail T1,
							STB_MaterialMaster T2,
							STB_FinalProductInfo T3,
							STB_TYPEINOUT T4
					WHERE    T1.DocNo = T3.DocNo
							AND T3.DocType = T4.DOCTYPE
							AND T1.ProductCode = T2.MaterialCode
							AND T3.DocStatus='FINISH' 
							AND (@pDocNo IS NULL OR @pDocNo ='' OR T1.DocNo=@pDocNo)
							AND (@pInvoiceNo IS NULL OR @pInvoiceNo ='' OR T3.InvoiceNo=@pInvoiceNo)
							AND (@pProductCode IS NULL OR @pProductCode ='' OR T1.ProductCode=@pProductCode)
							AND ((@pFromDate IS NULL OR @pFromDate='' OR T3.BasicDate >= @pFromDate) 	 
							AND (@pToDate IS NULL OR @pToDate =''    OR T3.BasicDate <= @pToDate)) 
					GROUP BY T1.ProductCode
	SELECT T1.DocNo,
	T3.BasicDate,
	T1.ProductCode, 
	T2.MaterialName, 
	T2.MaterialUnit, 
	T1.Quantity , 
	T1.Description ,
	T3.DEPARTMENT AS Department,
	T4.NAME AS TYPEINOUT,
	T3.InvoiceNo,
	T5.INVENTORY
	FROM
		STB_FinalProductDetail T1,
		STB_MaterialMaster T2,
		STB_FinalProductInfo T3,
		STB_TYPEINOUT T4,
		@TABLETEMP T5
	WHERE 1=1
		AND T1.DocNo = T3.DocNo
		AND T3.DocType = T4.DOCTYPE
		AND T1.ProductCode = T2.MaterialCode
		AND T1.ProductCode = T5.PRODUCTCODE
		AND T3.DocStatus='FINISH'
		AND (@pDocNo IS NULL OR @pDocNo ='' OR T1.DocNo=@pDocNo)
		AND (@pInvoiceNo IS NULL OR @pInvoiceNo ='' OR T3.InvoiceNo=@pInvoiceNo)
		AND (@pProductCode IS NULL OR @pProductCode ='' OR T1.ProductCode=@pProductCode)
		AND ((@pFromDate IS NULL OR @pFromDate='' OR T3.BasicDate >= @pFromDate) 	 
		AND (@pToDate IS NULL OR @pToDate =''    OR T3.BasicDate <= @pToDate)) 


	DELETE FROM @TABLETEMP
END