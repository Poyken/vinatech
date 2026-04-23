-- =============================================
-- Author : SJC
-- Group : 공통
-- Browsable : true
-- Create date : 2022-08-12
-- Description : 설비상태정보 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineStatusCode_popup]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			MachineStatusCode,
			MachineStatusName
	FROM
			VW_MachineStatusCode
	ORDER BY 
			MachineStatusName
END
