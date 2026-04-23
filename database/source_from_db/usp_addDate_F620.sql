
-- text exec usp_addDate_F620 'ML20251027000001','2025-01-02'
CREATE PROCEDURE [dbo].[usp_addDate_F620](
  @pLotID VARCHAR(100),       
  @pStartPeriod VARCHAR(20)
)
AS
BEGIN
   -- Author:Nguyen Hai Trieu (22/04/2025)
 SET NOCOUNT ON;
				DECLARE @LotID VARCHAR(100) = @pLotID
				DECLARE @StartDate VARCHAR(20) =@pStartPeriod


				--raiserror(@pStartDate,16,1)
					UPDATE STB_MaterialDocLotInfo  
						 SET   LotAttr10 = @StartDate
						 where  LotID = @LotID 
							  
						
				 UPDATE STB_MaterialLotInfo  
				 SET      LotAttr10 = @StartDate
					 where  LotID = @LotID 

END


