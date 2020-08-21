$ArrResults = @($XmlMAME2010.mame.game) | ForEach-Object {
    $Game = $_
    $BoolCompletelyFunctionalROMPackage = $true
    @($Game.rom) | ForEach-Object {
        $File = $_
        $BoolOptionalFile = $false
        if ($File.optional -eq 'yes') {
            $BoolOptionalFile = $true
        }
        if ($BoolOptionalFile -eq $false) {
            if (($File.status -eq 'baddump') -or ($File.status -eq 'nodump')) {
                $BoolCompletelyFunctionalROMPackage = $false
            }
        }
    }
    @($Game.disk) | ForEach-Object {
        $File = $_
        $BoolOptionalFile = $false
        if ($File.optional -eq 'yes') {
            $BoolOptionalFile = $true
        }
        if ($BoolOptionalFile -eq $false) {
            if (($File.status -eq 'baddump') -or ($file.status -eq 'nodump')) {
                $BoolCompletelyFunctionalROMPackage = $false
            }
        }
    }
    if ($BoolCompletelyFunctionalROMPackage -eq $false) { $Game }
}
