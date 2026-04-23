-- =============================================
-- Author:	    nguyentung
-- Create date: 2022-08-26
-- Browsable : true
-- Group : 
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_MachinePriceStack]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pSPWarehouseCode VARCHAR(20) = NULL,
	@pFromDate Date = NULL,
	@pToDate Date = NULL,
	@pSparePartSpec02 nvarchar(200) = NULL
as
begin	
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
	DECLARE @SparePartSpec02 NVARCHAR(200) = CASE WHEN ISNULL(@pSparePartSpec02,'') = '' THEN '*' ELSE @pSparePartSpec02 END
	

	;with table1 as
	(
		select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		from 
		(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			  sum(CurrentStockQty) as CurrentStockQty
		 from STB_VNSparePartStockInfo 
		 group by SparePartCode,SPWarehouseCode) aa
		 group by SparePartCode

	)

,tung as (
	select * from(
	SELECT
			--SPIOH.SparePartIOHistoryNo AS OldSparePartIOHistoryNo,
	  --      SPIOH.SparePartIOHistoryNo,
	        
	  --      SPIOH.SparePartIOTypeCode,
	  --      SPIOTC.SparePartIOTypeName,
	  --      SPIOTC.IOType,
	  --      SPIOTC.SparePartIOTypeDesc,

	'LAN'+  convert(varchar(3) , 
	ROW_NUMBER() over (partition by SPCH.MachineCode order by  SPCH.MachineCode,SPIOH.SparePartCode)) 
	--+'-'+	SPIOH.SparePartCode 
	as LAN,
	        
	        SPIOH.CompanyCode,
	        CI.CompanyName,
	        --CI.CompanyNameL,
	        
	        SPIOH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	       -- SPIOH.SPWarehouseCode,
	        --SPWI.SPWarehouseName,
	        
	        isnull(vdm.BARCODESYSTEM, SPCH.MachineCode) as MachineCode,
	        isnull(vdm.Vietnamese, MM.MachineName) as MachineName,
			vdm.BasePriceUSD as MachinePriceUSD,
			vdm.BasePriceVND as MachinePriceVND,
	        MM.IsProdMachine,
	        MM.MachineTypeCode,
	        MT.MachineTypeName,
			
			--SPIOH.SparePartCode,
	        --SPI.SparePartName,
	  --      SPI.SparePartSpec01,
	  --      SPI.SparePartSpec02,
	  --      SPI.SparePartSpec03,
	  --      SPI.SparePartSpec04,
	  --      SPI.SparePartSpec05,
			--TSP.TYPECODE,
			--TSP.TYPENAME,
	  --      SPI.SparePartImage,
	        SPI.BasicUnitPrice as baseSpartpartPrice,
	  --      SPI.BasicDeliveryDay,
	  --      SPI.BasicUnit,
	  --      SPI.SafeQty,
	  --      SPI.LastDeliveryVendor,
	  --      SPI.CompatibilityGroup,
			--SPI.Position,
	  --      SPIOH.SPLocationCode,
	  --      SPLI.SPLocationGroup,
	  --      SPLI.SPLocationName,
	        
	        --SPIOH.VendorCode,
	        
	        SPIOH.UnitPrice TepoSpartpartPrice,
	        SPIOH.ProcessQty * isnull(SPIOH.UnitPrice,1.1) as ProcessQty--,
	        --SPSI.CurrentStockQty,
			--t1.CurrentStockQtyKho1,
			--t1.CurrentStockQtyKho2,
			--t1.CurrentStockQty--,
	        --SPIOH.HistoryText,
	        
	        
	        --SPIOH.CreateDateTime,
	        --SPIOH.CreateUserID,
	  --      SPIOH.ChangeDateTime,
	  --      SPIOH.ChangeUserID,
			--SPIOH.LineCode,
			--LI.LineName,
			--SPIOH.CurlingGomaUniqueNo,
			--SPIOH.CodeEmp,
			--ED.Name,
			--ED.PartName,
		 --   convert(varchar, SPIOH.BasicDate, 111) as BasicDate
	FROM
			STB_VNSparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPIOH.SPLocationCode = SPLI.SPLocationCode
				AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			LEFT OUTER JOIN STB_VNSparePartInfo SPI WITH(NOLOCK)
				ON SPIOH.SparePartCode = SPI.SparePartCode 
			LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
				ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPIOH.CompanyCode = CI.CompanyCode
			--LEFT OUTER JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK)
			--	ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
			--	AND SPIOH.SPLocationCode = SPSI.SPLocationCode
			--	AND SPIOH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_VNSparePartChangeHistory SPCH WITH(NOLOCK)
				ON SPIOH.SparePartIOHistoryNo = SPCH.SparePartIOHistoryNo
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON SPCH.MachineCode = MM.MachineCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
			    ON LI.LineCode = SPIOH.LineCode
			LEFT JOIN Stb_EmployeeDepartment ED WITH(NOLOCK)
			  ON SPIOH.CODEEMP = ED.CODEEMP
			LEFT JOIN STB_TYPESPAREPART TSP WITH(NOLOCK)
				ON SPI.TypeCode = TSP.TYPECODE 
			left join table1 t1  WITH(NOLOCK)on  SPIOH.SparePartCode = t1.SparePartCode 
			left outer join STB_VN_DEVICEMACHINES vdm WITH(NOLOCK) on SPCH.MachineCode  = vdm.CodeB250
	WHERE 
			((@CompanyCode = '*') OR (SPIOH.CompanyCode = @CompanyCode)) AND 
	        ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) AND 
	        ((@SPWarehouseCode = '*') OR (SPIOH.SPWarehouseCode = @SPWarehouseCode)) AND 
			((@SparePartSpec02 = '*') OR (SPI.SparePartSpec02 like '%'+@SparePartSpec02+'%')) AND 
	        (SPIOTC.IOType = 'O')  AND SPIOH.Attribute1 IS NULL AND 
			SPIOH.BasicDate between @pFromDate and @pToDate 
			and SPCH.MachineCode is not null and SPCH.MachineCode<>'?'
			--and SPCH.MachineCode='VVEP123'
			) as srctable
pivot (
  sum(processqty)
  for LAN in ([lan1],[lan2],[lan3],[lan4],[lan5],[lan6],[lan7],[lan8],[lan9],[lan10],[lan11],[lan12],[lan13],[lan14],[lan15],[lan16],[lan17],[lan18],[lan19],[lan20],[lan21],[lan22],[lan23],[lan24],[lan25],[lan26],[lan27],[lan28],[lan29],[lan30],
			[lan31],[lan32],[lan33],[lan34],[lan35],[lan36],[lan37],[lan38],[lan39],[lan40],[lan41],[lan42],[lan43],[lan44],[lan45],[lan46],[lan47],[lan48],[lan49],[lan50],[lan51],[lan52],[lan53],[lan54],[lan55],[lan56],[lan57],[lan58],[lan59],[lan60],
			[lan61],[lan62],[lan63],[lan64],[lan65],[lan66],[lan67],[lan68],[lan69],[lan70],[lan71],[lan72],[lan73],[lan74],[lan75],[lan76],[lan77],[lan78],[lan79],[lan80],[lan81],[lan82],[lan83],[lan84],[lan85],[lan86],[lan87],[lan88],[lan89],[lan90],
			[lan91],[lan92],[lan93],[lan94],[lan95],[lan96],[lan97],[lan98],[lan99],[lan100],[lan101],[lan102],[lan103],[lan104],[lan105],[lan106],[lan107],[lan108],[lan109],[lan110],[lan111],[lan112],[lan113],[lan114],[lan115],[lan116],[lan117],[lan118],[lan119],[lan120])
--  for sparepartcode in ([SP535    ],
--[CSP000019  ],
--[CSP000685],
--[CSP000015],
--[CSP000460],
--[SP007],
--[CSP000593],
--[SP504],
--[CSP000149],
--[CSP000262],
--[CSP000469],
--[SP008],
--[SP060],
--[SP521],
--[SP92],
--[CSP000261],
--[CSP000465],
--[CSP000464],
--[CSP000508],
--[SP027],
--[SP45],
--[SP24],
--[SP51],
--[CSP000484],
--[CSP000432],
--[CSP000216],
--[CSP000758],
--[SP602],
--[CSP000412],
--[CSP000161],
--[CSP000552],
--[SP78],
--[SP003],
--[SP088],
--[CSP000554],
--[SP149],
--[CSP000462],
--[SP96],
--[SP514],
--[SP356],
--[CSP000574],
--[CSP000594],
--[CSP000512],
--[CSP000056],
--[SP116],
--[CSP000456],
--[CSP000510],
--[CSP000157],
--[SP52],
--[CSP000374],
--[CSP000606],
--[SP511],
--[CSP000854],
--[CSP000506],
--[CSP000159],
--[CSP000931],
--[SP061],
--[CSP000017],
--[CSP000749],
--[CSP000009],
--[CSP000719],
--[SP062],
--[CSP000174],
--[CSP000488],
--[CSP000713],
--[SP016],
--[CSP000430],
--[CSP000617],
--[CSP000249],
--[CSP000120],
--[CSP000404],
--[CSP000867],
--[CSP000923],
--[CSP000961],
--[SP093],
--[CSP000730],
--[SP510],
--[CSP000976],
--[CSP000011],
--[CSP000068],
--[CSP000443],
--[CSP000586],
--[CSP000611],
--[CSP000934],
--[SP502],
--[SP503],
--[CSP000220],
--[CSP000440],
--[CSP000471],
--[CSP000732],
--[CSP000800],
--[CSP000962],
--[SP28],
--[SP44],
--[CSP000587],
--[CSP000651],
--[SP506],
--[SP520],
--[CSP000498],
--[SP519],
--[CSP000455],
--[CSP000641],
--[CSP000687],
--[CSP000274],
--[CSP000649],
--[CSP000840],
--[SP053],
--[SP314],
--[SP513],
--[SP58],
--[SP66],
--[CSP000245],
--[CSP000439],
--[CSP000771],
--[SP509],
--[SP082],
--[CSP000705],
--[CSP000744],
--[CSP000951],
--[CSP000762],
--[CSP000406],
--[CSP000607],
--[CSP000621],
--[CSP000766],
--[CSP000828],
--[CSP000832],
--[SP043],
--[SP59],
--[SP82],
--[CSP000950],
--[CSP000495],
--[CSP000756],
--[CSP000634],
--[CSP000930],
--[CSP000691],
--[CSP000692],
--[CSP000723],
--[CSP000798],
--[CSP000016],
--[CSP000160],
--[CSP000925],
--[CSP000145],
--[CSP000229],
--[SP010],
--[CSP000545],
--[CSP000597],
--[CSP000686],
--[CSP000715],
--[CSP000725],
--[CSP000557],
--[CSP000605],
--[SP06],
--[SP345],
--[CSP000158],
--[CSP000788],
--[CSP000846],
--[CSP000847],
--[SP32],
--[SP09],
--[CSP000694],
--[CSP000970],
--[CSP000943],
--[CSP000241],
--[SP11],
--[SP507],
--[SP97],
--[SP15],
--[SP239],
--[CSP000564],
--[SP240],
--[CSP000393],
--[CSP000927],
--[CSP000942],
--[SP57],
--[SP301],
--[CSP000653],
--[CSP000682],
--[CSP000008])--([lan1],[lan2],[lan3],[lan4],[lan5],[lan6],[lan7],[lan8],[lan9],[lan10],[lan11],[lan12],[lan13],[lan14],[lan15],[lan16],[lan17],[lan18],[lan19],[lan20],[lan21],[lan22],[lan23],[lan24],[lan25],[lan26],[lan27],[lan28],[lan29],[lan30])
)
 as pvtb 
 )
 select * ,
MachinePriceUSD + isnull([lan1],0)+isnull([lan2],0)+isnull([lan3],0)+isnull([lan4],0)+isnull([lan5],0)+isnull([lan6],0)+
isnull([lan7],0)+isnull([lan8],0)+isnull([lan9],0)+isnull([lan10],0)+isnull([lan11],0)+isnull([lan12],0)+
isnull([lan13],0)+isnull([lan14],0)+isnull([lan15],0)+isnull([lan16],0)+isnull([lan17],0)+isnull([lan18],0)+
isnull([lan19],0)+isnull([lan20],0)+isnull([lan21],0)+isnull([lan22],0)+isnull([lan23],0)+isnull([lan24],0)+
isnull([lan25],0)+isnull([lan26],0)+isnull([lan27],0)+isnull([lan28],0)+isnull([lan29],0)+isnull([lan30],0)+
isnull([lan31],0)+isnull([lan32],0)+isnull([lan33],0)+isnull([lan34],0)+isnull([lan35],0)+isnull([lan36],0)+
isnull([lan37],0)+isnull([lan38],0)+isnull([lan39],0)+isnull([lan40],0)+isnull([lan41],0)+isnull([lan42],0)+
isnull([lan43],0)+isnull([lan44],0)+isnull([lan45],0)+isnull([lan46],0)+isnull([lan47],0)+isnull([lan48],0)+
isnull([lan49],0)+isnull([lan50],0)+isnull([lan51],0)+isnull([lan52],0)+isnull([lan53],0)+isnull([lan54],0)+
isnull([lan55],0)+isnull([lan56],0)+isnull([lan57],0)+isnull([lan58],0)+isnull([lan59],0)+isnull([lan60],0)+
isnull([lan61],0)+isnull([lan62],0)+isnull([lan63],0)+isnull([lan64],0)+isnull([lan65],0)+isnull([lan66],0)+
isnull([lan67],0)+isnull([lan68],0)+isnull([lan69],0)+isnull([lan70],0)+isnull([lan71],0)+isnull([lan72],0)+
isnull([lan73],0)+isnull([lan74],0)+isnull([lan75],0)+isnull([lan76],0)+isnull([lan77],0)+isnull([lan78],0)+
isnull([lan79],0)+isnull([lan80],0)+isnull([lan81],0)+isnull([lan82],0)+isnull([lan83],0)+isnull([lan84],0)+
isnull([lan85],0)+isnull([lan86],0)+isnull([lan87],0)+isnull([lan88],0)+isnull([lan89],0)+isnull([lan90],0)+
isnull([lan91],0)+isnull([lan92],0)+isnull([lan93],0)+isnull([lan94],0)+isnull([lan95],0)+isnull([lan96],0)+
isnull([lan97],0)+isnull([lan98],0)+isnull([lan99],0)+isnull([lan100],0)+isnull([lan101],0)+isnull([lan102],0)+
isnull([lan103],0)+isnull([lan104],0)+isnull([lan105],0)+isnull([lan106],0)+isnull([lan107],0)+isnull([lan108],0)+
isnull([lan109],0)+isnull([lan110],0)+isnull([lan111],0)+isnull([lan112],0)+isnull([lan113],0)+isnull([lan114],0)+
isnull([lan115],0)+isnull([lan116],0)+isnull([lan117],0)+isnull([lan118],0)+isnull([lan119],0)+isnull([lan120],0) as TotalPrice
 from tung
--group by LAN, CompanyCode, CompanyName, WorkCenterCode, WorkCenterName, WorkCenterNameL, SPWarehouseCode, MachineCode, MachineName, IsProdMachine, MachineTypeCode, MachineTypeName, BasicUnitPrice, UnitPrice

end









