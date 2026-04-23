CREATE PROCEDURE [dbo].[pop_Electrode_Coating_iud]
    @pProcessUserID VARCHAR(20),
    @pJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pos INT = 1;
    DECLARE @item NVARCHAR(MAX);
    DECLARE @start INT;
    DECLARE @end INT;

    -- JSON 배열 괄호 제거
    SET @pJson = LTRIM(RTRIM(REPLACE(REPLACE(@pJson, CHAR(13), ''), CHAR(10), '')));
    IF LEFT(@pJson, 1) = '[' SET @pJson = SUBSTRING(@pJson, 2, LEN(@pJson) - 1);
    IF RIGHT(@pJson, 1) = ']' SET @pJson = LEFT(@pJson, LEN(@pJson) - 1);

    WHILE 1 = 1
    BEGIN
        SET @start = CHARINDEX('{', @pJson, @pos);
        IF @start = 0 BREAK;

        SET @end = CHARINDEX('}', @pJson, @start);
        IF @end = 0 BREAK;

        SET @item = SUBSTRING(@pJson, @start, @end - @start + 1);

        -----------------------------------------------------
        -- MERGE: 값이 바뀌었을 때만 UPDATE 수행
        -----------------------------------------------------
        MERGE INTO STB_ElectrodeCoatingVisualInspectionInfo AS Target
        USING (
            SELECT
                JSON_VALUE(@item, '$.ElectrodeLotNumber') AS ElectrodeLotNumber,
                JSON_VALUE(@item, '$.SideCode') AS SideCode,
                JSON_VALUE(@item, '$.MeasureTimeCode') AS MeasureTimeCode,
                CAST(NULLIF(JSON_VALUE(@item, '$.Seq'), '') AS INT) AS Seq,
                CAST(NULLIF(JSON_VALUE(@item, '$.LeftValue'), '') AS NUMERIC(20,5)) AS LeftValue,
                CAST(NULLIF(JSON_VALUE(@item, '$.MiddleValue'), '') AS NUMERIC(20,5)) AS MiddleValue,
                CAST(NULLIF(JSON_VALUE(@item, '$.RightValue'), '') AS NUMERIC(20,5)) AS RightValue
        ) AS Source
        ON (
            Target.ElectrodeLotNumber = Source.ElectrodeLotNumber AND
            Target.SideCode = Source.SideCode AND
            Target.MeasureTimeCode = Source.MeasureTimeCode AND
            Target.Seq = Source.Seq
        )
        WHEN MATCHED AND (
                ISNULL(Target.LeftValue, -999999) <> ISNULL(Source.LeftValue, -999999)
             OR ISNULL(Target.MiddleValue, -999999) <> ISNULL(Source.MiddleValue, -999999)
             OR ISNULL(Target.RightValue, -999999) <> ISNULL(Source.RightValue, -999999)
        )
        THEN
            UPDATE SET
                LeftValue = Source.LeftValue,
                MiddleValue = Source.MiddleValue,
                RightValue = Source.RightValue,
                ChangeDateTime = GETDATE(),
                ChangeUserID = @pProcessUserID

        WHEN NOT MATCHED THEN
            INSERT (
                ElectrodeLotNumber, SideCode, MeasureTimeCode, Seq,
                LeftValue, MiddleValue, RightValue,
                CreateDateTime, CreateUserID
            )
            VALUES (
                Source.ElectrodeLotNumber, Source.SideCode, Source.MeasureTimeCode, Source.Seq,
                Source.LeftValue, Source.MiddleValue, Source.RightValue,
                GETDATE(), @pProcessUserID
            );

        SET @pos = @end + 1;
    END
END
