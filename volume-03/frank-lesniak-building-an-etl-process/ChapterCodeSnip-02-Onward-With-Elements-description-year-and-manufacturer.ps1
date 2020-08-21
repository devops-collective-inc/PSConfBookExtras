# Add to ForEach-Object {} block
if ($null -eq $Game.description) {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_ROMDisplayName' -Value ''
} else {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_ROMDisplayName' -Value $Game.description
}
if ($null -eq $Game.manufacturer) {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_Manufacturer' -Value ''
} else {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_Manufacturer' -Value $Game.manufacturer
}
if ($null -eq $Game.year) {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_Year' -Value ''
} else {
    $PSCustomObject | Add-Member -MemberType NoteProperty `
        -Name 'MAME2010_Year' -Value $Game.year
}
