-- =============================================
-- Author:		<Mr.Duy>
-- Create date: <2024-02-06>
-- Description:	<Description,,>
-- =============================================
--exec usp_VN_UpdateB682_ToExcel 'VVOJ242R750604'
CREATE PROCEDURE [dbo].[usp_VN_UpdateB682_ToExcel] 
	@pBarCode VARCHAR(20) = NULL
AS

BEGIN
	
	SET NOCOUNT ON;
	declare @ControlNo varchar,
	@defectQ22 numeric(20, 5) = 0.00000,
	@defectQ23 numeric(20, 5) = 0.00000,
	@defectQ24 numeric(20, 5) = 0.00000
	



	select @ControlNo=ControlNo from  STB_SetInfo  WHERE BARCODE=@pBarCode

	select @defectQ22 = DefectQty
	from STB_DefectRepairInfo
	where ControlNo = @ControlNo and DefectCode='V-22_00'

	select @defectQ23 = DefectQty
	from STB_DefectRepairInfo
	where ControlNo = @ControlNo and DefectCode='V-23_00'

	select @defectQ24 = DefectQty
	from STB_DefectRepairInfo
	where ControlNo = @ControlNo and DefectCode='V-24_00'
   
	if(@defectQ22 > 0)
	begin 
		update STB_DefectRepairInfo
		set DefectQty = @defectQ22
		where ControlNo =@ControlNo and DefectCode='V-22_00_BG'
	end
	if(@defectQ23 > 0)
	begin 
		update STB_DefectRepairInfo
		set DefectQty = @defectQ23
		where ControlNo =@ControlNo and DefectCode='V-23_00_BG'
	end
		if(@defectQ24 > 0)
	begin 
		update STB_DefectRepairInfo
		set DefectQty = @defectQ24
		where ControlNo =@ControlNo and DefectCode='V-24_00_BG'
	end


END
