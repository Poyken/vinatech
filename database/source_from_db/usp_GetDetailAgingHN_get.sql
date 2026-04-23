-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDetailAgingHN_get]  -- usp_GetDetailAgingHN_get 'VE250323-005' ,'MAY02' ,'2025-09-04'
			@pLotNo VARCHAR(50) = NULL,
			@pCOMPUTER VARCHAR(50) = NULL
			--@pCREATEDATE DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 --   DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	--DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'
	--DECLARE @LotNo VARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END

		
		--declare @tm VARCHAR(50) = CONVERT(VARCHAR, @pCREATEDATE, 120)
		--raiserror(@tm, 16, 1)
		--return;
			
			SELECT DISTINCT
				LOTNO AS Lot,
				NOITEMS AS [No.],
				RESULT AS [Result],
				CAPUF AS [CAP(uF)],
				LCUA AS [LC(uA)],
				DFPHANTRAM AS [DF(%)],
				ESRM AS [ESR(mΩ)],
				TIMEC AS [time],
				LINES,
				COMPUTER
			FROM stb_DetailAgaingHN WITH(NOLOCK)
			WHERE 
				LOTNO = @pLotNo
				AND COMPUTER = @pCOMPUTER
				--AND CREATEDATE =  @pCREATEDATE
				--AND CONVERT(VARCHAR, CREATEDATE, 120) = CONVERT(VARCHAR, DATEADD(hour, 2, @pCREATEDATE), 120)
			--ORDER BY CONVERT(DATETIME, LEFT(TIMEC, LEN(TIMEC) - 3), 103)


END



--select * from stb_DetailAgaingHN
--where LOTNO = '25RHV10MB6'
--and COMPUTER = 'MAY06'