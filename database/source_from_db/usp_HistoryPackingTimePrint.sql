-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================= exec usp_HistoryPackingTimePrint
CREATE PROCEDURE [dbo].[usp_HistoryPackingTimePrint]
		@pProcessUserID varchar(20)=NULL,
		@pProcessLanguage varchar(20)=NULL,
		@pLotNo varchar(30) = NULL,
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if(@pLotNo <> '')
		begin
			select * from STB_SavePackingTime_VVT
			where
			1=1
			and
			 LotNo=@pLotNo
			and 
			 @pFromDate +'00:00:00' <= PrintTime and PrintTime <= @pToDate +'23:59:59.999'
		end
	else
		begin 
			select * from STB_SavePackingTime_VVT
			where
			1=1
			and 
			 @pFromDate +'00:00:00' <= PrintTime and PrintTime <= @pToDate +'23:59:59.999'
		end 
END
