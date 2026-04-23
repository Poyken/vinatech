
CREATE PROC [dbo].[usp_MasterAgaingDetails]
@pIDCODE NVARCHAR(50) = NULL
AS
BEGIN
		DECLARE @IDCODE NVARCHAR(50) = @pIDCODE

		SELECT
				ID,
				IDCODE,
				LOTNO,
				DATAGAING,
				MODEL,
				NAMEERROR,
				STANDAGAING,
				QTYINPUT,
				QTYOK,
				NGESR,
				NGLC,
				NGOTHER,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID
				
		FROM 
			STB_MasterAgaingDetails WITH(NOLOCK)
		WHERE
				IDCODE = @IDCODE
END

