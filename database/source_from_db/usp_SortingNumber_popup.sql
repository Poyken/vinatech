-- =============================================
-- Author :
-- Group : 
-- Browsable :
-- Create date :
-- Description :
-- Modified :

-- =============================================
CREATE PROCEDURE [dbo].[usp_SortingNumber_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage
			    

	SELECT distinct EquipmentNumber as id,
    'Sorting ' + REPLACE(EquipmentNumber, '#', '') as SortingNumber
	FROM SortingDataImportExcel
	group by EquipmentNumber

END
