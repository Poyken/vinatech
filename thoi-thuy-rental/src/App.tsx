// src/App.tsx
import React, { useState, useEffect } from 'react';
import { Navigation } from './components/Navigation';
import { CatalogGallery } from './components/CatalogGallery';
import { CostCalculator } from './components/CostCalculator';
import { BookingForm } from './components/BookingForm';
import { AdminCalendar } from './components/AdminCalendar';
import { LaborManager } from './components/LaborManager';
import { AdminDashboard } from './components/AdminDashboard';
import { InventoryManager } from './components/InventoryManager';
import { initStorage, Contract, saveContract, EventType } from './db/rentalStorage';
import { Calendar, Phone, MapPin, Save, X } from 'lucide-react';

export default function App() {
  const [currentTab, setCurrentTab] = useState<string>('calculator');
  const [isAdminMode, setIsAdminMode] = useState<boolean>(false);
  const [isDarkMode, setIsDarkMode] = useState<boolean>(false);

  // States for cross-component navigation
  const [selectedPackageId, setSelectedPackageId] = useState<string | undefined>(undefined);
  const [calcData, setCalcData] = useState<any>(null);
  
  // Edit mode states
  const [editContractData, setEditContractData] = useState<Contract | null>(null);

  // Initialize simulated DB
  useEffect(() => {
    initStorage();
  }, []);

  // Sync dark mode class
  useEffect(() => {
    if (isDarkMode) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
  }, [isDarkMode]);

  // Navigate to calculator with a selected package pre-populated
  const handleSelectPackage = (packageId: string) => {
    setSelectedPackageId(packageId);
    setCurrentTab('calculator');
    
    // Clear selection flag after a small timeout so the user can re-trigger
    setTimeout(() => {
      setSelectedPackageId(undefined);
    }, 100);
  };

  // cost calculation completed -> proceed to booking form
  const handleProceedToBooking = (data: any) => {
    setCalcData(data);
    setCurrentTab('booking');
  };

  // booking success
  const handleBookingSuccess = () => {
    setCurrentTab('calculator');
    setCalcData(null);
  };

  // Edit contract submission handler
  const handleEditSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editContractData) {
      saveContract(editContractData);
      alert('Đã cập nhật thông tin hợp đồng thành công!');
      setEditContractData(null);
      setCurrentTab('dashboard');
    }
  };

  const handleEditItemQuantityChange = (itemId: string, newQty: number) => {
    if (!editContractData) return;
    const updatedItems = editContractData.items.map(item => {
      if (item.itemId === itemId) {
        return { ...item, quantity: Math.max(0, newQty) };
      }
      return item;
    }).filter(item => item.quantity > 0);

    setEditContractData({
      ...editContractData,
      items: updatedItems
    });
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  return (
    <div className="app-container">
      {/* Header bar controls navigation */}
      <Navigation
        currentTab={currentTab}
        setCurrentTab={setCurrentTab}
        isAdminMode={isAdminMode}
        setIsAdminMode={setIsAdminMode}
        isDarkMode={isDarkMode}
        setIsDarkMode={setIsDarkMode}
      />

      {/* Main rendering slot */}
      <main className="main-content">
        
        {/* Client Cost Calculator */}
        {currentTab === 'calculator' && (
          <CostCalculator
            preselectedPackageId={selectedPackageId}
            onProceedToBooking={handleProceedToBooking}
          />
        )}

        {/* Client Catalog samples */}
        {currentTab === 'catalog' && (
          <CatalogGallery onSelectPackage={handleSelectPackage} />
        )}

        {/* Client Booking Form */}
        {currentTab === 'booking' && calcData && (
          <BookingForm
            calcData={calcData}
            onBack={() => setCurrentTab('calculator')}
            onSuccess={handleBookingSuccess}
          />
        )}

        {/* Admin Views */}
        {isAdminMode && (
          <>
            {/* Work Calendar */}
            {currentTab === 'calendar' && (
              <AdminCalendar
                onEditContract={(contract) => {
                  setEditContractData(contract);
                  setCurrentTab('edit_contract');
                }}
              />
            )}

            {/* Dashboard manager */}
            {currentTab === 'dashboard' && (
              <AdminDashboard
                onEditContract={(contract) => {
                  setEditContractData(contract);
                  setCurrentTab('edit_contract');
                }}
              />
            )}

            {/* Staff list coordinator */}
            {currentTab === 'labor' && (
              <LaborManager />
            )}

            {/* Inventory catalog manager */}
            {currentTab === 'inventory' && (
              <InventoryManager />
            )}

            {/* Edit Contract Form */}
            {currentTab === 'edit_contract' && editContractData && (
              <div style={{ maxWidth: '800px', margin: '0 auto' }}>
                <div className="glass" style={{ padding: '2.5rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border)', paddingBottom: '0.5rem' }}>
                    <h3 style={{ fontSize: '1.8rem', color: 'var(--primary)', margin: 0 }}>Cập Nhật Hợp Đồng: {editContractData.clientName}</h3>
                    <button onClick={() => setEditContractData(null)} style={{ border: 'none', background: 'transparent', cursor: 'pointer', fontSize: '1.2rem', color: 'var(--text-dark)' }}>
                      <X size={24} />
                    </button>
                  </div>

                  <form onSubmit={handleEditSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem', fontSize: '0.9rem' }}>
                    
                    {/* Customer info */}
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Gia chủ/Khách hàng:</label>
                        <input
                          type="text"
                          required
                          value={editContractData.clientName}
                          onChange={(e) => setEditContractData({ ...editContractData, clientName: e.target.value })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        />
                      </div>
                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Số điện thoại liên hệ:</label>
                        <input
                          type="tel"
                          required
                          value={editContractData.clientPhone}
                          onChange={(e) => setEditContractData({ ...editContractData, clientPhone: e.target.value })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        />
                      </div>
                    </div>

                    {/* Dates and type */}
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '1.5rem' }}>
                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Loại hình dịch vụ:</label>
                        <select
                          value={editContractData.eventType}
                          onChange={(e) => setEditContractData({ ...editContractData, eventType: e.target.value as EventType })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        >
                          <option value="wedding">💒 Đám cưới</option>
                          <option value="funeral">🕯️ Đám hiếu</option>
                          <option value="longevity">👵 Mừng thọ</option>
                          <option value="retail">🪑 Thuê lẻ</option>
                          <option value="other">🎪 Khác</option>
                        </select>
                      </div>

                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ngày lắp đặt:</label>
                        <input
                          type="date"
                          required
                          value={editContractData.eventDate}
                          onChange={(e) => setEditContractData({ ...editContractData, eventDate: e.target.value })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        />
                      </div>

                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ngày tháo dỡ:</label>
                        <input
                          type="date"
                          required
                          value={editContractData.endDate}
                          onChange={(e) => setEditContractData({ ...editContractData, endDate: e.target.value })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        />
                      </div>
                    </div>

                    {/* Address & notes */}
                    <div>
                      <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Địa chỉ thi công:</label>
                      <input
                        type="text"
                        required
                        value={editContractData.address}
                        onChange={(e) => setEditContractData({ ...editContractData, address: e.target.value })}
                        style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                      />
                    </div>

                    {/* Financial prices options */}
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1.2fr', gap: '1.5rem', alignItems: 'center' }}>
                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Phí vận chuyển (VND):</label>
                        <input
                          type="number"
                          step={50000}
                          value={editContractData.shippingFee}
                          onChange={(e) => setEditContractData({ ...editContractData, shippingFee: Number(e.target.value) })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                        />
                      </div>

                      <div>
                        <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Giá ghi đè thủ công (VND):</label>
                        <input
                          type="number"
                          step={100000}
                          value={editContractData.customPrice !== undefined ? editContractData.customPrice : ''}
                          placeholder="Mặc định theo hệ thống"
                          onChange={(e) => setEditContractData({
                            ...editContractData,
                            customPrice: e.target.value !== '' ? Number(e.target.value) : undefined
                          })}
                          style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', fontWeight: 'bold', color: 'var(--primary)' }}
                        />
                      </div>

                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'flex', gap: '0.2rem', alignItems: 'flex-start', marginTop: '1rem' }}>
                        <span>*</span> Nhập giá ghi đè để thay đổi toàn bộ tổng tiền thanh toán mà không cần tính theo chi tiết từng thiết bị.
                      </div>
                    </div>

                    {/* Equipment Details editor */}
                    <div style={{ borderTop: '1px solid var(--border)', paddingTop: '1rem' }}>
                      <strong style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--primary)' }}>ĐIỀU CHỈNH SỐ LƯỢNG THIẾT BỊ:</strong>
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', background: 'rgba(0,0,0,0.01)', padding: '1rem', borderRadius: 'var(--radius-sm)' }}>
                        {editContractData.items.map(item => (
                          <div key={item.itemId} style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', alignItems: 'center', gap: '1rem' }}>
                            <span>{item.name}</span>
                            <span style={{ color: 'var(--text-muted)' }}>Đơn giá: {formatVND(item.price)}</span>
                            <input
                              type="number"
                              min={0}
                              value={item.quantity}
                              onChange={(e) => handleEditItemQuantityChange(item.itemId, Number(e.target.value))}
                              style={{ padding: '0.3rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '80px', background: 'transparent', color: 'inherit' }}
                            />
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Special Notes area */}
                    <div>
                      <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Ghi chú thi công:</label>
                      <textarea
                        value={editContractData.notes}
                        onChange={(e) => setEditContractData({ ...editContractData, notes: e.target.value })}
                        rows={2}
                        style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit', resize: 'vertical' }}
                      />
                    </div>

                    {/* Submit or cancel */}
                    <div style={{ display: 'flex', gap: '1rem', justifyContent: 'flex-end', borderTop: '1px solid var(--border)', paddingTop: '1rem', marginTop: '0.5rem' }}>
                      <button type="button" onClick={() => setEditContractData(null)} className="btn btn-outline">
                        Hủy
                      </button>
                      <button type="submit" className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <Save size={16} /> Lưu Thay Đổi
                      </button>
                    </div>

                  </form>
                </div>
              </div>
            )}
          </>
        )}

      </main>

      {/* Warm-Luxury Footer */}
      <footer style={{
        marginTop: 'auto',
        borderTop: '1px solid var(--border)',
        padding: '2rem',
        textAlign: 'center',
        background: 'rgba(140, 29, 46, 0.02)',
        fontSize: '0.85rem',
        color: 'var(--text-muted)'
      }}>
        <div style={{ fontFamily: 'var(--font-serif)', fontSize: '1rem', color: 'var(--primary)', marginBottom: '0.4rem', fontWeight: 600 }}>
          Phông Rạp Thời Thủy — Trọn Vẹn Nghĩa Tình Trong Mọi Khoảnh Khắc
        </div>
        <div>Hệ thống điều phối phông rạp, bàn ghế tiệc cưới, mừng thọ, đám hiếu và thiết bị sự kiện.</div>
        <div style={{ marginTop: '0.5rem', fontSize: '0.75rem', opacity: 0.7 }}>
          © 2026 Phông Rạp Thời Thủy. Hệ thống được lập trình vận hành tối ưu cho máy tính và thiết bị di động.
        </div>
      </footer>
    </div>
  );
}
