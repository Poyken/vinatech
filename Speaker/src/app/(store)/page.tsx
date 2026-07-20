import React from 'react';
import Link from 'next/link';
import { productService } from '../../services/productService';
import { categoryService } from '../../services/categoryService';
import ProductCard from '../../components/ProductCard';
import SoundQuizWidget from '../../components/SoundQuizWidget';
import { Sparkles, Shield, Truck, Zap, Headphones, Speaker, Tv, Smartphone, Volume2, Music4 } from 'lucide-react';

export const revalidate = 0; // Fresh data on reload

const getCategoryIcon = (id: string) => {
  switch (id) {
    case 'cat-bookshelf':
      return <Speaker className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
    case 'cat-floorstanding':
      return <Volume2 className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
    case 'cat-bluetooth':
      return <Smartphone className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
    case 'cat-soundbar':
      return <Tv className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
    case 'cat-monitor':
      return <Music4 className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
    default:
      return <Speaker className="w-5 h-5 text-zinc-400 group-hover:text-primary transition-colors" />;
  }
};

export default async function HomePage() {
  const categories = await categoryService.getCategories();
  const allProducts = await productService.getProducts();
  const featuredProducts = allProducts.filter((p) => p.rating >= 4.7).slice(0, 4);

  const benefits = [
    { icon: Truck, title: 'Vận chuyển hỏa tốc', desc: 'Miễn phí giao hàng toàn quốc. Đóng gói 3 lớp bảo vệ chuyên dụng chống va đập.' },
    { icon: Shield, title: 'Bảo hành chính hãng', desc: 'Cam kết loa chính hãng 100%. Bảo hành 1 đổi 1 trong 30 ngày nếu có lỗi nhà sản xuất.' },
    { icon: Zap, title: 'Lắp đặt chuyên nghiệp', desc: 'Đội ngũ kỹ thuật hỗ trợ căn chỉnh âm hình, tối ưu góc nghe trực tiếp tại nhà.' },
  ];

  const brands = [
    { name: 'JBL', text: 'Chất Âm Mỹ Uy Lực', image: 'https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=400&auto=format&fit=crop' },
    { name: 'Marshall', text: 'Huyền Thoại Retro & Rock', image: 'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?q=80&w=400&auto=format&fit=crop' },
    { name: 'KEF', text: 'Đồng Trục Anh Quốc Đột Phá', image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=400&auto=format&fit=crop' },
    { name: 'Klipsch', text: 'Điện Ảnh Hoa Kỳ Cổ Điển', image: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=400&auto=format&fit=crop' },
    { name: 'KRK', text: 'Chuẩn Mực Kiểm Âm Vàng', image: 'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=400&auto=format&fit=crop' },
    { name: 'Yamaha', text: 'Độ Trung Thực Tuyệt Đối', image: 'https://images.unsplash.com/photo-1598653222000-6b7b7a552625?q=80&w=400&auto=format&fit=crop' },
  ];

  return (
    <div className="w-full flex flex-col items-center">
      {/* 1. HERO SECTION */}
      <section className="relative w-full min-h-[90vh] flex items-center justify-center overflow-hidden pt-12 bg-background">
        {/* Glow Radial Gradients */}
        <div className="absolute top-1/4 left-1/4 -translate-x-1/2 -translate-y-1/2 w-[35rem] h-[35rem] rounded-full bg-orange-500/5 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 translate-x-1/2 translate-y-1/2 w-[30rem] h-[30rem] rounded-full bg-amber-500/3 blur-[100px] pointer-events-none" />
        
        {/* Grid Background */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--border)_1px,transparent_1px),linear-gradient(to_bottom,var(--border)_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)] opacity-40 dark:opacity-50" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full py-12 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative z-10">
          {/* Left Text Column */}
          <div className="lg:col-span-7 space-y-6 text-left">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-input-bg border border-border rounded-full text-xs font-bold text-primary tracking-wide shadow-sm animate-fade-in-up stagger-1">
              <Sparkles className="w-3.5 h-3.5" />
              Công Nghệ Âm Thanh Mới Nhất 2026
            </div>
            
            <h1 className="text-4xl sm:text-6xl font-black tracking-tight leading-none text-foreground uppercase animate-fade-in-up stagger-2">
              Âm Thanh Tuyệt Mỹ <br />
              <span className="text-primary">Trong Không Gian</span> <br />
              Đẳng Cấp
            </h1>
            
            <p className="text-muted-text text-base sm:text-lg max-w-xl leading-relaxed animate-fade-in-up stagger-3">
              Trải nghiệm các dòng loa Hi-Fi, loa cột gia đình, và loa kiểm âm phòng thu chính hãng từ các thương hiệu hàng đầu thế giới với ưu đãi độc quyền tại Poyken Sound.
            </p>
            
            <div className="flex flex-wrap gap-4 pt-2 animate-fade-in-up stagger-4">
              <Link
                href="/catalog"
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-extrabold tracking-wide rounded-full hover:shadow-lg hover:shadow-primary/20 transition-all hover:scale-105 active:scale-95 text-center flex items-center gap-2 justify-center shadow-md shadow-primary/10 btn-premium"
              >
                <Headphones className="w-5 h-5" />
                Khám Phá Cửa Hàng
              </Link>
              <a
                href="#benefits"
                className="px-8 py-4 bg-input-bg hover:bg-card-hover text-foreground font-bold border border-border rounded-full transition-all text-center shadow-sm hover-glow"
              >
                Tại Sao Chọn Chúng Tôi?
              </a>
            </div>
          </div>

          {/* Right Sound wave graphics */}
          <div className="lg:col-span-5 flex flex-col items-center justify-center relative animate-fade-in-up stagger-3">
            <div className="w-72 h-72 sm:w-96 sm:h-96 rounded-full border-4 border-border flex items-center justify-center p-6 relative animate-float animate-glow-slow shadow-inner bg-muted-bg/30">
              {/* Spinning record background */}
              <div className="absolute inset-0 rounded-full border border-dashed border-border/80 animate-spin-slow" style={{ animationDuration: '20s' }} />
              <div className="absolute inset-10 rounded-full border border-border/50" />
              <div className="absolute inset-20 rounded-full border border-border/80" />
              
              {/* Inner Glowing Speaker Core */}
              <div className="w-full h-full rounded-full bg-gradient-to-tr from-card via-card to-background border border-border flex flex-col items-center justify-center shadow-lg relative overflow-hidden group animate-pulse-subtle">
                <div className="absolute inset-0 bg-gradient-to-tr from-primary/5 to-transparent group-hover:from-primary/10 transition-all" />
                
                {/* Real Spinning Speaker Driver Image */}
                <div className="w-24 h-24 sm:w-32 sm:h-32 rounded-full overflow-hidden border-2 border-border/80 shadow-md relative z-10 flex-shrink-0 group-hover:scale-110 transition-transform duration-700">
                  <img 
                    src="https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop" 
                    alt="Speaker Driver Core" 
                    className="w-full h-full object-cover scale-110 animate-spin-slow"
                    style={{ animationDuration: '15s' }}
                  />
                </div>
                
                {/* CSS Animated Soundwave Bars */}
                <div className="flex items-end justify-center h-10 mt-4 gap-0.5 z-10">
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.1s', height: '15px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.4s', height: '35px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.2s', height: '24px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.6s', height: '40px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.3s', height: '18px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.5s', height: '30px' }} />
                  <div className="sound-bar animate-wave" style={{ animationDelay: '0.1s', height: '22px' }} />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 2. BRANDS HIGHLIGHT */}
      <section className="w-full py-16 bg-muted-bg/20 border-y border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <p className="text-center text-xs font-bold uppercase tracking-widest text-muted-text mb-8 animate-fade-in-up stagger-1">
            THƯƠNG HIỆU PHÂN PHỐI ĐỘC QUYỀN
          </p>
          <div className="grid grid-cols-2 md:grid-cols-6 gap-6 animate-fade-in-up stagger-2">
            {brands.map((brand) => (
              <Link 
                key={brand.name}
                href={`/catalog?brand=${brand.name}`}
                className="relative h-28 rounded-2xl overflow-hidden group border border-border shadow-sm hover-glow flex flex-col justify-end"
              >
                {/* Background Brand Image */}
                <img 
                  src={brand.image} 
                  alt={brand.name} 
                  className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
                />
                
                {/* Dark Vignette Overlay */}
                <div className="absolute inset-0 bg-gradient-to-t from-stone-950/90 via-stone-950/40 to-transparent transition-opacity duration-300" />
                
                {/* Text contents */}
                <div className="relative p-4 z-10 text-left">
                  <h4 className="text-white font-black text-sm sm:text-base tracking-wider uppercase leading-none group-hover:text-primary transition-colors">
                    {brand.name}
                  </h4>
                  <p className="text-[9px] text-stone-300 font-bold uppercase tracking-widest mt-1">
                    {brand.text}
                  </p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* 3. CATEGORIES SECTION */}
      <section className="w-full py-20 bg-background">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-4 animate-fade-in-up stagger-1">
            <div className="text-left">
              <span className="text-xs font-black uppercase text-primary tracking-widest">PHÂN LOẠI THIẾT BỊ</span>
              <h2 className="text-3xl font-extrabold text-foreground uppercase mt-1">DÒNG SẢN PHẨM PHÙ HỢP</h2>
            </div>
            <Link 
              href="/catalog" 
              className="text-sm font-bold text-muted-text hover:text-primary transition-colors"
            >
              Xem tất cả dòng loa →
            </Link>
          </div>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-6 animate-fade-in-up stagger-2">
            {categories.map((cat) => (
              <Link
                key={cat.id}
                href={`/catalog?categoryId=${cat.id}`}
                className="group relative p-6 bg-card border border-border hover:border-border-hover hover:bg-card-hover rounded-2xl overflow-hidden transition-all flex flex-col justify-between min-h-[140px] shadow-sm hover:shadow text-left"
              >
                <div className="absolute inset-0 bg-gradient-to-tr from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                <div className="w-10 h-10 bg-input-bg border border-border rounded-xl flex items-center justify-center mb-4 group-hover:border-primary transition-colors">
                  {getCategoryIcon(cat.id)}
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-foreground group-hover:text-primary transition-colors leading-tight">
                    {cat.name}
                  </h3>
                  <p className="text-xs text-muted-text mt-1 uppercase tracking-wider font-semibold">
                    Xem sản phẩm
                  </p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* 4. FEATURED PRODUCTS */}
      <section className="w-full py-20 bg-muted-bg/10 border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-4 animate-fade-in-up stagger-1">
            <div className="text-left">
              <span className="text-xs font-black uppercase text-primary tracking-widest">NỔI BẬT NHẤT</span>
              <h2 className="text-3xl font-extrabold text-foreground uppercase mt-1">LOA ĐƯỢC ĐÁNH GIÁ CAO NHẤT</h2>
            </div>
            <Link 
              href="/catalog?sort=rating" 
              className="text-sm font-bold text-muted-text hover:text-primary transition-colors"
            >
              Xem toàn bộ sản phẩm →
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 animate-fade-in-up stagger-2">
            {featuredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </div>
      </section>

      {/* 5. INTERACTIVE SOUND QUIZ WIDGET */}
      <section className="w-full py-16 bg-background border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SoundQuizWidget />
        </div>
      </section>

      {/* 6. SPOTLIGHT CAMPAIGN BANNER */}
      <section className="w-full py-16 bg-background border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="relative rounded-3xl overflow-hidden bg-gradient-to-r from-stone-950 to-stone-900 text-white p-8 sm:p-12 md:p-16 flex flex-col md:flex-row justify-between items-center gap-8 shadow-xl border border-border">
            {/* Background pattern mask */}
            <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:3rem_3rem] pointer-events-none" />
            <div className="absolute top-1/2 left-1/4 -translate-y-1/2 w-[30rem] h-[30rem] rounded-full bg-primary/10 blur-[100px] pointer-events-none" />
            
            <div className="text-left space-y-4 max-w-xl relative z-10">
              <span className="text-xs font-black uppercase text-primary tracking-widest">Chiến dịch đặc biệt</span>
              <h2 className="text-3xl sm:text-4xl font-extrabold uppercase leading-tight">
                Marshall Vintage Series <br />
                <span className="text-primary font-medium text-2xl sm:text-3xl lowercase italic">retro vibes, modern sound</span>
              </h2>
              <p className="text-xs sm:text-sm text-stone-300 leading-relaxed">
                Đưa không gian sống của bạn quay ngược thời gian về thập niên 70 với thiết kế bọc da, tấm ê-căng cổ điển kết hợp núm vặn đồng thau sang trọng. Sở hữu ngay các mẫu loa Marshall Stanmore & Emberton thế hệ mới với ưu đãi độc quyền giảm giá đến 1.500.000 ₫ trong tuần lễ tri ân.
              </p>
              
              <div className="flex flex-wrap gap-4 pt-4">
                <Link
                  href="/catalog?brand=Marshall"
                  className="px-6 py-3 bg-primary hover:bg-orange-700 text-white font-extrabold text-xs uppercase tracking-wider rounded-xl transition-all hover:scale-105 shadow-md shadow-primary/20 btn-premium"
                >
                  Trải nghiệm ngay
                </Link>
                <Link
                  href="/product/marshall-stanmore-iii"
                  className="px-6 py-3 bg-white/10 hover:bg-white/20 text-white border border-white/20 font-bold text-xs uppercase tracking-wider rounded-xl transition-all hover:scale-105"
                >
                  Chi tiết sản phẩm
                </Link>
              </div>
            </div>

            {/* Campaign Image Mockup */}
            <div className="w-full sm:w-80 md:w-96 aspect-square rounded-2xl overflow-hidden bg-input-bg border border-border shadow-2xl relative z-10 flex-shrink-0 animate-pulse-subtle">
              <img 
                src="https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?q=80&w=600&auto=format&fit=crop" 
                alt="Marshall Stanmore Speaker" 
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>
      </section>

      {/* 7. AUDIO JOURNAL / BLOG SECTION */}
      <section className="w-full py-20 bg-muted-bg/10 border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-4 animate-fade-in-up stagger-1">
            <div className="text-left">
              <span className="text-xs font-black uppercase text-primary tracking-widest">Khám phá cẩm nang</span>
              <h2 className="text-3xl font-extrabold text-foreground uppercase mt-1">CẨM NANG ÂM THANH</h2>
            </div>
            <a 
              href="#" 
              className="text-sm font-bold text-muted-text hover:text-primary transition-colors"
            >
              Xem tất cả bài viết →
            </a>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 animate-fade-in-up stagger-2">
            {/* Post 1 */}
            <div className="group bg-card border border-border rounded-2xl overflow-hidden hover-glow flex flex-col justify-between">
              <div className="aspect-video w-full overflow-hidden bg-input-bg border-b border-border">
                <img 
                  src="https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=500&auto=format&fit=crop" 
                  alt="Bookshelf Speaker Placement" 
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <div className="p-6 text-left space-y-3 flex-1 flex flex-col justify-between">
                <div className="space-y-2">
                  <span className="text-[9px] font-bold text-primary uppercase tracking-wider bg-primary/10 border border-primary/20 px-2 py-0.5 rounded">Hướng dẫn</span>
                  <h3 className="text-sm font-black text-foreground group-hover:text-primary transition-colors leading-snug">
                    Cách bố trí loa Bookshelf chuẩn góc nghe nhạc Hi-Fi trong phòng khách
                  </h3>
                  <p className="text-[11px] text-muted-text leading-relaxed line-clamp-2">
                    Bố trí loa không chỉ đơn giản là đặt chúng lên kệ. Khám phá quy tắc tam giác đều và cách chống rung chấn giúp tối ưu hóa âm hình sân khấu.
                  </p>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-border text-[10px] text-muted-text/80">
                  <span>Bởi Kỹ sư âm thanh Huy Trần</span>
                  <span>05 Tháng 7, 2026</span>
                </div>
              </div>
            </div>

            {/* Post 2 */}
            <div className="group bg-card border border-border rounded-2xl overflow-hidden hover-glow flex flex-col justify-between">
              <div className="aspect-video w-full overflow-hidden bg-input-bg border-b border-border">
                <img 
                  src="https://images.unsplash.com/photo-1598653222000-6b7b7a552625?q=80&w=500&auto=format&fit=crop" 
                  alt="Monitor Speaker Compare" 
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <div className="p-6 text-left space-y-3 flex-1 flex flex-col justify-between">
                <div className="space-y-2">
                  <span className="text-[9px] font-bold text-primary uppercase tracking-wider bg-primary/10 border border-primary/20 px-2 py-0.5 rounded">So sánh</span>
                  <h3 className="text-sm font-black text-foreground group-hover:text-primary transition-colors leading-snug">
                    So sánh loa kiểm âm KRK Rokit và Yamaha HS Series: Đâu là chân ái?
                  </h3>
                  <p className="text-[11px] text-muted-text leading-relaxed line-clamp-2">
                    Lựa chọn giữa đáp tuyến phẳng tịt của Yamaha HS5 và âm trầm đầy đặn của KRK Rokit 5 luôn là bài toán khó cho người mới bắt đầu làm nhạc.
                  </p>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-border text-[10px] text-muted-text/80">
                  <span>Bởi Producer Minh Đức</span>
                  <span>02 Tháng 7, 2026</span>
                </div>
              </div>
            </div>

            {/* Post 3 */}
            <div className="group bg-card border border-border rounded-2xl overflow-hidden hover-glow flex flex-col justify-between">
              <div className="aspect-video w-full overflow-hidden bg-input-bg border-b border-border">
                <img 
                  src="https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=500&auto=format&fit=crop" 
                  alt="What is Dolby Atmos" 
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <div className="p-6 text-left space-y-3 flex-1 flex flex-col justify-between">
                <div className="space-y-2">
                  <span className="text-[9px] font-bold text-primary uppercase tracking-wider bg-primary/10 border border-primary/20 px-2 py-0.5 rounded">Kiến thức</span>
                  <h3 className="text-sm font-black text-foreground group-hover:text-primary transition-colors leading-snug">
                    Dolby Atmos là gì? Tại sao loa Soundbar thế hệ mới bắt buộc phải có?
                  </h3>
                  <p className="text-[11px] text-muted-text leading-relaxed line-clamp-2">
                    Không chỉ dừng lại ở âm thanh vòm 5.1 hay 7.1, Dolby Atmos kiến tạo một bầu trời âm thanh 3D trên đỉnh đầu mang tính cách mạng cho rạp phim tại gia.
                  </p>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-border text-[10px] text-muted-text/80">
                  <span>Bởi Reviewer Hoàng Bách</span>
                  <span>28 Tháng 6, 2026</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 8. BENEFITS SECTION */}
      <section id="benefits" className="w-full py-20 bg-background border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-xl mx-auto mb-16 animate-fade-in-up stagger-1">
            <span className="text-xs font-black uppercase text-primary tracking-widest">TẠI SAO CHỌN POYKEN SOUND</span>
            <h2 className="text-3xl font-extrabold text-foreground uppercase mt-1">DỊCH VỤ PREMIUM XỨNG TẦM</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 animate-fade-in-up stagger-2">
            {benefits.map((benefit, idx) => (
              <div 
                key={idx}
                className="p-8 bg-card border border-border hover:border-border-hover hover:bg-card-hover rounded-2xl flex flex-col items-center text-center space-y-4 hover-glow transition-all"
              >
                <div className="p-4 bg-input-bg border border-border rounded-full text-primary group-hover:scale-110 transition-transform shadow-sm">
                  <benefit.icon className="w-8 h-8" />
                </div>
                <h3 className="text-lg font-bold text-foreground uppercase tracking-wide">{benefit.title}</h3>
                <p className="text-sm text-muted-text leading-relaxed max-w-xs">{benefit.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 9. NEWSLETTER PROMO */}
      <section className="w-full py-24 relative overflow-hidden bg-gradient-to-b from-muted-bg/10 to-muted-bg/30 border-t border-border">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[40rem] h-[20rem] rounded-full bg-primary/5 blur-[120px] pointer-events-none" />
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10 space-y-6">
          <span className="text-xs font-black uppercase text-primary tracking-widest">ĐĂNG KÝ HỘI VIÊN V.I.P</span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-foreground uppercase leading-none">
            NHẬN VOUCHER GIẢM 10% CHO ĐƠN HÀNG ĐẦU TIÊN
          </h2>
          <p className="text-sm text-muted-text max-w-md mx-auto leading-relaxed">
            Đăng ký nhận bản tin để không bỏ lỡ các thông báo mở bán loa phiên bản giới hạn và các chương trình ưu đãi đặc quyền.
          </p>
          <div className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto pt-2">
            <input
              type="email"
              placeholder="Email của bạn..."
              className="bg-input-bg border border-border text-sm text-foreground placeholder-muted-text/70 px-5 py-3 rounded-full focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 flex-1 shadow-sm"
            />
            <button className="bg-primary hover:bg-orange-700 text-white text-sm font-extrabold px-8 py-3 rounded-full hover:shadow-lg hover:shadow-primary/10 transition-all hover:scale-105 active:scale-95 shadow-md shadow-primary/10 btn-premium">
              ĐĂNG KÝ NGAY
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}
