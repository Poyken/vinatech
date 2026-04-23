-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-18
-- Description:	Lấy ra danh sách các vị trị ở kho thành phẩm
-- =============================================
CREATE PROCEDURE usp_GetFinishGood_BNByLocation
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	;with data1 as (
      select --top 1000 
      idcode as materiallotno,LotNo	as barcode,	/*PublicCode	materialsource,*/SoInVoice	MaterialThickness,
      case when fish.materialcode='' or fish.MaterialCode is null then isnull(si.MaterialCode,'') else  fish.MaterialCode end +' - '+ PublicCode as materialsource,
      case when fish.materialcode='' or fish.MaterialCode is null then isnull(si.MaterialCode,'') else  fish.MaterialCode end +' - '+ PublicCode as materialcode,
      SoPhieuNhapKho	materialstockattribute,LoaiHinhToKhai stockattrib1,	INPUTFROM stockattrib2,	TypeProduction stockattrib3, PackQty currentqty,
      'WH'	materiallocationcode,	packingid,	lotno,StatusSystem	vendorlotno,''	lotattr01,	''lotattr02	,''lotattr03,''	lotattr04,''	lotattr05,
      ''	lotattr06,''	lotattr07,''	lotattr08,	partno,''lotattr10,createdate	createdatetime,userid	createuserid,
      createdatechange	changedatetime,useridchange changeuserid,28	rollqty,/*0	totalqty,0	totalstock,*/	materialname,'EA'	MaterialUnit,
      case when LOCATIONS='' or LOCATIONS is null then 'Not Input' else LOCATIONS end as location
      from STB_VN_FINISHGOODS fish with(nolock) 
      left outer join STB_SetInfo SI  with(nolock) on si.Barcode = fish.LotNo
      where flag=1  and (TYPEEXPORT='' or TYPEEXPORT is null)  and (Statusout='' or Statusout is null) and StatusSystem=N'Nhập'
       and ISNULL(LOCATIONS, '') <> '' 
            )
          ,       data2 as(
            select  partno, location,materiallocationcode,materialsource,count(*) as totalstock,sum(CurrentQty) as totalqty
            from data1
            group by partno,location,materiallocationcode,materialsource
            )
            select  data1.*,data2.totalqty,data2.totalstock /*,mm.materialname,mm.MaterialUnit*/ from data1
            join data2 on data1.location=data2.location and data1.partno=data2.partno and data1.materialsource=data2.materialsource
      order by [location],partno,MaterialCode    
END
