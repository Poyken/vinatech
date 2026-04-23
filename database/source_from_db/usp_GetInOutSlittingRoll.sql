-- =============================================
-- Author:		ngoloan	
-- Create date: 2021/07/19
-- Description: usp_GetInOutSlittingRoll
-- =============================================
CREATE PROCEDURE usp_GetInOutSlittingRoll
	-- Add the parameters for the stored procedure here
	@pFromDate date, 
	@pToDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
					select
				      
					   a.Materialcode,
					   a.MaterialName,
					   a.ElectrodeThick,
					   a.SlittingWidth,
					   COALESCE(sum(a.TondauNhap),0) -  COALESCE(sum(b.TonDauXuat),0) as TonDau,
					   COALESCE(sum(a.NhapTrongKy),0) as NhapTrongKy,
					   COALESCE(sum(b.XuatTrongKy),0) as XuatTrongKy,
					   COALESCE(sum(a.TonCuoiNhap),0) -  COALESCE(sum(b.TonCuoiXuat),0) as TonCuoi
				from
				(select   c.Materialcode,
						 c.MaterialName,
						c.SlittingWidth,
						c.ElectrodeThick,
						sum(c.TondauNhap) as tondaunhap,
						sum(c.NhapTrongKy) as nhaptrongky,
						sum(c.TonCuoiNhap) as toncuoinhap from
				(SELECT   
						 
						SI.Materialcode
						 ,MM.MaterialName
						 ,ElectrodeThick
					  	,ESR.SlittingWidth
						,case when esr.createdatetime < @pFromDate then sum(ESR.GoodQtyLength) end   AS TondauNhap
						,case when esr.createdatetime between @pFromDate and @pToDate then sum(ESR.GoodQtyLength) end   AS NhapTrongKy
						,case when esr.createdatetime < @pToDate then sum(ESR.GoodQtyLength) end  AS TonCuoiNhap
						FROM STB_ElectrodeSlittingResult ESR
						 LEFT OUTER JOIN STB_SetInfo SI
						 ON ESR.ElectrodeLotNumber = SI.Barcode
						 LEFT OUTER JOIN STB_MaterialMaster MM
						  ON MM.MaterialCode = SI.MaterialCode

					WHERE MM.MaterialName  IS NOT NULL AND SI.MaterialCode IS NOT NULL

					GROUP BY SI.Materialcode,MM.MaterialName,ElectrodeThick,SlittingWidth,ESR.Createdatetime
					) c 
					group by c.Materialcode,
							c.MaterialName,
							c.SlittingWidth,c.ElectrodeThick )a

					left join

					(select Materialcode, materialname, electrodethick, slittingwidth ,
					case when dateoutput < @pFromDate then sum(ActuallyQtyRequest) end as TonDauXuat,
					case when DateOutPut between @pFromDate and @pToDate then  sum(ActuallyQtyRequest) end as XuatTrongKy,
					case when dateoutput < @pToDate then sum(ActuallyQtyRequest) end as TonCuoiXuat
					from 
					STB_VN_ELECTRODE_REQUESTFORM
					group by Materialcode, materialname, electrodethick, slittingwidth,DateOutPut
					) b
					ON a.Materialcode = b.materialcode and a.electrodethick = b.electrodethick and a.slittingwidth= b.slittingwidth

					group by 
					   a.Materialcode,
					   a.MaterialName,
					   a.ElectrodeThick,
					   a.SlittingWidth
					order by a.Materialcode



END
