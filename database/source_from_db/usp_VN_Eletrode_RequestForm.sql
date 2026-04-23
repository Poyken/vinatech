	CREATE PROC [dbo].[usp_VN_Eletrode_RequestForm]
	AS
	BEGIN
								select
				        ROW_NUMBER() OVER(ORDER BY a.Materialcode ASC) AS RowNum,
					   a.Materialcode,
					  -- a.Materialcode,
					   a.MaterialName,
					   a.ElectrodeThick,
					   a.SlittingWidth,
					   COALESCE(GoodQtyLength,0) - COALESCE(ActuallyQtyRequest,0) as GoodQtyLength
				from
				(SELECT   
						 
						SI.Materialcode
						 ,MM.MaterialName
						 ,ElectrodeThick
					  	,ESR.SlittingWidth
						,SUM(ESR.GoodQtyLength) AS GoodQtyLength

						FROM STB_ElectrodeSlittingResult ESR
						 LEFT OUTER JOIN STB_SetInfo SI
						 ON ESR.ElectrodeLotNumber = SI.Barcode
						 LEFT OUTER JOIN STB_MaterialMaster MM
						  ON MM.MaterialCode = SI.MaterialCode

					WHERE MM.MaterialName  IS NOT NULL AND SI.MaterialCode IS NOT NULL

					GROUP BY SI.Materialcode,MM.MaterialName,ElectrodeThick,SlittingWidth) a
					left join

					(select Materialcode, materialname, electrodethick, slittingwidth ,sum(ActuallyQtyRequest) as ActuallyQtyRequest from 
					STB_VN_ELECTRODE_REQUESTFORM
					group by Materialcode, materialname, electrodethick, slittingwidth) b
					ON a.Materialcode = b.materialcode and a.electrodethick = b.electrodethick and a.slittingwidth= b.slittingwidth

					order by a.Materialcode

END	
