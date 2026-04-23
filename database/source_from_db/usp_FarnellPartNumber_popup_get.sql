-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-10-07
-- Description:	PartNumber popup
-- =============================================
CREATE PROCEDURE [dbo].[usp_FarnellPartNumber_popup_get]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT '4739181' AS CustomerPartNumber, 'Farnell' AS CustomerName, 'WEC3R0105QG' AS SupplierPartNumber union all
	SELECT '4739182', 'Farnell', 'WEC3R0335QG' union all
	SELECT '4739183', 'Farnell', 'WEC3R0505QG' union all
	SELECT '4739184', 'Farnell', 'WEC3R0106QG' union all
	SELECT '4739185', 'Farnell', 'WEC3R0156QG' union all
	SELECT '4739186', 'Farnell', 'WEC3R0256QG' union all
	SELECT '4739187', 'Farnell', 'WEC3R0506QG' union all
	SELECT '4739189', 'Farnell', 'VEC3R0107QG' union all
	SELECT '4739191', 'Farnell', 'VEC3R0227QG' union all
	SELECT '4739192', 'Farnell', 'VEC3R0367QG' union all
	SELECT '4739193', 'Farnell', 'VEC3R0507QG' union all
	SELECT '4739194', 'Farnell', 'WEC6R0504QG-I' union all
	SELECT '4739195', 'Farnell', 'WEC6R0155QG-I' union all
	SELECT '4739196', 'Farnell', 'WEC6R0255QG-I' union all
	SELECT '4739197', 'Farnell', 'WEC6R0505QG-I' union all
	SELECT '4739198', 'Farnell', 'WEC6R0504QG-O' union all
	SELECT '4739199', 'Farnell', 'WEC6R0155QG-O' union all
	SELECT '4739200', 'Farnell', 'WEC6R0255QG-O' union all
	SELECT '4739201', 'Farnell', 'WEC6R0505QG-O' union all
	SELECT '4739202', 'Farnell', 'VEC3R0105QG' union all
	SELECT '4739203', 'Farnell', 'VEC3R0335QG' union all
	SELECT '4739204', 'Farnell', 'VEC3R0505QG' union all
	SELECT '4739205', 'Farnell', 'VEC3R0106QG' union all
	SELECT '4739208', 'Farnell', 'VEC3R0256QG' union all
	SELECT '4739212', 'Farnell', 'VEC6R0255QG-I' union all
	SELECT '4739215', 'Farnell', 'VEL08253R8506G' union all
	SELECT '4739216', 'Farnell', 'VEL10303R8107G' union all
	SELECT '4739217', 'Farnell', 'VEL10403R8157G' union all
	SELECT '4739219', 'Farnell', 'VEL13253R8157G' union all
	SELECT '4739221', 'Farnell', 'VEL13353R8257G' union all
	SELECT '4739214', 'Farnell', 'VEL08203R8306G' union all

	--2025-12-08
	SELECT '4739207', 'Farnell', 'VEC3R0156QG' union all
	SELECT '4739209', 'Farnell', 'VEC3R0506QG' union all
	SELECT '4739210', 'Farnell', 'VEC6R0504QG-I' union all
	SELECT '4739211', 'Farnell', 'VEC6R0155QG-I' union all
	SELECT '4739213', 'Farnell', 'VEC6R0505QG-I'

END
