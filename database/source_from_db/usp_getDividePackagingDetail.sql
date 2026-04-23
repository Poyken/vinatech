-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-04
-- Description:	Click vào 1 dòng sẽ xem chi tiết lịch sử chia tem
-- exec usp_getDividePackagingDetail 'HNDPK0000000125'
-- =============================================
CREATE PROCEDURE [dbo].[usp_getDividePackagingDetail] 
	-- Add the parameters for the stored procedure here
	@pDividePackagingID VARCHAR(50)
AS
BEGIN
    DECLARE @DividePackagingID VARCHAR(50) = @pDividePackagingID 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
						 SELECT 
						 DP.PackingID,
						 DP.MaterialCode,
						 DP.Qty,
						 DP.GRDate,
						 DP.LotNo,
						 DP.CreateDateTime,
						 DP.CreateUserID
						    
						  from STB_DividePackaging DP
						
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 1
						order by DP.PackingID
END
