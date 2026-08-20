-- =========================================================================================
-- Test XML Save in usp_SanminaShipmentPlan_iud
-- =========================================================================================

DECLARE @XmlTest NVARCHAR(MAX) = N'
<DataSet>
    <SanminaShipmentPlan_INSERT>
        <PONumber>PO2026-SAN-001</PONumber>
        <PartNumber>LFIBLM164855</PartNumber>
        <LotNo></LotNo>
        <Quantity>200</Quantity>
        <TotalBox>20</TotalBox>
        <ISACTIVE>1</ISACTIVE>
        <Remark>Test Save XML SmartFramework</Remark>
    </SanminaShipmentPlan_INSERT>
</DataSet>';

EXEC usp_SanminaShipmentPlan_iud 
    @pProcessUserID = 'TEST_USER',
    @pProcessLanguage = 'vi-VN',
    @pProcessViewName = 'SanminaShipmentPlan',
    @pXml = @XmlTest;

-- Verify inserted record
SELECT PlanID, IsActive, PONumber, PartNumber, LotNo, QtyPerBox, TotalBox, Status, Remark, CreateUserID 
FROM STB_SanminaShipmentPlan 
WHERE PONumber = 'PO2026-SAN-001';

-- Clean up
DELETE FROM STB_SanminaShipmentPlan WHERE PONumber = 'PO2026-SAN-001';
PRINT 'Test XML Save executed and cleaned up successfully!';
GO
