-- Procedure: usp_DoReindexing

-- =============================================
-- Author:        Kim Han Young(hykim@awoo.co.kr)
-- Group: System
-- Browsable : False
-- Create date: 2017-08-27
-- Description: 조각화가 지정된 비율보다 많이 발생한 테이블들을 대상으로 인덱스를 다시 작성 또는 구성합니다.
--                조각화가 30% 미만이면 REORGANIZE(다시구성) 
--                조각화가 30% 이상이면 REBUILD(다시작성)
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoReindexing]
    @pFragmentaion INT = 0,    -- 조각화 비율.지정된 값보다 조각화가 많이 발생한 데이터 조회.NULL 또는 0이면 전체조회
    @pListOnly BIT = 0    -- 1 로 설정하면 조각화 정보만 조회
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Method VARCHAR(20)

    DECLARE @Fragment TABLE
    (
        ROW INT IDENTITY(1,1),
        TableName NVARCHAR(100),
        IndexName NVARCHAR(100),
        Fragmentaion FLOAT
    )
    ;
    WITH Fragmentation AS
    (
        SELECT 
                IndexId = IPS.index_id, 
                IndexName = IX.name, 
                Fragmentaion = IPS.avg_fragmentation_in_percent  ,
                TableName = o.name
        FROM 
            sys.dm_db_index_physical_stats (DB_ID(),  NULL, NULL, NULL, NULL) AS IPS
            JOIN sys.indexes AS IX
                ON    IPS.object_id = IX.object_id AND 
                    IPS.index_id = IX.index_id
            INNER JOIN sys.objects O
                ON    O.object_id = IX.object_id
         WHERE
                IX.name IS NOT NULL AND
                O.type = 'U' AND
                ((@pFragmentaion = 0) OR (avg_fragmentation_in_percent > @pFragmentaion))
    )
    INSERT INTO @Fragment
    SELECT
            F.TableName,
            F.IndexName,
            F.Fragmentaion
    FROM
            Fragmentation F

    IF @pListOnly = 0 BEGIN
        DECLARE @ROW INT = 1,
                @COUNT INT,
                @TableName NVARCHAR(100),
                @IndexName NVARCHAR(100),
                @Fragmentaion FLOAT

        SELECT
                @COUNT = COUNT(*)
        FROM
                @Fragment F

        DECLARE @RebuildQuery NVARCHAR(MAX),
                @Query NVARCHAR(MAX)
        SET @RebuildQuery = 'ALTER INDEX @IndexName ON @TableName @Method;'  


        WHILE @ROW <= @COUNT BEGIN
            SELECT
                    @TableName = F.TableName,
                    @IndexName = F.IndexName,
                    @Fragmentaion = F.Fragmentaion
            FROM
                    @Fragment F
            WHERE
                    F.ROW = @ROW

            IF @Fragmentaion > 5 BEGIN
                IF @pFragmentaion > 30 BEGIN
                    SET @Method = 'REBUILD'
                END ELSE BEGIN
                    SET @Method = 'REORGANIZE'
                END

                SET @Query = REPLACE(@RebuildQuery,'@IndexName', @IndexName)
                SET @Query = REPLACE(@Query,'@TableName', @TableName)
                SET @Query = REPLACE(@Query,'@Method',@Method)

                PRINT(@Query)
                EXEC(@Query)
            END

            SET @ROW = @ROW + 1
        END
    END ELSE BEGIN
        SELECT
                *
        FROM
                @Fragment
    END
END

GO

