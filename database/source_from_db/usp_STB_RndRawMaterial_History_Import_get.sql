
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[usp_STB_RndRawMaterial_History_Import_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pMaterialCode NVARCHAR(50) = NULL, 
    @pFromDate DATETIME = NULL, 
    @pToDate DATETIME = NULL 
AS
BEGIN
    SET NOCOUNT ON;

  	Declare @FromDate               Datetime = convert(datetime, convert(varchar(10),@pFromDate,120)+' 10:00:00' ,120)
	, @ToDate                   Datetime = convert(datetime, convert(varchar(10),Dateadd(Day,1,@pToDate),120)+' 10:00:00' ,120)

    BEGIN TRY
        SELECT 
            H.MaterialCode,
            M.[Description],
            H.OldValue,  
            H.ImportValue, 
            H.NewValue, 
            H.ActionType,
            H.CreatedBy, 
            H.CreatedDate, 
            H.Remark,
            RD.GroupCode,
            VW.MBISizeH,
			VW.MBISizeW
        FROM STB_RnDRawMaterial_HN_History H
        LEFT JOIN STB_RndRawMaterial_HN M ON H.MaterialCode = M.MaterialCode
        LEFT JOIN STB_RnDRawMaterial_HN RD ON H.MaterialCode = RD.MaterialCode
        LEFT JOIN VW_ModelBasicInfo VW ON H.MaterialCode = VW.ModelCode
        WHERE 
            H.CreatedDate BETWEEN @FromDate AND @ToDate
            
            AND (@pMaterialCode IS NULL OR @pMaterialCode = '' OR H.MaterialCode LIKE '%' + @pMaterialCode + '%')
            AND H.ActionType IN ('INSERT','UPDATE')
        
        ORDER BY H.CreatedDate DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ERROR_MSG NVARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH
END
