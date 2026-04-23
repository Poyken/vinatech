

CREATE PROCEDURE [dbo].[usp_Vietnam_POBom_VVT_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = NULL,
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	declare @tung NVARCHAR(3000) = substring(@pXml,3500,2900)
	raiserror(@tung,16,1)
	return;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) ,
			--@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			--@IsUseAll BIT = CASE WHEN ISNULL(@pIsUseAll,0) = 1 THEN 0 ELSE 1 END
			@lstPO NVARCHAR(MAX) = '''',
			@Xml  NVARCHAR(MAX) =   @pXml,
			@strsql NVARCHAR(MAX) 

	DECLARE @ProcessViewName VARCHAR(50) = 'ProductionOrderInfo'
	DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName  

	--ProductionOrderInfo

	DECLARE @ERROR_MSG NVARCHAR(MAX)
		DECLARE @iDoc INT



	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Xml
		BEGIN TRY
			DECLARE SourceData CURSOR FOR
            SELECT
					PONo
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								PONo VARCHAR(50)
							)



       OPEN SourceData
        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								 @PONo
						 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END


			select @lstPO = @lstPO +''','''+ @PONo

			--declare @Barcode1 varchar(60) = @Barcode + @LevelBx;
			--RAISERROR( @Barcode1 ,16, 1);			
			--return;	
		end 


		select @lstPO = @lstPO + ''''

	--raiserror (@lstPO,16,1)
	--return;

	 --AND
					--POB.MaterialCode LIKE @MaterialCode AND
					--POB.IsUseProduction IN (1,@IsUseAll)
		
		  DECLARE @STMT AS NVARCHAR(MAX) = 'SELECT
					CASE
						WHEN ParentId IS NULL THEN 1
						ELSE 2
					END AS Seq,
					POB.Id,
					POB.ParentId,
					POB.MaterialCode,
					MM.MaterialName,
					POB.BomVersion,
					POB.ChildMaterialCode,
					CMM.MaterialName AS ChildMaterialName,
					CMM.MaterialTypeCode,
					MT.MaterialTypeName,
					CMM.MaterialSpec,
					CMM.ProductGroupCode,
					PG.ProductGroupName,
					POB.ChildBomVersion,
					POB.BomUnit,
					CMM.MaterialUnit,
					ISNULL((
						SELECT
								SUM(MS.StockQty)
						FROM
								STB_MaterialStock MS WITH(NOLOCK)
						WHERE
								MS.CompanyCode = PO.CompanyCode AND
								MS.WorkCenterCode = PO.WorkCenterCode AND
								MS.MaterialCode = POB.ChildMaterialCode AND
								MS.MaterialStockAttribute = ''NORMAL''
					),0) AS StockQty,
					sum(POB.UsedQty) as UsedQty,
					sum(POB.TotalUsedQty) as TotalUsedQty,
					POB.RouteCode,
					POB.IsOptionItem,
					POB.BomDetailDesc,
					POB.StdCombSec
			FROM
					STB_ProductionOrderBom POB WITH(NOLOCK)
					INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK)
						ON	PO.PONo = POB.PONo
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON	MM.MaterialCode = POB.MaterialCode
					LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
						ON	CMM.MaterialCode = POB.ChildMaterialCode
					LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
						ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
						ON	PG.ProductGroupCode = CMM.ProductGroupCode
			WHERE
					POB.PONo  in ('+@lstPO+')
			GROUP by 
					POB.Id,
					POB.ParentId,
					POB.MaterialCode,
					MM.MaterialName,
					POB.BomVersion,
					POB.ChildMaterialCode,
					CMM.MaterialName, --AS ChildMaterialName,
					CMM.MaterialTypeCode,
					MT.MaterialTypeName,
					CMM.MaterialSpec,
					CMM.ProductGroupCode,
					PG.ProductGroupName,
					POB.ChildBomVersion,
					POB.BomUnit,
					CMM.MaterialUnit,			
					POB.RouteCode,
					POB.IsOptionItem,
					POB.BomDetailDesc,
					PO.CompanyCode,
					PO.WorkCenterCode,
					POB.StdCombSec
			ORDER BY
					CASE WHEN ParentId IS NULL THEN 1
						ELSE 2
					END,
					MaterialCode,
					BomVersion
		   '

		   declare @ccount numeric(18,0) = 0;
		   select @ccount = count(*)
		   from STB_Vietnam_POBom_VVT


		   if(@ccount<>0) begin
				update STB_Vietnam_POBom_VVT
				set sqlstring=@STMT
				where userid=@ProcessUserID
		   end 
		   else begin
				  insert into STB_Vietnam_POBom_VVT (sqlstring, userid)
				  values(@STMT, @ProcessUserID)
		  end

		  	--raiserror (@lstPO,16,1)
	--return;
		  

    END TRY
	BEGIN CATCH

		
				raiserror (@lstPO,16,1)
				return;
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc








END
