
--    select [dbo].[fn_VVT_getdatebyVendorLot]('SRFYO85','VVPS0220001E17-019')

ALTER  FUNCTION  [dbo].[fn_VVT_getdatebyVendorLot] (
		@materialcode varchar(20) = null,
		@vendorlot    nvarchar(1000) = null
	)

RETURNS varchar(20) AS 
begin
	
	declare @date varchar(20)=''

	set @materialcode=rtrim(ltrim(@materialcode))
	set @vendorlot=rtrim(ltrim(@vendorlot))
	

	if(@vendorlot like '%#%' and CHARINDEX('#',@vendorlot,1)<12) 
		set @vendorlot = stuff(@vendorlot,1,CHARINDEX('#',@vendorlot,1),'')

	   	
	declare @datetest varchar(10)= getdate() ;
	declare @YEARstrElectrode varchar(100)=  'PQRSTUVWXYZABCDEFGHJKLMNO';
	--select SUBSTRING(@YEARstr,(DATEPART(year,'2023-01-01' ))%25+1,1)
	--select (DATEPART(year,@datetest )-2000)/25*25
	--select '2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/25*25 +charindex('q',@YEARstr)-1),3)
	
	declare @YEARofTerminal varchar(100)=  'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	   

	declare @dayStrPBDM00 varchar(100)=  '123456789ABCDEFGHJKLMNRSTUVWXYZ';



	set @date = 
	 case 
	when @materialcode in ('GCSAAT-001') then 
							 '2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/26*26 +charindex(substring(@vendorlot,2,1),@YEARstrElectrode)-1),3)
							 +'-'+ substring(@vendorlot,3,2)
							 +'-'+ substring(@vendorlot,5,2)

	when @materialcode in ('GAKA00-002') then '20'+ substring(@vendorlot,1,8)
	when @materialcode in ('GBAKAC-039'
						,'GBAKAC-053'
						,'GBAKAC-036'
						,'GBAKAC-S03'
						,'GBAKAC-037'	
						,'GBAKAC-005'
						,'GBAKAC-051'
						,'GBAKAC-S09'
						,'GBAKAC-059'
						,'GBAKAC-060'
						,'GBAKAC-048'
						,'GBAKAC-064'
						,'GBAKAC-063'	
						,'GBAKAC-V03'
						,'GBAKAC-054'
						) then '202'+ substring(@vendorlot,2,1) 
											+'-'
											+ right('0' + case 
											when substring(@vendorlot,3,1)='A' then '10'
											when substring(@vendorlot,3,1)='B' then '11'
											when substring(@vendorlot,3,1)='C' then '12'
											else substring(@vendorlot,3,1) end,2)
											+'-'
											+substring(@vendorlot,4,2) 

	when @materialcode in ('GAKCCA-003','GAKCCA-002') then '20'+ substring(@vendorlot,2,2)+'-'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)
	
	--when @materialcode='GADACB-001' then '20'+ substring(@vendorlot,1,8)

	when @materialcode='GADPCB-002' then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2) + '-15'

	when @materialcode='PBDM00-187' then 
											'20'+ substring(@vendorlot,1,2)
											+'-'
											+ right('0'+case 
											when substring(@vendorlot,3,1)='A' then '10'
											when substring(@vendorlot,3,1)='B' then '11'
											when substring(@vendorlot,3,1)='C' then '12'
											else substring(@vendorlot,3,1) end,2)
											+'-'
											+ right('0'+convert(varchar(3),CHARINDEX('z',@dayStrPBDM00)),2)
	
	when @materialcode in ('GBRLAC-005') then
											'20' + substring(@vendorlot,4,2)
											+ '-'
											+ substring(@vendorlot,6,2)
											+ '-'
											+ substring(@vendorlot,8,2)

	when @materialcode in  ('GCTN00-S01',
							'GCTN00-002')   then 
											(case when (substring(@vendorlot,3,1)<'7') then '202' else '201' end )
											+ substring(@vendorlot,3,1) 
											+ '-' 
											+ substring(@vendorlot,4,2) 
											+ '-' 
											+ substring(@vendorlot,6,2)


	when @materialcode in  ('GCMTTT-024',
							'GCMTTT-002',
							'GCMTTT-012',
							'GCMTTT-013')   then 
											'20' + substring(@vendorlot,1,2) 
											+ '-' 
											+ (case 
											when substring(@vendorlot,3,1)='A' then '12'
											when substring(@vendorlot,3,1)='B' then '11'
											when substring(@vendorlot,3,1)='C' then '10'
											when substring(@vendorlot,3,1)='D' then '09'
											when substring(@vendorlot,3,1)='E' then '08'
											when substring(@vendorlot,3,1)='F' then '07'
											when substring(@vendorlot,3,1)='G' then '06'
											when substring(@vendorlot,3,1)='H' then '05'
											when substring(@vendorlot,3,1)='J' then '04'
											when substring(@vendorlot,3,1)='K' then '03'
											when substring(@vendorlot,3,1)='L' then '02'
											when substring(@vendorlot,3,1)='M' then '01' end )
											+ '-' 
											+ substring(@vendorlot,4,2)

	when @materialcode='GAPOCA-006' then 
											'20' + substring(@vendorlot,5,2) 
											+ '-' 
											+(case 
											when substring(@vendorlot,4,1)='A' then '01'
											when substring(@vendorlot,4,1)='B' then '02'
											when substring(@vendorlot,4,1)='C' then '03'
											when substring(@vendorlot,4,1)='D' then '04'
											when substring(@vendorlot,4,1)='E' then '05'
											when substring(@vendorlot,4,1)='F' then '06'
											when substring(@vendorlot,4,1)='G' then '07'
											when substring(@vendorlot,4,1)='H' then '08'
											when substring(@vendorlot,4,1)='J' then '09'
											when substring(@vendorlot,4,1)='K' then '10'
											when substring(@vendorlot,4,1)='L' then '11'
											when substring(@vendorlot,4,1)='M' then '12' end)
											+'-15'											

    when @materialcode in ('GAZOCB-001' 
						 ,'GCMDPT-309' 
						 ,'GCSN00-002'
						 ,'VSBMD16-001' 
						 ,'VMDDW00-001' 
						 ,'153_BTRAYMD' 
						 ,'153_CTRAYMD' 
						 ,'153_SABTRAYHL' 
						 ,'153_SACTRAYHL' 
						 ,'153_SATRAY_VNF' 
						 ,'153_SATRAY0820-OL' 
						 ,'153_SATRAY1030' 
						 ,'153_SATRAY1320' 
						 ,'153_SATRAY1325' 
						 ,'153_SATRAY2245' 
						 ,'153_TRAY0825VPC' 
						 ,'153_TRAY1030VPC'
						 ,'WRHI00-001')  then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)


	when @materialcode in ('CRNCA5-002','CRPSC0-002','SREYPK0','SRFYPK0')  or substring(@vendorlot,1,2) in ('VV','VJ') and left(right(@vendorlot,3),1)='E'
													                   then 
																			'2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/25*25 +charindex(substring(@vendorlot,3,1),@YEARstrElectrode)-1),3)
																			+ '-' 
																			+(case 
																			when substring(@vendorlot,4,1)='J' then '01'
																			when substring(@vendorlot,4,1)='K' then '02'
																			when substring(@vendorlot,4,1)='L' then '03'
																			when substring(@vendorlot,4,1)='M' then '04'
																			when substring(@vendorlot,4,1)='N' then '05'
																			when substring(@vendorlot,4,1)='O' then '06'
																			when substring(@vendorlot,4,1)='P' then '07'
																			when substring(@vendorlot,4,1)='Q' then '08'
																			when substring(@vendorlot,4,1)='R' then '09'
																			when substring(@vendorlot,4,1)='S' then '10'
																			when substring(@vendorlot,4,1)='T' then '11'
																			when substring(@vendorlot,4,1)='U' then '12' end)
																			+'-'
																			+ substring(@vendorlot,5,2)


	when @materialcode in('GAJCFO-002' ,'GAJCFO-010') then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ (case when substring(@vendorlot,5,2)='1' then '07' when substring(@vendorlot,5,2)='2' then '14' when substring(@vendorlot,5,2)='3' then '21' when substring(@vendorlot,5,2)='4' then '28' else '01' end)
	
	when @materialcode in ('GBRBPL-001' ,'GBRBPL-002','GBRBPL-003')  then  '20'+ substring(@vendorlot,9,2)+'-'+ substring(@vendorlot,11,2)+'-'+ substring(@vendorlot,13,2)

	when @materialcode='GAHSCB-001' then '20'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)
	
	when @materialcode='WRHI00-002' then convert(varchar(10),convert(date,@vendorlot, 103),120)

	else '' end	

	--declare @tung varchar(20)= [dbo].[fn_VVT_getdatebyVendorLot]('GAKA00-002','23-04-11-1')
	--print @tung
	return @date

end
