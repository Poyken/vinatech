-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2025-04-28
-- Description:	
-- =============================================
CREATE PROCEDURE usp_InformationWaste_get_T888 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCodeNVL VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ VARCHAR(50) = CASE WHEN ISNULL(@pCodeNVL,'') = '' THEN '%' ELSE @pCodeNVL END
	SELECT 
       WS.LOAIHANG,
       WS.CODENVL,
       WS.NAMESNVL,
       WS.UNIT,
       WS.PRICES,
       WS.NORM,
       WS.DESCPRTIONS,
       WS.CreateDateTime,
       WS.CreateUserID ,
       WS.ChangeDateTime,
       WS.ChangeUserID
  
   from
       STB_VN_B598 WS WHERE (@pCodeNVL IS NULL OR @pCodeNVL = '' OR WS.CODENVL LIKE @pCodeNVL)
END
