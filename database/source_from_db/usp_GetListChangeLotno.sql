-- =============================================
-- Author:		Mr.Duy
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetListChangeLotno]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		 select CPNA.ID,CPNA.oldLotID,SI.MaterialCode,MM.MaterialName,CPNA.NewLotID,isLotID,CPNA.CreateUserID,CPNA.Createdatetime from STB_ChangePartNoAndLotNo CPNA
		 left join stb_setinfo SI on CPNA.oldLotID = SI.Barcode
		 left join  STB_MaterialMaster MM  on SI.MaterialCode = MM.MaterialCode
		 order by CPNA.Createdatetime desc
END
--select *from stb_setinfo where barcode = 'VVOU173R850614'
