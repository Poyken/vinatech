-- Check for recent changes by MR.trung in the marking master table
SELECT * 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE ChangeUserID = 'MR.trung' 
AND ChangeDateTime > '2026-04-01'
ORDER BY ChangeDateTime DESC;

-- Check for the specific lot VE251120-002 history if possible
-- (There is no history table for this, but we can look at ProcedureLog)
SELECT * 
FROM STB_ProcedureLog 
WHERE VariableValue LIKE '%MK00000974%' 
OR VariableValue LIKE '%VE251120-002%'
ORDER BY CreateDateTime DESC;
