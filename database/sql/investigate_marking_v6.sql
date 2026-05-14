-- Check the specific model and look for 6D1 or 5H1
SELECT 
    ModelCode, ModelName, 
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05, 
    MBIExtText06, MBIExtText07, MBIExtText08, MBIExtText09, MBIExtText10
FROM STB_ModelBasicInfo 
WHERE ModelCode LIKE '16RHV470MC11XXT%';

-- Also check SavePackingTime
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'VE251120-002';
