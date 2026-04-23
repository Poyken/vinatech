-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-09-21
-- Description:	Lấy ra vị trí của lot điện cực hiện tại exec usp_LocationElectric '','','VVOR2020001E13'
-- =============================================
CREATE PROCEDURE usp_LocationElectric
	@pProcessUserID varchar(20)=NULL,
	@pProcessLanguage varchar(20)=NULL,
	@pElectrodeLotNumber varchar(30) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--RAISERROR(14138, -1, -1, @pElectrodeLotNumber);
	select ESR.*,MM.MaterialCode,MM.MaterialName
	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  where 
	  1=1
	  and	ESR.ElectrodeLotNumber=@pElectrodeLotNumber

END
