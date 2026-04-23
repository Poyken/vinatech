-- =============================================
-- Author:		<Author,,Kevin Nguyen>
-- Create date: <20220,06,18>
-- Description:	<The search data for scrap>
-- =============================================
CREATE PROCEDURE usp_VN_Search_Scrap
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pLine VARCHAR(20) = NULL,
	@pModel VARCHAR(50) = NULL,
	@pItem  VARCHAR(50) = NULL,
	@pNG VARCHAR(50) = NULL,
	@pNameError VARCHAR(50) = NULL,
	@pWeights VARCHAR(20)= NULL,
	@pStatusError VARCHAR(50) = NULL,
	@pNameShift  VARCHAR(50) = NULL,
	@pDecs VARCHAR(50) = NULL
AS
BEGIN
		SET NOCOUNT ON;

		DECLARE @Line VARCHAR(20) = CASE WHEN ISNULL(@pLine,'') = '' THEN '*' ELSE @pLine END,
				@Model VARCHAR(50)= CASE WHEN ISNULL (@pModel, '') = '' THEN '*' ELSE @pModel END,
				@Item VARCHAR(50)= CASE WHEN ISNULL (@pItem, '') = '' THEN '*' ELSE @pItem END,
				@NG  VARCHAR(50)= CASE WHEN ISNULL (@pNG, '') = '' THEN '*' ELSE @pNG END,
				@NameError  VARCHAR(50)= CASE WHEN ISNULL (@pNameError, '') = '' THEN '*' ELSE @pNameError END,
				@Weights VARCHAR(50)= CASE WHEN ISNULL (@pWeights, '') = '' THEN '*' ELSE @pWeights END,
				@StatusError VARCHAR(50)= CASE WHEN ISNULL (@pStatusError, '') = '' THEN '*' ELSE @pStatusError END,
				@NameShift VARCHAR(50)= CASE WHEN ISNULL (@pNameShift, '') = '' THEN '*' ELSE @pNameShift END,
				@Decs VARCHAR(50)= CASE WHEN ISNULL (@pDecs, '') = '' THEN '*' ELSE @pDecs END

				SELECT 
				    
					 
					 VNSHOW.Line,
					 VNSHOW.Model,
					 VNSHOW.Item,
					 VNSHOW.NG,
					 VNSHOW.NameError,
					 VNSHOW.Weights,
					 VNSHOW.Decs,
					 VNSHOW.StatusError,
					 VNSHOW.NameShift,
					 VNSHOW.CreateDateTime AS Dates,
					 RIGHT(VNSHOW.CreateDateTime,8) AS Times,
					 CreateUserID,
					 VNSHOW.IDPE
					

				FROM
					 STB_VN_PRODUCTION_ERROR VNSHOW WITH(NOLOCK)
				
				WHERE  
					  ((@Line = '*')) OR((Line = @Line)) 
						AND
						((@Model = '*')) OR((Model = @Model)) 
						AND
						((@Item = '*')) OR((Item = @Item)) 
						AND
						((@NG = '*')) OR((NG = @NG)) 
						AND
						((@NameError = '*')) OR((NameError = @NameError)) 
						AND
						((@Weights = '*')) OR((Weights = @Weights)) 
						AND
						((@StatusError = '*')) OR((StatusError = @StatusError)) 
						AND
						((@NameShift = '*')) OR((NameShift = @NameShift)) 
						AND
						((@Decs = '*')) OR((Decs = @Decs)) 
					
END
