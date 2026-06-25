-- =============================================
-- Author:         vanduc
-- Create date:    2026-06-11
-- Description:    QC Inspection Group popup for Hung Yen (_HY) screens
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_HY_popup]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
            QIG.QcInspectionGroupCode,
            QIG.QcInspectionGroupName,
            QIG.QcInspectionGroupDesc
    FROM
            STB_QcInspectionGroup QIG WITH(NOLOCK)
    WHERE
            ((QIG.IsUsed = 1)) 

END