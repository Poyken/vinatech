-- =============================================
-- Author : Mr.Tung
-- Group : 공통
-- Browsable : true
-- Create date : 2021-05-19
-- Description : 패킹수량 팝업
-- Modified : usp_Vietnam_PackingQtyPerSize_popup '','','VJMQ173R825705'
-- Modified : usp_Vietnam_PackingQtyPerSize_popup '','','VVOO053R825702'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackingQtyPerSize_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Barcode VARCHAR(20) = @pBarcode,
			@ProdSize VARCHAR(10)
 --raiserror(@Barcode,16,1)
	SELECT @ProdSize = RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
	  FROM STB_ModelBasicInfo with(nolock)
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock) WHERE Barcode = @Barcode)
	------------------------------------ - Ha add 10/08/2024
	 Declare @MaterialCode VARCHAR(20)
	  SELECT @MaterialCode= MaterialCode FROM STB_SetInfo with(nolock) WHERE Barcode = @Barcode
	 if(@Barcode='1325')
		begin	
				set @ProdSize ='1325'
		end 
		--select * from STB_PackingQtyPerSize where ProdSize = '1325'
		
---------------------------------------
	if(@Barcode like 'VE%') --Mr.Duy  get Qty after VE06 by Hanam factory with MarkingCode
	begin
		/*;with getTotalNGbyRoute as 
		(
				select SI.Barcode,T1.ControlNo,isnull(MarkingCode,'') as MarkingCode,SUM(T1.DefectQty) as DefectQty 
				from STB_DefectRepairInfo T1
				Left join  STB_SetInfo SI on T1.ControlNo=Si.ControlNo
				 WHERE
				 T1.FindRouteCode >'VE06'
				Group by SI.Barcode,T1.ControlNo,isnull(MarkingCode,'')
		)
	select  (CL.Qty-DefectQty) as Seq,@ProdSize as ProdSize ,  (CL.Qty-DefectQty) as  PackingQty	
		from STB_CreateMarkingLetterAndQtyForBarcode CL
		left join getTotalNGbyRoute SI on CL.Barcode = SI.Barcode
		 where CL.Barcode =  @Barcode
		union all */
		select 150 as Seq ,@ProdSize as ProdSize , 150 as PackingQty union all
		select 200 as Seq ,@ProdSize as ProdSize , 200 as PackingQty union all
		select 250 as Seq ,@ProdSize as ProdSize , 250 as PackingQty union all
		select 400 as Seq ,@ProdSize as ProdSize , 400 as PackingQty union all
		select 500 as Seq ,@ProdSize as ProdSize , 500 as PackingQty union all
		select 600 as Seq ,@ProdSize as ProdSize , 600 as PackingQty union all
		select 700 as Seq ,@ProdSize as ProdSize , 700 as PackingQty union all
		select 900 as Seq ,@ProdSize as ProdSize , 900 as PackingQty union all
		select 1000 as Seq ,@ProdSize as ProdSize , 1000 as PackingQty union all
		select 1500 as Seq ,@ProdSize as ProdSize , 1500 as PackingQty union all
		select 1800 as Seq ,@ProdSize as ProdSize , 1800 as PackingQty union all
		select 2000 as Seq ,@ProdSize as ProdSize , 2000 as PackingQty union all
		SELECT  PQPS.PackingQty AS Seq,
			PQPS.ProdSize,
			PQPS.PackingQty
	FROM
			STB_PackingQtyPerSize PQPS with(nolock)
	WHERE
			PQPS.ProdSize = @ProdSize
			and PQPS.IsUsed = 1           --DinhManh add 01-10-2025

	end
	else
	begin
		;with packinfo as (
	SELECT  PQPS.PackingQty AS Seq,
			PQPS.ProdSize
	FROM
			STB_PackingQtyPerSize PQPS with(nolock)
	WHERE
			PQPS.ProdSize = @ProdSize
			and PQPS.IsUsed = 1           --DinhManh add 01-10-2025

	) 
	select *, seq as PackingQty from packinfo
    ORDER BY seq DESC
	end
	
    
    
 
END



	----------------------------- comment 2025-01-10/ add data on [A418] PackingQtyPerSize ----------------------------------------------- 
	--union all
	--select 600 as Seq, @ProdSize  where @ProdSize in ('3562','3582','3567','35105','1012')

	
	--union all
	--select 2100 as Seq, @ProdSize where @ProdSize ='2245'

	--	union all
	--select 1000 as Seq, @ProdSize where @ProdSize ='1830'

	--		union all
	--select 6000 as Seq, @ProdSize where @ProdSize ='0816'
	--		union all
	--select 1440 as Seq, @ProdSize where @ProdSize ='0820 '

	--			union all
	--select 2880 as Seq, @ProdSize where @ProdSize ='0820 '
	--			union all
	--select 8000 as Seq, @ProdSize where @ProdSize ='0612'
	--				union all
	--select 2880 as Seq, @ProdSize where @ProdSize ='0825'
	--				union all
	--select 4000 as Seq, @ProdSize where @ProdSize ='0825'
	--				union all
	--select 1440 as Seq, @ProdSize where @ProdSize ='0825'
	--					union all
	--select 400 as Seq, @ProdSize  where @ProdSize ='1359'
	--				union all
	--select 800 as Seq, @ProdSize  where @ProdSize ='1359'
	--	union all
	--select 840 as Seq, @ProdSize  where @ProdSize ='1335'
	--	union all
	--select 1000 as Seq, @ProdSize  where @ProdSize ='1335'
	--union all
	--select 1400 as Seq, @ProdSize  where @ProdSize ='1025'
	--		union all
	--select 700 as Seq, @ProdSize  where @ProdSize ='1025'
	--			union all
	--select 3000 as Seq, @ProdSize  where @ProdSize ='1035'
	--	union all
	--select 2000 as Seq, @ProdSize  where @ProdSize ='1030'
	-------------------------------------------------------------------------------------------
