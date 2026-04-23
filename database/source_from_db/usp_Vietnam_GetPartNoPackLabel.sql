
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-09
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetPartNoPackLabel]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(50) = NULL,
						@pOriginalPartno VARCHAR(50) = NULL,
						@pVVorVJ VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	select 'VEC3R0256QG' as newPartNo,'VEC3R0256QG' as newPartNoVal union all
	select 'WEC3R0256QG-B11R','WEC3R0256QG-B11R' union all
	select 'WEC3R0256QG','WEC3R0256QG' 

END
