-- =============================================
-- Author:	Kevin Nguyen(nguyennha@vina.co.kr)
-- Create date: 2020.06.23
-- Browsable : true
-- Group : EA VN TEAM
-- Description:	The inventory first stage months function.
-- =============================================
CREATE PROC [dbo].[usp_VN_MODEL_INVENTORY]
AS
BEGIN
		SET NOCOUNT ON;

			SELECT 
					T1.CLASSIFY,
					T1.MODEL,
					T1.PRODUCTIONNAME,
					T1.UNIT,
					T1.ACTUALLYQTY,
					T1.DateInput,
					T1.NAMETYPE,
					T1.DESCRIPTIONS,
					T1.CreateUserID,
					CONVERT(DATE,T1.CreateDateTime) AS Dates,
					RIGHT(T1.CreateDateTime,8) AS Times
					

			FROM 
					STB_VN_InventoryFirst T1 WITH(NOLOCK)

		   ORDER BY DateInput DESC
					
		--SELECT 
		--		CODEMODEL,
		--		NAMES,
		--		IsUsed,
		--		DECRISPTION,
		--		CONVERT(DATE,CreateDateTime) AS CreateDateTime,
		--		RIGHT(CreateDateTime,8) AS TimeCreate,
		--		CreateUserID,
		--		CONVERT(DATE,ChangeDateTime) AS ChangeDateTime,
		--		ChangeUserID,
		--		RIGHT(ChangeDateTime,8) AS Timechange,
		--		IDM
		--FROM
		--		STB_VN_MODEL_INVENTORY WITH(NOLOCK)
END
