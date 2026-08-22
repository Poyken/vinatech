$data = Import-Csv "scratch/db_aging_lots.csv"

# Current state of the plan:
# 13/08: Target 20000 -> wants +100 to +200 -> [20100, 20200]
# 14/08: Target 40000 -> wants +100 to +200 -> [40100, 40200]
# 15/08: Target 23000 -> wants +100 to +200 -> [23100, 23200]
# 16/08: Target 25000 -> wants +100 to +200 -> [25100, 25200]
# 17/08: Target 25000 -> wants +100 to +200 -> [25100, 25200]
# 18/08: Target 25000 -> wants +100 to +200 -> [25100, 25200]
# 19/08: Target 26000 -> wants +100 to +200 -> [26100, 26200]

# Let's inspect the current B782 sums:
# Day 13: 20,042.00 (Diff: +42) -> can add +100 to one lot or pick another lot -> 20,142 (Diff: +142)
# Day 14: 40,069.00 (Diff: +69) -> can add +80 to one lot or pick another lot -> 40,149 (Diff: +149)
# Day 15: 22,892.00 (Diff: -108) -> can add a 500 pcs lot or adjust -> 23,150 (Diff: +150)
# Day 16: 24,966.00 (Diff: -34) -> can add a 500 pcs lot or adjust -> 25,150 (Diff: +150)
# Day 17: 24,971.00 (Diff: -29) -> can add a 500 pcs lot or adjust -> 25,150 (Diff: +150)
# Day 18: 24,942.00 (Diff: -58) -> can add a 500 pcs lot or adjust -> 25,150 (Diff: +150)
# Day 19: 26,027.00 (Diff: +27) -> can add +120 or adjust -> 26,150 (Diff: +150)

# Let's see: on each day, if we pick candidate lots:
# Day 13: Currently 18 lots = 20,042.
# If we replace one 1050 lot with a larger lot, or add a lot or adjust ProdQty:
# Let's test combinations!
