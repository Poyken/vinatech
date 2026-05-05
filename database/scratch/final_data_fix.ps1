$items = @(
    @{Code='35VHV68MC6XXXXVC01'; Name='Polymer AL-Cap'; Spec='VE_ChipRouting'; Unit='EA'; Type='FERT'; Group='SMD'; NameL=''},
    @{Code='63VUH33MC10XXXVC01'; Name='Polymer AL-Cap'; Spec='VE_ChipRouting'; Unit='EA'; Type='FERT'; Group='SMD'; NameL=''},
    @{Code='10VHV1000MD12XVC01'; Name='Polymer AL-Cap'; Spec='VE_ChipRouting'; Unit='EA'; Type='FERT'; Group='SMD'; NameL=''},
    @{Code='25VHV470ME12XXVC01'; Name='Polymer AL-Cap'; Spec='VE_ChipRouting'; Unit='EA'; Type='FERT'; Group='SMD'; NameL=''},
    @{Code='6VHVL330MC6XXXVC01'; Name='Polymer AL-Cap'; Spec='VE_ChipRouting'; Unit='EA'; Type='FERT'; Group='SMD'; NameL=''},
    @{Code='15HB10A000A'; Name='BASE PLATE HB-10A'; NameL='BASE HB-10A'; Spec='Base plate'; Unit='EA'; Type='ROH'; Group='BASE-PLATE'},
    @{Code='15HBV63A00A'; Name='BASE PLATE HB-6.3A'; NameL='BASE HB-6.3A'; Spec='Base plate'; Unit='EA'; Type='ROH'; Group='BASE-PLATE'},
    @{Code='10191053025'; Name='ANODE FOI U191 53 VFS 2.5mm'; NameL=''; Spec='Anode foil'; Unit='M2'; Type='ROH'; Group='ANODE-FOIL'},
    @{Code='10170490035'; Name='ANODE FOIL U170 4.9VFS 3.5mm'; NameL=''; Spec='Anode foil'; Unit='M2'; Type='ROH'; Group='ANODE-FOIL'}
)

foreach ($item in $items) {
    $sql = "UPDATE STB_MaterialMaster SET 
                MaterialName = N'$($item.Name)', 
                MaterialNameL = N'$($item.NameL)',
                MaterialSpec = N'$($item.Spec)', 
                MaterialUnit = '$($item.Unit)', 
                MaterialTypeCode = '$($item.Type)', 
                ProductGroupCode = '$($item.Group)',
                ChangeDateTime = GETDATE(),
                ChangeUserID = 'vinaadmin'
            WHERE MaterialCode = '$($item.Code)'"
    
    Write-Host "Updating $($item.Code)..."
    Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
}
