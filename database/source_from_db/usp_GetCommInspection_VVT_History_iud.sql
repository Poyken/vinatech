
-- =============================================
-- Author:	    HaNguyen
-- Create date: 2024-07-22
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCommInspection_VVT_History_iud]
    @pCommInspDocNo VARCHAR(20)= null,
	@pAccontent NVARCHAR(50) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CommInspDocNo VARCHAR(20) = @pCommInspDocNo
	DECLARE  @Accontent NVARCHAR(50) = @pAccontent
	DECLARE  @test NVARCHAR(50) 
	--raiserror(@CommInspDocNo,16,1)
 update STB_CommInspDocHistory set Accontent=@Accontent where CommInspDocNo like @CommInspDocNo

  
END
