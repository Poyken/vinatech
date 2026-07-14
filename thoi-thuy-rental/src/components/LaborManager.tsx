// src/components/LaborManager.tsx
import React, { useState } from 'react';
import { Users, Plus, Edit, Trash2, Phone, Clipboard, BadgeAlert, Award } from 'lucide-react';
import { Labor, getLabors, saveLabor, deleteLabor, getContracts, saveContract } from '../db/rentalStorage';

export const LaborManager: React.FC = () => {
  const [labors, setLabors] = useState<Labor[]>(getLabors());
  const [contracts, setContracts] = useState(getContracts());
  
  // Worker Form states
  const [isEditing, setIsEditing] = useState(false);
  const [workerId, setWorkerId] = useState('');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [role, setRole] = useState<'main' | 'helper'>('helper');
  const [salaryPerDay, setSalaryPerDay] = useState(300000);
  const [active, setActive] = useState(true);

  // Assignment states
  const [selectedContractId, setSelectedContractId] = useState('');
  const [selectedWorkerIds, setSelectedWorkerIds] = useState<string[]>([]);

  const handleSaveWorker = (e: React.FormEvent) => {
    e.preventDefault();
    const newWorker: Labor = {
      id: workerId || `l_${Date.now()}`,
      name,
      phone,
      role,
      salaryPerDay: Number(salaryPerDay),
      active
    };
    
    const updated = saveLabor(newWorker);
    setLabors(updated);
    resetForm();
  };

  const handleEditClick = (w: Labor) => {
    setIsEditing(true);
    setWorkerId(w.id);
    setName(w.name);
    setPhone(w.phone);
    setRole(w.role);
    setSalaryPerDay(w.salaryPerDay);
    setActive(w.active);
  };

  const handleDeleteClick = (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn xóa hồ sơ thợ này?')) {
      const updated = deleteLabor(id);
      setLabors(updated);
    }
  };

  const resetForm = () => {
    setIsEditing(false);
    setWorkerId('');
    setName('');
    setPhone('');
    setRole('helper');
    setSalaryPerDay(300000);
    setActive(true);
  };

  // Crew assignment trigger
  const handleAssignCrew = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedContractId) return;

    const contract = contracts.find(c => c.id === selectedContractId);
    if (contract) {
      // Calculate labor cost based on workers assigned:
      // total salary = sum of (salaryPerDay * 2 days of setup/dismantling)
      let totalCost = 0;
      selectedWorkerIds.forEach(id => {
        const worker = labors.find(l => l.id === id);
        if (worker) {
          totalCost += worker.salaryPerDay * 2;
        }
      });

      const updatedContract = {
        ...contract,
        assignedLaborIds: selectedWorkerIds,
        laborCost: totalCost > 0 ? totalCost : contract.laborCost
      };

      const updatedContracts = saveContract(updatedContract);
      setContracts(updatedContracts);
      alert('Đã phân công thợ và cập nhật bảng lương thành công!');
      setSelectedContractId('');
      setSelectedWorkerIds([]);
    }
  };

  const handleWorkerCheckboxChange = (wId: string, checked: boolean) => {
    if (checked) {
      setSelectedWorkerIds(prev => [...prev, wId]);
    } else {
      setSelectedWorkerIds(prev => prev.filter(id => id !== wId));
    }
  };

  const formatVND = (num: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  // Get active upcoming contracts that need workers
  const pendingContracts = contracts.filter(c => c.status !== 'completed');

  // Calculate salary summary for each worker (total wages earned based on contracts assigned)
  const getPayrollSummary = () => {
    return labors.map(worker => {
      let assignedCount = 0;
      let totalEarned = 0;
      
      contracts.forEach(c => {
        if (c.status !== 'pending' && c.assignedLaborIds.includes(worker.id)) {
          assignedCount += 1;
          totalEarned += worker.salaryPerDay * 2; // Assuming 2 days of work per contract
        }
      });

      return {
        ...worker,
        assignedCount,
        totalEarned
      };
    });
  };

  const payrollSummary = getPayrollSummary();

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      {/* Page Title */}
      <div className="glass" style={{ padding: '1.25rem 2rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        <Users size={24} color="var(--primary)" />
        <h2 style={{ fontSize: '1.5rem', margin: 0 }}>Điều Phối Nhân Lực & Bảng Lương</h2>
      </div>

      {/* Grid view splitting Form vs Table */}
      <div style={{ display: 'grid', gridTemplateColumns: '0.8fr 1.2fr', gap: '2rem' }}>
        
        {/* Worker Profile Form */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            {isEditing ? 'Sửa Hồ Sơ Thợ' : 'Thêm Thợ Mới'}
          </h3>
          
          <form onSubmit={handleSaveWorker} style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
            <div>
              <label style={{ fontSize: '0.9rem', fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Họ và tên thợ:</label>
              <input
                type="text"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ví dụ: Lê Văn Hải"
                style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              />
            </div>

            <div>
              <label style={{ fontSize: '0.9rem', fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Số điện thoại:</label>
              <input
                type="tel"
                required
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="Ví dụ: 0912345678"
                style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div>
                <label style={{ fontSize: '0.9rem', fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Vai trò:</label>
                <select
                  value={role}
                  onChange={(e) => setRole(e.target.value as any)}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                >
                  <option value="main">Thợ Chính (Lắp đặt chính)</option>
                  <option value="helper">Thợ Phụ (Vác đồ/Bê vác)</option>
                </select>
              </div>

              <div>
                <label style={{ fontSize: '0.9rem', fontWeight: 600, display: 'block', marginBottom: '0.3rem' }}>Lương / Ngày công:</label>
                <input
                  type="number"
                  required
                  step={50000}
                  value={salaryPerDay}
                  onChange={(e) => setSalaryPerDay(Number(e.target.value))}
                  style={{ padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
                />
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginTop: '0.5rem' }}>
              <input
                type="checkbox"
                id="worker_active"
                checked={active}
                onChange={(e) => setActive(e.target.checked)}
                style={{ width: '16px', height: '16px' }}
              />
              <label htmlFor="worker_active" style={{ fontSize: '0.9rem', fontWeight: 600, cursor: 'pointer' }}>Đang sẵn sàng làm việc (Hoạt động)</label>
            </div>

            <div style={{ display: 'flex', gap: '0.75rem', marginTop: '1rem' }}>
              <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>
                {isEditing ? 'Cập Nhật' : 'Lưu Hồ Sơ'}
              </button>
              {isEditing && (
                <button type="button" onClick={resetForm} className="btn btn-outline">
                  Hủy
                </button>
              )}
            </div>
          </form>
        </div>

        {/* Workers List Table */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            Hồ Sơ Nhân Sự Hiện Tại
          </h3>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.9rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--border)', textAlign: 'left', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Thợ</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Liên hệ</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Vai trò</th>
                  <th style={{ padding: '0.6rem 0.4rem' }}>Lương/Ngày</th>
                  <th style={{ padding: '0.6rem 0.4rem', textAlign: 'center' }}>Trạng thái</th>
                  <th style={{ padding: '0.6rem 0.4rem', textAlign: 'center' }}>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {labors.map(w => (
                  <tr key={w.id} style={{ borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
                    <td style={{ padding: '0.75rem 0.4rem', fontWeight: 600 }}>{w.name}</td>
                    <td style={{ padding: '0.75rem 0.4rem', color: 'var(--text-muted)' }}>
                      <a href={`tel:${w.phone}`} style={{ display: 'flex', alignItems: 'center', gap: '0.2rem' }}>
                        <Phone size={14} /> {w.phone}
                      </a>
                    </td>
                    <td style={{ padding: '0.75rem 0.4rem' }}>
                      <span className="badge" style={{
                        fontSize: '0.75rem',
                        backgroundColor: w.role === 'main' ? 'rgba(140,29,46,0.1)' : 'rgba(0,0,0,0.05)',
                        color: w.role === 'main' ? 'var(--primary)' : 'var(--text-dark)'
                      }}>
                        {w.role === 'main' ? '🏆 Thợ Chính' : '👷 Thợ Phụ'}
                      </span>
                    </td>
                    <td style={{ padding: '0.75rem 0.4rem', fontWeight: 'bold' }}>{formatVND(w.salaryPerDay)}</td>
                    <td style={{ padding: '0.75rem 0.4rem', textAlign: 'center' }}>
                      <span style={{
                        width: '8px',
                        height: '8px',
                        borderRadius: '50%',
                        display: 'inline-block',
                        backgroundColor: w.active ? '#4caf50' : '#f44336',
                        marginRight: '0.3rem'
                      }} />
                      {w.active ? 'Sẵn sàng' : 'Bận'}
                    </td>
                    <td style={{ padding: '0.75rem 0.4rem', textAlign: 'center' }}>
                      <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
                        <button onClick={() => handleEditClick(w)} className="btn btn-outline" style={{ padding: '0.3rem', borderRadius: '4px' }} title="Sửa">
                          <Edit size={14} />
                        </button>
                        {w.id !== 'l_bo_duc' && (
                          <button onClick={() => handleDeleteClick(w.id)} className="btn btn-outline" style={{ padding: '0.3rem', borderRadius: '4px', color: 'var(--danger)', borderColor: 'rgba(198,40,40,0.2)' }} title="Xóa">
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

      </div>

      {/* Grid: Crew Assignment Scheduler & Monthly Payroll Report */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '2rem' }}>
        
        {/* Crew Scheduler (Assign workers to contracts) */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            <Clipboard size={18} style={{ marginRight: '0.3rem', verticalAlign: 'middle' }} />
            Phân Công Lắp Dựng Cho Đám Sắp Diễn Ra
          </h3>

          <form onSubmit={handleAssignCrew} style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
            <div>
              <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.4rem' }}>Chọn Đám Cần Dựng:</label>
              <select
                required
                value={selectedContractId}
                onChange={(e) => {
                  setSelectedContractId(e.target.value);
                  const selectedC = contracts.find(c => c.id === e.target.value);
                  setSelectedWorkerIds(selectedC ? selectedC.assignedLaborIds : []);
                }}
                style={{ padding: '0.6rem', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', width: '100%', background: 'transparent', color: 'inherit' }}
              >
                <option value="">-- Chọn đám cần lắp đặt phông rạp --</option>
                {pendingContracts.map(c => {
                  let eventLabel = c.eventType === 'funeral' ? '🕯️ Đám hiếu' : c.eventType === 'wedding' ? '💒 Đám cưới' : '🎪 Sự kiện';
                  return (
                    <option key={c.id} value={c.id}>
                      [{c.eventDate}] {eventLabel} - {c.clientName} ({c.address}) - Cần khoảng {Math.ceil(c.items.reduce((acc, it) => acc + (it.itemId === 'rap_lon' ? it.quantity/20 : it.quantity*0.1), 2))} thợ
                    </option>
                  );
                })}
              </select>
            </div>

            {selectedContractId && (
              <div>
                <label style={{ fontWeight: 600, display: 'block', marginBottom: '0.5rem' }}>Chọn danh sách thợ phân công đi làm:</label>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.8rem', background: 'rgba(0,0,0,0.02)', padding: '1rem', borderRadius: 'var(--radius-sm)' }}>
                  {labors.map(w => (
                    <label key={w.id} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', padding: '0.25rem', fontSize: '0.9rem' }}>
                      <input
                        type="checkbox"
                        checked={selectedWorkerIds.includes(w.id)}
                        onChange={(e) => handleWorkerCheckboxChange(w.id, e.target.checked)}
                      />
                      <span>
                        <strong>{w.name}</strong> ({w.role === 'main' ? 'Thợ chính' : 'Thợ phụ'} - {formatVND(w.salaryPerDay)})
                      </span>
                    </label>
                  ))}
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'block', marginTop: '0.4rem' }}>
                  * Chi phí nhân công tính bằng tổng tiền ngày của thợ x 2 ngày làm việc (ngày lắp + ngày dọn dẹp).
                </span>
              </div>
            )}

            <button
              type="submit"
              disabled={!selectedContractId}
              className="btn btn-primary"
              style={{ padding: '0.6rem 1.2rem', width: '200px', alignSelf: 'flex-start' }}
            >
              Lưu Phân Công Thợ
            </button>
          </form>
        </div>

        {/* Monthly Payroll Summary report */}
        <div className="glass" style={{ padding: '2rem' }}>
          <h3 style={{ fontSize: '1.25rem', color: 'var(--primary)', marginBottom: '1.25rem', borderBottom: '1px solid var(--border)', paddingBottom: '0.4rem' }}>
            <Award size={18} style={{ marginRight: '0.3rem', verticalAlign: 'middle' }} />
            Thống Kê Công & Lương Tháng Này
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {payrollSummary.map(ps => (
              <div key={ps.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(0,0,0,0.05)', paddingBottom: '0.5rem' }}>
                <div>
                  <strong style={{ display: 'block', fontSize: '0.95rem' }}>{ps.name}</strong>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    Đã đi lắp: <strong>{ps.assignedCount} đám</strong> ({ps.assignedCount * 2} ngày công)
                  </span>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span style={{ display: 'block', fontWeight: 'bold', color: 'var(--primary)', fontSize: '1rem' }}>{formatVND(ps.totalEarned)}</span>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{ps.role === 'main' ? 'Lương chính' : 'Lương phụ'}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>

    </div>
  );
};
