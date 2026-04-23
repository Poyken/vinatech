
CREATE PROCEDURE [dbo].[usp_VVT_printHHlabel_popup]
				@pPN VARCHAR(100) = NULL,
				@pDC VARCHAR(100) = NULL,
				@pMPN VARCHAR(100) = NULL			
AS
BEGIN
	SET NOCOUNT ON;
	
	select '11-04174' as HH , 'WEC3R0705QG' as MPN union 
	select '11-04282','WEC2R7106QG-L' union
	select '11-04336','WEC3R0106QG-L' union
	select '11-04368','WEC3R0256QG' union
	select '11-04386','WEC3R0156QG' union
	select 'D0161-001008','VEC2R7106ZG' union
	select 'P000359290','WEC2R7106QG-L' union
	select 'P100013240','WEC2R7106QG-L' union
	select 'P100013250','WEC3R0106QG-L' union
	select 'P100013490','WEC3R0106QG-L' union
	select 'P100013480','WEC3R0505QG' union
	select 'DG11-00012','WEC3R0126HC-B070R' union
	select 'D10-25200-00','VEC2R7406QC' union
	select 'M4953','WEC6R0105QA-OT-L(L&G)'
	
END





































