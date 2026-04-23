CREATE PROC [dbo].[usp_VN_BENDING_TAPPING]
@pLOTNO NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @Barcode NVARCHAR(50) = @pLOTNO


		SELECT
				vbt.ID,
				vbt.CODEPRODUCTION,
				vbt.FWAL,
				vbt.Vol,
				vbt.CODEERROR,
				vbt.NAMEERROR,
				vbt.QTYERROR,
				vbt.LOTNO,
				replace(vbt.MachineName,'￡','') as MachineName,   ----
				vbt.ModelCode,     ----
				vbt.TYPESS,
				vbt.QTYLOTNO,
				vbt.CreateDateTime,
				vbt.CreateUserID,
				vbt.ChangeDateTime,
				vbt.ChangeUserID
		FROM
			 STB_VN_BENDING_TAPPING  vbt  WITH(NOLOCK)
			 left outer join stb_setinfo  si  WITH(NOLOCK) on vbt.lotno = si.barcode
			 left outer join stb_materialmaster  mm   WITH(NOLOCK) on si.materialcode = mm.materialcode
		WHERE
			 LOTNO = @Barcode

END