-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-20
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_esrAgingSD_get]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20) =NULL,
			@pProcessLanguage VARCHAR(20) =NULL,
			@pFromdate datetime = NULL,
			@pTodate datetime = NULL,
			@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END

	DECLARE	@FromDate   VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate		VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, @pToDate), 120) + ' 10:00:00'



	--raiserror(@LotNo, 16, 1);
	--return;

	IF (@LotNo <> '%')
		BEGIN
				SELECT 
					SPN.ID,
					SPN.LotNo,
					SPN.[FileName],
					SPN.CH,
					SPN.OCV,
					SPN.OCV등급,
					SPN.충전V,
					SPN.충전I,
					SPN.방전V,
					SPN.방전I,
					SPN.방전용량,
					SPN.방전용량등급,
					SPN.DCR,
					SPN.DCR등급,
					SPN.CreateDateTime ,
					SPN.CreateUserID,
					SPN.ChangeDateTime,
					SPN.ChangeUserID

			FROM
				STB_Vvt_SdProds_new SPN WITH(NOLOCK)
			WHERE 
				SPN.LotNo LIKE @LotNo
				OR SPN.[FileName] LIKE  @LotNo

			--raiserror('hi', 16, 1);
			--return;
		END

	ELSE

		BEGIN
			SELECT 
					SPN.ID,
					SPN.LotNo,
					SPN.[FileName],
					SPN.CH,
					SPN.OCV,
					SPN.OCV등급,
					SPN.충전V,
					SPN.충전I,
					SPN.방전V,
					SPN.방전I,
					SPN.방전용량,
					SPN.방전용량등급,
					SPN.DCR,
					SPN.DCR등급,
					SPN.CreateDateTime ,
					SPN.CreateUserID,
					SPN.ChangeDateTime,
					SPN.ChangeUserID

			FROM
				STB_Vvt_SdProds_new SPN WITH(NOLOCK)
			WHERE 
				SPN.CreateDateTime BETWEEN @FromDate AND @ToDate
		END



END
