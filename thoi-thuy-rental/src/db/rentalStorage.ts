// src/db/rentalStorage.ts

export type EventType = 'wedding' | 'funeral' | 'longevity' | 'retail' | 'other';
export type ContractStatus = 'pending' | 'deposited' | 'setting_up' | 'ongoing' | 'dismantling' | 'completed';

export interface ContractItem {
  itemId: string;
  name: string;
  quantity: number;
  price: number;
}

export interface Contract {
  id: string;
  clientName: string;
  clientPhone: string;
  eventType: EventType;
  eventDate: string; // YYYY-MM-DD
  endDate: string;   // YYYY-MM-DD
  address: string;
  notes: string;
  items: ContractItem[];
  shippingFee: number;
  laborCost: number; // estimated or manual
  customPrice?: number; // Manual override price
  status: ContractStatus;
  isUrgent?: boolean;
  assignedLaborIds: string[];
}

export interface Labor {
  id: string;
  name: string;
  phone: string;
  role: 'main' | 'helper';
  salaryPerDay: number;
  active: boolean;
}

export interface InventoryItem {
  id: string;
  name: string;
  category: 'tent' | 'table' | 'chair' | 'decor' | 'other';
  totalStock: number;
  unit: string;
  unitPriceRetail: number;
}

// Initial Mock Inventory
const DEFAULT_INVENTORY: InventoryItem[] = [
  { id: 'rap_lon', name: 'Rạp không gian lớn', category: 'tent', totalStock: 300, unit: 'm²', unitPriceRetail: 60000 },
  { id: 'rap_nho', name: 'Khung rạp sắt nhỏ (3m x 4m)', category: 'tent', totalStock: 8, unit: 'khung', unitPriceRetail: 800000 },
  { id: 'ghe_tiffany', name: 'Ghế Tiffany nơ lụa', category: 'chair', totalStock: 250, unit: 'cái', unitPriceRetail: 25000 },
  { id: 'ghe_nhua', name: 'Ghế nhựa đỏ có tựa', category: 'chair', totalStock: 500, unit: 'cái', unitPriceRetail: 5000 },
  { id: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', category: 'table', totalStock: 60, unit: 'bộ', unitPriceRetail: 150000 },
  { id: 'ban_dai', name: 'Bàn dài hai họ phủ lụa', category: 'table', totalStock: 12, unit: 'bộ', unitPriceRetail: 250000 },
  { id: 'gia_tien_hoa_lua', name: 'Set Gia tiên hoa lụa cao cấp', category: 'decor', totalStock: 3, unit: 'bộ', unitPriceRetail: 3500000 },
  { id: 'gia_tien_hoa_tuoi', name: 'Set Gia tiên hoa tươi nghệ thuật', category: 'decor', totalStock: 2, unit: 'bộ', unitPriceRetail: 12000000 },
  { id: 'cong_hoa', name: 'Cổng hoa cưới/cổng chào', category: 'decor', totalStock: 5, unit: 'cái', unitPriceRetail: 1000000 },
  { id: 'quat_cong_nghiep', name: 'Quạt hơi nước công nghiệp', category: 'other', totalStock: 15, unit: 'cái', unitPriceRetail: 120000 },
  { id: 'he_thong_den', name: 'Bộ đèn LED pha sân khấu', category: 'other', totalStock: 8, unit: 'bộ', unitPriceRetail: 300000 }
];

// Initial Mock Labors
const DEFAULT_LABOR: Labor[] = [
  { id: 'l_bo_thuy', name: 'Bố Thủy (Chủ Nhà)', phone: '0987654321', role: 'main', salaryPerDay: 0, active: true },
  { id: 'l_hung', name: 'Nguyễn Văn Hùng', phone: '0912345678', role: 'main', salaryPerDay: 400000, active: true },
  { id: 'l_hai', name: 'Lê Văn Hải', phone: '0934567890', role: 'helper', salaryPerDay: 300000, active: true },
  { id: 'l_huy', name: 'Trần Quốc Huy', phone: '0945678901', role: 'helper', salaryPerDay: 300000, active: true },
  { id: 'l_tuan', name: 'Phạm Minh Tuấn', phone: '0956789012', role: 'helper', salaryPerDay: 300000, active: true }
];

// Helper to get dates relative to today
const getRelativeDateStr = (offsetDays: number): string => {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().split('T')[0];
};

// Initial Mock Contracts
const DEFAULT_CONTRACTS: Contract[] = [
  {
    id: 'c_001',
    clientName: 'Nguyễn Văn Minh',
    clientPhone: '0981122334',
    eventType: 'wedding',
    eventDate: getRelativeDateStr(5),
    endDate: getRelativeDateStr(7),
    address: 'Số 15, ngõ 88, Quế Võ, Bắc Ninh',
    notes: 'Nhà trong ngõ hơi hẹp, rạp dài. Đám cưới trang trí tông hồng pastel.',
    items: [
      { itemId: 'rap_lon', name: 'Rạp không gian lớn', quantity: 100, price: 60000 },
      { itemId: 'ghe_tiffany', name: 'Ghế Tiffany nơ lụa', quantity: 100, price: 25000 },
      { itemId: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', quantity: 10, price: 150000 },
      { itemId: 'gia_tien_hoa_lua', name: 'Set Gia tiên hoa lụa cao cấp', quantity: 1, price: 3500000 },
      { itemId: 'cong_hoa', name: 'Cổng hoa cưới/cổng chào', quantity: 1, price: 1000000 }
    ],
    shippingFee: 500000,
    laborCost: 1800000,
    status: 'deposited',
    assignedLaborIds: ['l_bo_thuy', 'l_hung', 'l_hai']
  },
  {
    id: 'c_002',
    clientName: 'Bà Trần Thị Lan',
    clientPhone: '0905566778',
    eventType: 'funeral',
    eventDate: getRelativeDateStr(0),
    endDate: getRelativeDateStr(2),
    address: 'Thôn Chùa, Yên Dũng, Bắc Giang',
    notes: 'ĐÁM HIẾU - LẮP GẤP. Cần hoàn thành trước 18h tối nay.',
    items: [
      { itemId: 'rap_nho', name: 'Khung rạp sắt nhỏ (3m x 4m)', quantity: 2, price: 800000 },
      { itemId: 'ghe_nhua', name: 'Ghế nhựa đỏ có tựa', quantity: 150, price: 5000 },
      { itemId: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', quantity: 15, price: 150000 },
      { itemId: 'quat_cong_nghiep', name: 'Quạt hơi nước công nghiệp', quantity: 4, price: 120000 }
    ],
    shippingFee: 300000,
    laborCost: 1000000,
    status: 'setting_up',
    isUrgent: true,
    assignedLaborIds: ['l_bo_thuy', 'l_huy', 'l_tuan']
  },
  {
    id: 'c_003',
    clientName: 'Cụ Nguyễn Hữu Thọ',
    clientPhone: '0977889900',
    eventType: 'longevity',
    eventDate: getRelativeDateStr(12),
    endDate: getRelativeDateStr(13),
    address: 'Tân Yên, Bắc Giang',
    notes: 'Mừng thọ 80 tuổi cụ ông. Trang trí phông đỏ vàng chữ THỌ.',
    items: [
      { itemId: 'rap_nho', name: 'Khung rạp sắt nhỏ (3m x 4m)', quantity: 3, price: 800000 },
      { itemId: 'ghe_tiffany', name: 'Ghế Tiffany nơ lụa', quantity: 60, price: 25000 },
      { itemId: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', quantity: 6, price: 150000 }
    ],
    shippingFee: 400000,
    laborCost: 1400000,
    status: 'pending',
    assignedLaborIds: ['l_bo_thuy', 'l_hung']
  }
];

// Initialize Storage
export const initStorage = () => {
  if (!localStorage.getItem('thoi_thuy_inventory')) {
    localStorage.setItem('thoi_thuy_inventory', JSON.stringify(DEFAULT_INVENTORY));
  }
  if (!localStorage.getItem('thoi_thuy_labor')) {
    localStorage.setItem('thoi_thuy_labor', JSON.stringify(DEFAULT_LABOR));
  }
  if (!localStorage.getItem('thoi_thuy_contracts')) {
    localStorage.setItem('thoi_thuy_contracts', JSON.stringify(DEFAULT_CONTRACTS));
  }
};

// Database APIs
export const getInventory = (): InventoryItem[] => {
  initStorage();
  return JSON.parse(localStorage.getItem('thoi_thuy_inventory') || '[]');
};

export const saveInventoryItem = (item: InventoryItem): InventoryItem[] => {
  const inventory = getInventory();
  const index = inventory.findIndex(i => i.id === item.id);
  if (index >= 0) {
    inventory[index] = item;
  } else {
    inventory.push(item);
  }
  localStorage.setItem('thoi_thuy_inventory', JSON.stringify(inventory));
  return inventory;
};

export const deleteInventoryItem = (id: string): InventoryItem[] => {
  const inventory = getInventory().filter(i => i.id !== id);
  localStorage.setItem('thoi_thuy_inventory', JSON.stringify(inventory));
  return inventory;
};

export const getLabors = (): Labor[] => {
  initStorage();
  return JSON.parse(localStorage.getItem('thoi_thuy_labor') || '[]');
};

export const saveLabor = (labor: Labor): Labor[] => {
  const labors = getLabors();
  const index = labors.findIndex(l => l.id === labor.id);
  if (index >= 0) {
    labors[index] = labor;
  } else {
    labors.push(labor);
  }
  localStorage.setItem('thoi_thuy_labor', JSON.stringify(labors));
  return labors;
};

export const deleteLabor = (id: string): Labor[] => {
  const labors = getLabors().filter(l => l.id !== id);
  localStorage.setItem('thoi_thuy_labor', JSON.stringify(labors));
  return labors;
};

export const getContracts = (): Contract[] => {
  initStorage();
  return JSON.parse(localStorage.getItem('thoi_thuy_contracts') || '[]');
};

export const saveContract = (contract: Contract): Contract[] => {
  const contracts = getContracts();
  const index = contracts.findIndex(c => c.id === contract.id);
  if (index >= 0) {
    contracts[index] = contract;
  } else {
    contracts.push(contract);
  }
  localStorage.setItem('thoi_thuy_contracts', JSON.stringify(contracts));
  return contracts;
};

export const deleteContract = (id: string): Contract[] => {
  const contracts = getContracts().filter(c => c.id !== id);
  localStorage.setItem('thoi_thuy_contracts', JSON.stringify(contracts));
  return contracts;
};

// Core availability logic for both items and labor
export const checkAvailabilityForDate = (dateStr: string, excludeContractId?: string) => {
  const contracts = getContracts().filter(c => 
    c.status !== 'completed' && 
    c.id !== excludeContractId &&
    dateStr >= c.eventDate && 
    dateStr <= c.endDate
  );

  // 1. Calculate occupied equipment
  const occupiedItems: Record<string, number> = {};
  contracts.forEach(contract => {
    contract.items.forEach(item => {
      occupiedItems[item.itemId] = (occupiedItems[item.itemId] || 0) + item.quantity;
    });
  });

  const inventory = getInventory();
  const availableItems = inventory.map(item => ({
    ...item,
    occupied: occupiedItems[item.id] || 0,
    available: Math.max(0, item.totalStock - (occupiedItems[item.id] || 0))
  }));

  // 2. Calculate labor occupancy
  const occupiedLaborIds = new Set<string>();
  contracts.forEach(c => {
    c.assignedLaborIds.forEach(id => occupiedLaborIds.add(id));
  });

  const labors = getLabors();
  const availableLabors = labors.map(l => ({
    ...l,
    isOccupied: occupiedLaborIds.has(l.id)
  }));

  return {
    items: availableItems,
    labors: availableLabors
  };
};

// Profit stats calculator
export const getFinancialStats = () => {
  const contracts = getContracts();
  
  let totalRevenue = 0;
  let totalLaborCost = 0;
  let totalShippingCost = 0;
  
  const revenueByType: Record<EventType, number> = {
    wedding: 0,
    funeral: 0,
    longevity: 0,
    retail: 0,
    other: 0
  };

  const countByType: Record<EventType, number> = {
    wedding: 0,
    funeral: 0,
    longevity: 0,
    retail: 0,
    other: 0
  };

  contracts.forEach(c => {
    // Calculate contract revenue
    let rev = c.customPrice !== undefined ? c.customPrice : c.items.reduce((sum, item) => sum + item.quantity * item.price, 0) + c.shippingFee;
    
    // Add to aggregates if completed or confirmed
    if (c.status !== 'pending') {
      totalRevenue += rev;
      totalLaborCost += c.laborCost;
      totalShippingCost += c.shippingFee;
      
      revenueByType[c.eventType] += rev;
      countByType[c.eventType] += 1;
    }
  });

  const netProfit = totalRevenue - totalLaborCost - (totalShippingCost * 0.4);

  return {
    totalRevenue,
    totalLaborCost,
    totalShippingCost,
    netProfit,
    revenueByType,
    countByType,
    totalContracts: contracts.length
  };
};
