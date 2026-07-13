// src/components/BookingForm.tsx
import React, { useState, useEffect, useMemo } from 'react';
import { Calendar, Phone, MapPin, Notebook, CheckCircle, AlertTriangle, ArrowLeft } from 'lucide-react';
import { EventType, Contract, saveContract, checkAvailabilityForDate } from '../db/rentalStorage';

interface BookingFormProps {
  calcData: {
    eventType: EventType;
    items: Array<{ itemId: string; name: string; quantity: number; price: number }>;
    shippingFee: number;
    laborCost: number;
    estimatedStaff: number;
    totalAmount: number;
  };
  onBack: () => void;
  onSuccess: () => void;
}

export const BookingForm: React.FC<BookingFormProps> = ({
  calcData,
  onBack,
  onSuccess
}) => {
  const [clientName, setClientName] = useState('');
  const [clientPhone, setClientPhone] = useState('');
  const [eventDate, setEventDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [address, setAddress] = useState('');
  const [notes, setNotes] = useState('');
  const [isBooked, setIsBooked] = useState(false);

  // Set default dates based on event type
  useEffect(() => {
    const today = new Date();
    if (calcData.eventType === 'funeral') {
      setEventDate(today.toISOString().split('T')[0]);
      
      const twoDaysLater = new Date();
      twoDaysLater.setDate(today.getDate() + 2);
      setEndDate(twoDaysLater.toISOString().split('T')[0]);
    } else {
      const threeDaysLater = new Date();
      threeDaysLater.setDate(today.getDate() + 3);
      setEventDate(threeDaysLater.toISOString().split('T')[0]);
      
      const fiveDaysLater = new Date();
      fiveDaysLater.setDate(today.getDate() + 5);
      setEndDate(fiveDaysLater.toISOString().split('T')[0]);
    }
  }, [calcData.eventType]);

  // Adjust end date if it is set prior to event date
  useEffect(() => {
    if (eventDate && (!endDate || endDate < eventDate)) {
      const d = new Date(eventDate);
      d.setDate(d.getDate() + 2);
      setEndDate(d.toISOString().split('T')[0]);
    }
  }, [eventDate]);

  // Stock checks memoized for maximum rendering speed
  const availabilityWarnings = useMemo(() => {
    if (!eventDate) return [];

    const checkResults = checkAvailabilityForDate(eventDate);
    const warnings: string[] = [];

    calcData.items.forEach(cItem => {
      const stockItem = checkResults.items.find(i => i.id === cItem.itemId);
      if (stockItem && stockItem.available < cItem.quantity) {
        warnings.push(
          `Thiết bị [${cItem.name}] chỉ còn trống ${stockItem.available} ${stockItem.unit} (Đơn hàng yêu cầu ${cItem.quantity} ${stockItem.unit}).`
        );
      }
    });

    return warnings;
  }, [eventDate, calcData.items, checkAvailabilityForDate]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const newContract: Contract = {
      id: `c_${Date.now()}`,
      clientName,
      clientPhone,
      eventType: calcData.eventType,
      eventDate,
      endDate: endDate || eventDate,
      address,
      notes: `${notes}${calcData.eventType === 'funeral' ? ' [ĐƠN HỎA TỐC]' : ''}`,
      items: calcData.items,
      shippingFee: calcData.shippingFee,
      laborCost: calcData.laborCost,
      status: calcData.eventType === 'funeral' ? 'setting_up' : 'pending',
      isUrgent: calcData.eventType === 'funeral',
      assignedLaborIds: []
    };

    saveContract(newContract);
    setIsBooked(true);
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto' }}>
      
      {/* 3-Step Visual Stepper */}
      <div className="stepper no-print" style={{ marginBottom: '2.5rem' }}>
        <div className="step-item completed">
          <div className="step-number">1</div>
          <span className="step-label">Báo Giá & Combo</span>
        </div>
        <div className={`step-item ${isBooked ? 'completed' : 'active'}`}>
          <div className="step-number">2</div>
          <span className="step-label">Nhập Thông Tin</span>
        </div>
        <div className={`step-item ${isBooked ? 'active' : ''}`}>
          <div className="step-number">3</div>
          <span className="step-label">Hoàn Tất</span>
        </div>
      </div>

      {isBooked ? (
        <div className="glass-premium" style={{ padding: '3rem 2rem', textAlign: 'center' }}>
          <CheckCircle size={72} color="var(--success)" style={{ margin: '0 auto 1.5rem auto' }} />
          <h3 style={{ fontSize: '2rem', color: 'var(--primary)', marginBottom: '1rem' }}>Đăng Ký Đặt Lịch Thành Công!</h3>
          <p style={{ color: 'var(--text-muted)', marginBottom: '2rem', fontSize: '0.95rem' }}>
            Yêu cầu dịch vụ của bạn đã được ghi nhận. Chủ cửa hàng Thời Thủy sẽ liên hệ lại với bạn qua số điện thoại để chốt hợp đồng và nhận tiền cọc trong vòng 30 phút.
          </p>

          <div className="glass" style={{ padding: '1.5rem', textAlign: 'left', marginBottom: '2rem', display: 'flex', flexDirection: 'column', gap: '0.6rem', fontSize: '0.95rem' }}>
            <div><strong>Khách hàng:</strong> {clientName}</div>
            <div><strong>Số điện thoại:</strong> {clientPhone}</div>
            <div><strong>Ngày thi công:</strong> {eventDate} đến {endDate}</div>
            <div><strong>Địa chỉ lắp đặt:</strong> {address}</div>
            <div><strong>Tổng kinh phí dự kiến:</strong> <span style={{ color: 'var(--primary)', fontWeight: 'bold' }}>{formatVND(calcData.totalAmount)}</span></div>
          </div>

          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button onClick={onSuccess} className="btn btn-primary">
              Quay Lại Trang Chủ
            </button>
            <a href={`https://zalo.me/0987654321`} target="_blank" rel="noreferrer" className="btn btn-outline" style={{ borderColor: '#0068ff', color: '#0068ff' }}>
              💬 Nhắn Zalo Báo Gấp
            </a>
          </div>
        </div>
      ) : (
        <div>
          <button onClick={onBack} className="btn btn-outline" style={{ marginBottom: '1.5rem', padding: '0.5rem 1rem', fontSize: '0.85rem' }}>
            <ArrowLeft size={16} /> Quay lại bảng tính giá
          </button>

          <div className="glass" style={{ padding: '2.5rem', display: 'flex', flexDirection: 'column', gap: '2rem' }}>
            <div>
              <h3 style={{ fontSize: '1.8rem', color: 'var(--primary)', borderBottom: '1px solid var(--border)', paddingBottom: '0.5rem', margin: 0 }}>
                Thông Tin Nhập Đơn Đặt Lịch
              </h3>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.4rem' }}>
                Phục vụ loại sự kiện: <strong>
                  {calcData.eventType === 'wedding' && 'Đám Cưới / Đám Hỏi'}
                  {calcData.eventType === 'funeral' && 'Đám Hiếu (Khẩn Cấp)'}
                  {calcData.eventType === 'longevity' && 'Mừng Thọ'}
                  {calcData.eventType === 'retail' && 'Thuê Lẻ Thiết Bị'}
                  {calcData.eventType === 'other' && 'Khác'}
                </strong>
              </p>
            </div>

            {/* Warnings banner */}
            {availabilityWarnings.length > 0 && calcData.eventType !== 'funeral' && (
              <div style={{
                background: 'rgba(239, 108, 0, 0.06)',
                border: '1.2px solid var(--warning)',
                padding: '1.25rem',
                borderRadius: 'var(--radius-sm)',
                color: 'var(--warning)',
                display: 'flex',
                flexDirection: 'column',
                gap: '0.5rem'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: 'bold' }}>
                  <AlertTriangle size={20} />
                  <span>CẢNH BÁO THỜI GIAN THỰC: THIẾT BỊ BỊ TRÙNG LỊCH/QUÁ TẢI KHO</span>
                </div>
                <ul style={{ paddingLeft: '1.5rem', fontSize: '0.85rem', lineHeight: '1.5' }}>
                  {availabilityWarnings.map((warning, i) => (
                    <li key={i}>{warning}</li>
                  ))}
                </ul>
                <span style={{ fontSize: '0.8rem', fontStyle: 'italic', marginTop: '0.2rem' }}>
                  * Lưu ý: Bạn vẫn có thể tiếp tục gửi yêu cầu. Chủ cửa hàng sẽ chủ động sắp xếp điều tiết thiết bị hoặc thuê thêm từ đối tác liên minh để đáp ứng.
                </span>
              </div>
            )}

            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Họ Tên Gia Chủ / Đại Diện:</label>
                  <div style={{ position: 'relative' }}>
                    <input
                      type="text"
                      required
                      value={clientName}
                      onChange={(e) => setClientName(e.target.value)}
                      placeholder="Ví dụ: Nguyễn Văn A"
                      style={{ paddingLeft: '2.5rem' }}
                    />
                    <CheckCircle size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                  </div>
                </div>

                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Số Điện Thoại:</label>
                  <div style={{ position: 'relative' }}>
                    <input
                      type="tel"
                      required
                      value={clientPhone}
                      onChange={(e) => setClientPhone(e.target.value)}
                      placeholder="Ví dụ: 0987654321"
                      style={{ paddingLeft: '2.5rem' }}
                    />
                    <Phone size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                  </div>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Ngày Lắp Đặt / Thi Công:</label>
                  <div style={{ position: 'relative' }}>
                    <input
                      type="date"
                      required
                      value={eventDate}
                      onChange={(e) => setEventDate(e.target.value)}
                      style={{ paddingLeft: '2.5rem' }}
                    />
                    <Calendar size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                  </div>
                </div>

                <div>
                  <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Ngày Tháo Dỡ / Thu Dọn:</label>
                  <div style={{ position: 'relative' }}>
                    <input
                      type="date"
                      required
                      value={endDate}
                      onChange={(e) => setEndDate(e.target.value)}
                      style={{ paddingLeft: '2.5rem' }}
                    />
                    <Calendar size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                  </div>
                </div>
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Địa Chỉ Nhận Hàng & Lắp Đặt Chi Tiết:</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="text"
                    required
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="Xóm/Thôn, Xã/Huyện, Tỉnh..."
                    style={{ paddingLeft: '2.5rem' }}
                  />
                  <MapPin size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Ghi Chú Vận Chuyển / Lắp Đặt:</label>
                <div style={{ position: 'relative' }}>
                  <textarea
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder="Ngõ ngách chật hẹp, thời gian lắp đặt cụ thể hoặc ghi chú tông màu..."
                    rows={3}
                    style={{ paddingLeft: '2.5rem', resize: 'vertical' }}
                  />
                  <Notebook size={16} style={{ position: 'absolute', left: '12px', top: '15px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              {/* Order Brief Summary Card */}
              <div style={{
                background: 'rgba(140,29,46,0.03)',
                border: '1px solid var(--border)',
                padding: '1.5rem',
                borderRadius: 'var(--radius-md)',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center'
              }}>
                <div>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block' }}>Hạng mục thuê: {calcData.items.length} mục</span>
                  <span style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>TỔNG CHI PHÍ BÁO GIÁ:</span>
                </div>
                <span style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--primary)' }}>{formatVND(calcData.totalAmount)}</span>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                style={{ padding: '1rem', fontSize: '1.1rem', borderRadius: 'var(--radius-md)', marginTop: '0.5rem' }}
              >
                {calcData.eventType === 'funeral' ? '⚡ Xác Nhận Đơn Đám Hiếu Hỏa Tốc' : '✓ Gửi Yêu Cầu Đặt Lịch'}
              </button>

            </form>
          </div>
        </div>
      )}
    </div>
  );
};
