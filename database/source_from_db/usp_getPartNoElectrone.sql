-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-12-10
-- Description:	Lấy ra partno của lot điện cực
-- =============================================
CREATE PROCEDURE [dbo].[usp_getPartNoElectrone]
	@pLotID                varchar(50) = Null,
	@partNo varchar(50) Output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	;with getlistElect as (
					SELECT   ESR.ElectrodeLotNumber
					--,ESR.Seq
					,ESR.ElectrodeThick
					,ESR.SlittingWidth
					,MaterialThickness
					,ESR.ProductionQty
					,ESR.Barcode
					,MM.MaterialSource
					,MM.MaterialCode
					,MM.MaterialName
					,ESR.SlittingMaterialCode
			  FROM STB_ElectrodeSlittingResult ESR
					  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
					  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
				 WHERE ESR.Barcode = @pLotID
			 --ORDER BY Seq
			),
			getconfig as(
			select distinct Partno,SlittingCode,SlittingSize ,Width, min(Farad) as Farad
			from stb_slittinglocationconfig_vvt vvt	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
		--	and vvt.WarehouseLocation='VVT_F1' -- hiện tại chỉ có bắc ninh sản xuất điện cực nên so sánh với config điện cực của bắc ninh
			group by Partno,SlittingCode,SlittingSize,Width
			)
			,
			getFrad as (
			select PartNo,SlittingCode,SlittingSize,Farad,Width
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,cw.Barcode,ElectrodeThick,SlittingWidth
			
			from getconfig	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
			)
			,resultst as (
					select PartNo,SlittingCode,SlittingSize,
					case when PartNo in ('1840') and SlittingCode in ('YP') and Farad in ('50','60') -- bỏ trắng theo yêu cầu của Mr.Bách 2024-09-18
						then 
							null
						else
							Farad
						end as Farad
					,Width
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,Barcode,ElectrodeThick,SlittingWidth from getFrad 	
			)
					select @partNo=PartNo from resultst 	
END
