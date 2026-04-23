-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
--exec usp_stb_MergeBoxRealityHist_531_get 'VVOO152R725665'
CREATE PROCEDURE [dbo].[usp_MergeBoxRealityHist_531_get]
    @pMergeNumber VARCHAR(50) = NULL
AS
BEGIN
	 
	     DECLARE @MergeNumber VARCHAR(50)=@pMergeNumber

		select * from stb_MergeBoxRealityHist where MergeNumber=@pMergeNumber
		
END

    
	--select * from stb_MergeBoxRealityHist
	--delete from stb_MergeBoxRealityHist



