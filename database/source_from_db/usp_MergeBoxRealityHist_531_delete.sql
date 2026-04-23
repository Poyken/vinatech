-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
--exec usp_stb_MergeBoxRealityHist_531_get 'VVOO152R725665'
CREATE PROCEDURE [dbo].[usp_MergeBoxRealityHist_531_delete]
    @pProcessUserID VARCHAR(20) = NULL,
    @pProcessLanguage VARCHAR(20) = NULL,
	@pId int  = NULL
  
	
AS
BEGIN
	--declare @test VARCHAR(20)=@pId
	--RAISERROR(@test, 16, 1);
	DECLARE  @MergeNumber VARCHAR(50)
	DECLARE @Id int= @pId
	DECLARE @BoxQty int 

	select @MergeNumber=MergeNumber from stb_MergeBoxRealityHist where Id =@Id

	 
	Delete from stb_MergeBoxRealityHist where Id =@Id

	select @BoxQty= sum(BoxQty) from stb_MergeBoxRealityHist where MergeNumber=@MergeNumber
	update stb_MergeBoxReality set BoxQty=@BoxQty where MergeNumber=@MergeNumber
END
    
	--select * from stb_MergeBoxRealityHist
	--delete from stb_MergeBoxRealityHist


