

CREATE PROCEDURE [dbo].[usp_Stationery_popup]
	

AS
BEGIN
	
	select
		StationeryCode,
		StationeryName,
		TypeStationery,
		BasicUnit,
		Description,
		CreateDateTime,
		CreateUserID,
		ChangeDateTime,
		ChangeUserID,
		StationeryCode as OldStationeryCode
	FROM
	       STB_StationeryInfo
	
	order by StationeryCode
END
