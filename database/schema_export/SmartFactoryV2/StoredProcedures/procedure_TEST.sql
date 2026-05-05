-- Procedure: procedure_TEST
CREATE PROCEDURE procedure_TEST   --프로시저 이름 못정함^!^ 하루 기준으로 불량품의 갯수를 측정하고 30개가 넘으면 메일을 발송하는 프로시저
(
    @pToTime DATETIME
)
AS
BEGIN
    DECLARE @errorCountTable TABLE(
                errorID BIGINT,
                errorLINE_NUM INT,
                errorINSPECTION_DATE DATETIME,
                errorESR_VALUE VARCHAR(100),
                errorMaterialCode VARCHAR(20)
            )
    DECLARE @ID BIGINT
            ,@ESR_VALUE VARCHAR(100)
			,@convertedESR_VALUE FLOAT
            ,@MaterialCode VARCHAR(20)

    DECLARE @tableCount INT
            ,@numCounter INT
            ,@standardUpperESR FLOAT
            ,@standardLowerESR FLOAT
            ,@fromTime DATETIME
            ,@toTime DATETIME

    SET @toTime = @pToTime
    SET @fromTime = DATEADD(DAY, -7, @pToTime)

    DECLARE dataSelectCursor CURSOR FOR SELECT ID, ESR_VALUE, MaterialCode FROM ERPSVR.VINATech.dbo.VECS_ESR_INSPECTION WHERE INSPECTION_DATE >= @fromTime AND INSPECTION_DATE < @ToTime

    OPEN dataSelectCursor
    FETCH NEXT FROM dataSelectCursor INTO @ID, @ESR_VALUE, @MaterialCode

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
		BEGIN TRY
	        SELECT @convertedESR_VALUE = CONVERT(FLOAT, @ESR_VALUE)
		END TRY
		BEGIN CATCH
			SELECT @ESR_VALUE = LEFT(@ESR_VALUE, 6)
			SELECT @convertedESR_VALUE = CONVERT(FLOAT, @ESR_VALUE)
		END CATCH

        SELECT @standardUpperESR = CONVERT(FLOAT, UpperSpec) FROM SmartFactoryV2.dbo.STB_ModelSpec where SpecItemCode = 'SM0041' AND ModelCode = @MaterialCode;

        SELECT @standardLowerESR = CONVERT(FLOAT, LowerSpec) FROM SmartFactoryV2.dbo.STB_ModelSpec where SpecItemCode = 'SM0041' AND ModelCode = @MaterialCode;

        IF (@ESR_VALUE < @standardLowerESR  OR @ESR_VALUE > @standardUpperESR)
        BEGIN
            INSERT @errorCountTable(errorID, errorLINE_NUM, errorINSPECTION_DATE, errorESR_VALUE, errorMaterialCode) SELECT ID, LINE_NUM, INSPECTION_DATE, ESR_VALUE, MaterialCode FROM ERPSVR.VINATech.dbo.VECS_ESR_INSPECTION WHERE ID = @ID
        END

		Fetch Next From dataSelectCursor Into @ID, @ESR_VALUE, @MaterialCode
    END

    SELECT * FROM @errorCountTable

	Close dataSelectCursor; 
	Deallocate dataSelectCursor;
END
GO

