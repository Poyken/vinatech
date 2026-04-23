CREATE PROC usp_DoMakeRawMaterialInputHistBE
    @pBarcode VARCHAR(20)
AS
BEGIN
    Declare @Barcode VARCHAR(20) = @pBarcode
    Declare @MaterialCode VARCHAR(20) = 'EDVTSY-001'
    Declare @StartLevel INT = 0; -- 사용자가 정의한 해당 품목의 현재 레벨 (0, 2, 3 등)
    Declare @RawMaterialInputHistNo VARCHAR(20)
    Declare @ChildMaterialCode VARCHAR(50)
    Declare @FinalRawMaterialInputList TABLE 
    (
        ActualLevel INT
       ,ParentMaterialCode VARCHAR(50)
       ,ChildMaterialCode VARCHAR(50)
       ,RelativeLevel INT
       ,SortPath VARCHAR(MAX)
    );

    -- 시작 레벨에 따른 최대 전개 깊이(Depth) 설정 로직
    -- 레벨 0이면 +2단계까지(레벨2), 그 외에는 +1단계까지만 조회
    DECLARE @MaxDepth INT = CASE 
        WHEN @StartLevel = 0 THEN 2 
        ELSE 1 
    END;

    WITH BOM_CTE AS (
        -- 1. Anchor Member: 시작 품목 설정
        SELECT 
            H.MaterialCode,
            CAST(NULL AS VARCHAR(50)) AS ParentMaterialCode,
            CAST(H.MaterialCode AS VARCHAR(50)) AS ChildMaterialCode,
            0 AS RelativeLevel, -- 검색 시작점으로부터의 상대적 레벨
            CAST(H.MaterialCode AS VARCHAR(MAX)) AS SortPath
        FROM STB_BOMHeader H
        WHERE H.MaterialCode = @MaterialCode

        UNION ALL

        -- 2. Recursive Member: 하위 품목을 재귀적으로 조인
        SELECT 
            D.MaterialCode,
            D.MaterialCode AS ParentMaterialCode,
            D.ChildMaterialCode,
            C.RelativeLevel + 1 AS RelativeLevel,
            CAST(C.SortPath + ' > ' + D.ChildMaterialCode AS VARCHAR(MAX)) AS SortPath
        FROM STB_BOMDetail D
        INNER JOIN BOM_CTE C ON D.MaterialCode = C.ChildMaterialCode
        WHERE C.RelativeLevel < @MaxDepth -- 설정된 깊이까지만 재귀 수행
    )
    INSERT INTO @FinalRawMaterialInputList
    SELECT DISTINCT 
        @StartLevel + RelativeLevel AS ActualLevel, -- 실제 레벨 계산 (시작레벨 + 상대레벨)
        ParentMaterialCode AS ParentMaterialCode,
        ChildMaterialCode,
        RelativeLevel,
        SortPath
    FROM BOM_CTE
    WHERE RelativeLevel = 2
    ORDER BY SortPath;

    DECLARE cur CURSOR FOR

    SELECT ChildMaterialCode FROM @FinalRawMaterialInputList

    OPEN cur

    FETCH NEXT FROM cur INTO @ChildMaterialCode

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
	    EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT

	    INSERT INTO STB_RawMaterialInputHist (RawMaterialInputHistNo, Barcode, ProductGroupCode, RawMaterialBarcode,MaterialCode)
		    SELECT @RawMaterialInputHistNo
                  ,@Barcode
                  ,(SELECT MaterialSpec FROM STB_MaterialMaster WHERE MaterialCode = @ChildMaterialCode)
                  ,NULL
                  ,@ChildMaterialCode
	    FETCH NEXT FROM cur INTO @ChildMaterialCode
    END

    CLOSE cur
    DEALLOCATE cur
END