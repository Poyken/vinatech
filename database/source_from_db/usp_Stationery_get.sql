

CREATE PROCEDURE [dbo].[usp_Stationery_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pStationeryCode VARCHAR(20) = NULL,
    @pStationeryName NVARCHAR(100) = NULL,
	@pCompanyCode NVARCHAR(50) = NULL,
	@pWorkCenterCode NVARCHAR(50) = NULL,
	@pNameWorkCenterCode NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @StationeryCode VARCHAR(20) = CASE WHEN ISNULL(@pStationeryCode,'') = '' THEN '*' ELSE @pStationeryCode END
      DECLARE @StationeryName NVARCHAR(100) = CASE WHEN ISNULL(@pStationeryName,'') = '' THEN '*' ELSE @pStationeryName END
	 
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
		StationeryCode as OldStationeryCode,
		WorkCenterCode,
		NameWorkCenterCode
	FROM
	       STB_StationeryInfo
	WHERE
	        ((@StationeryCode = '*') OR (StationeryCode = @StationeryCode)) AND
			((@pWorkCenterCode = '*') OR (WorkCenterCode = @pWorkCenterCode)) AND
	        ((@StationeryName = '*') OR (StationeryName like '%'+@StationeryName+'%'))
		
	order by StationeryCode
END


--select * from STB_StationeryInfo

--alter table STB_StationeryInfo
--add
--		CompanyCode NVARCHAR(50) NULL,
--		WorkCenterCode NVARCHAR(50) NULL,
--		NameWorkCenterCode NVARCHAR(50) NULL


