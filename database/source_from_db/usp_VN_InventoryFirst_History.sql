CREATE PROC [dbo].[usp_VN_InventoryFirst_History]
AS
SET NOCOUNT ON;
	BEGIN
			SELECT 
					IDIFH,
					IDIF,
					CLASSIFY,
					STAGE,
					MODEL,
					PRODUCTIONNAME,
					UNIT,
					STATUSS,
					LOCATIONS,
					QTYONPAGER,
					ACTUALLYQTY,
					DESCRIPTIONS,
					CreateUserID,
					CONVERT(DATE,CreateDateTime) AS Dates,
					RIGHT(CreateDateTime,8) AS Times,
					ChangeUserID,
					CONVERT(DATE,ChangeDateTime) AS DateChange,
					RIGHT(ChangeDateTime,8) AS TimesChange

			FROM 
					STB_VN_InventoryFirst_History WITH (NOLOCK)
	END