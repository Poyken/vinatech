# ==============================================================================
# ULTRA SQL STUDIO -- GUI TOOL (ASCII-SAFE ENCODING IMMUNE)
# Usage: powershell -ExecutionPolicy Bypass -File .\ultra_sql_gui.ps1
# ==============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Data

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$serversToTry = @(
    "192.168.112.254,5398",
    "192.168.1.234,5398",
    "192.168.1.200,5398",
    "192.168.1.100,5398",
    "dbserver.hycap.co.kr,5398",
    "175.201.218.156,5398",
    "localhost"
)

$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$script:activeConn = $null
$script:activeServer = ""

function Get-ActiveConnection {
    if ($script:activeConn -ne $null -and $script:activeConn.State -eq [System.Data.ConnectionState]::Open) {
        return $script:activeConn
    }

    foreach ($srv in $serversToTry) {
        try {
            $connStr = "Server=$srv;Database=$database;User Id=$user;Password=$password;Connect Timeout=3;Encrypt=False;"
            $c = New-Object System.Data.SqlClient.SqlConnection($connStr)
            $c.Open()
            if ($c.State -eq [System.Data.ConnectionState]::Open) {
                $script:activeConn = $c
                $script:activeServer = $srv
                return $c
            }
        } catch {}
    }
    return $null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "ULTRA SQL STUDIO -- VINATECH MES TOOL"
$form.Size = New-Object System.Drawing.Size(950, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# Top Status Panel
$panelTop = New-Object System.Windows.Forms.Panel
$panelTop.Dock = "Top"
$panelTop.Height = 50
$panelTop.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$form.Controls.Add($panelTop)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "[...] Dang kiem tra ket noi SQL Server..."
$lblStatus.Location = New-Object System.Drawing.Point(15, 15)
$lblStatus.AutoSize = $true
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$lblStatus.ForeColor = [System.Drawing.Color]::Yellow
$panelTop.Controls.Add($lblStatus)

$btnReconnect = New-Object System.Windows.Forms.Button
$btnReconnect.Text = "[RECONNECT]"
$btnReconnect.Location = New-Object System.Drawing.Point(800, 10)
$btnReconnect.Size = New-Object System.Drawing.Size(110, 30)
$btnReconnect.FlatStyle = "Flat"
$btnReconnect.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnReconnect.ForeColor = [System.Drawing.Color]::White
$panelTop.Controls.Add($btnReconnect)

# SQL Editor Panel
$lblSql = New-Object System.Windows.Forms.Label
$lblSql.Text = "Nhap / Dan cau lenh SQL tai day (Nhan F5 hoac bam Execute):"
$lblSql.Location = New-Object System.Drawing.Point(15, 60)
$lblSql.AutoSize = $true
$lblSql.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$form.Controls.Add($lblSql)

$txtSql = New-Object System.Windows.Forms.TextBox
$txtSql.Multiline = $true
$txtSql.ScrollBars = "Both"
$txtSql.Location = New-Object System.Drawing.Point(15, 85)
$txtSql.Size = New-Object System.Drawing.Size(900, 160)
$txtSql.Font = New-Object System.Drawing.Font("Consolas", 10.5)
$txtSql.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$txtSql.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$form.Controls.Add($txtSql)

# Button Panel
$btnExecute = New-Object System.Windows.Forms.Button
$btnExecute.Text = "[EXECUTE F5]"
$btnExecute.Location = New-Object System.Drawing.Point(15, 255)
$btnExecute.Size = New-Object System.Drawing.Size(180, 35)
$btnExecute.FlatStyle = "Flat"
$btnExecute.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$btnExecute.ForeColor = [System.Drawing.Color]::White
$btnExecute.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnExecute)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "[CLEAR]"
$btnClear.Location = New-Object System.Drawing.Point(205, 255)
$btnClear.Size = New-Object System.Drawing.Size(140, 35)
$btnClear.FlatStyle = "Flat"
$btnClear.BackColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
$btnClear.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btnClear)

# Template Combo
$lblTpl = New-Object System.Windows.Forms.Label
$lblTpl.Text = "Mau SQL nhanh:"
$lblTpl.Location = New-Object System.Drawing.Point(360, 263)
$lblTpl.AutoSize = $true
$form.Controls.Add($lblTpl)

$cboTemplate = New-Object System.Windows.Forms.ComboBox
$cboTemplate.DropDownStyle = "DropDownList"
$cboTemplate.Location = New-Object System.Drawing.Point(470, 260)
$cboTemplate.Size = New-Object System.Drawing.Size(445, 25)
$cboTemplate.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$cboTemplate.ForeColor = [System.Drawing.Color]::White
$cboTemplate.Items.Add("-- Chon cau lenh mau --")
$cboTemplate.Items.Add("Check STB_SetInfo (Theo ControlNo)")
$cboTemplate.Items.Add("Check STB_ProdRouteHist (Lich su cong doan)")
$cboTemplate.Items.Add("Check STB_MaterialLotInfo (Ton kho dong goi)")
$cboTemplate.Items.Add("Revert B351 Template (Dong bo 4 bang)")
$cboTemplate.SelectedIndex = 0
$form.Controls.Add($cboTemplate)

# Results Grid View
$lblRes = New-Object System.Windows.Forms.Label
$lblRes.Text = "Bang Ket Qua / Thong bao:"
$lblRes.Location = New-Object System.Drawing.Point(15, 305)
$lblRes.AutoSize = $true
$form.Controls.Add($lblRes)

$gridResults = New-Object System.Windows.Forms.DataGridView
$gridResults.Location = New-Object System.Drawing.Point(15, 330)
$gridResults.Size = New-Object System.Drawing.Size(900, 315)
$gridResults.BackgroundColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$gridResults.ForeColor = [System.Drawing.Color]::Black
$gridResults.AutoSizeColumnsMode = "AllCells"
$gridResults.ReadOnly = $true
$form.Controls.Add($gridResults)

# Status Check Handler
$checkConnection = {
    $conn = Get-ActiveConnection
    if ($conn -ne $null) {
        $lblStatus.Text = "[OK] DA KET NOI TOI SERVER: $script:activeServer (DB: $database)"
        $lblStatus.ForeColor = [System.Drawing.Color]::LightGreen
    } else {
        $lblStatus.Text = "[ERROR] KHONG THE KET NOI TOI BAT KY SERVER SQL NAO!"
        $lblStatus.ForeColor = [System.Drawing.Color]::LightPink
    }
}

$form.Add_Shown($checkConnection)
$btnReconnect.Add_Click($checkConnection)

# Template Select Event
$cboTemplate.Add_SelectedIndexChanged({
    switch ($cboTemplate.SelectedIndex) {
        1 { $txtSql.Text = "SELECT ControlNo, Barcode, MaterialCode, DayPlanNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '20250801000357'" }
        2 { $txtSql.Text = "SELECT ControlNo, RouteCode, LineCode, ProdQty, JobDate FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = '20250801000357'" }
        3 { $txtSql.Text = "SELECT MaterialLotNo, LotNo, MaterialCode, PackingID FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = 'VVQJ303R070507'" }
        4 { $txtSql.Text = "BEGIN TRAN;`nUPDATE SmartFactoryV2.dbo.STB_SetInfo SET Barcode = 'MA_GOC', MaterialCode = 'MA_GOC', DayPlanNo = 'DAYPLAN_GOC' WHERE ControlNo = 'MA_CONTROL';`nUPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo SET MaterialCode = 'MA_GOC', MaterialLotNo = 'MA_GOC', LotNo = 'MA_GOC' WHERE LotNo = 'MA_CU';`nUPDATE SmartFactoryV2.dbo.STB_ProdRouteHist SET DayPlanNo = 'DAYPLAN_GOC', MaterialCode = 'MA_GOC' WHERE ControlNo = 'MA_CONTROL';`nDELETE FROM SmartFactoryV2.dbo.STB_LotChangeMaterialHistory WHERE CPHNo = 54875;`nCOMMIT TRAN;" }
    }
})

$btnClear.Add_Click({ $txtSql.Text = "" })

# SQL Execution Handler
$doExecute = {
    $sqlText = $txtSql.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($sqlText)) { return }

    $conn = Get-ActiveConnection
    if ($conn -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Chua ket noi duoc toi SQL Server!", "Loi Ket Noi", "OK", "Error")
        return
    }

    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 120
        $cmd.CommandText = $sqlText

        if ($sqlText -match "^(?i)\s*(SELECT|WITH|EXEC|EXECUTE|SHOW|DESC|SP_)") {
            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            $null = $adapter.Fill($dt)
            $gridResults.DataSource = $dt
            $lblRes.Text = "Bang Ket Qua ($($dt.Rows.Count) dong):"
        } else {
            $affected = $cmd.ExecuteNonQuery()
            $dt = New-Object System.Data.DataTable
            $null = $dt.Columns.Add("Thong bao thuc thi SQL")
            $null = $dt.Rows.Add("THANH CONG! Da thuc thi xong cau lenh SQL. So dong bi anh huong: $affected")
            $gridResults.DataSource = $dt
            $lblRes.Text = "Thong bao thuc thi thanh cong:"
        }
    } catch {
        $dt = New-Object System.Data.DataTable
        $null = $dt.Columns.Add("LOI SQL THUC THI")
        $null = $dt.Rows.Add($_.Exception.Message)
        $gridResults.DataSource = $dt
        $lblRes.Text = "Loi thuc thi SQL:"
    }
}

$btnExecute.Add_Click($doExecute)

# F5 Shortcut Key
$form.KeyPreview = $true
$form.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::F5) {
        & $doExecute
    }
})

# Show Window
[void]$form.ShowDialog()
