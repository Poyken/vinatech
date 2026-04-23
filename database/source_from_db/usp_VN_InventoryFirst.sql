-- =============================================
-- Author:	Kevin Nguyen(nguyennha@vina.co.kr)
-- Create date: 2020.06.23
-- Browsable : true
-- Group : EA VN TEAM
-- Description:	The inventory first stage months function.
-- =============================================
CREATE PROC [dbo].[usp_VN_InventoryFirst]
	@pFromBasicDate DATE = NULL,
	@pToBasicDate DATE = NULL,
	@pSTAGE VARCHAR(50) = NULL,
	@pMODEL VARCHAR(50) = NULL
	
WITH RECOMPILE	
AS
BEGIN
SET NOCOUNT ON;
	
		
			DECLARE @STAGE VARCHAR(50) = CASE WHEN ISNULL(@pSTAGE,'') = '' THEN '%' ELSE @pSTAGE END, 
				    @MODEL VARCHAR(50) =  CASE WHEN ISNULL(@pMODEL,'') = '' THEN '%' ELSE @pMODEL END
			DECLARE @FromBasicDate DATE = @pFromBasicDate
			DECLARE @ToBasicDate DATE = @pToBasicDate
			
			SELECT 
					T1.CLASSIFY,
					T1.MODEL,
					T1.PRODUCTIONNAME,
					T1.UNIT,
					T1.ACTUALLYQTY,
					T1.DateInput,
					T1.NAMETYPE,
					T1.DESCRIPTIONS,
					T1.CreateUserID,
					CONVERT(DATE,T1.CreateDateTime) AS Dates,
					RIGHT(T1.CreateDateTime,8) AS Times,
					IDIF

			FROM 
					STB_VN_InventoryFirst T1 WITH(NOLOCK)
					
		    WHERE 1=1
			    AND
				(
					((@FromBasicDate IS NULL) OR CONVERT(DATE,T1.DateInput) >= @FromBasicDate)
					AND ((@ToBasicDate IS NULL) OR CONVERT(DATE,T1.DateInput) <= @ToBasicDate)
				)
				AND
				(T1.STAGE LIKE @STAGE)
				AND
				(T1.MODEL LIKE @MODEL)
				
	END
