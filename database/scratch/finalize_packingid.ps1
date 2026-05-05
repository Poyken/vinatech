$sql = @"
UPDATE STB_MaterialLotInfo 
SET PackingID = 'PKQN0500501',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin'
WHERE LotNo = 'VVQK273R025601';

UPDATE STB_SetInfo 
SET PackingID = 'PKQN0500501',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin'
WHERE Barcode = 'VVQK273R025601';
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
