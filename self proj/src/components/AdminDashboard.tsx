// src/components/AdminDashboard.tsx
import React, { useState, useMemo } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { ClipboardList, Plus, Search, DollarSign, Users, AlertTriangle, ShieldCheck, RefreshCw, Trash2, Edit, CheckSquare } from 'lucide-react';
import { Contract, getContracts, saveContract, deleteContract, getFinancialStats, checkAvailabilityForDate, EventType, ContractStatus, getInventory } from '../db/rentalStorage';

interface AdminDashboardProps {
  onEditContract: (contract: Contract) => void;
}

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ onEditContract }) => {
  const [contracts, setContracts] = useState<Contract[]>(getContracts());
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  
  // Inventory check date picker (default to today)
  const [checkDate, setCheckDate] = useState(new Date().toISOString().split('T')[0]);

  // Quick-Add form states
  const [showQuickAdd, setShowQuickAdd] = useState(false);
  const [qName, setQName] = useState('');
  const [qPhone, setQPhone] = useState('');
  const [qType, setQType] = useState<EventType>('funeral');
  const [qDate, setQDate] = useState(new Date().toISOString().split('T')[0]);
  const [qEndDate, setQEndDate] = useState(new Date().toISOString().split('T')[0]);
  const [qAddress, setQAddress] = useState('');
  const [qOverridePrice, setQOverridePrice] = useState(5000000);
  const [qNotes, setQNotes] = useState('');

  const refreshData = () => {
    setContracts(getContracts());
  };

  const handleDelete = (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn xóa đơn hàng này?')) {
      const updated = deleteContract(id);
      setContracts(updated);
    }
  };

  const handleStatusChange = (id: string, status: ContractStatus) => {
    const c = contracts.find(item => item.id === id);
    if (c) {
      const updated = { ...c, status };
      const updatedList = saveContract(updated);
      setContracts(updatedList);
    }
  };

  const handleQuickAddSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Auto populate basic equipment depending on selected type
    const inventory = getInventory();
    const items = [];
    
    if (qType === 'funeral') {
      items.push({ itemId: 'rap_nho', name: 'Khung rạp sắt nhỏ (3m x 4m)', quantity: 2, price: 800000 });
      items.push({ itemId: 'ghe_nhua', name: 'Ghế nhựa đỏ có tựa', quantity: 100, price: 5000 });
      items.push({ itemId: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', quantity: 10, price: 150000 });
    } else if (qType === 'retail') {
      items.push({ itemId: 'ghe_nhua', name: 'Ghế nhựa đỏ có tựa', quantity: 50, price: 5000 });
    } else {
      items.push({ itemId: 'rap_nho', name: 'Khung rạp sắt nhỏ (3m x 4m)', quantity: 3, price: 800000 });
      items.push({ itemId: 'ghe_tiffany', name: 'Ghế Tiffany nơ lụa', quantity: 60, price: 25000 });
      items.push({ itemId: 'ban_tron', name: 'Bàn tròn phủ khăn (10 người)', quantity: 6, price: 150000 });
    }

    const newContract: Contract = {
      id: `c_${Date.now()}`,
      clientName: qName,
      clientPhone: qPhone,
      eventType: qType,
      eventDate: qDate,
      endDate: qEndDate || qDate,
      address: qAddress,
      notes: `${qNotes} (Tạo nhanh từ Dashboard)`,
      items,
      shippingFee: qType === 'retail' ? 0 : 300000,
      laborCost: qType === 'retail' ? 0 : 1000000,
      customPrice: Number(qOverridePrice),
      status: qType === 'funeral' ? 'setting_up' : 'deposited',
      isUrgent: qType === 'funeral',
      assignedLaborIds: []
    };

    saveContract(newContract);
    setContracts(getContracts());
    setShowQuickAdd(false);
    resetQuickAddForm();
    alert('Đã thêm nhanh đơn hàng thành công!');
  };

  const resetQuickAddForm = () => {
    setQName('');
    setQPhone('');
    setQType('funeral');
    setQDate(new Date().toISOString().split('T')[0]);
    setQEndDate(new Date().toISOString().split('T')[0]);
    setQAddress('');
    setQOverridePrice(5000000);
    setQNotes('');
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  // Memoized Financial Statistics
  const stats = useMemo(() => {
    return getFinancialStats();
  }, [contracts]);

  // Memoized Inventory & Labor Audit for the chosen date
  const auditResults = useMemo(() => {
    return checkAvailabilityForDate(checkDate);
  }, [checkDate, contracts]);

  // Memoized Search and Filter Contracts
  const filteredContracts = useMemo(() => {
    return contracts.filter(c => {
      const matchesSearch = c.clientName.toLowerCase().includes(searchTerm.toLowerCase()) || 
                            c.clientPhone.includes(searchTerm) || 
                            c.address.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesType = filterType === 'all' || c.eventType === filterType;
      const matchesStatus = filterStatus === 'all' || c.status === filterStatus;
      
      return matchesSearch && matchesType && matchesStatus;
    });
  }, [contracts, searchTerm, filterType, filterStatus]);

  // Memoized Recharts Bar Chart Configuration
  const chartData = useMemo(() => {
    return [
      { name: 'Đám Cưới', 'Doanh Thu': stats.revenueByType.wedding, color: '#8c1d2e' },
      { name: 'Đám Hiếu', 'Doanh Thu': stats.revenueByType.funeral, color: '#c62828' },
      { name: 'Mừng Thọ', 'Doanh Thu': stats.revenueByType.longevity, color: '#800020' },
      { name: 'Thuê Lẻ', 'Doanh Thu': stats.revenueByType.retail, color: '#1565c0' },
      { name: 'Khác', 'Doanh Thu': stats.revenueByType.other, color: '#736764' }
    ];
  }, [stats.revenueByType]);

  // Memoized Recharts Pie Chart Configuration
  const pieData = useMemo(() => {
    return Object.keys(stats.revenueByType).map(key => {
      let name = 'Khác';
      if (key === 'wedding') name = 'Đám Cưới';
      if (key === 'funeral') name = 'Đám Hiếu';
      if (key === 'longevity') name = 'Mừng Thọ';
      if (key === 'retail') name = 'Thuê Lẻ';
      return {
        name,
        value: stats.revenueByType[key as EventType]
      };
    }).filter(item => item.value > 0);
  }, [stats.revenueByType]);

  const PIE_COLORS = ['#8c1d2e', '#c62828', '#800020', '#1565c0', '#736764'];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      {/* Dashboard Header */}
      <div className="glass" style={{ padding: '1.25rem 2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ClipboardList size={24} color="var(--primary)" />
          <h2 style={{ fontSize: '1.5rem', margin: 0 }}>Quản Lý Đơn Hàng & Doanh Thu</h2>
        </div>

        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button onClick={refreshData} className="btn btn-outline" style={{ padding: '0.5rem' }} title="Tải lại dữ liệu">
            <RefreshCw size={18} />
          </button>
          <button onClick={() => setShowQuickAdd(true)} className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
            <Plus size={18} /> Tạo Đơn Hỏa Tốc / Gọi Điện
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.5rem' }}>
        
        {/* Expected Revenue */}
        <div className="glass" style={{ padding: '1.5rem', borderLeft: '4px solid var(--accent)' }}>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block', fontWeight: 'bold' }}>TỔNG DOANH THU ĐƠN (ĐÃ CỌC/HOÀN THÀNH)</span>
          <h3 style={{ fontSize: '1.8rem', margin: '0.2rem 0', color: 'var(--primary)' }}>{formatVND(stats.totalRevenue)}</h3>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Phí vận chuyển: {formatVND(stats.totalShippingCost)}</span>
        </div>

        {/* Net Profit */}
        <div className="glass" style={{ padding: '1.5rem', borderLeft: '4px solid var(--success)' }}>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block', fontWeight: 'bold' }}>LỢI NHUẬN RÒNG DỰ TÍNH (TRỪ THƯỢ LẮP)</span>
          <h3 style={{ fontSize: '1.8rem', margin: '0.2rem 0', color: '#2e7d32' }}>{formatVND(stats.netProfit)}</h3>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Doanh thu trừ nhân công & xăng xe (40%)</span>
        </div>

        {/* Labor Costs */}
        <div className="glass" style={{ padding: '1.5rem', borderLeft: '4px solid var(--info)' }}>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block', fontWeight: 'bold' }}>TỔNG CHI PHÍ NHÂN CÔNG ĐÃ CHI TRẢ</span>
          <h3 style={{ fontSize: '1.8rem', margin: '0.2rem 0', color: '#1565c0' }}>{formatVND(stats.totalLaborCost)}</h3>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Thanh toán thợ dựng + thợ bê</span>
        </div>

        {/* Active orders count */}
        <div className="glass" style={{ padding: '1.5rem', borderLeft: '4px solid var(--text-muted)' }}>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block', fontWeight: 'bold' }}>TỔNG SỐ LƯỢNG HỢP ĐỒNG SỰ KIỆN</span>
          <h3 style={{ fontSize: '1.8rem', margin: '0.2rem 0' }}>{stats.totalContracts} đơn</h3>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Bao gồm cưới, tang, mừng thọ, thuê lẻ</span>
        </div>

      </div>

      {/* Analytics Charts */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '2rem' }}>
        
        {/* Bar chart */}
        <div className="glass" style={{ padding: '1.5rem', height: '350px' }}>
          <h3 style={{ fontSize: '1.1rem', marginBottom: '1rem', color: 'var(--primary)' }}>Cơ Cấu Doanh Thu Theo Loại Dịch Vụ</h3>
          <ResponsiveContainer width="100%" height="90%">
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis tickFormatter={(val) => `${val / 1000000}M`} />
              <Tooltip formatter={(value) => formatVND(Number(value))} />
              <Legend />
              <Bar dataKey="Doanh Thu" fill="var(--primary)" radius={[4, 4, 0, 0]}>
                {chartData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Pie chart */}
        <div className="glass" style={{ padding: '1.5rem', height: '350px', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ fontSize: '1.1rem', marginBottom: '1rem', color: 'var(--primary)' }}>Tỷ Lệ Đóng Góp Doanh Thu</h3>
          {pieData.length > 0 ? (
            <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={pieData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={3}
                    dataKey="value"
                    label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
                  >
                    {pieData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => formatVND(Number(value))} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <div style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--text-muted)' }}>
              Chưa có dữ liệu giao dịch phát sinh
            </div>
          )}
        </div>

      </div>

      {/* Main Order Management List & Live Inventory Checker */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.3fr 0.7fr', gap: '2rem' }}>
        
        {/* Order Spreadsheet List */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            Danh Sách Hợp Đồng Cửa Hàng
          </h3>

          {/* Search Controls */}
          <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.5rem', flexWrap: 'wrap' }}>
            <div style={{ position: 'relative', flex: 1, minWidth: '200px' }}>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Tìm khách hàng, số điện thoại, địa chỉ..."
                style={{ padding: '0.5rem 0.5rem 0.5rem 2rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              />
              <Search size={16} style={{ position: 'absolute', left: '8px', top: '10px', color: 'var(--text-muted)' }} />
            </div>

            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', background: 'transparent', color: 'inherit' }}
            >
              <option value="all">Tất cả loại sự kiện</option>
              <option value="wedding">💒 Đám cưới</option>
              <option value="funeral">🕯️ Đám hiếu</option>
              <option value="longevity">👵 Mừng thọ</option>
              <option value="retail">🪑 Thuê lẻ</option>
            </select>

            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', background: 'transparent', color: 'inherit' }}
            >
              <option value="all">Tất cả trạng thái</option>
              <option value="pending">Chờ duyệt</option>
              <option value="deposited">Đã đặt cọc</option>
              <option value="setting_up">Đang dựng rạp</option>
              <option value="ongoing">Đang diễn ra</option>
              <option value="dismantling">Đang tháo dỡ</option>
              <option value="completed">Đã hoàn thành</option>
            </select>
          </div>

          {/* Orders Table */}
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--border)', textAlign: 'left', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Gia chủ</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Loại đám</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Thời gian thi công</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Địa chỉ</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Tổng tiền</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Trạng thái</th>
                  <th style={{ padding: '0.6rem 0.4rem', textAlign: 'center' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {filteredContracts.map(c => {
                  const rev = c.customPrice !== undefined ? c.customPrice : c.items.reduce((sum, item) => sum + item.quantity * item.price, 0) + c.shippingFee;
                  
                  return (
                    <tr key={c.id} style={{ borderBottom: '1px solid rgba(0,0,0,0.05)', background: c.isUrgent ? 'rgba(198,40,40,0.02)' : '' }}>
                      <td style={{ padding: '0.75rem 0.4rem', fontWeight: 600 }}>
                        <div style={{ display: 'flex', flexDirection: 'column' }}>
                          <span>{c.clientName} {c.isUrgent && <span className="urgent-badge" style={{ fontSize: '0.6rem', padding: '0.05rem 0.2rem' }}>GẤP</span>}</span>
                          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{c.clientPhone}</span>
                        </div>
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem' }}>
                        <span className={`badge ${
                          c.eventType === 'wedding' ? 'badge-wedding' : 
                          c.eventType === 'funeral' ? 'badge-funeral' : 
                          c.eventType === 'longevity' ? 'badge-longevity' : 
                          c.eventType === 'retail' ? 'badge-retail' : 'badge-other'
                        }`} style={{ fontSize: '0.7rem', padding: '0.1rem 0.4rem' }}>
                          {c.eventType === 'wedding' && 'Cưới'}
                          {c.eventType === 'funeral' && 'Hiếu'}
                          {c.eventType === 'longevity' && 'Lên Lão'}
                          {c.eventType === 'retail' && 'Thuê Lẻ'}
                        </span>
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem', color: 'var(--text-muted)' }}>
                        {c.eventDate} đến {c.endDate}
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem', maxWidth: '150px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }} title={c.address}>
                        {c.address}
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem', fontWeight: 'bold', color: 'var(--primary)' }}>
                        {c.customPrice !== undefined ? (
                          <span style={{ textDecoration: 'underline dotted', cursor: 'help' }} title="Giá nhập tay ghi đè">{formatVND(c.customPrice)}</span>
                        ) : formatVND(rev)}
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem' }}>
                        <select
                          value={c.status}
                          onChange={(e) => handleStatusChange(c.id, e.target.value as ContractStatus)}
                          style={{
                            padding: '0.2rem',
                            fontSize: '0.75rem',
                            borderRadius: '4px',
                            border: '1px solid var(--border)',
                            background: 'transparent',
                            color: 'inherit',
                            fontWeight: 600
                          }}
                        >
                          <option value="pending">Chờ duyệt</option>
                          <option value="deposited">Đã cọc</option>
                          <option value="setting_up">Đang dựng</option>
                          <option value="ongoing">Đang tiệc</option>
                          <option value="dismantling">Đang dọn</option>
                          <option value="completed">Hoàn thành</option>
                        </select>
                      </td>
                      <td style={{ padding: '0.75rem 0.4rem', textAlign: 'center' }}>
                        <div style={{ display: 'flex', gap: '0.4rem', justifyContent: 'center' }}>
                          <button onClick={() => onEditContract(c)} className="btn btn-outline" style={{ padding: '0.25rem', borderRadius: '4px' }} title="Sửa">
                            <Edit size={12} />
                          </button>
                          <button onClick={() => handleDelete(c.id)} className="btn btn-outline" style={{ padding: '0.25rem', borderRadius: '4px', color: 'var(--danger)', borderColor: 'rgba(198,40,40,0.2)' }} title="Xóa">
                            <Trash2 size={12} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {/* Live Inventory checker */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            Tra Cứu Kho Thiết Bị Ngày Thi Công
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div>
              <label style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'block', marginBottom: '0.3rem' }}>Chọn ngày kiểm tra tồn kho:</label>
              <input
                type="date"
                value={checkDate}
                onChange={(e) => setCheckDate(e.target.value)}
                style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              />
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', marginTop: '0.5rem' }}>
              {auditResults.items.map(item => {
                const isOverStock = item.available <= 0;
                return (
                  <div key={item.id} style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '0.5rem 0.75rem',
                    borderRadius: 'var(--radius-sm)',
                    background: isOverStock ? 'rgba(211, 47, 47, 0.05)' : 'rgba(0,0,0,0.02)',
                    border: isOverStock ? '1px solid rgba(211, 47, 47, 0.2)' : '1px dashed var(--border)'
                  }}>
                    <div>
                      <strong style={{ display: 'block', fontSize: '0.9rem' }}>{item.name}</strong>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                        Đang cho thuê: {item.occupied} / {item.totalStock} {item.unit}
                      </span>
                    </div>

                    <div style={{ textAlign: 'right' }}>
                      <span style={{
                        display: 'block',
                        fontWeight: 'bold',
                        color: isOverStock ? 'var(--danger)' : 'var(--success)',
                        fontSize: '0.95rem'
                      }}>
                        Còn trống: {item.available} {item.unit}
                      </span>
                      {isOverStock && (
                        <span style={{ fontSize: '0.7rem', color: 'var(--danger)', display: 'block', fontWeight: 'bold' }}>⚠️ HẾT HÀNG</span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

      </div>

      {/* Quick-Add Popup Modal */}
      {showQuickAdd && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.5)',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          zIndex: 1000,
          padding: '1rem'
        }}>
          <div className="glass-premium" style={{ maxWidth: '600px', width: '100%', padding: '2rem', position: 'relative' }}>
            <button
              onClick={() => setShowQuickAdd(false)}
              style={{ position: 'absolute', top: '1rem', right: '1rem', border: 'none', background: 'transparent', fontSize: '1.5rem', cursor: 'pointer', color: 'var(--text-dark)' }}
            >
              ✕
            </button>

            <h3 style={{ fontSize: '1.6rem', color: 'var(--primary)', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              ⚡ Tạo Đơn Hỏa Tốc / Nhận Lịch Qua Điện Thoại
            </h3>

            <form onSubmit={handleQuickAddSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem', fontSize: '0.9rem' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Gia chủ/Khách hàng:</label>
                  <input
                    type="text"
                    required
                    value={qName}
                    onChange={(e) => setQName(e.target.value)}
                    placeholder="Ví dụ: Ông Nguyễn Văn B"
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  />
                </div>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Số điện thoại:</label>
                  <input
                    type="tel"
                    required
                    value={qPhone}
                    onChange={(e) => setQPhone(e.target.value)}
                    placeholder="Ví dụ: 0988776655"
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1.2fr', gap: '1rem', alignItems: 'center' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Loại sự kiện:</label>
                  <select
                    value={qType}
                    onChange={(e) => {
                      const type = e.target.value as EventType;
                      setQType(type);
                      if (type === 'funeral') setQOverridePrice(5000000);
                      else if (type === 'retail') setQOverridePrice(500000);
                      else setQOverridePrice(15000000);
                    }}
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  >
                    <option value="funeral">🕯️ Đám Hiếu (Gấp)</option>
                    <option value="wedding">💒 Đám Cưới/Hỏi</option>
                    <option value="longevity">👵 Mừng Thọ</option>
                    <option value="retail">🪑 Thuê Lẻ Thiết Bị</option>
                    <option value="other">🎪 Khác</option>
                  </select>
                </div>

                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ngày lắp đặt:</label>
                  <input
                    type="date"
                    required
                    value={qDate}
                    onChange={(e) => {
                      setQDate(e.target.value);
                      if (qEndDate < e.target.value) setQEndDate(e.target.value);
                    }}
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  />
                </div>

                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ngày dỡ rạp:</label>
                  <input
                    type="date"
                    required
                    value={qEndDate}
                    onChange={(e) => setQEndDate(e.target.value)}
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  />
                </div>
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Địa chỉ lắp đặt chi tiết:</label>
                <input
                  type="text"
                  required
                  value={qAddress}
                  onChange={(e) => setQAddress(e.target.value)}
                  placeholder="Xóm/Thôn, Xã/Huyện, Bắc Ninh..."
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.2fr', gap: '1rem', alignItems: 'center' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Tổng tiền ghi đè (nhập tay):</label>
                  <input
                    type="number"
                    step={100000}
                    required
                    value={qOverridePrice}
                    onChange={(e) => setQOverridePrice(Number(e.target.value))}
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', fontWeight: 'bold', color: 'var(--primary)' }}
                  />
                </div>

                <div style={{ display: 'flex', alignItems: 'center', marginTop: '1.2rem', gap: '0.4rem', color: 'var(--text-muted)' }}>
                  <DollarSign size={16} />
                  <span style={{ fontSize: '0.75rem' }}>Hệ thống tự gán sẵn các thiết bị cơ bản để bạn tháo dỡ rạp/kho dễ dàng.</span>
                </div>
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ghi chú đặc sắc:</label>
                <textarea
                  value={qNotes}
                  onChange={(e) => setQNotes(e.target.value)}
                  placeholder="Ghi chú điện thoại nhanh..."
                  rows={2}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit', resize: 'none' }}
                />
              </div>

              <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem', justifyContent: 'flex-end' }}>
                <button type="button" onClick={() => setShowQuickAdd(false)} className="btn btn-outline">
                  Hủy bỏ
                </button>
                <button type="submit" className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                  <ShieldCheck size={16} /> Tạo Đơn Hàng Ngay
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      
    </div>
  );
};
