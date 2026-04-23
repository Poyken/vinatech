-- =============================================
-- Author:		DinhManh
-- Create date: 2025-11-29
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getMarkingLetterTapping_VVT]  -- exec usp_getMarkingLetterTapping_VVT 'mak1', 'mak2', 'mak3', 'mak4', 'mak5-mak6'
	-- Add the parameters for the stored procedure here
		@m1 VARCHAR(20) = NULL,
		@m2 VARCHAR(20) = NULL,
		@m3 VARCHAR(20) = NULL,
		@m4 VARCHAR(20) = NULL,
		@m5 VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		declare  @pmark1 VARCHAR(20),
				 @pmark2 VARCHAR(20),
				 @pmark3 VARCHAR(20),
				 @pmark4 VARCHAR(20),
				 @pmark5 VARCHAR(20)
				 --@MarkingLetters VARCHAR(30)

		set @pmark1 = case when len(@m1)>3 then @m1 else '' end
		set @pmark2 = case when len(@m2)>3 then '-' + @m2 else '' end
		set @pmark3 = case when len(@m3)>3 then '-' + @m3 else '' end
		set @pmark4 = case when len(@m4)>3 then '-' + @m4 else '' end
		set @pmark5 = case when len(@m5)>3 then '-' + @m5 else '' end
		
		declare @MarkingLetterstmp varchar(50) =  @pmark1 + replace(@pmark2,@pmark1,'') 
												+ replace(replace(@pmark3,@pmark1,''),@pmark2,'')
												+ replace(replace(replace(@pmark4,@pmark1,''),@pmark2,''),@pmark3,'')
												+ replace(replace(replace(replace(@pmark5,@pmark1,''),@pmark2,''),@pmark3,''),@pmark4,'')
							
		SET @MarkingLetterstmp =  replace(@MarkingLetterstmp, ' ', '')					
									
		SET @MarkingLetterstmp= replace(replace(@MarkingLetterstmp, '--','-'), '--','-')

		SET @MarkingLetterstmp = case when right(@MarkingLetterstmp,1)='-' then substring(@MarkingLetterstmp,1,len(@MarkingLetterstmp)-1) else @MarkingLetterstmp end

		SET @MarkingLetterstmp =  replace(@MarkingLetterstmp, '-', ' - ')

	
	--raiserror(@m2, 16, 1)
	--return;


	SELECT 'MarkingLetters' AS [Types], @MarkingLetterstmp AS MarkingLetters UNION ALL
	SELECT 'mark1' , @m1 UNION ALL
	SELECT 'mark2' , @m2 UNION ALL
	SELECT 'mark3' , @m3 UNION ALL
	SELECT 'mark1+mark2' , CONCAT(@m1, ' - ', @m2) UNION ALL
	SELECT 'mark1+mark3' , CONCAT(@m1, ' - ', @m3) UNION ALL
	SELECT 'mark2+mark3' , CONCAT(@m2, ' - ', @m3)

	

END
