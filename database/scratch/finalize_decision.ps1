$sql = @"
UPDATE STB_SetInfo 
SET LotDecisionResult = 'Pass', 
    LotNumber = Barcode,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin'
WHERE Barcode = 'VVQK273R025601';

UPDATE STB_CommInspDocHistory
SET IsFinished = 1,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin'
WHERE ProdNo = '20260505000501';
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
