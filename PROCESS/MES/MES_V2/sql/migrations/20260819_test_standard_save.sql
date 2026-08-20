-- =========================================================================================
-- Test standardized usp_SanminaShipmentPlan_iud with SmartFramework Grid XML
-- =========================================================================================

DECLARE @XmlTest NVARCHAR(MAX) = N'
<DataSet>
    <SanminaShipmentPlan_INSERT>
        <PONumber>PO2026-SAN-001</PONumber>
        <PartNumber>LFIBLM164855</PartNumber>
        <LotNo></LotNo>
        <Quantity>200</Quantity>
        <TotalBox>20</TotalBox>
        <IsActive>1</IsActive>
        <Remark>SmartFramework Standard Test</Remark>
    </SanminaShipmentPlan_INSERT>
</DataSet>';

EXEC usp_SanminaShipmentPlan_iud 
    @pProcessUserID = 'vanduc',
    @pProcessLanguage = 'vi-VN',
    @pProcessViewName = 'SanminaShipmentPlan',
    @pXml = @XmlTest;

-- Verify
SELECT PlanID, IsActive, PONumber, PartNumber, LotNo, QtyPerBox, TotalBox, Status, Remark, CreateUserID 
FROM STB_SanminaShipmentPlan 
WHERE PONumber = 'PO2026-SAN-001';

-- Clean up
DELETE FROM STB_SanminaShipmentPlan WHERE PONumber = 'PO2026-SAN-001';
PRINT 'Test standardized XML save executed successfully!';
GO
