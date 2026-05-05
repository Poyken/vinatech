-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchWeightLogs]
    @pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
    @pFromDate DATETIME,
    @pToDate   DATETIME,
    @pLineCode NVARCHAR(50) = NULL
AS
	DECLARE @Offset INT = 2;

    DECLARE @FromDate DATETIME = DATEADD(HOUR, @Offset, @pFromDate);
    DECLARE @ToDate   DATETIME = DATEADD(HOUR, @Offset, @pToDate);
	DECLARE	@LineCode     VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LineCode,
       Value as Giatrican,
        CreatedAt As ThoiGianCan,
       Ip,
        LineNum,
        Barcode as LotNo
    FROM 
        [dbo].[Stb_LogWeight]
    WHERE 
     
        (CreatedAt >= @FromDate AND CreatedAt <= @ToDate)
        AND
      
        (@pLineCode IS NULL OR @pLineCode = '' OR LineCode = @pLineCode)
    ORDER BY 
        CreatedAt DESC;
END
