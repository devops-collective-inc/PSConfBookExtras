$CSVMAME2010Filtered = $CSVMAME2010 | Where-Object {
    $_.MAME2010_CloneOf -eq '' `
        -and $_.MAME2010_IsBIOSROM -eq 'False' `
        -and $_.MAME2010_FunctionalROMPackage -eq 'True' `
        -and $_.MAME2010_DisplayCount -eq '1' `
        -and $_.MAME2010_ROMPackageHasInput -eq 'True' `
        -and $_.MAME2010_P1_NumInputControls_dial -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_doublejoy_4way_4way -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_doublejoy_8way_8way -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_keyboard -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_lightgun -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_paddle -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_pedal -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_stick -eq '0' `
        -and $_.MAME2010_P1_NumInputControls_trackball -eq '0' `
        -and $_.MAME2010_OverallStatus -ne 'Preliminary'
} | ForEach-Object {
    if ($_.MAME2010_NumberOfButtons -ne 'N/A') {
        if (([int]($_.MAME2010_NumberOfButtons)) -le 6) {
            $_
        }
    } else {
        $_
    }
} | ForEach-Object {
    # Perform more filtering in an alternative way to avoid book line wrap
    $StrPropertyName = 'MAME2010_P1_NumInputControls_doublejoy_2wayhorizontal'
    $StrPropertyName += '_2wayhorizontal'
    $ArrProperty = @($_.PSObject.Properties |
        Where-Object { $_.Name -eq $StrPropertyName })
    if ($ArrProperty.Count -ge 1) {
        if ($ArrProperty.Value -eq '0') {
            $_
        }
    }
} | ForEach-Object {
    # Perform more filtering in an alternative way to avoid book line wrap
    $StrPropertyName = 'MAME2010_P1_NumInputControls_doublejoy_2wayvertical'
    $StrPropertyName += '_2wayvertical'
    $ArrProperty = @($_.PSObject.Properties |
        Where-Object { $_.Name -eq $StrPropertyName })
    if ($ArrProperty.Count -ge 1) {
        if ($ArrProperty.Value -eq '0') {
            $_
        }
    }
}
