-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_getMaterialCodeToSystem
@pDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--exec  usp_InventoryMaterialF512New '2024-09-19'
	CREATE TABLE #TempEmployees (
	Id VARCHAR(50),
    MaterialCode VARCHAR(50),
    MaterialCode1 VARCHAR(50),
	BomVersion VARCHAR(50),
    ChildMaterialCode VARCHAR(50),
	ChildBomVersion VARCHAR(50),
    RouteCode VARCHAR(50),
    MaterialName VARCHAR(50),
	BomUnit VARCHAR(50),
	ParentBomHeaderUnit VARCHAR(50),
	BomHeaderUnit VARCHAR(50),
    MaterialUnit VARCHAR(50),
    TotalProdQty NUMERIC(20,5),
	UsedQty1 NUMERIC(10,5),
	UsedQty2 NUMERIC(10,5),
	UsedQty3 NUMERIC(10,5),
	UsedQty4 NUMERIC(10,5),
	UsedQty5 NUMERIC(10,5),
	TotalNvlTToQty NUMERIC(20,5),
	TotalOK NUMERIC(20,5),
	TotalNvlTToOK NUMERIC(20,5),
	TotalDefect NUMERIC(20,5),
	TotalNvlTToDefect NUMERIC(20,5),
	ProductGroupCode VARCHAR(50)
);
INSERT INTO #TempEmployees
EXEC usp_InventoryMaterialF512New @pDate;
--SELECT * FROM #TempEmployees;

-- Xoá bảng tạm khi hoàn tất
declare @columns NVARCHAR(MAX), @query NVARCHAR(MAX);
	
   	SELECT @columns = STUFF((
    
				SELECT DISTINCT ',' + QUOTENAME(ChildMaterialCode)
					FROM #TempEmployees
					FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '');
				
				-- exec usp_getMaterialCodeToSystem '2024-09-21'
					-- Build the dynamic pivot query
					SET @query = '
					WITH pivotBomCTE AS (
						SELECT * 
						FROM (
							SELECT  MaterialCode,ChildMaterialCode,TotalNvlTToOK
							FROM #TempEmployees
							
						) AS SourceTable
						PIVOT (
							Sum(TotalNvlTToOK)
							FOR ChildMaterialCode IN (' + @columns + ')
						) AS PivotTable
					)
					SELECT MaterialCode FROM pivotBomCTE;'; 
					EXEC sp_executesql @query;
					DROP TABLE #TempEmployees;
END
