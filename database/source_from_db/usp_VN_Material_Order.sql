	CREATE PROC [dbo].[usp_VN_Material_Order]
	AS
	BEGIN

	DECLARE @pMaterialWarehouseCode NVARCHAR(50) ='ROH_VN_WH'
	DECLARE @MaterialWarehouseCode NVARCHAR(50) = 'ROH_VN_WH'

	SELECT DISTINCT a1.materialcode, SUM(stockqty) AS stockqty

	FROM	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)

			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo
		

	WHERE
			 (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and MaterialLocationCode not like 'PROD%'    and  MaterialLocationCode  not like 'ROUTE%'
			OR MaterialLocationCode like @MaterialWarehouseCode+'%'
					)
			AND (SELECT  count(*) FROM [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) WHERE LotID=a1.lotid and materiallotno is not null ) = 0
			AND (SELECT  count(*) FROM [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) WHERE LotID=a1.lotid  ) = 0 
			AND (SELECT  count(*) FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) WHERE LotID=a1.lotid  ) = 0  
			AND lotid>'ML20191120' and lotid not in ('ML20210630000413','ML20210630000414','ML20220110000007','ML20220110000008','ML20220110000009','ML20220110000010','ML20220110000011','ML20220110000012','ML20211020000127')
			GROUP BY a1.materialcode, stockqty
			UNION ALL 
			SELECT DISTINCT STB_MaterialLotInfo.MaterialCode,STB_MaterialLotInfo.CurrentQty FROM [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) 
			WHERE LotID like 'SP%' and MaterialWarehouseCode=@MaterialWarehouseCode
			or MaterialWarehouseCode= CASE WHEN @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH') THEN @MaterialWarehouseCode ELSE '' END

END

			--select * from STB_MaterialLotInfo