-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_StatusEquipment_get]
AS
BEGIN

	--select Categories, Standar, LineName,SHIFTS,[1] as '  1                       ',[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]
	--FROM (
	--  select b.Categories, b.Standar, c.LineName,a.SHIFTS,day(A.CHECKDATE) as checkdate,
	--		case when a.STATUSMACHINE = 0 then 'NORMAL'
	--			 WHEN A.STATUSMACHINE = 1 THEN 'ABNORMAL'
	--			 ELSE '' END STATUS
	--		from STB_VN_STATUSMACHINE a left join STB_VN_STAGEMACHINES_DETAIL b on a.CODEID = b.CODEID 
	--		left join  STB_LineInfo c ON a.linecode = c.LineCode
	--		where Month(CHECKDATE) = month(getdate())  and year(checkdate) = year(getdate())
	--		) x
	--  PIVOT (max(status) FOR  checkdate  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
	--) pvt


		select LineName,SHIFTS,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]
	FROM (
	  select  c.LineName,a.SHIFTS,day(A.CHECKDATE) as checkdate,
			case when a.STATUSMACHINE = 0 then 'NORMAL'
				 WHEN A.STATUSMACHINE = 1 THEN 'ABNORMAL'
				 ELSE '' END STATUS
			from STB_VN_STATUSMACHINE a left join STB_VN_STAGEMACHINES_DETAIL b on a.CODEID = b.CODEID 
			left join  STB_LineInfo c ON a.linecode = c.LineCode
			where Month(CHECKDATE) = month(getdate())  and year(checkdate) = year(getdate())
			) x
	  PIVOT (max(status) FOR  checkdate  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
	) pvt
	order by LineName
END

