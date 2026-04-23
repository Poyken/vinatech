CREATE PROCEDURE [dbo].[usp_get_FinalProductInfo]
	@pDocNo varchar(50) = NULL,
	@pFromDate DateTime = NULL,
	@pToDate DateTime = NULL,
	@pInvoiceNo varchar(20) = NULL

AS
BEGIN
	SELECT T1.DocNo,  
	convert(varchar, T1.BasicDate, 111) as BasicDate, 
--	BasicDate,
	
	T1.DocType,
	T2.NAME as NameDocType,
	T1.DocStatus,
	T1.InvoiceNo, 
	T1.Description,
	T1.CreateUserID, 
	convert(varchar, T1.CreateDateTime, 120) as CreateDateTime, 
	convert(varchar, T1.ChangeDateTime, 120) as ChangeDateTime, 
	--T1.CreateDateTime, 
	--T1.ChangeDateTime,
	T1.ChangeUserID,
	T1.Department
	FROM
		STB_FinalProductInfo T1, STB_TYPEINOUT T2

	WHERE T1.DocType = T2.DOCTYPE
		AND (@pDocNo IS NULL OR @pDocNo ='' OR T1.DocNo =@pDocNo)
		AND (@pInvoiceNo IS NULL OR @pInvoiceNo ='' OR T1.InvoiceNo =@pInvoiceNo)
		AND ((@pFromDate IS NULL OR @pFromDate='' OR T1.BasicDate >= @pFromDate) 	 
		AND (@pToDate IS NULL OR @pToDate =''    OR T1.BasicDate <= @pToDate)) 
	ORDER BY T1.DocNo
END
