import json

# Let's define the CAD to 3D transformation:
# cadX range: [100, 1000] -> worldX in [-85.5, +85.5]
# cadY range: [150, 650]  -> worldZ in [+47.0, -47.0] (1Y at bottom = +47, 10Y at top = -47)

def cad_to_3d(cad_x, cad_y, floor_y=0):
    wx = (cad_x - 550.0) * (171.0 / 900.0)
    wz = (400.0 - cad_y) * (94.0 / 500.0)
    return round(wx, 1), round(floor_y, 1), round(wz, 1)

print("Sample 3D mappings:")
print("101 Showroom (108, 629):", cad_to_3d(108, 629, 0))
print("104 Warehouse (108, 320):", cad_to_3d(108, 320, 0))
print("105 Logistics Dock (192, 120):", cad_to_3d(192, 120, 0))
print("128 Control (295, 711):", cad_to_3d(295, 711, 0))
print("151 FFT PCCC (959, 711):", cad_to_3d(959, 711, 0))
print("115A Canteen (1014, 260):", cad_to_3d(1014, 260, 0))
print("304 IT Room 2F (109, 580):", cad_to_3d(109, 580, 24))
