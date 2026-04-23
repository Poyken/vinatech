CREATE PROC usp_VN_FinishGoodInput
@pQcNo NVARCHAR(50)
AS
BEGIN
		SELECT	
				LotID,
				LotNo,
				MaterialCode,
				MaterialQcNo,
				CurrentQty,
				DecisionResult,
				INPUT,
				CONVERT(DATE, DateIn) AS Datetin,
				RIGHT(DateIn,8) AS Times
				
		FROM
				STB_VN_FINISHGOOD


	    WHERE
				MaterialQcNo=@pQcNo AND INPUT = N'Nhập'
				
END