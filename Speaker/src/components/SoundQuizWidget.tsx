'use client';

import React, { useState } from 'react';
import { Speaker, Music, Tv, Disc, ArrowRight, Heart } from 'lucide-react';
import Link from 'next/link';

interface QuizOption {
  id: string;
  title: string;
  desc: string;
  genre: string;
  icon: React.ReactNode;
  recommendations: Array<{
    name: string;
    brand: string;
    price: string;
    slug: string;
    image: string;
  }>;
}

export default function SoundQuizWidget() {
  const [selectedId, setSelectedId] = useState('acoustic');

  const options: QuizOption[] = [
    {
      id: 'acoustic',
      title: 'Acoustic & Vocal',
      desc: 'Nhạc nhẹ, tình khúc mộc mạc, tôn vinh giọng ca ca sĩ và âm thanh nhạc cụ chi tiết.',
      genre: 'Acoustic, Jazz, Pop Ballad',
      icon: <Music className="w-5 h-5 text-primary" />,
      recommendations: [
        {
          name: 'JBL L52 Classic',
          brand: 'JBL',
          price: '24.500.000 ₫',
          slug: 'jbl-l52-classic',
          image: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=400&auto=format&fit=crop'
        },
        {
          name: 'KEF Q350',
          brand: 'KEF',
          price: '18.900.000 ₫',
          slug: 'kef-q350',
          image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=400&auto=format&fit=crop'
        }
      ]
    },
    {
      id: 'dance',
      title: 'EDM & Sôi Động',
      desc: 'Nhạc điện tử, Rap, Hip-hop, Dance với yêu cầu âm trầm bass siêu sâu, chắc khỏe và mạnh mẽ.',
      genre: 'EDM, Dance, Rap, Vinahouse',
      icon: <Disc className="w-5 h-5 text-primary" />,
      recommendations: [
        {
          name: 'Marshall Stanmore III',
          brand: 'Marshall',
          price: '9.490.000 ₫',
          slug: 'marshall-stanmore-iii',
          image: 'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?q=80&w=400&auto=format&fit=crop'
        },
        {
          name: 'Marshall Emberton II',
          brand: 'Marshall',
          price: '3.990.000 ₫',
          slug: 'marshall-emberton-ii',
          image: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?q=80&w=400&auto=format&fit=crop'
        }
      ]
    },
    {
      id: 'cinema',
      title: 'Điện Ảnh & Phòng Game',
      desc: 'Xem phim bom tấn, chơi game AAA với hiệu ứng âm thanh vòm 3D hoành tráng sống động.',
      genre: 'Phim bom tấn, Playstation, Soundbar',
      icon: <Tv className="w-5 h-5 text-primary" />,
      recommendations: [
        {
          name: 'Klipsch RP-8000F II',
          brand: 'Klipsch',
          price: '36.500.000 ₫',
          slug: 'klipsch-rp-8000f-ii',
          image: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=400&auto=format&fit=crop'
        },
        {
          name: 'JBL Bar 1000',
          brand: 'JBL',
          price: '22.900.000 ₫',
          slug: 'jbl-bar-1000',
          image: 'https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=400&auto=format&fit=crop'
        }
      ]
    },
    {
      id: 'monitor',
      title: 'Thu Âm & Sản Xuất',
      desc: 'Phối nhạc chuyên nghiệp, kiểm âm cần độ trung thực tuyệt đối, đáp ứng tần số phẳng hoàn hảo.',
      genre: 'Kiểm âm Studio, DJ, Mixer',
      icon: <Speaker className="w-5 h-5 text-primary" />,
      recommendations: [
        {
          name: 'KRK ROKIT 5 G4',
          brand: 'KRK',
          price: '8.800.000 ₫',
          slug: 'krk-rokit-5-g4',
          image: 'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=400&auto=format&fit=crop'
        },
        {
          name: 'Yamaha HS5',
          brand: 'Yamaha',
          price: '9.500.000 ₫',
          slug: 'yamaha-hs-5',
          image: 'https://images.unsplash.com/photo-1598653222000-6b7b7a552625?q=80&w=400&auto=format&fit=crop'
        }
      ]
    }
  ];

  const currentOption = options.find((opt) => opt.id === selectedId) || options[0];

  return (
    <div className="bg-card border border-border rounded-3xl p-6 sm:p-10 shadow-sm max-w-7xl mx-auto w-full">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
        
        {/* Left: Option selector */}
        <div className="lg:col-span-5 space-y-6 text-left">
          <div>
            <span className="text-xs font-black uppercase text-primary tracking-widest">Cá nhân hóa trải nghiệm</span>
            <h3 className="text-2xl sm:text-3xl font-extrabold text-foreground uppercase mt-1">Gu Âm Nhạc Của Bạn?</h3>
            <p className="text-xs text-muted-text mt-2 leading-relaxed">
              Chọn phong cách âm nhạc yêu thích của bạn dưới đây, hệ thống Poyken Sound sẽ ngay lập tức đề xuất mẫu loa có chất âm tương ứng hoàn hảo nhất.
            </p>
          </div>

          <div className="space-y-3">
            {options.map((opt) => {
              const isSelected = opt.id === selectedId;
              return (
                <div
                  key={opt.id}
                  onClick={() => setSelectedId(opt.id)}
                  className={`p-4 rounded-2xl border cursor-pointer flex gap-4 items-center transition-all ${
                    isSelected
                      ? 'bg-muted-bg border-primary shadow-md shadow-primary/5 translate-x-1'
                      : 'bg-transparent border-border/80 hover:border-border-hover'
                  }`}
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 border ${
                    isSelected ? 'bg-primary/5 border-primary/20' : 'bg-input-bg border-border'
                  }`}>
                    {opt.icon}
                  </div>
                  <div>
                    <h4 className="text-xs font-black text-foreground uppercase tracking-wide">{opt.title}</h4>
                    <p className="text-[10px] text-muted-text mt-0.5 max-w-[280px] leading-tight">{opt.desc}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Right: Dynamic recommendations card */}
        <div className="lg:col-span-7 bg-muted-bg/60 border border-border rounded-3xl p-6 sm:p-8 flex flex-col justify-between shadow-sm relative overflow-hidden min-h-[380px] text-left animate-in fade-in duration-300">
          <div className="absolute top-0 right-0 w-32 h-32 bg-primary/5 rounded-full blur-2xl -mr-10 -mt-10" />
          
          <div className="relative z-10">
            <span className="text-[10px] bg-primary/10 text-primary font-black uppercase px-2 py-0.5 rounded-md border border-primary/20 tracking-wider">
              {currentOption.genre}
            </span>
            <h4 className="text-lg font-black text-foreground uppercase mt-3">Đề xuất hoàn hảo cho bạn</h4>
            <p className="text-xs text-muted-text mt-1 max-w-md leading-relaxed">
              Các chuyên gia âm thanh Poyken Sound đã tối ưu hóa cấu hình sản phẩm dưới đây giúp tái hiện chân thực nhất dải âm phù hợp với dòng nhạc bạn chọn.
            </p>
          </div>

          {/* Recommended products grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 my-6 relative z-10">
            {currentOption.recommendations.map((prod) => (
              <div 
                key={prod.slug}
                className="group border border-border rounded-2xl p-4 bg-card hover:bg-card-hover hover:border-primary/20 transition-all hover:shadow-md"
              >
                {/* Image */}
                <div className="aspect-video w-full rounded-xl overflow-hidden bg-input-bg border border-border relative">
                  <img 
                    src={prod.image} 
                    alt={prod.name} 
                    className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                </div>
                {/* Meta */}
                <div className="mt-3">
                  <span className="text-[9px] font-bold text-muted-text uppercase tracking-widest">{prod.brand}</span>
                  <h5 className="text-xs font-black text-foreground truncate group-hover:text-primary transition-colors mt-0.5">{prod.name}</h5>
                  
                  <div className="flex justify-between items-center mt-2.5">
                    <span className="text-xs font-extrabold text-primary">{prod.price}</span>
                    <Link
                      href={`/product/${prod.slug}`}
                      className="p-1.5 bg-input-bg border border-border rounded-full text-muted-text hover:text-primary hover:border-primary transition-all active:scale-95 shadow-sm"
                    >
                      <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="flex items-center justify-between border-t border-border pt-4 relative z-10 text-xs">
            <span className="text-muted-text flex items-center gap-1">
              <Heart className="w-4 h-4 text-primary fill-primary/10" />
              Độc quyền phân phối tại Việt Nam
            </span>
            <Link 
              href="/catalog" 
              className="font-bold text-primary hover:underline flex items-center gap-1 uppercase tracking-wider text-[11px]"
            >
              Xem tất cả sản phẩm
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

        </div>

      </div>
    </div>
  );
}
