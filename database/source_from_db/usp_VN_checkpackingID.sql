CREATE PROC [dbo].[usp_VN_checkpackingID]
@PACKID NVARCHAR(50)
AS
BEGIN
		SELECT
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				PartNo,
				PublicCode,
				Country,
				StatusSystem,
				Statusout,
				LOCATIONS
				
		FROM 
				STB_VN_FINISHGOODS
		WHERE
				PackingID = @PACKID AND PackingID IS NOT NULL AND Statusout IS NULL
				
END