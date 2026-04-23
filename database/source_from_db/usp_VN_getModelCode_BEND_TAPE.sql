
create  PROC  [dbo].[usp_VN_getModelCode_BEND_TAPE]
@pLOTNO NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		select  RTRIM(LTRIM(SUBSTRING(MaterialName, CHARINDEX(' ', MaterialName), 30))) as MaterialName,
				RTRIM(LTRIM(SUBSTRING(MaterialName, CHARINDEX(' ', MaterialName), 30))) as MaterialNameVal

		from    stb_materialMaster
		where   MaterialTypeCode in ('FERT','MDL') 
		
		and MaterialName is not null 
		and 
		(MaterialName like '%VEC%'
		 or MaterialName like '%WEC%'
		  or MaterialName like '%VHC%'
		   or MaterialName like '%VET%'
		    or MaterialName like '%VEM%'
			 or MaterialName like '%WEN%'
			 or MaterialName like '%VEP%'
			 or MaterialName like '%VLC%'
			 or MaterialName like '%VEP%'
			 or MaterialName like '%VEN%'
			 or MaterialName like '%VEB%'
			 )
			 order by RTRIM(LTRIM(SUBSTRING(MaterialName, CHARINDEX(' ', MaterialName), 30))) 

END
