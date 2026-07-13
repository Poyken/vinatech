// src/components/AdminCalendar.tsx
import React, { useState } from 'react';
import { Calendar as CalendarIcon, ChevronLeft, ChevronRight, MapPin, Users, Phone, DollarSign, Edit } from 'lucide-react';
import { Contract, getContracts, EventType, saveContract, getLabors } from '../db/rentalStorage';

interface AdminCalendarProps {
  onEditContract: (contract: Contract) => void;
}

export const AdminCalendar: React.FC<AdminCalendarProps> = ({ onEditContract }) => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedContract, setSelectedContract] = useState<Contract | null>(null);

  const contracts = getContracts();
  const labors = getLabors();

  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();

  // Calendar calculations
  const firstDayOfMonth = new Date(year, month, 1).getDay(); // Day of week (0-6)
  const daysInMonth = new Date(year, month + 1, 0).getDate(); // Total days (28-31)
  
  const handlePrevMonth = () => {
    setCurrentDate(new Date(year, month - 1, 1));
  };

  const handleNextMonth = () => {
    setCurrentDate(new Date(year, month + 1, 1));
  };

  const monthNames = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
  ];

  // Helper to format date string
  const formatDateKey = (dayNum: number): string => {
    const dStr = dayNum < 10 ? `0${dayNum}` : `${dayNum}`;
    const mStr = (month + 1) < 10 ? `0${month + 1}` : `${month + 1}`;
    return `${year}-${mStr}-${dStr}`;
  };

  // Find contracts that overlap with this date
  const getContractsForDate = (dateKey: string): Contract[] => {
    return contracts.filter(c => dateKey >= c.eventDate && dateKey <= c.endDate);
  };

  const getBadgeClass = (type: EventType) => {
    if (type === 'wedding') return 'badge-wedding';
    if (type === 'funeral') return 'badge-funeral';
    if (type === 'longevity') return 'badge-longevity';
    if (type === 'retail') return 'badge-retail';
    return 'badge-other';
  };

  const getStatusText = (status: string) => {
    if (status === 'pending') return 'Chờ duyệt';
    if (status === 'deposited') return 'Đã đặt cọc';
    if (status === 'setting_up') return 'Đang dựng rạp';
    if (status === 'ongoing') return 'Đang diễn ra';
    if (status === 'dismantling') return 'Đang dỡ dọn';
    if (status === 'completed') return 'Đã hoàn thành';
    return status;
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  // Generate calendar cells
  const calendarCells = [];
  
  // Empty spaces for previous month's days
  // Standard grid assumes Sunday = 0. To align, we check firstDayOfMonth.
  // In Vietnam, calendar week often starts on Monday (1). But standard 0 is fine.
  for (let i = 0; i < firstDayOfMonth; i++) {
    calendarCells.push(<div key={`empty-${i}`} style={{ border: '1px solid var(--border)', background: 'rgba(0,0,0,0.02)', minHeight: '100px' }} />);
  }

  // Actual days
  for (let day = 1; day <= daysInMonth; day++) {
    const dateKey = formatDateKey(day);
    const dateContracts = getContractsForDate(dateKey);
    const isToday = new Date().toISOString().split('T')[0] === dateKey;

    calendarCells.push(
      <div
        key={`day-${day}`}
        style={{
          border: '1px solid var(--border)',
          background: isToday ? 'rgba(212, 175, 55, 0.05)' : 'var(--bg-card)',
          minHeight: '110px',
          padding: '0.4rem',
          display: 'flex',
          flexDirection: 'column',
          transition: 'var(--transition)'
        }}
      >
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '0.4rem'
        }}>
          <span style={{
            fontSize: '0.9rem',
            fontWeight: 'bold',
            color: isToday ? 'var(--primary)' : 'inherit',
            background: isToday ? 'var(--accent)' : 'transparent',
            borderRadius: '50%',
            width: '24px',
            height: '24px',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center'
          }}>
            {day}
          </span>
          {dateContracts.some(c => c.isUrgent) && (
            <span className="urgent-badge" style={{ fontSize: '0.65rem', padding: '0.1rem 0.3rem', borderRadius: '4px' }}>⚡ GẤP</span>
          )}
        </div>

        {/* Contract list inside the cell */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.3rem', flex: 1, overflowY: 'auto' }}>
          {dateContracts.map(c => {
            const displayTitle = c.eventType === 'funeral' ? `Hiếu: ${c.clientName}` : `${c.clientName}`;
            return (
              <div
                key={c.id}
                onClick={() => setSelectedContract(c)}
                className={`badge ${getBadgeClass(c.eventType)}`}
                style={{
                  fontSize: '0.75rem',
                  padding: '0.2rem 0.4rem',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  textAlign: 'left',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  fontWeight: 600,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.2rem'
                }}
                title={c.clientName}
              >
                {c.eventType === 'funeral' && '🕯️'}
                {c.eventType === 'wedding' && '💒'}
                {c.eventType === 'longevity' && '👵'}
                {c.eventType === 'retail' && '🪑'}
                {displayTitle}
              </div>
            );
          })}
        </div>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
      
      {/* Calendar Header Controls */}
      <div className="glass" style={{ padding: '1.25rem 2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <CalendarIcon size={24} color="var(--primary)" />
          <h2 style={{ fontSize: '1.5rem', margin: 0 }}>Lịch Thi Công & Lắp Dựng</h2>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
          <button onClick={handlePrevMonth} className="btn btn-outline" style={{ padding: '0.4rem' }}>
            <ChevronLeft size={20} />
          </button>
          
          <h3 style={{ margin: 0, minWidth: '150px', textAlign: 'center', fontFamily: 'var(--font-serif)', fontSize: '1.3rem' }}>
            {monthNames[month]} - {year}
          </h3>

          <button onClick={handleNextMonth} className="btn btn-outline" style={{ padding: '0.4rem' }}>
            <ChevronRight size={20} />
          </button>
        </div>
      </div>

      {/* Main Grid Calendar */}
      <div className="glass" style={{ padding: '1.5rem', overflowX: 'auto' }}>
        <div style={{ minWidth: '700px' }}>
          {/* Weekday titles */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            textAlign: 'center',
            fontWeight: 'bold',
            borderBottom: '2px solid var(--border)',
            paddingBottom: '0.5rem',
            marginBottom: '0.5rem',
            color: 'var(--text-muted)'
          }}>
            <div>Chủ Nhật</div>
            <div>Thứ Hai</div>
            <div>Thứ Ba</div>
            <div>Thứ Tư</div>
            <div>Thứ Năm</div>
            <div>Thứ Sáu</div>
            <div>Thứ Bảy</div>
          </div>

          {/* Days Grid */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            gap: '1px',
            background: 'var(--border)'
          }}>
            {calendarCells}
          </div>
        </div>
      </div>

      {/* Detail Popup Modal */}
      {selectedContract && (
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
          <div className="glass-premium" style={{
            maxWidth: '650px',
            width: '100%',
            padding: '2rem',
            position: 'relative',
            maxHeight: '90vh',
            overflowY: 'auto'
          }}>
            <button
              onClick={() => setSelectedContract(null)}
              style={{
                position: 'absolute',
                top: '1rem',
                right: '1rem',
                border: 'none',
                background: 'transparent',
                fontSize: '1.5rem',
                cursor: 'pointer',
                color: 'var(--text-dark)'
              }}
            >
              ✕
            </button>

            {/* Header info */}
            <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', marginBottom: '1rem' }}>
              <span className={`badge ${getBadgeClass(selectedContract.eventType)}`} style={{ fontSize: '0.85rem' }}>
                {selectedContract.eventType === 'wedding' && '💒 Đám Cưới'}
                {selectedContract.eventType === 'funeral' && '🕯️ Đám Hiếu'}
                {selectedContract.eventType === 'longevity' && '👵 Mừng Thọ'}
                {selectedContract.eventType === 'retail' && '🪑 Thuê Lẻ'}
              </span>
              {selectedContract.isUrgent && (
                <span className="urgent-badge" style={{ fontSize: '0.75rem' }}>HỎA TỐC GẤP</span>
              )}
              <span className="badge" style={{ backgroundColor: 'rgba(0,0,0,0.05)', fontSize: '0.85rem' }}>
                {getStatusText(selectedContract.status)}
              </span>
            </div>

            <h3 style={{ fontSize: '1.8rem', color: 'var(--primary)', marginBottom: '1.5rem' }}>
              Chi Tiết Đơn: {selectedContract.clientName}
            </h3>

            {/* Content grid */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem', fontSize: '0.95rem' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                    <Phone size={16} color="var(--primary)" />
                    <strong>Điện thoại:</strong>
                  </div>
                  <a href={`tel:${selectedContract.clientPhone}`} style={{ color: 'var(--primary)', fontWeight: 'bold' }}>{selectedContract.clientPhone}</a>
                </div>

                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                    <CalendarIcon size={16} color="var(--primary)" />
                    <strong>Thời gian:</strong>
                  </div>
                  <span>{selectedContract.eventDate} đến {selectedContract.endDate}</span>
                </div>
              </div>

              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem' }}>
                  <MapPin size={16} color="var(--primary)" />
                  <strong>Địa chỉ thi công:</strong>
                </div>
                <span>{selectedContract.address}</span>
              </div>

              {/* Equipment lists */}
              <div style={{ borderTop: '1px solid var(--border)', paddingTop: '1rem' }}>
                <strong style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--primary)' }}>THIẾT BỊ ĐÃ THUÊ:</strong>
                <div style={{ background: 'rgba(0,0,0,0.02)', padding: '1rem', borderRadius: 'var(--radius-sm)' }}>
                  {selectedContract.items.map((item, index) => (
                    <div key={index} style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem', marginBottom: '0.3rem' }}>
                      <span>- {item.name}</span>
                      <strong>{item.quantity}</strong>
                    </div>
                  ))}
                  <div style={{ display: 'flex', justifyContent: 'space-between', borderTop: '1px solid rgba(0,0,0,0.05)', paddingTop: '0.5rem', marginTop: '0.5rem', fontWeight: 'bold' }}>
                    <span>Tổng tiền (cả vận chuyển):</span>
                    <span style={{ color: 'var(--primary)' }}>
                      {formatVND(
                        selectedContract.customPrice !== undefined
                          ? selectedContract.customPrice
                          : selectedContract.items.reduce((sum, item) => sum + item.quantity * item.price, 0) + selectedContract.shippingFee
                      )}
                    </span>
                  </div>
                </div>
              </div>

              {/* Crew assignment info */}
              <div style={{ borderTop: '1px solid var(--border)', paddingTop: '1rem' }}>
                <strong style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--primary)' }}>NHÂN CÔNG LẮP DỰNG:</strong>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginBottom: '0.5rem' }}>
                  {selectedContract.assignedLaborIds.length > 0 ? (
                    selectedContract.assignedLaborIds.map(lId => {
                      const lab = labors.find(l => l.id === lId);
                      return (
                        <span key={lId} className="badge" style={{ backgroundColor: 'rgba(212, 175, 55, 0.1)', color: 'var(--text-dark)', border: '1px solid var(--accent)' }}>
                          👤 {lab ? lab.name : lId}
                        </span>
                      );
                    })
                  ) : (
                    <span style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Chưa phân công thợ cho đám này.</span>
                  )}
                </div>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  Chi phí nhân công: <strong>{formatVND(selectedContract.laborCost)}</strong>
                </div>
              </div>

              {/* Special instructions */}
              {selectedContract.notes && (
                <div style={{ background: 'rgba(212,175,55,0.04)', borderLeft: '3px solid var(--accent)', padding: '0.8rem', fontSize: '0.85rem' }}>
                  <strong>Lưu ý:</strong> {selectedContract.notes}
                </div>
              )}
            </div>

            {/* Actions in footer */}
            <div style={{ display: 'flex', gap: '1rem', marginTop: '2rem', borderTop: '1px solid var(--border)', paddingTop: '1.25rem', justifyContent: 'flex-end' }}>
              <button
                onClick={() => {
                  setSelectedContract(null);
                  onEditContract(selectedContract);
                }}
                className="btn btn-outline"
                style={{ padding: '0.5rem 1rem', fontSize: '0.85rem' }}
              >
                <Edit size={16} /> Sửa Hợp Đồng
              </button>
              <button
                onClick={() => setSelectedContract(null)}
                className="btn btn-primary"
                style={{ padding: '0.5rem 1rem', fontSize: '0.85rem' }}
              >
                Đóng Lại
              </button>
            </div>
          </div>
        </div>
      )}
      
    </div>
  );
};
