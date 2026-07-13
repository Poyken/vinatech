// src/components/InventoryManager.tsx
import React, { useState } from 'react';
import { Package, Plus, Trash2, Edit, Save, X, DollarSign, Archive } from 'lucide-react';
import { InventoryItem, getInventory, saveInventoryItem, deleteInventoryItem } from '../db/rentalStorage';

export const InventoryManager: React.FC = () => {
  const [inventory, setInventory] = useState<InventoryItem[]>(getInventory());
  
  // Form states for adding/editing items
  const [isEditing, setIsEditing] = useState(false);
  const [itemId, setItemId] = useState('');
  const [name, setName] = useState('');
  const [category, setCategory] = useState<'tent' | 'table' | 'chair' | 'decor' | 'other'>('other');
  const [totalStock, setTotalStock] = useState(100);
  const [unit, setUnit] = useState('cái');
  const [unitPriceRetail, setUnitPriceRetail] = useState(10000);

  const resetForm = () => {
    setIsEditing(false);
    setItemId('');
    setName('');
    setCategory('other');
    setTotalStock(100);
    setUnit('cái');
    setUnitPriceRetail(10000);
  };

  const handleSaveItem = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Generate id if empty
    // e.g. "Đèn Chiếu Sáng" -> "den_chieu_sang"
    const generatedId = itemId || name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[đĐ]/g, 'd')
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '_') + `_${Date.now()}`;

    const newItem: InventoryItem = {
      id: itemId || generatedId,
      name,
      category,
      totalStock: Number(totalStock),
      unit,
      unitPriceRetail: Number(unitPriceRetail)
    };

    const updated = saveInventoryItem(newItem);
    setInventory(updated);
    resetForm();
    alert('Đã cập nhật danh mục thiết bị thành công!');
  };

  const handleEditClick = (item: InventoryItem) => {
    setIsEditing(true);
    setItemId(item.id);
    setName(item.name);
    setCategory(item.category);
    setTotalStock(item.totalStock);
    setUnit(item.unit);
    setUnitPriceRetail(item.unitPriceRetail);
  };

  const handleDeleteClick = (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn xóa thiết bị này khỏi danh mục? (Đơn hàng cũ đã đặt thiết bị này vẫn lưu trữ bình thường)')) {
      const updated = deleteInventoryItem(id);
      setInventory(updated);
    }
  };

  const getCategoryLabel = (cat: string) => {
    if (cat === 'tent') return '🎪 Phông rạp';
    if (cat === 'table') return '🍱 Bàn ăn';
    if (cat === 'chair') return '🪑 Ghế ngồi';
    if (cat === 'decor') return '🌸 Đồ trang trí';
    return '📦 Thiết bị khác';
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      {/* Header */}
      <div className="glass" style={{ padding: '1.25rem 2rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        <Package size={24} color="var(--primary)" />
        <h2 style={{ fontSize: '1.5rem', margin: 0 }}>Cấu Hình Giá & Thiết Bị Kho</h2>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '0.8fr 1.2fr', gap: '2rem' }}>
        
        {/* Add/Edit Form */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            {isEditing ? 'Sửa Thông Tin Thiết Bị' : 'Thêm Thiết Bị Mới'}
          </h3>

          <form onSubmit={handleSaveItem} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem', fontSize: '0.9rem' }}>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Tên thiết bị:</label>
              <input
                type="text"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ví dụ: Đèn LED pha sân khấu"
                style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Phân loại chính:</label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value as any)}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                >
                  <option value="tent">🎪 Phông rạp che</option>
                  <option value="table">🍱 Bàn tiệc</option>
                  <option value="chair">🪑 Ghế ngồi</option>
                  <option value="decor">🌸 Đồ trang trí (gia tiên/cổng)</option>
                  <option value="other">📦 Thiết bị khác</option>
                </select>
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Đơn vị tính:</label>
                <input
                  type="text"
                  required
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  placeholder="Ví dụ: cái, bộ, m², khung..."
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Tổng số lượng có (Kho):</label>
                <input
                  type="number"
                  required
                  value={totalStock}
                  onChange={(e) => setTotalStock(Math.max(0, Number(e.target.value)))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                />
              </div>

              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Đơn giá cho thuê lẻ:</label>
                <input
                  type="number"
                  required
                  step={1000}
                  value={unitPriceRetail}
                  onChange={(e) => setUnitPriceRetail(Math.max(0, Number(e.target.value)))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit', fontWeight: 'bold' }}
                />
              </div>
            </div>

            <div style={{ display: 'flex', gap: '0.75rem', marginTop: '1rem' }}>
              <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>
                {isEditing ? 'Cập Nhật Thiết Bị' : 'Thêm Vào Kho'}
              </button>
              {isEditing && (
                <button type="button" onClick={resetForm} className="btn btn-outline">
                  Hủy
                </button>
              )}
            </div>

          </form>
        </div>

        {/* Catalog Table list */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            Danh Sách Thiết Bị Của Cửa Hàng
          </h3>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--border)', textAlign: 'left', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Tên thiết bị</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Phân loại</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Tổng kho</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Đơn giá lẻ</th>
                  <th style={{ padding: '0.6rem 0.4rem', textAlign: 'center' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {inventory.map(item => (
                  <tr key={item.id} style={{ borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
                    <td style={{ padding: '0.7rem 0.4rem', fontWeight: 600 }}>{item.name}</td>
                    <td style={{ padding: '0.7rem 0.4rem', color: 'var(--text-muted)' }}>{getCategoryLabel(item.category)}</td>
                    <td style={{ padding: '0.7rem 0.4rem', fontWeight: 'bold' }}>
                      {item.totalStock} <span style={{ fontSize: '0.75rem', fontWeight: 'normal', color: 'var(--text-muted)' }}>{item.unit}</span>
                    </td>
                    <td style={{ padding: '0.7rem 0.4rem', fontWeight: 'bold', color: 'var(--primary)' }}>
                      {formatVND(item.unitPriceRetail)}
                    </td>
                    <td style={{ padding: '0.7rem 0.4rem', textAlign: 'center' }}>
                      <div style={{ display: 'flex', gap: '0.4rem', justifyContent: 'center' }}>
                        <button onClick={() => handleEditClick(item)} className="btn btn-outline" style={{ padding: '0.25rem', borderRadius: '4px' }} title="Sửa">
                          <Edit size={12} />
                        </button>
                        <button onClick={() => handleDeleteClick(item.id)} className="btn btn-outline" style={{ padding: '0.25rem', borderRadius: '4px', color: 'var(--danger)', borderColor: 'rgba(198,40,40,0.2)' }} title="Xóa">
                          <Trash2 size={12} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

      </div>

    </div>
  );
};
