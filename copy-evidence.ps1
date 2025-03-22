$evidence = ".\evidence"
$evidence_copy = ".\evidence-copy"
$evidence_hashes = ".\evidence-hashes"

#Create copy and hash folders if they don't exist
New-Item -Force -ItemType Directory -Path $evidence_copy
New-Item -Force -ItemType Directory -Path $evidence_hashes

#Loop through each evidence file
Get-ChildItem -Path $evidence | ForEach-Object {
    #Copy the original file
    Write-Host "Copying: $($_.Name)"
    Copy-Item $($_.Fullname) $evidence_copy\$($_.Name)

    #Calculate hashes for old and copy files
    $old_hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    Write-Host "Original SHA256: $old_hash"
    $copy_hash = (Get-FileHash $evidence_copy\$($_.Name) -Algorithm SHA256).Hash
    Write-Host "Copied SHA256:   $copy_hash"

    #Write the original hashes to the disk in case of needing to later re-verify files
    $old_hash | Out-File -FilePath $evidence_hashes\$($_.Name)

    #Compare hashes, output if files have been copied properly or not
    if ($old_hash -eq $copy_hash) {
        Write-Host "Successfully copied and verified $($_.Name)" -ForegroundColor Green
    } else {
        Write-Host "Failed to copy $($_.Name)" -ForegroundColor Red
    }

    #Spacing between each file for cleaner output
    Write-Host "$line"
}