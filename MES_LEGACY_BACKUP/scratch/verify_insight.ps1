$allLots = Import-Csv "scratch/aging_lots_with_material.csv"

# Let's inspect the exact Excel allocation in Sheet 1:
# Sheet 1 has:
# Day 13 (col B): 10 lots VVQO (10,590.0 pcs)
# Day 14 (col C): 21 lots (1 VVQN + 20 VVQO) = 21,598.0 pcs
# Day 15 (col D): 3 lots (subset of col C) = 3,193.0 pcs
# Day 16 (col E): 5 lots (subset of col C) = 5,323.0 pcs
# Day 17 (col F): 16 lots (12 from col C + 4 new VVQO) = 16,878.0 pcs
# Day 18 (col G): 6 lots VVQO = 6,394.0 pcs
# Day 19 (col H): 4 lots VVQP = 4,273.0 pcs

# Total unique Excel lots = 45 lots.
# If Excel lots are placed on their respective single dates:
# Option A (Strict Excel unique columns):
# - 13/08: 10 lots VVQO (10,590 pcs)
# - 14/08: If 14/08 keeps only the remaining 1 lot from col C (VVQO183R072711) or what?
# Wait! In Excel:
# Column 14/08 had 21 lots.
# Column 15/08 had 3 lots.
# Column 16/08 had 5 lots.
# Column 17/08 had 16 lots (12 of which were in col C, plus 4 new).
# Notice: 3 (day 15) + 5 (day 16) + 12 (day 17) + 1 (VVQO183R072711) = 21 lots!
# THAT MEANS: In Excel, the 21 lots listed under 14/08 were ACTUALLY intended to be distributed across 14/08, 15/08, 16/08, 17/08!
# Let's verify this insight!

Write-Output "=== INSIGHT VERIFICATION ==="
$colC = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748', 'VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760', 'VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO183R072711')
$colD = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748') # 3 lots
$colE = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760') # 5 lots
$colF = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735') # 16 lots

Write-Output "Col D in Col C: $(($colD | Where-Object { $colC -contains $_ }).Count) / $($colD.Count)"
Write-Output "Col E in Col C: $(($colE | Where-Object { $colC -contains $_ }).Count) / $($colE.Count)"
Write-Output "Col F in Col C: $(($colF | Where-Object { $colC -contains $_ }).Count) / $($colF.Count)"
Write-Output "Col F new lots: $(($colF | Where-Object { $colC -notcontains $_ }) -join ', ')"
