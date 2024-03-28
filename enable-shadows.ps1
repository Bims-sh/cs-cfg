param(
    [string]$filePath
)

# Echo GitHub link
Write-Output "Script source: https://github.com/Bims-sh/cs-cfg/enable-shadows.ps1"

# Check for read-only
$file = Get-Item $filePath
if ($file.IsReadOnly) {
    Write-Host "The file is read-only. Exiting..."
    exit
}

# Backup file
$backupPath = $filePath + ".bak"
Copy-Item -Path $filePath -Destination $backupPath
Write-Output "A backup has been created at $backupPath"

# Read file content
$content = Get-Content -Path $filePath -Raw

# Edit the file content
$newContent = $content -replace '("setting.csm_max_shadow_dist_override"\s+)"\d+"', '${1}"560"'
$newContent = $newContent -replace '("setting.lb_shadow_texture_width_override"\s+)"\d+"', '${1}"518"'
$newContent = $newContent -replace '("setting.lb_shadow_texture_height_override"\s+)"\d+"', '${1}"518"'
$newContent = $newContent -replace '("setting.lb_enable_shadow_casting"\s+)"\d+"', '${1}"1"'

# Save the modified content
Set-Content -Path $filePath -Value $newContent

# Set the file as readonly
Set-ItemProperty -Path $filePath -Name IsReadOnly -Value $true

# Echo message
Write-Output "The file has been placed at $filePath and the modifications were successful."
