// src/components/CatalogGallery.tsx
import React, { useState } from 'react';
import { Sparkles, CalendarRange, Heart, ArrowRight } from 'lucide-react';

interface CatalogItem {
  id: string;
  name: string;
  category: 'wedding' | 'funeral' | 'longevity' | 'retail';
  description: string;
  priceTag: string;
  features: string[];
  gradient: string;
  icon: string;
}

const CATALOG_ITEMS: CatalogItem[] = [
  {
    id: 'pack_wedding_luxury',
    name: 'Gói Cưới Hoàng Gia (Luxury Gold)',
    category: 'wedding',
    description: 'Phong cách cưới hoàng gia với tông màu trắng vàng chủ đạo, cổng hoa tươi nghệ thuật, ghế Tiffany thắt nơ sang trọng.',
    priceTag: 'Từ 25.000.000 VNĐ',
    features: ['Rạp không gian phủ voan cao cấp', 'Trang trí gia tiên hoa tươi 100%', '10 bộ bàn ghế Tiffany nơ lụa', 'Cổng hoa tươi đón khách cao 2.5m'],
    gradient: 'linear-gradient(135deg, #e6c875 0%, #b38b2d 100%)',
    icon: '👑'
  },
  {
    id: 'pack_wedding_traditional',
    name: 'Gói Cưới Hỷ Sự (Truyền Thống Đỏ)',
    category: 'wedding',
    description: 'Tone đỏ truyền thống biểu trưng cho sự may mắn và hạnh phúc lứa đôi. Rạp trang trí chữ Hỷ thêu tay tỉ mỉ.',
    priceTag: 'Từ 12.000.000 VNĐ',
    features: ['Rạp khung sắt xếp phủ lụa đỏ trắng', 'Gia tiên hoa lụa cao cấp tông đỏ', 'Bàn thờ tơ hồng, bộ lư đồng', '8 bộ bàn tròn phủ khăn voan đỏ'],
    gradient: 'linear-gradient(135deg, #f857a6 0%, #ff5858 100%)',
    icon: '囍'
  },
  {
    id: 'pack_funeral_standard',
    name: 'Gói Đám Hiếu Trang Nghiêm (Lắp Nhanh)',
    category: 'funeral',
    description: 'Hỗ trợ lắp dựng khẩn cấp trong vòng 2-4 giờ. Trang trí trang nghiêm với tông màu vàng-trắng-đen kính cẩn.',
    priceTag: 'Tính theo thực tế (Hỗ trợ giá đặc biệt)',
    features: ['Lắp dựng hỏa tốc trong 3 giờ', 'Khung rạp sắt nhỏ che nắng mưa', '100-300 ghế nhựa đỏ/xanh', 'Đèn pha chiếu sáng ban đêm'],
    gradient: 'linear-gradient(135deg, #4b5563 0%, #1f2937 100%)',
    icon: '🕯️'
  },
  {
    id: 'pack_longevity_traditional',
    name: 'Gói Mừng Thọ Bách Niên Giai Lão',
    category: 'longevity',
    description: 'Dành riêng cho lễ mừng thọ các cụ ông cụ bà. Phông nền đỏ thêu nổi chữ THỌ lớn mang tài lộc và sức khỏe.',
    priceTag: 'Từ 8.000.000 VNĐ',
    features: ['Backdrop chữ THỌ sơn son thếp vàng', 'Trang trí tông đỏ - vàng ấm cúng', 'Ghế phủ áo thêu chữ Thọ', 'Hệ thống quạt hơi nước'],
    gradient: 'linear-gradient(135deg, #800020 0%, #4a0010 100%)',
    icon: '👵'
  },
  {
    id: 'pack_retail_tiffany',
    name: 'Thuê Lẻ Ghế Tiffany Cao Cấp',
    category: 'retail',
    description: 'Cho thuê lẻ ghế Tiffany làm tiệc ngoài trời, đính kèm nơ lụa thắt hoa nhiều màu sắc.',
    priceTag: '25.000 VNĐ / cái / ngày',
    features: ['Chất liệu sắt sơn tĩnh điện cao cấp', 'Kèm nệm bọc da êm ái', 'Hỗ trợ thắt nơ lụa theo màu yêu cầu', 'Nhận đơn từ 20 cái trở lên'],
    gradient: 'linear-gradient(135deg, #5c258d 0%, #4389a2 100%)',
    icon: '🪑'
  },
  {
    id: 'pack_retail_rap_lon',
    name: 'Thuê Lẻ Rạp Không Gian Lớn',
    category: 'retail',
    description: 'Khung rạp sắt cường lực, khẩu độ lớn phù hợp cho tiệc cưới ngoài trời đông khách hoặc sự kiện địa phương.',
    priceTag: '60.000 VNĐ / m² / ngày',
    features: ['Nhôm định hình chịu lực tốt', 'Bạt chống thấm cao cấp', 'Chiều rộng linh hoạt từ 6m đến 12m', 'Bao gồm lắp đặt và tháo dỡ'],
    gradient: 'linear-gradient(135deg, #11998e 0%, #38ef7d 100%)',
    icon: '🎪'
  }
];

interface CatalogGalleryProps {
  onSelectPackage: (packageId: string) => void;
}

export const CatalogGallery: React.FC<CatalogGalleryProps> = ({ onSelectPackage }) => {
  const [filter, setFilter] = useState<'all' | 'wedding' | 'funeral' | 'longevity' | 'retail'>('all');

  const filteredItems = CATALOG_ITEMS.filter(item => {
    if (filter === 'all') return true;
    return item.category === filter;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      {/* Intro Banner */}
      <div className="glass-premium" style={{
        padding: '3rem 2rem',
        textAlign: 'center',
        background: 'linear-gradient(rgba(140,29,46,0.03), rgba(212,175,55,0.03))'
      }}>
        <h2 style={{ fontSize: '2.4rem', fontFamily: 'var(--font-serif)', color: 'var(--primary)' }}>
          Mẫu Thiết Kế Phông Rạp & Trang Trí
        </h2>
        <p style={{ maxWidth: '700px', margin: '1rem auto 0 auto', color: 'var(--text-muted)' }}>
          Chúng tôi mang đến các dịch vụ lắp đặt phông rạp chất lượng cao, phục vụ từ đám hỏi, đám cưới lộng lẫy đến đám tang trang nghiêm, đám thọ ấm áp và cung cấp thuê lẻ bàn ghế giá tốt nhất Bắc Ninh - Bắc Giang.
        </p>
      </div>

      {/* Filter Tabs */}
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        gap: '0.75rem',
        flexWrap: 'wrap'
      }}>
        {(['all', 'wedding', 'funeral', 'longevity', 'retail'] as const).map(cat => {
          let label = 'Tất cả';
          if (cat === 'wedding') label = '💒 Đám Cưới & Đám Hỏi';
          if (cat === 'funeral') label = '🕯️ Đám Hiếu (Hỏa Tốc)';
          if (cat === 'longevity') label = '👵 Mừng Thọ / Lên Lão';
          if (cat === 'retail') label = '🪑 Thuê Thiết Bị Lẻ';

          return (
            <button
              key={cat}
              onClick={() => setFilter(cat)}
              className={`btn ${filter === cat ? 'btn-primary' : 'btn-outline'}`}
              style={{
                borderRadius: '30px',
                padding: '0.5rem 1.2rem',
                fontSize: '0.85rem'
              }}
            >
              {label}
            </button>
          );
        })}
      </div>

      {/* Grid List */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(360px, 1fr))',
        gap: '2rem',
        marginTop: '1rem'
      }}>
        {filteredItems.map(item => (
          <div
            key={item.id}
            className="glass"
            style={{
              display: 'flex',
              flexDirection: 'column',
              borderRadius: 'var(--radius-md)',
              overflow: 'hidden',
              transition: 'var(--transition)',
              cursor: 'pointer'
            }}
            onMouseOver={(e) => {
              e.currentTarget.style.transform = 'translateY(-5px)';
              e.currentTarget.style.boxShadow = 'var(--shadow-lg)';
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'var(--glass-shadow)';
            }}
            onClick={() => onSelectPackage(item.id)}
          >
            {/* Styled Header Card */}
            <div style={{
              height: '160px',
              background: item.gradient,
              padding: '1.5rem',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              color: 'white',
              position: 'relative'
            }}>
              <span style={{ fontSize: '3rem', alignSelf: 'flex-end', opacity: 0.9 }}>
                {item.icon}
              </span>
              <div>
                <span style={{
                  fontSize: '0.75rem',
                  textTransform: 'uppercase',
                  fontWeight: 'bold',
                  background: 'rgba(255, 255, 255, 0.25)',
                  padding: '0.2rem 0.6rem',
                  borderRadius: '10px'
                }}>
                  {item.category === 'wedding' && 'Cưới Hỏi'}
                  {item.category === 'funeral' && 'Đám Hiếu'}
                  {item.category === 'longevity' && 'Mừng Thọ'}
                  {item.category === 'retail' && 'Thuê Lẻ'}
                </span>
                <h3 style={{ margin: '0.5rem 0 0 0', fontSize: '1.4rem', color: 'white' }}>
                  {item.name}
                </h3>
              </div>
            </div>

            {/* Card Content */}
            <div style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', flex: 1 }}>
              <p style={{
                fontSize: '0.9rem',
                color: 'var(--text-muted)',
                marginBottom: '1rem',
                flex: 1
              }}>
                {item.description}
              </p>

              <div style={{ marginBottom: '1.25rem' }}>
                <span style={{ fontSize: '0.8rem', fontWeight: 'bold', color: 'var(--primary)', display: 'block', marginBottom: '0.4rem' }}>
                  HẠNG MỤC CHÍNH:
                </span>
                <ul style={{ listStyleType: 'none', paddingLeft: 0 }}>
                  {item.features.map((f, i) => (
                    <li key={i} style={{
                      fontSize: '0.85rem',
                      color: 'var(--text-dark)',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.4rem',
                      marginBottom: '0.2rem'
                    }}>
                      <span style={{ color: 'var(--accent)' }}>✦</span> {f}
                    </li>
                  ))}
                </ul>
              </div>

              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                borderTop: '1px solid var(--border)',
                paddingTop: '1rem',
                marginTop: 'auto'
              }}>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block' }}>GIÁ DỰ KIẾN</span>
                  <span style={{ fontSize: '1.1rem', fontWeight: 'bold', color: 'var(--primary)' }}>{item.priceTag}</span>
                </div>
                <button
                  className="btn btn-outline"
                  style={{
                    padding: '0.4rem 0.8rem',
                    fontSize: '0.8rem',
                    borderRadius: '20px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.25rem'
                  }}
                >
                  Đặt Ngay <ArrowRight size={14} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
