// src/components/Navigation.tsx
import { Sparkles, Calendar, Users, ClipboardList, ShieldAlert, Sun, Moon, Home, Package } from 'lucide-react';

interface NavigationProps {
  currentTab: string;
  setCurrentTab: (tab: string) => void;
  isAdminMode: boolean;
  setIsAdminMode: (admin: boolean) => void;
  isDarkMode: boolean;
  setIsDarkMode: (dark: boolean) => void;
}

export const Navigation: React.FC<NavigationProps> = ({
  currentTab,
  setCurrentTab,
  isAdminMode,
  setIsAdminMode,
  isDarkMode,
  setIsDarkMode
}) => {
  return (
    <header className="glass" style={{
      position: 'sticky',
      top: 0,
      zIndex: 100,
      padding: '1rem 2rem',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      borderRadius: '0 0 var(--radius-md) var(--radius-md)',
      marginBottom: '1rem'
    }}>
      {/* Logo */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        <div style={{
          background: 'var(--primary)',
          color: 'white',
          width: '40px',
          height: '40px',
          borderRadius: '50%',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          fontSize: '1.4rem',
          fontWeight: 'bold',
          boxShadow: '0 4px 10px rgba(140, 29, 46, 0.2)'
        }}>
          囍
        </div>
        <div>
          <h1 style={{
            fontSize: '1.3rem',
            margin: 0,
            color: 'var(--primary)',
            fontWeight: 800,
            letterSpacing: '0.03em'
          }}>
            Phông Rạp Thời Thủy
          </h1>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block', marginTop: '-4px' }}>
            Rạp Sự Kiện, Đám Cưới, Đám Hiếu Hỏa Tốc
          </span>
        </div>
      </div>

      {/* Nav Menu */}
      <nav style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
        <button
          className={`btn ${currentTab === 'calculator' ? 'btn-primary' : 'btn-outline'}`}
          onClick={() => setCurrentTab('calculator')}
          style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
        >
          <Home size={16} />
          <span>Báo Giá & Đặt Lịch</span>
        </button>

        <button
          className={`btn ${currentTab === 'catalog' ? 'btn-primary' : 'btn-outline'}`}
          onClick={() => setCurrentTab('catalog')}
          style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
        >
          <Sparkles size={16} />
          <span>Mẫu Phông Rạp</span>
        </button>

        {isAdminMode && (
          <>
            <button
              className={`btn ${currentTab === 'calendar' ? 'btn-primary' : 'btn-outline'}`}
              onClick={() => setCurrentTab('calendar')}
              style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
            >
              <Calendar size={16} />
              <span>Lịch Thi Công</span>
            </button>

            <button
              className={`btn ${currentTab === 'dashboard' ? 'btn-primary' : 'btn-outline'}`}
              onClick={() => setCurrentTab('dashboard')}
              style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
            >
              <ClipboardList size={16} />
              <span>Đơn Hàng & Kho</span>
            </button>

            <button
              className={`btn ${currentTab === 'inventory' ? 'btn-primary' : 'btn-outline'}`}
              onClick={() => setCurrentTab('inventory')}
              style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
            >
              <Package size={16} />
              <span>Giá & Thiết Bị</span>
            </button>

            <button
              className={`btn ${currentTab === 'labor' ? 'btn-primary' : 'btn-outline'}`}
              onClick={() => setCurrentTab('labor')}
              style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
            >
              <Users size={16} />
              <span>Quản Lý Thợ</span>
            </button>
          </>
        )}
      </nav>

      {/* Toolbar Controls */}
      <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
        {/* Dark Mode Toggle */}
        <button
          onClick={() => setIsDarkMode(!isDarkMode)}
          style={{
            background: 'transparent',
            border: 'none',
            cursor: 'pointer',
            padding: '0.5rem',
            color: 'var(--text-dark)',
            display: 'flex',
            alignItems: 'center',
            borderRadius: '50%',
            transition: 'var(--transition)'
          }}
          title={isDarkMode ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối"}
          onMouseOver={(e) => e.currentTarget.style.backgroundColor = 'rgba(140, 29, 46, 0.05)'}
          onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
        >
          {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
        </button>

        {/* Admin Toggle */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
          padding: '0.4rem 0.8rem',
          borderRadius: '20px',
          border: '1px dashed var(--accent)',
          background: isAdminMode ? 'rgba(212, 175, 55, 0.08)' : 'transparent'
        }}>
          <ShieldAlert size={16} color="var(--accent)" />
          <span style={{ fontSize: '0.85rem', fontWeight: 600 }}>Chủ Cửa Hàng</span>
          <label style={{
            position: 'relative',
            display: 'inline-block',
            width: '40px',
            height: '22px',
            cursor: 'pointer'
          }}>
            <input
              type="checkbox"
              checked={isAdminMode}
              onChange={(e) => {
                setIsAdminMode(e.target.checked);
                if (e.target.checked) {
                  // switch to calendar by default when admin mode turns on
                  setCurrentTab('calendar');
                } else {
                  setCurrentTab('calculator');
                }
              }}
              style={{ opacity: 0, width: 0, height: 0 }}
            />
            <span style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: '#ccc',
              transition: '.4s',
              borderRadius: '34px'
            }} className="slider-round">
              <span style={{
                position: 'absolute',
                content: '""',
                height: '16px',
                width: '16px',
                left: isAdminMode ? '21px' : '3px',
                bottom: '3px',
                backgroundColor: 'white',
                transition: '.4s',
                borderRadius: '50%',
                boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
              }} />
            </span>
          </label>
        </div>
      </div>
      
      <style>{`
        input:checked + .slider-round {
          background-color: var(--primary) !important;
        }
      `}</style>
    </header>
  );
};
