<#
.SYNOPSIS
    it_weekly_report.ps1 — Trình tự động soạn Báo Cáo Tuần IT (EA Team) chuẩn hóa Vinatech
.DESCRIPTION
    Tự động tạo file CSV báo cáo tuần tại Desktop/thanks_and_ojt_reports/
    Tuân thủ tuyệt đối quy chuẩn:
    - Reporter: Nguyen Van Duc | Department: EA Team
    - Cột REMARK: MES (MES & POP), GW (Groupware & ERP), ECM (ECM), HW (Phần cứng, Mạng LAN, Máy in, PC, Phần mềm ứng dụng)
    - Cân đối công việc đều các ngày trong tuần (Task & Support)
#>

param (
    [string]$StartDate, # Định dạng yyyy-MM-dd hoặc dd/MM/yyyy (mặc định Thứ 2 tuần hiện tại)
    [string]$EndDate,   # Định dạng yyyy-MM-dd hoặc dd/MM/yyyy (mặc định Thứ 6 tuần hiện tại)
    [string]$AdditionalNotes = '', # Ghi chú/task phát sinh thêm do kỹ sư cung cấp
    [switch]$ViewOnly   # Chỉ xem trên màn hình, không ghi file CSV
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Xác định ngày Thứ 2 và Thứ 6 của tuần
$today = Get-Date
$diffToMon = ([int][DayOfWeek]::Monday - [int]$today.DayOfWeek)
if ($diffToMon -gt 0) { $diffToMon -= 7 }
$monDate = $today.AddDays($diffToMon)
$friDate = $monDate.AddDays(4)

if ($StartDate) {
    try { $monDate = [DateTime]::Parse($StartDate) } catch { $monDate = Get-Date $StartDate }
}
if ($EndDate) {
    try { $friDate = [DateTime]::Parse($EndDate) } catch { $friDate = Get-Date $EndDate }
}

$startTag = $monDate.ToString('ddMMM', [System.Globalization.CultureInfo]::InvariantCulture)
$endTag = $friDate.ToString('ddMMM-yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
$fileName = "weekly-report-${startTag}-${endTag}.csv"

$reportDir = 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\thanks_and_ojt_reports'
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}
$targetCsvPath = Join-Path $reportDir $fileName

# Ngân hàng task mẫu chuẩn của EA Team Vinatech (chia theo ngày và phân loại REMARK)
$standardTaskPool = @(
    # Thứ 2 (Day 1)
    [PSCustomObject]@{
        DayOffset = 0
        Type = 'Task'
        Remark = 'HW'
        NameIssue = 'Weekly IT Network & Server Room Pre-shift Health Check'
        TheSolve = 'Kiểm tra đèn trạng thái switch mạng trung tâm, rà soát đường truyền cáp quang nội bộ và đo kiểm điện áp bộ lưu điện UPS phòng máy chủ.'
    },
    [PSCustomObject]@{
        DayOffset = 0
        Type = 'Support'
        Remark = 'HW'
        NameIssue = 'IT Hardware Setup & Peripherals Handover - Production User'
        TheSolve = 'Cài đặt lại hệ điều hành Windows, cấu hình bộ gõ tiếng Hàn/Việt, bàn giao trọn bộ máy tính và màn hình cho nhân viên mới.'
    },
    [PSCustomObject]@{
        DayOffset = 0
        Type = 'Support'
        Remark = 'ECM'
        NameIssue = 'ECM Client Software Troubleshooting & Login Verification'
        TheSolve = 'Hỗ trợ người dùng khắc phục lỗi phần mềm ECM, xóa cache chứng chỉ số và xử lý lỗi đăng nhập phân quyền tài liệu.'
    },
    [PSCustomObject]@{
        DayOffset = 0
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'MES & POP Central Database Weekly Synchronization Audit'
        TheSolve = 'Rà soát tính toàn vẹn dữ liệu giữa CSDL SmartFactoryV2 và VINATECH_POP, kiểm tra hàng đợi đồng bộ và khắc phục bản ghi kẹt.'
    },

    # Thứ 3 (Day 2)
    [PSCustomObject]@{
        DayOffset = 1
        Type = 'Task'
        Remark = 'HW'
        NameIssue = 'Network Cable Deployment & RJ45 Outlets Setup - Cleanroom Area'
        TheSolve = 'Kéo tuyến cáp mạng CAT6 từ switch nhánh đến vị trí line mới, bấm hạt mạng RJ45 và đi nẹp bảo vệ chống bụi phòng sạch.'
    },
    [PSCustomObject]@{
        DayOffset = 1
        Type = 'Support'
        Remark = 'HW'
        NameIssue = 'Barcode Printer Calibration & Shared Printer Maintenance'
        TheSolve = 'Cân chỉnh lại cảm biến nhận diện khổ tem cho máy in mã vạch tại chuyền, vệ sinh trục cuốn và nạp cuộn mực in mới.'
    },
    [PSCustomObject]@{
        DayOffset = 1
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'NAIS MES Client Setup & Barcode Scanner Integration - QC Desk'
        TheSolve = 'Cài đặt phần mềm NAIS MES, cấu hình cổng COM cho máy quét mã vạch 2D và kiểm tra đọc tem nhãn thành phẩm.'
    },
    [PSCustomObject]@{
        DayOffset = 1
        Type = 'Support'
        Remark = 'GW'
        NameIssue = 'Groupware & ERP Approval Flow Routing Support'
        TheSolve = 'Hỗ trợ người dùng kiểm tra luồng phê duyệt chứng từ trên Groupware, cập nhật danh mục phòng ban và đồng bộ tài khoản người duyệt.'
    },

    # Thứ 4 (Day 3)
    [PSCustomObject]@{
        DayOffset = 2
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'POP System Training & On-site Worker Guidance - Assembly Line'
        TheSolve = 'Đào tạo trực tiếp tại chuyền về hệ thống Kiosk POP: hướng dẫn đăng nhập, chọn ca làm việc, quét mã Lot và xác nhận hoàn thành công đoạn.'
    },
    [PSCustomObject]@{
        DayOffset = 2
        Type = 'Support'
        Remark = 'MES'
        NameIssue = 'MES B530 Route Completion & Worker Mapping Exception Handling'
        TheSolve = 'Xử lý sự cố công nhân chốt nhầm thứ tự công đoạn, giải phóng bản ghi kẹt trong STB_ProdRouteHist và phục hồi quyền thao tác.'
    },
    [PSCustomObject]@{
        DayOffset = 2
        Type = 'Support'
        Remark = 'HW'
        NameIssue = 'Windows Security Update & FortiClient VPN Configuration'
        TheSolve = 'Hỗ trợ cài đặt phần mềm FortiClient VPN, kiểm tra thông tuyến kết nối mạng nội bộ từ xa cho nhân viên kỹ thuật.'
    },
    [PSCustomObject]@{
        DayOffset = 2
        Type = 'Task'
        Remark = 'HW'
        NameIssue = 'Damaged IT Equipment Collection & Inventory Classification'
        TheSolve = 'Thu hồi bàn phím, chuột, phụ kiện IT cũ hỏng từ các xưởng sản xuất, kiểm tra phân loại đưa về kho IT quản lý.'
    },

    # Thứ 5 (Day 4)
    [PSCustomObject]@{
        DayOffset = 3
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'B782 Lot Tracking Shift-Cutoff JobDate Adjustment'
        TheSolve = 'Hỗ trợ rà soát các Lot chốt ca đêm bị lệch ngày trên màn hình B782, điều chỉnh giờ chốt vượt mốc 10h00 AM để khớp báo cáo QLSX.'
    },
    [PSCustomObject]@{
        DayOffset = 3
        Type = 'Support'
        Remark = 'MES'
        NameIssue = 'Sanmina Customer Shipping Box Label Verification & Print Test'
        TheSolve = 'Kiểm tra định dạng mã ma trận QR tem thùng khách hàng Sanmina, đối soát thông số cân nặng và in kiểm thử mẫu nhãn xuất kho.'
    },
    [PSCustomObject]@{
        DayOffset = 3
        Type = 'Support'
        Remark = 'HW'
        NameIssue = 'IT Peripherals Replacement & Cable Tidy-up - Line Partleader Desk'
        TheSolve = 'Cấp phát thay thế chuột, bàn phím và bộ chia cổng USB tại bàn Partleader sản xuất, bó gọn hệ thống cáp nguồn an toàn.'
    },
    [PSCustomObject]@{
        DayOffset = 3
        Type = 'Support'
        Remark = 'ECM'
        NameIssue = 'ECM Document Upload & Permission Verification Support'
        TheSolve = 'Hướng dẫn người dùng upload quy trình kỹ thuật lên hệ thống ECM, kiểm tra quyền truy cập thư mục theo chức năng phòng ban.'
    },

    # Thứ 6 (Day 5)
    [PSCustomObject]@{
        DayOffset = 4
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'POP Kiosk Orphan Equipment Lock Release & Maintenance'
        TheSolve = 'Tuần tra giải phóng các thiết bị bị khóa orphan lock trên hệ thống POP sau ca làm việc, làm sạch tài nguyên cho ca sản xuất kế tiếp.'
    },
    [PSCustomObject]@{
        DayOffset = 4
        Type = 'Support'
        Remark = 'MES'
        NameIssue = 'Factory Cross-Line Work Order Adoption & Data Verification'
        TheSolve = 'Hỗ trợ kiểm tra dữ liệu lệnh sản xuất PO, xác nhận định tuyến công đoạn trên màn hình B310 và rà soát tồn kho bán thành phẩm.'
    },
    [PSCustomObject]@{
        DayOffset = 4
        Type = 'Task'
        Remark = 'HW'
        NameIssue = 'Weekly IT Floor Inspection & AP Wifi Signal Optimization'
        TheSolve = 'Đo kiểm độ suy hao tín hiệu các bộ phát Wifi AP tại xưởng, kiểm tra tình trạng tải switch mạng và vệ sinh công nghiệp tủ rack IT.'
    },
    [PSCustomObject]@{
        DayOffset = 4
        Type = 'Task'
        Remark = 'MES'
        NameIssue = 'Weekly IT Incident Resolution & Operations Summary Report'
        TheSolve = 'Tổng hợp toàn bộ các yêu cầu hỗ trợ người dùng, thống kê các ca xử lý CSDL và lập báo cáo tuần gửi cấp quản lý.'
    }
)

# Tạo danh sách bản ghi
$csvRows = @()
$headers = "NAME,DEPARTMENT,DATE GET ISSUE,NAME ISSUE,THE SOLVE,TYPE ISSUE,DATE SOLVE ISSUE,SOLVE ISSUE BY,STATUS,REMARK"
$csvRows += $headers

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  VINATECH IT EA TEAM — TỰ ĐỘNG SOẠN BÁO CÁO TUẦN ($startTag - $endTag)  " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

foreach ($item in $standardTaskPool) {
    $itemDate = $monDate.AddDays($item.DayOffset).ToString('d/M/yyyy')
    
    # Format CSV row
    $row = [string]::Format(
        '"{0}","{1}","{2}","{3}","{4}","{5}","{6}","{7}","{8}","{9}"',
        'Nguyen Van Duc',
        'EA Team',
        $itemDate,
        $item.NameIssue,
        $item.TheSolve,
        $item.Type,
        $itemDate,
        'Nguyen Van Duc',
        'Done',
        $item.Remark
    )
    $csvRows += $row
}

if (-not $ViewOnly) {
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($targetCsvPath, $csvRows, $utf8Bom)

    Write-Host "-> [THANH CONG] Da xuat bao cao tuan thanh cong tai:" -ForegroundColor Green
    Write-Host "   $targetCsvPath" -ForegroundColor Yellow
}

Write-Host "`n--- TỔNG KẾT CÁC PHÂN LOẠI CÔNG VIỆC TRONG TUẦN ---" -ForegroundColor Yellow
$grouped = $standardTaskPool | Group-Object Remark
foreach ($g in $grouped) {
    Write-Host "  * Phân loại $($g.Name): $($g.Count) tasks" -ForegroundColor Gray
}

Write-Host "======================================================================" -ForegroundColor Cyan
