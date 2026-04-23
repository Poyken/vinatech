CREATE PROCEDURE [dbo].[usp_get_StatusScrap]

AS
BEGIN
	select 'CHO PHE' as Status from STB_ScrapsByLot
	UNION
	select 'BAO PHE' as Status from STB_ScrapsByLot
	UNION
	select 'XUAT RA SAN XUAT' as Status from STB_ScrapsByLot
END
