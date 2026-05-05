-- Procedure: us_vn_Show_Detail_StoreMachines
CREATE PROC us_vn_Show_Detail_StoreMachines
AS
BEGIN
		SELECT
				
				CODESTOREMACHINES,
				NAMESTORE,
				Locations,
				Descptions,
				IsUsed,
				CreateDateTime AS Dates,
				RIGHT(CreateDateTime,8) AS Times,
				CreateUserID,
				ChangeDateTime AS DatesChange,
				RIGHT(ChangeDateTime,8) AS TimeChane,
				ChangeUserID
		FROM

			 STB_VN_STOREMACHINES WITH(NOLOCK)

END
GO

