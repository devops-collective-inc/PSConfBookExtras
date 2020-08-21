$ArrCSVMAME2010 = @($XmlMAME2010.mame.game) | ForEach-Object {
    $Game = $_
    $PSCustomObject = New-Object PSCustomObject
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'ROMName' -Value $Game.name
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_ROMName' -Value $Game.name
    if ($null -eq $Game.cloneof) {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_CloneOf' -Value ''
    } else {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_CloneOf' -Value $Game.cloneof
    }
    if (($null -eq $Game.isbios) -or ('no' -eq $Game.isbios)) {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_IsBIOSROM' -Value 'False'
    } else {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_IsBIOSROM' -Value 'True'
    }
    if (($null -eq $Game.runnable) -or `
        ('yes' -eq $Game.runnable)) {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_IsRunnable' -Value 'True'
    } else {
        $PSCustomObject | Add-Member -MemberType NoteProperty `
            -Name 'MAME2010_IsRunnable' -Value 'False'
    }
    $PSCustomObject
}
