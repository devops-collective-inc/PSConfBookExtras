graph simple {
    Edge -From "begin"  -To "middle"
    Edge -From "middle" -To "end"
} | Export-PSGraph -ShowGraph