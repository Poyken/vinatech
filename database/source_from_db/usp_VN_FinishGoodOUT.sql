CREATE PROC [dbo].[usp_VN_FinishGoodOUT]
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
				OUTPUTS,
				CONVERT(DATE, DateOut) AS Dateout,
				RIGHT(DateOut,8) AS Times
				
		FROM
				STB_VN_FINISHGOOD


	    WHERE
				MaterialQcNo=@pQcNo AND OUTPUTS = N'Xuất'
				
END