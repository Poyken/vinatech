CREATE PROCEDURE [dbo].[usp_get_FinalProductDetail]
	@pDocNo varchar(50) = NULL
AS
BEGIN
	SELECT T1.ID,T1.DocNo, 
	T1.ProductCode, 
	T2.MaterialName, 
	T2.MaterialUnit, 
	T1.Quantity, 
	T1.Description, 
	convert(varchar, T1.CreateDateTime, 120) as CreateDateTime,
	T1.CreateUserID, 
	convert(varchar, T1.ChangeDateTime, 120) as ChangeDateTime,
	T1.ChangeUserID
	FROM
		STB_FinalProductDetail T1,STB_MaterialMaster T2,STB_FinalProductInfo T3
	WHERE 1=1
		AND T1.DocNo = T3.DocNo
		AND T1.ProductCode = T2.MaterialCode
		AND (@pDocNo IS NULL OR @pDocNo ='' OR T1.DocNo=@pDocNo)
END
