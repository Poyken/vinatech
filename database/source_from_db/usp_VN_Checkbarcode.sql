CREATE PROC usp_VN_Checkbarcode
@pQcNo NVARCHAR(100)
AS
BEGIN
		SELECT 
					
				   MaterialQcNo

			FROM
					STB_MaterialLotInfo T1

			LEFT JOIN 

					 STB_MaterialQcDetail T2 ON T2.MaterialQcNo= T1.LotNo

			WHERE

					 T2.MaterialQcNo IS NOT NULL AND MaterialQcNo=@pQcNo


END