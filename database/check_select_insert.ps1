[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$query = @"
declare @pBarcode varchar(50) = 'VJQM1320001E01-008';
declare @pLotNo varchar(50) = 'VVQM163R072742';
declare @pLocation varchar(50) = '';
declare @pProcessLanguage varchar(50) = 'EA_PASS';
declare @pProcessUserID varchar(50) = 'admin';

;with checkWidth as (
	select mm.MaterialCode,mm.MaterialName,mm.MaterialSource,mm.MaterialThickness, esr.ElectrodeLotNumber,esr.Barcode,seq,
	esr.ElectrodeThick,esr.SlittingWidth,esr.GoodQtyLength,esr.CreateDateTime,esr.CreateUserID,esr.LotUniqueNumber
	from STB_SetInfo  si					with(nolock) 
	join STB_ElectrodeSlittingInfo   esi	with(nolock) on si.Barcode = esi.ElectrodeLotNumber
	join STB_ElectrodeSlittingResult  esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
	left outer join STB_MaterialMaster  mm	with(nolock) on si.MaterialCode = mm.MaterialCode
	where esr.Barcode=@pBarcode 
)
select top 1 PartNo,convert(varchar(19),getdate(),120),SlittingCode,SlittingSize,
Farad,Width,RollQty,
case when @pProcessLanguage='EA_PASS' then (case when isnull(@pLocation,'') = '' then 'NoInput' else @pLocation end )  
else (case when MaterialName like '%+%' or MaterialName like '%Etch%' then PositiveLocation else NegativeLocation end) end 
,MaterialCode,MaterialName,MaterialSource,
MaterialThickness,ElectrodeLotNumber,Barcode,seq,ElectrodeThick,SlittingWidth,
GoodQtyLength ,cw.CreateDateTime,@pProcessUserID,LotUniqueNumber,(case when @pLocation='SANXUAT' then 'ROUTE_VN_WH' else 'ELEC_VN_WH' end) 

from stb_slittinglocationconfig_vvt	with(nolock) 
join checkWidth cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
and  Width=cw.SlittingWidth 

and  (
		 isnull(PositiveLocation,'     ')= isnull(@pLocation,' ')
		or isnull(NegativeLocation,'     ')= isnull(@pLocation,' ')
		or isnull(@pLocation,'')='' and @pProcessLanguage='EA_PASS' and (@pProcessUserID<>'' and @pProcessUserID is not null)
	 )
							
and PartNo  like case when @pLotNo is not null and @pLotNo<>'' then ((select CASE WHEN MBISizeW IS NOT NULL
			 THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
			 ELSE CONVERT(VARCHAR(10), CONVERT(INT,MBISizeD) ) END 
			from STB_ModelBasicInfo mbi	with(nolock) 
			where ModelCode= (select MaterialCode from STB_SetInfo 	with(nolock)  where Barcode=@pLotNo ))
			) else '%' end

and convert(varchar(7),convert(numeric(5,1),Farad)) 
	like case when @pLotNo is not null and @pLotNo<>'' 
	then (
			(select 
			case when charindex('.',MBIExtText05) > 0 then MBIExtText05 else MBIExtText05+'.0' end
			from STB_ModelBasicInfo mbi	with(nolock) 
			where ModelCode= (select MaterialCode from STB_SetInfo 	with(nolock)  where Barcode=@pLotNo )
			)
		) else '%' end
"@

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    $dt | ConvertTo-Csv -NoTypeInformation
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
