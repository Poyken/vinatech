-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-29
-- Description:	Lịch sử đóng thùng to hà nam
-- =============================================
CREATE PROCEDURE usp_getHistoryMerBox
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20)=NULL,
						@pWorkCenterCode VARCHAR(20)=NULL,
						@pFromDate date = NULL,
						@pToDate date = NULL,
						@pPackingOutPutFinishGoodsID VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode      VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@PackingOutPutFinishGoodsID    VARCHAR(20) = CASE WHEN ISNULL(@pPackingOutPutFinishGoodsID, '') = ''   THEN '*' ELSE @pPackingOutPutFinishGoodsID  END



	select 
	POP.PackingOutPutFinishGoodsID,
	POP.MaterialCode,
	MM.MaterialName,
	POP.CurrentQty,
	POP.Marking,
	POP.CombineMaterialcodeAndQty,
	POP.CreateDateTime,
	POP.CreateUserID 
	from STB_PackingOutPutFinishGoods_HN POP
	left join STB_MaterialMaster MM on POP.MaterialCode = MM.MaterialCode
END
