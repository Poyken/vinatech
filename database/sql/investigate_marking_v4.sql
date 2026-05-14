-- Search for the material in different master tables
SELECT * FROM STB_ModelBasicInfo WHERE ModelCode LIKE '%16RHV470MC11XXT001%';
SELECT * FROM STB_MaterialMaster WHERE MaterialCode LIKE '%16RHV470MC11XXT001%';

-- Check SavePackingTime for the lot
SELECT * FROM STB_SavePackingTime_VVT WHERE PackingID = 'VE251120-002' OR LotNo = 'VE251120-002';

-- Search for marking info in common places
SELECT * FROM STB_ProcedureLog WHERE VariableValue LIKE '%6D1%' OR VariableValue LIKE '%5H1%';
