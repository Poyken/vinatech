-- =============================================
-- Author: Mr.Tung
-- Create date: 2022-03-30
-- Browsable : true

-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ListPriorFIFO_VVT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialCode VARCHAR(20)=NULL
AS

BEGIN
	 set nocount on;

	SELECT MLI.MATERIALCODE,MM.MATERIALNAME, MIN(SUBSTRING(LOTID,1,6)+'-'+SUBSTRING(LOTID,7,2)+'-'+SUBSTRING(LOTID,9,2)) LOTPREFIX, 
		min(PRODUCTIONDATE) INPUTDATE,MIN(MLI.CREATEDATETIME) INPUTDATETIME,min(LOTATTR10) VENDORLOTDATE--, COUNT(*) LOTCOUNT
	from stb_materiallotinfo mli  with(nolock)
		left outer join stb_materialmaster mm with(nolock) on mli.materialcode=mm.materialcode
	where materialwarehousecode='ROH_VN_WH' 
	and (mli.MaterialCode=@pMaterialCode or @pMaterialCode is null or @pMaterialCode='')
	group by mli.materialcode,mm.materialname--,productiondate,lotattr10
	order by materialcode

END

