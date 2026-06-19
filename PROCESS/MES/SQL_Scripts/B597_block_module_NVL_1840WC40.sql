-- =============================================
-- Chặn NVL trên B597 cho Model 1840-WC(40) — RDMD00-266
-- Author: ducnv
-- Date: 2026-06-19
-- =============================================

BEGIN TRAN

DECLARE @sp_text NVARCHAR(MAX)
SELECT @sp_text = definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid')

DECLARE @anchor NVARCHAR(500) = N'END -- end ch' + NCHAR(7863) + N'n chemical' 
    + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10) 
    + N'   ' + CHAR(9)+CHAR(9) + N'set @RawMaterialBarcode'

IF CHARINDEX(@anchor, @sp_text) = 0
BEGIN
    PRINT N'LOI: Khong tim thay anchor point!'
    ROLLBACK
    RETURN
END

DECLARE @NL NCHAR(2) = CHAR(13)+CHAR(10)
DECLARE @T NCHAR(1) = CHAR(9)

DECLARE @newblock NVARCHAR(MAX) = N'END -- end ch' + NCHAR(7863) + N'n chemical' + @NL + @NL
    + @T + N'-- ducnv 2026-06-19: Ch' + NCHAR(7863) + N'n NVL Module cho model 1840-WC(40) (RDMD00-266)' + @NL
    + @T + N'-- ModuleWire -> WRHI00-007, ModuleChip -> VRE-009, ModulePCB -> PBDM00-004' + @NL
    + @T + N'IF @MaterialCode = ''RDMD00-266'' AND ISNULL(@pProductGroupCode, '''') IN (''ModuleWire'', ''ModuleChip'', ''ModulePCB'')' + @NL
    + @T + N'BEGIN' + @NL
    + @T+@T + N'IF ISNULL(LTRIM(RTRIM(@LotMaterialBarcode)), '''') NOT IN ('''', ''0'')' + @NL
    + @T+@T + N'BEGIN' + @NL
    + @T+@T+@T + N'IF ISNULL(@mmmaterialcode, '''') = ''''' + @NL
    + @T+@T+@T + N'BEGIN' + @NL
    + @T+@T+@T+@T + N'SET @err = N''M' + NCHAR(227) + N' NVL kh' + NCHAR(244) + N'ng h' + NCHAR(7907) + N'p l' + NCHAR(7879) + N' c' + NCHAR(7911) + N'a LotNo: '' + @pBarcode + N'' v' + NCHAR(7899) + N'i m' + NCHAR(227) + N' nh' + NCHAR(7853) + N'p: '' + ISNULL(@LotMaterialBarcode, '''')' + @NL
    + @T+@T+@T+@T + N'RAISERROR(@err, 16, 1)' + @NL
    + @T+@T+@T+@T + N'RETURN' + @NL
    + @T+@T+@T + N'END' + @NL + @NL
    + @T+@T+@T + N'IF @pProductGroupCode = ''ModuleWire'' AND @mmmaterialcode <> ''WRHI00-007''' + @NL
    + @T+@T+@T + N'BEGIN' + @NL
    + @T+@T+@T+@T + N'SET @err = N''M' + NCHAR(227) + N' Wire kh' + NCHAR(244) + N'ng ' + NCHAR(273) + NCHAR(250) + N'ng c' + NCHAR(7911) + N'a LotNo: '' + @pBarcode + N'' v' + NCHAR(7899) + N'i m' + NCHAR(227) + N' nguy' + NCHAR(234) + N'n v' + NCHAR(7853) + N't li' + NCHAR(7879) + N'u: '' + @mmmaterialcode + N''. C' + NCHAR(7847) + N'n: WRHI00-007''' + @NL
    + @T+@T+@T+@T + N'RAISERROR(@err, 16, 1)' + @NL
    + @T+@T+@T+@T + N'RETURN' + @NL
    + @T+@T+@T + N'END' + @NL + @NL
    + @T+@T+@T + N'IF @pProductGroupCode = ''ModuleChip'' AND @mmmaterialcode <> ''VRE-009''' + @NL
    + @T+@T+@T + N'BEGIN' + @NL
    + @T+@T+@T+@T + N'SET @err = N''M' + NCHAR(227) + N' Chip kh' + NCHAR(244) + N'ng ' + NCHAR(273) + NCHAR(250) + N'ng c' + NCHAR(7911) + N'a LotNo: '' + @pBarcode + N'' v' + NCHAR(7899) + N'i m' + NCHAR(227) + N' nguy' + NCHAR(234) + N'n v' + NCHAR(7853) + N't li' + NCHAR(7879) + N'u: '' + @mmmaterialcode + N''. C' + NCHAR(7847) + N'n: VRE-009''' + @NL
    + @T+@T+@T+@T + N'RAISERROR(@err, 16, 1)' + @NL
    + @T+@T+@T+@T + N'RETURN' + @NL
    + @T+@T+@T + N'END' + @NL + @NL
    + @T+@T+@T + N'IF @pProductGroupCode = ''ModulePCB'' AND @mmmaterialcode <> ''PBDM00-004''' + @NL
    + @T+@T+@T + N'BEGIN' + @NL
    + @T+@T+@T+@T + N'SET @err = N''M' + NCHAR(227) + N' PCB kh' + NCHAR(244) + N'ng ' + NCHAR(273) + NCHAR(250) + N'ng c' + NCHAR(7911) + N'a LotNo: '' + @pBarcode + N'' v' + NCHAR(7899) + N'i m' + NCHAR(227) + N' nguy' + NCHAR(234) + N'n v' + NCHAR(7853) + N't li' + NCHAR(7879) + N'u: '' + @mmmaterialcode + N''. C' + NCHAR(7847) + N'n: PBDM00-004''' + @NL
    + @T+@T+@T+@T + N'RAISERROR(@err, 16, 1)' + @NL
    + @T+@T+@T+@T + N'RETURN' + @NL
    + @T+@T+@T + N'END' + @NL
    + @T+@T + N'END' + @NL
    + @T + N'END' + @NL + @NL
    + N'   ' + @T+@T + N'set @RawMaterialBarcode'

SET @sp_text = REPLACE(@sp_text, @anchor, @newblock)
SET @sp_text = REPLACE(@sp_text, 'CREATE PROCEDURE', 'ALTER PROCEDURE')
EXEC sp_executesql @sp_text

-- Verify
DECLARE @newdef NVARCHAR(MAX)
SELECT @newdef = definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid')

SELECT 
    CASE WHEN CHARINDEX('ducnv 2026-06-19', @newdef) > 0 THEN 'OK' ELSE 'MISSING' END AS CodeTag,
    CASE WHEN CHARINDEX('WRHI00-007', @newdef, CHARINDEX('ducnv 2026-06-19', @newdef)) > 0 THEN 'OK' ELSE 'MISSING' END AS Wire,
    CASE WHEN CHARINDEX('VRE-009', @newdef, CHARINDEX('ducnv 2026-06-19', @newdef)) > 0 THEN 'OK' ELSE 'MISSING' END AS Chip,
    CASE WHEN CHARINDEX('PBDM00-004', @newdef, CHARINDEX('ducnv 2026-06-19', @newdef)) > 0 THEN 'OK' ELSE 'MISSING' END AS PCB

ROLLBACK
