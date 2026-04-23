create PROC [dbo].[usp_vvt_infoDone_qcaudit]
			@pID INT
AS
BEGIN
	        select ls.id,ls.LineCode, isnull(li.LineName,ls.LineName) LineName, ls.routename, 
  replace(replace(ls.errorcode,ls.errorname,''),'-Comment:','')+'_.'+ ls.errorname +'.._'+ isnull(tbend.errorcode,'') endcode,
  convert(varchar(19),ls.createdatetime,120) beginOccur, convert(varchar(19),tbend.createdatetime,120) finishTime, 
  DATEDIFF(MINUTE, ls.createdatetime, tbend.createdatetime) DuringOP  , ls.statusEmail audi
from stb_linesituation_vvt ls with(nolock) 
left outer join stb_linesituation_vvt tbend with(nolock)  on ls.id=tbend.statusApp
left outer join  STB_LineInfo li with(nolock)  on ls.LineCode=li.linecode 
where   (tbend.statusApp=@pID or ls.id=@pID)

END