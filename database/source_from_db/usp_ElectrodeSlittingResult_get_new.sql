-- =============================================
-- Author:		Mr,Duy
-- Create date: 2024-07-27
-- Description:	In tem mới hiển thị theo yêu cầu của Mr.Bách
-- =============================================
-- exec usp_ElectrodeSlittingResult_get_new  '','','VJOP2510501E01'
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingResult_get_new] 
	  @pProcessUserID VARCHAR(20),
	  @pProcessLanguage VARCHAR(20),
	  @pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
--declare @pLotNo varchar(20)=''
--declare @eapassing varchar(20)='EA_PASS'	
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber					
		;with
			getlistElect as (
					SELECT   ESR.ElectrodeLotNumber
					--,ESR.Seq
					,ESR.ElectrodeThick
					,ESR.SlittingWidth
					,MaterialThickness
					,ESR.ProductionQty
					,ESR.GoodQtyLength
					,ESR.CreateDateTime
					,ESR.CreateUserID
					,ESR.ChangeDateTime
					,ESR.ChangeUserID
					,'Report' AS CommandType
					,ESR.Barcode
					,ESR.Seq
					,ESR.LotUniqueNumber
					,RIGHT(ESR.Barcode, 3) AS CutNo
					,MM.MaterialSource
					,MM.MaterialCode
					,MM.MaterialName
					, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValue
					,ESR.SlittingMaterialCode
			  FROM STB_ElectrodeSlittingResult ESR
					  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
					  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
			 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
			 --ORDER BY Seq
			),
			getconfig as(
			select distinct Partno,SlittingCode,SlittingSize ,Width, min(Farad) as Farad
			from stb_slittinglocationconfig_vvt vvt	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
			group by Partno,SlittingCode,SlittingSize,Width
			)
			,
			getFrad as (
			select  PartNo,SlittingCode,SlittingSize,Farad,Width,cw.Seq,cw.CommandType
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,cw.Barcode,ElectrodeThick,SlittingWidth,
			GoodQtyLength ,cw.CreateDateTime,LotUniqueNumber,cw.CutNo
			
			from getconfig	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
					)
					select * from getlistElect 
END
