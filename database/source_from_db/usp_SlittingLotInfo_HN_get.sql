-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-01-17
-- Description:	Chia tem slitting
-- ============================================= exec  
CREATE PROCEDURE [dbo].[usp_SlittingLotInfo_HN_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotID VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @LotID VARCHAR(20) = @pLotID
		,@Materialcode varchar(20)
	       ,@sumTem NUMERIC(20, 10)
		   ,@SlitingLength NUMERIC(20, 10)

		declare @isCheckSlitting int;
		select @isCheckSlitting=COUNT(LotID) from STB_MaterialLotInfo where LotID=@LotID and isSlitting=1
		if(@isCheckSlitting>0)
		begin
			RAISERROR( N'Lot này đã  chốt slitting không thể thay đổi nữa' ,16, 1)
			return
		end 


   select @Materialcode=MaterialCode from stb_materiallotinfo where lotid= @pLotID
   if(@Materialcode is null or @Materialcode ='')
		 select @Materialcode=MaterialCode from stb_materialdoclotinfo where lotid= @pLotID

		SELECT @LotID AS LotID
	      ,@Materialcode as Materialcode
		  ,'' AS ChildmaterialcodeUse
		  ,'' AS Childmaterialcode	
		  ,1 AS sumTem
		  ,0.0 AS SlitingLength
END
