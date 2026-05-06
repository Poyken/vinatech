
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-09
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetVVPackLabel]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(50) = NULL,
						@pOriginalPartno VARCHAR(50) = NULL,
						@pVVorVJ VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	select 'VV' as VVorVJ,'VV' as VVorVJval union all
	select 'VJ','VJ'

END


