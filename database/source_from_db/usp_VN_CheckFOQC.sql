CREATE PROC [dbo].[usp_VN_CheckFOQC] -- exec usp_VN_CheckFOQC 'VVLM063R010620'
--@MaterialQcNo NVARCHAR(50)
AS
BEGIN
--SELECT	
--	RIGHT(MaterialQcNo,14) AS MaterialQcNo
--FROM [SmartFactoryV2].[dbo].[STB_MaterialQcInfo]
--WHERE  MaterialQcNo = 'F' + @MaterialQcNo AND DecisionResult='Pass' AND InspectionDocType='FOQC'

--select * from STB_MaterialQcInfo
--where DecisionResult='Pass'  and InspectionDocType='OQC' and MaterialQcNo = @MaterialQcNo
print 'abc'
END
