// src/components/CostCalculator.tsx
import React, { useState, useEffect, useMemo } from 'react';
import { CalendarRange, Truck, Users, Sparkles, Check, AlertCircle, Copy, Printer, ShoppingBag } from 'lucide-react';
import { EventType, getInventory, InventoryItem } from '../db/rentalStorage';

interface CostCalculatorProps {
  preselectedPackageId?: string;
  onProceedToBooking: (calcData: {
    eventType: EventType;
    items: Array<{ itemId: string; name: string; quantity: number; price: number }>;
    shippingFee: number;
    laborCost: number;
    estimatedStaff: number;
    totalAmount: number;
  }) => void;
}

export const CostCalculator: React.FC<CostCalculatorProps> = ({
  preselectedPackageId,
  onProceedToBooking
}) => {
  const [eventType, setEventType] = useState<EventType>('wedding');
  
  // Custom states for standard events (Wedding, Funeral, Longevity)
  const [useLargeTent, setUseLargeTent] = useState(true);
  const [tentWidth, setTentWidth] = useState(4);
  const [tentLength, setTentLength] = useState(10);
  const [smallTentFrames, setSmallTentFrames] = useState(2);
  const [tableSets, setTableSets] = useState(8);
  const [chairType, setChairType] = useState<'ghe_tiffany' | 'ghe_nhua'>('ghe_tiffany');
  const [decorType, setDecorType] = useState<'gia_tien_hoa_lua' | 'gia_tien_hoa_tuoi' | 'none'>('gia_tien_hoa_lua');
  const [includeGate, setIncludeGate] = useState(true);
  const [fansCount, setFansCount] = useState(2);
  const [lightsCount, setLightsCount] = useState(1);
  const [distance, setDistance] = useState(5); // km
  const [isNarrowAlley, setIsNarrowAlley] = useState(false);

  // States for Retail Rentals
  const [retailQuantities, setRetailQuantities] = useState<Record<string, number>>({});

  const inventory = getInventory();

  // Preset Combo options for users to select quickly
  const applyPreset = (presetType: 'wedding_small' | 'wedding_large' | 'funeral_basic' | 'longevity_standard') => {
    if (presetType === 'wedding_small') {
      setEventType('wedding');
      setUseLargeTent(true);
      setTentWidth(4);
      setTentLength(10);
      setTableSets(5);
      setChairType('ghe_tiffany');
      setDecorType('gia_tien_hoa_lua');
      setIncludeGate(true);
      setFansCount(2);
      setLightsCount(1);
    } else if (presetType === 'wedding_large') {
      setEventType('wedding');
      setUseLargeTent(true);
      setTentWidth(6);
      setTentLength(20);
      setTableSets(15);
      setChairType('ghe_tiffany');
      setDecorType('gia_tien_hoa_tuoi');
      setIncludeGate(true);
      setFansCount(4);
      setLightsCount(2);
    } else if (presetType === 'funeral_basic') {
      setEventType('funeral');
      setUseLargeTent(false);
      setSmallTentFrames(2);
      setTableSets(10);
      setChairType('ghe_nhua');
      setDecorType('none');
      setIncludeGate(false);
      setFansCount(3);
      setLightsCount(1);
    } else if (presetType === 'longevity_standard') {
      setEventType('longevity');
      setUseLargeTent(false);
      setSmallTentFrames(3);
      setTableSets(8);
      setChairType('ghe_tiffany');
      setDecorType('gia_tien_hoa_lua');
      setIncludeGate(true);
      setFansCount(2);
      setLightsCount(1);
    }
  };

  // Handle preselected packages
  useEffect(() => {
    if (preselectedPackageId) {
      if (preselectedPackageId === 'pack_wedding_luxury') {
        applyPreset('wedding_large');
      } else if (preselectedPackageId === 'pack_wedding_traditional') {
        applyPreset('wedding_small');
      } else if (preselectedPackageId === 'pack_funeral_standard') {
        applyPreset('funeral_basic');
      } else if (preselectedPackageId === 'pack_longevity_traditional') {
        applyPreset('longevity_standard');
      } else if (preselectedPackageId === 'pack_retail_tiffany') {
        setEventType('retail');
        setRetailQuantities({ ghe_tiffany: 50 });
      } else if (preselectedPackageId === 'pack_retail_rap_lon') {
        setEventType('retail');
        setRetailQuantities({ rap_lon: 100 });
      }
    }
  }, [preselectedPackageId]);

  // Adjust defaults when eventType changes manually
  const handleEventTypeChange = (type: EventType) => {
    setEventType(type);
    if (type === 'funeral') {
      setChairType('ghe_nhua');
      setDecorType('none');
      setIncludeGate(false);
      setUseLargeTent(false);
    } else if (type === 'longevity') {
      setChairType('ghe_tiffany');
      setDecorType('gia_tien_hoa_lua');
      setIncludeGate(true);
    } else if (type === 'wedding') {
      setChairType('ghe_tiffany');
      setDecorType('gia_tien_hoa_lua');
      setIncludeGate(true);
    }
  };

  // Pricing Engine calculations - Optimized using useMemo
  const costCalculation = useMemo(() => {
    let items: Array<{ itemId: string; name: string; quantity: number; price: number }> = [];
    
    if (eventType !== 'retail') {
      // 1. Calculate Tent cost
      if (useLargeTent) {
        const area = tentWidth * tentLength;
        const pricePerM2 = inventory.find(i => i.id === 'rap_lon')?.unitPriceRetail || 60000;
        items.push({
          itemId: 'rap_lon',
          name: `Rạp không gian lớn (${tentWidth}m x ${tentLength}m)`,
          quantity: area,
          price: pricePerM2
        });
      } else {
        const pricePerFrame = inventory.find(i => i.id === 'rap_nho')?.unitPriceRetail || 800000;
        items.push({
          itemId: 'rap_nho',
          name: `Khung rạp sắt nhỏ (${smallTentFrames} khung)`,
          quantity: smallTentFrames,
          price: pricePerFrame
        });
      }

      // 2. Calculate Table & Chair cost
      const chairsCount = tableSets * 10;
      const tablePrice = inventory.find(i => i.id === 'ban_tron')?.unitPriceRetail || 150000;
      const chairPrice = inventory.find(i => i.id === chairType)?.unitPriceRetail || 5000;
      const chairName = chairType === 'ghe_tiffany' ? 'Ghế Tiffany nơ lụa' : 'Ghế nhựa đỏ có tựa';

      items.push({
        itemId: 'ban_tron',
        name: `Bàn tròn phủ khăn (${tableSets} bộ)`,
        quantity: tableSets,
        price: tablePrice
      });
      items.push({
        itemId: chairType,
        name: `${chairName} (${chairsCount} cái)`,
        quantity: chairsCount,
        price: chairPrice
      });

      // 3. Decoration Backdrops
      if (decorType !== 'none') {
        const decorPrice = inventory.find(i => i.id === decorType)?.unitPriceRetail || 3500000;
        const decorName = decorType === 'gia_tien_hoa_lua' ? 'Set Gia tiên hoa lụa cao cấp' : 'Set Gia tiên hoa tươi nghệ thuật';
        items.push({
          itemId: decorType,
          name: decorName,
          quantity: 1,
          price: decorPrice
        });
      }

      // 4. Floral Gate
      if (includeGate) {
        const gatePrice = inventory.find(i => i.id === 'cong_hoa')?.unitPriceRetail || 1000000;
        items.push({
          itemId: 'cong_hoa',
          name: 'Cổng hoa cưới/cổng chào',
          quantity: 1,
          price: gatePrice
        });
      }

      // 5. Utility items (Fans, Lights)
      if (fansCount > 0) {
        const fanPrice = inventory.find(i => i.id === 'quat_cong_nghiep')?.unitPriceRetail || 120000;
        items.push({
          itemId: 'quat_cong_nghiep',
          name: `Quạt hơi nước công nghiệp (${fansCount} cái)`,
          quantity: fansCount,
          price: fanPrice
        });
      }
      if (lightsCount > 0) {
        const lightPrice = inventory.find(i => i.id === 'he_thong_den')?.unitPriceRetail || 300000;
        items.push({
          itemId: 'he_thong_den',
          name: `Bộ đèn LED pha sân khấu (${lightsCount} bộ)`,
          quantity: lightsCount,
          price: lightPrice
        });
      }
    } else {
      // Retail mode: build items from retailQuantities state
      inventory.forEach(invItem => {
        const qty = retailQuantities[invItem.id] || 0;
        if (qty > 0) {
          items.push({
            itemId: invItem.id,
            name: invItem.name,
            quantity: qty,
            price: invItem.unitPriceRetail
          });
        }
      });
    }

    // Shipping calculation
    let shippingFee = 0;
    if (eventType !== 'retail' || Object.keys(retailQuantities).length > 0) {
      shippingFee = distance <= 5 ? 200000 : 200000 + (distance - 5) * 20000;
      if (distance === 0) shippingFee = 0;
    }

    // Labor calculation logic
    let estimatedStaff = 0;
    if (eventType !== 'retail') {
      let tentWeightVal = useLargeTent ? (tentWidth * tentLength) / 20 : smallTentFrames * 1.5;
      let tablesWeightVal = tableSets * 0.4;
      let decorWeightVal = decorType !== 'none' ? 1 : 0;
      
      estimatedStaff = Math.ceil(tentWeightVal + tablesWeightVal + decorWeightVal);
      if (isNarrowAlley) estimatedStaff += 1;
      if (estimatedStaff < 2 && eventType !== 'retail') estimatedStaff = 2;
    } else {
      let totalItemsCount = Object.values(retailQuantities).reduce((a, b) => a + b, 0);
      estimatedStaff = Math.max(1, Math.ceil(totalItemsCount / 100));
      if (totalItemsCount === 0) estimatedStaff = 0;
    }

    const laborCost = estimatedStaff * 300000 * 2;
    const itemsSubtotal = items.reduce((sum, item) => sum + item.quantity * item.price, 0);
    const totalAmount = itemsSubtotal + shippingFee;

    return {
      items,
      shippingFee,
      laborCost,
      estimatedStaff,
      itemsSubtotal,
      totalAmount
    };
  }, [
    eventType,
    useLargeTent,
    tentWidth,
    tentLength,
    smallTentFrames,
    tableSets,
    chairType,
    decorType,
    includeGate,
    fansCount,
    lightsCount,
    distance,
    isNarrowAlley,
    retailQuantities,
    inventory
  ]);

  const { items, shippingFee, laborCost, estimatedStaff, itemsSubtotal, totalAmount } = costCalculation;

  const handleRetailQtyChange = (itemId: string, val: number) => {
    setRetailQuantities(prev => ({
      ...prev,
      [itemId]: Math.max(0, val)
    }));
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  // Copy quote details to clipboard for Zalo sharing
  const copyQuoteToClipboard = () => {
    let text = `✨ BÁO GIÁ THUÊ PHÔNG RẠP THỜI THỦY ✨\n`;
    text += `--------------------------------------\n`;
    text += `Dịch vụ: ${
      eventType === 'wedding' ? 'Đám Cưới / Đám Hỏi' :
      eventType === 'funeral' ? 'Đám Hiếu (Kính cẩn)' :
      eventType === 'longevity' ? 'Mừng Thọ' : 'Thuê lẻ thiết bị'
    }\n`;
    text += `--------------------------------------\n`;
    
    items.forEach(item => {
      text += `+ ${item.name}: ${item.quantity} x ${formatVND(item.price)}\n`;
    });
    
    if (shippingFee > 0) {
      text += `+ Phí vận chuyển (${distance}km): ${formatVND(shippingFee)}\n`;
    }
    
    text += `--------------------------------------\n`;
    text += `💰 TỔNG CHI PHÍ BÁO GIÁ: ${formatVND(totalAmount)}\n`;
    text += `📞 Liên hệ Zalo/Hotline: 0987.654.321 để đặt cọc và xếp thợ.\n`;
    text += `Xin chân thành cảm ơn quý khách!`;

    navigator.clipboard.writeText(text).then(() => {
      alert('Đã sao chép nội dung báo giá! Bạn có thể dán (Paste) để gửi ngay qua Zalo/SMS.');
    }).catch(err => {
      console.error('Lỗi khi sao chép: ', err);
    });
  };

  // Trigger browser printing for receipt
  const triggerPrint = () => {
    window.print();
  };

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '2rem' }}>
      
      {/* Configuration Controls */}
      <div className="glass no-print" style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        <div>
          <h3 style={{ fontSize: '1.6rem', color: 'var(--primary)', borderBottom: '1px solid var(--border)', paddingBottom: '0.5rem', marginBottom: '1rem' }}>
            Thiết Lập Sự Kiện
          </h3>
          
          {/* Event type tabs */}
          <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
            {(['wedding', 'funeral', 'longevity', 'retail'] as const).map(type => {
              let label = 'Đám Cưới';
              if (type === 'funeral') label = 'Đám Hiếu (Gấp)';
              if (type === 'longevity') label = 'Mừng Thọ';
              if (type === 'retail') label = 'Thuê Lẻ';
              
              return (
                <button
                  key={type}
                  className={`btn ${eventType === type ? 'btn-primary' : 'btn-outline'}`}
                  onClick={() => handleEventTypeChange(type)}
                  style={{
                    padding: '0.4rem 1.2rem',
                    fontSize: '0.85rem',
                    borderRadius: '20px',
                    borderColor: type === 'funeral' && eventType !== 'funeral' ? 'var(--danger)' : ''
                  }}
                >
                  {type === 'funeral' && '🕯️ '}
                  {type === 'wedding' && '💒 '}
                  {type === 'longevity' && '👵 '}
                  {type === 'retail' && '🪑 '}
                  {label}
                </button>
              );
            })}
          </div>

          {/* Quick Preset Combos (Helpful for quick client choices) */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            background: 'rgba(212,175,55,0.06)',
            padding: '0.6rem 1rem',
            borderRadius: 'var(--radius-sm)',
            border: '1px solid var(--border-gold)',
            flexWrap: 'wrap'
          }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 'bold', color: 'var(--text-dark)' }}>Chọn nhanh Combo mẫu:</span>
            {eventType === 'wedding' && (
              <>
                <button onClick={() => applyPreset('wedding_small')} className="btn btn-outline" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem', borderRadius: '4px' }}>Cưới nhỏ (50 khách)</button>
                <button onClick={() => applyPreset('wedding_large')} className="btn btn-outline" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem', borderRadius: '4px' }}>Cưới lớn (150 khách)</button>
              </>
            )}
            {eventType === 'funeral' && (
              <button onClick={() => applyPreset('funeral_basic')} className="btn btn-outline" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem', borderRadius: '4px' }}>Hiếu cơ bản (100 khách)</button>
            )}
            {eventType === 'longevity' && (
              <button onClick={() => applyPreset('longevity_standard')} className="btn btn-outline" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem', borderRadius: '4px' }}>Mừng thọ tiêu chuẩn</button>
            )}
            {eventType === 'retail' && (
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Vui lòng chọn số lượng trực tiếp bên dưới.</span>
            )}
          </div>
        </div>

        {/* Funeral Urgent warning banner */}
        {eventType === 'funeral' && (
          <div style={{
            background: 'rgba(211, 47, 47, 0.06)',
            border: '1.2px solid var(--danger)',
            padding: '1rem',
            borderRadius: 'var(--radius-sm)',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '0.75rem',
            color: 'var(--danger)'
          }}>
            <AlertCircle size={22} style={{ flexShrink: 0, marginTop: '2px' }} />
            <div>
              <strong style={{ display: 'block', fontSize: '0.95rem', marginBottom: '0.2rem' }}>ĐƠN HÀNG HỎA TỐC ĐÁM HIẾU</strong>
              <span style={{ fontSize: '0.85rem', lineHeight: '1.4' }}>
                Hệ thống sẽ chuyển sang chế độ chuẩn bị nhanh, ưu tiên linh hoạt rạp nhỏ dễ dựng và kiểm tra gấp thợ rảnh lắp đặt trong ngày. Các thiết kế hoa rực rỡ và cổng chào cưới hỏi sẽ bị ẩn đi.
              </span>
            </div>
          </div>
        )}

        {/* Dynamic Controls based on selected type */}
        {eventType !== 'retail' ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            
            {/* Tents controls */}
            <div>
              <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.5rem' }}>Loại Rạp Che:</label>
              <div style={{ display: 'flex', gap: '1rem', marginBottom: '0.75rem' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', cursor: 'pointer' }}>
                  <input
                    type="radio"
                    checked={useLargeTent}
                    onChange={() => setUseLargeTent(true)}
                    disabled={eventType === 'funeral'}
                  />
                  <span>Rạp Không Gian Lớn (Mái vòm bạt)</span>
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', cursor: 'pointer' }}>
                  <input
                    type="radio"
                    checked={!useLargeTent}
                    onChange={() => setUseLargeTent(false)}
                  />
                  <span>Khung Rạp Sắt Nhỏ (Lắp ghép khung)</span>
                </label>
              </div>

              {useLargeTent ? (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', background: 'rgba(140,29,46,0.03)', padding: '1rem', borderRadius: 'var(--radius-sm)' }}>
                  <div>
                    <label style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'block' }}>Chiều rộng rạp (mét): {tentWidth}m</label>
                    <input
                      type="range"
                      min={4}
                      max={12}
                      step={2}
                      value={tentWidth}
                      onChange={(e) => setTentWidth(Number(e.target.value))}
                      style={{ width: '100%' }}
                    />
                  </div>
                  <div>
                    <label style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'block' }}>Chiều dài rạp (mét): {tentLength}m</label>
                    <input
                      type="range"
                      min={6}
                      max={40}
                      step={2}
                      value={tentLength}
                      onChange={(e) => setTentLength(Number(e.target.value))}
                      style={{ width: '100%' }}
                    />
                  </div>
                </div>
              ) : (
                <div style={{ background: 'rgba(140,29,46,0.03)', padding: '1rem', borderRadius: 'var(--radius-sm)' }}>
                  <label style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'block', marginBottom: '0.4rem' }}>Số lượng khung rạp sắt lắp ghép (mỗi khung 3m x 4m): {smallTentFrames} khung</label>
                  <input
                    type="number"
                    min={1}
                    max={10}
                    value={smallTentFrames}
                    onChange={(e) => setSmallTentFrames(Math.max(1, Number(e.target.value)))}
                    style={{ padding: '0.4rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100px' }}
                  />
                </div>
              )}
            </div>

            {/* Tables and chairs sets */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
              <div>
                <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.4rem' }}>Số Lượng Bàn Ghế (Mỗi bộ 1 bàn tròn + 10 ghế):</label>
                <input
                  type="number"
                  min={1}
                  max={60}
                  value={tableSets}
                  onChange={(e) => setTableSets(Math.max(1, Number(e.target.value)))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%' }}
                />
              </div>

              <div>
                <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.4rem' }}>Loại Ghế Ngồi:</label>
                <select
                  value={chairType}
                  onChange={(e) => setChairType(e.target.value as any)}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                >
                  <option value="ghe_tiffany">Ghế Tiffany Cao Cấp (Nơ Lụa)</option>
                  <option value="ghe_nhua">Ghế Nhựa Đỏ Có Tựa (Tiết Kiệm)</option>
                </select>
              </div>
            </div>

            {/* Decor & Gate (Only for Weddings/Longevity) */}
            {eventType !== 'funeral' && (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                <div>
                  <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.4rem' }}>Gói Gia Tiên (Bàn Thờ Gia Bảo):</label>
                  <select
                    value={decorType}
                    onChange={(e) => setDecorType(e.target.value as any)}
                    style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                  >
                    <option value="gia_tien_hoa_lua">Trang trí Gia tiên Hoa lụa</option>
                    <option value="gia_tien_hoa_tuoi">Trang trí Gia tiên Hoa tươi cao cấp</option>
                    <option value="none">Không thuê trang trí gia tiên</option>
                  </select>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', marginTop: '1.5rem' }}>
                  <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontWeight: 600 }}>
                    <input
                      type="checkbox"
                      checked={includeGate}
                      onChange={(e) => setIncludeGate(e.target.checked)}
                      style={{ width: '18px', height: '18px' }}
                    />
                    <span>Thuê thêm Cổng Hoa chào khách</span>
                  </label>
                </div>
              </div>
            )}

            {/* Utility accessories */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
              <div>
                <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.4rem' }}>Số lượng quạt hơi nước công nghiệp:</label>
                <input
                  type="number"
                  min={0}
                  max={10}
                  value={fansCount}
                  onChange={(e) => setFansCount(Math.max(0, Number(e.target.value)))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%' }}
                />
              </div>

              <div>
                <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.4rem' }}>Số bộ đèn LED sân khấu:</label>
                <input
                  type="number"
                  min={0}
                  max={6}
                  value={lightsCount}
                  onChange={(e) => setLightsCount(Math.max(0, Number(e.target.value)))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%' }}
                />
              </div>
            </div>

          </div>
        ) : (
          /* Retail Mode */
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '0.5rem' }}>
              Chọn số lượng thiết bị thuê lẻ cần thiết:
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem', maxHeight: '350px', overflowY: 'auto', paddingRight: '0.3rem' }}>
              {inventory.map(item => (
                <div key={item.id} style={{ display: 'grid', gridTemplateColumns: '2fr 1.2fr 1fr', alignItems: 'center', gap: '1rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.6rem' }}>
                  <span style={{ fontSize: '0.95rem', fontWeight: 500 }}>{item.name}</span>
                  <span style={{ fontSize: '0.85rem', color: 'var(--primary)', fontWeight: 'bold' }}>
                    {formatVND(item.unitPriceRetail)}/{item.unit}
                  </span>
                  <input
                    type="number"
                    min={0}
                    max={item.totalStock}
                    value={retailQuantities[item.id] || ''}
                    placeholder="0"
                    onChange={(e) => handleRetailQtyChange(item.id, Number(e.target.value))}
                    style={{ padding: '0.4rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%' }}
                  />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Logistics & Shipping Options */}
        <div style={{ borderTop: '1px solid var(--border)', paddingTop: '1.25rem', marginTop: '0.5rem' }}>
          <h4 style={{ fontSize: '1.1rem', marginBottom: '0.75rem', color: 'var(--primary)' }}>Vận chuyển & Thi công đặc thù:</h4>
          <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '1.5rem', alignItems: 'center' }}>
            <div>
              <label style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'block' }}>Khoảng cách vận chuyển (km): {distance} km</label>
              <input
                type="range"
                min={0}
                max={50}
                value={distance}
                onChange={(e) => setDistance(Number(e.target.value))}
                style={{ width: '100%' }}
              />
            </div>
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', cursor: 'pointer', fontSize: '0.9rem', fontWeight: 600 }}>
                <input
                  type="checkbox"
                  checked={isNarrowAlley}
                  onChange={(e) => setIsNarrowAlley(e.target.checked)}
                  style={{ width: '16px', height: '16px' }}
                />
                <span>Ngõ hẻm cực nhỏ (phụ thu công kéo xe)</span>
              </label>
            </div>
          </div>
        </div>

      </div>

      {/* Bill Receipt Preview */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        <div className="glass-premium print-receipt-only" style={{ padding: '2rem', display: 'flex', flexDirection: 'column', height: '100%' }}>
          
          {/* Header */}
          <div style={{ textAlign: 'center', borderBottom: '2px dashed var(--border)', paddingBottom: '1rem', marginBottom: '1.5rem' }}>
            <span style={{ fontSize: '0.85rem', textTransform: 'uppercase', letterSpacing: '0.1em', color: 'var(--accent)', fontWeight: 'bold' }}>Hóa Đơn Báo Giá Tạm Tính</span>
            <h4 style={{ fontSize: '1.8rem', color: 'var(--primary)', marginTop: '0.2rem' }}>Phông Rạp Thời Thủy</h4>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Mã báo giá: TT-{Math.floor(1000 + Math.random() * 9000)}</span>
          </div>

          {/* Bill Items */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '0.8rem', fontSize: '0.9rem' }}>
            {items.length > 0 ? (
              items.map((item, idx) => (
                <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(140,29,46,0.05)', paddingBottom: '0.4rem' }}>
                  <div>
                    <span style={{ display: 'block', fontWeight: 500 }}>{item.name}</span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                      {item.quantity} x {formatVND(item.price)}
                    </span>
                  </div>
                  <span style={{ fontWeight: 600 }}>{formatVND(item.quantity * item.price)}</span>
                </div>
              ))
            ) : (
              <span style={{ color: 'var(--text-muted)', textAlign: 'center', padding: '2rem 0' }}>Chưa chọn thiết bị nào</span>
            )}

            {/* Shipping row */}
            {shippingFee > 0 && (
              <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(140,29,46,0.05)', paddingBottom: '0.4rem' }}>
                <div>
                  <span style={{ display: 'block', fontWeight: 500 }}>Phí vận chuyển ({distance}km)</span>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    {distance <= 5 ? 'Gói cơ bản <= 5km' : 'Gói cơ bản + 20.000đ/km'}
                  </span>
                </div>
                <span style={{ fontWeight: 600 }}>{formatVND(shippingFee)}</span>
              </div>
            )}

            {/* Subtotal */}
            <div style={{ display: 'flex', justifyContent: 'space-between', borderTop: '2px solid var(--border)', paddingTop: '0.8rem', fontWeight: 'bold' }}>
              <span>Tổng tiền thiết bị & xe cộ:</span>
              <span style={{ color: 'var(--primary)' }}>{formatVND(itemsSubtotal + shippingFee)}</span>
            </div>
            
            {/* Staff information block - hidden when printing */}
            <div className="no-print" style={{
              background: 'rgba(212, 175, 55, 0.06)',
              border: '1px solid var(--border-gold)',
              padding: '1rem',
              borderRadius: 'var(--radius-sm)',
              marginTop: '1rem',
              display: 'flex',
              flexDirection: 'column',
              gap: '0.4rem'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--accent)' }}>
                <Users size={18} />
                <strong style={{ fontSize: '0.85rem', color: 'var(--text-dark)' }}>ĐIỀU PHỐI NHÂN LỰC DỰ KIẾN:</strong>
              </div>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                - Số thợ lắp dựng ước lượng: <strong style={{ color: 'var(--text-dark)' }}>{estimatedStaff} thợ</strong>
              </div>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                - Chi phí thợ dự toán (2 ngày): <strong style={{ color: 'var(--text-dark)' }}>{formatVND(laborCost)}</strong>
              </div>
            </div>
          </div>

          {/* Action buttons (Print, Copy Zalo, Book) */}
          <div style={{ marginTop: '1.5rem', borderTop: '2px dashed var(--border)', paddingTop: '1.5rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem' }}>
              <span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>TỔNG CHI PHÍ BÁO GIÁ:</span>
              <span style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--primary)' }}>{formatVND(totalAmount)}</span>
            </div>

            {/* Quick Share toolbar */}
            <div className="no-print" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', marginBottom: '1rem' }}>
              <button
                onClick={copyQuoteToClipboard}
                disabled={items.length === 0}
                className="btn btn-outline"
                style={{ padding: '0.5rem', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '0.3rem', borderRadius: 'var(--radius-sm)' }}
              >
                <Copy size={14} /> Sao chép gửi Zalo
              </button>
              <button
                onClick={triggerPrint}
                disabled={items.length === 0}
                className="btn btn-outline"
                style={{ padding: '0.5rem', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '0.3rem', borderRadius: 'var(--radius-sm)' }}
              >
                <Printer size={14} /> In tờ báo giá
              </button>
            </div>

            <button
              onClick={() => onProceedToBooking({
                eventType,
                items,
                shippingFee,
                laborCost,
                estimatedStaff,
                totalAmount
              })}
              disabled={items.length === 0}
              className="btn btn-primary no-print"
              style={{ width: '100%', padding: '1rem', fontSize: '1.1rem', borderRadius: 'var(--radius-md)' }}
            >
              Tiến Hành Đặt Lịch & Gửi Yêu Cầu
            </button>
          </div>
        </div>
      </div>
      
    </div>
  );
};
