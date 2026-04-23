-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-25
-- Description:	Lấy lịch sử thay đổi nguyên liệu đầu vào của hàng hà nam
-- ============================================= exec usp_getMaterialInputHaNamFactory '','','VE250210-005'
CREATE PROCEDURE usp_getMaterialInputHaNamFactory
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLotID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select HCIMOB.ID,HCIMOB.LotID,SI.MaterialCode,OldMaterialCode,MM1.MaterialName as OldMaterialName,NewMaterialCode,MM2.MaterialName as NewMaterialName,IsUse,HCIMOB.CreateDateTime,HCIMOB.CreateUserID,HCIMOB.ChangeDateTime
	,HCIMOB.ChangeUserID ,HCIMOB.Reason,HCIMOB.UseQty
	    from STB_HistoryChangeInputMaterialOfBOM HCIMOB
		left join STB_SetInfo SI on SI.barcode= @pLotID
		left join STB_MaterialMaster MM1 on HCIMOB.OldMaterialCode = MM1.MaterialCode
		left join STB_MaterialMaster MM2 on HCIMOB.OldMaterialCode = MM2.MaterialCode
	 where LotID=@pLotid

END
