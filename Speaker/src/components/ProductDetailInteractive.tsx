'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Product, Review } from '../lib/types';
import { useCart } from '../context/CartContext';
import { Star, ShoppingCart, Play, Pause, Send, User, CheckCircle2 } from 'lucide-react';

interface ProductDetailInteractiveProps {
  product: Product;
  initialReviews: Review[];
}

export default function ProductDetailInteractive({ product, initialReviews }: ProductDetailInteractiveProps) {
  const { addToCart } = useCart();
  const [selectedImage, setSelectedImage] = useState(product.images[0] || '');
  const [quantity, setQuantity] = useState(1);
  
  // Audio state
  const [isPlaying, setIsPlaying] = useState(false);
  const [audioProgress, setAudioProgress] = useState(0);
  const [waveHeights, setWaveHeights] = useState<number[]>(new Array(24).fill(20));
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  // Review states
  const [reviews, setReviews] = useState<Review[]>(initialReviews);
  const [reviewName, setReviewName] = useState('');
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewComment, setReviewComment] = useState('');
  const [reviewSuccess, setReviewSuccess] = useState(false);

  // Sync selected image if product changes
  useEffect(() => {
    setSelectedImage(product.images[0] || '');
  }, [product]);

  // Setup simulated audio URL if none provided
  const demoAudioUrl = product.audioUrl || 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  // Audio effect
  useEffect(() => {
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
      }
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  const handlePlayPause = () => {
    if (!audioRef.current) {
      audioRef.current = new Audio(demoAudioUrl);
      audioRef.current.loop = true;
      audioRef.current.addEventListener('timeupdate', () => {
        if (audioRef.current) {
          const progress = (audioRef.current.currentTime / audioRef.current.duration) * 100;
          setAudioProgress(isNaN(progress) ? 0 : progress);
        }
      });
      audioRef.current.addEventListener('ended', () => {
        setIsPlaying(false);
        setAudioProgress(0);
      });
    }

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
      setWaveHeights(new Array(24).fill(20));
    } else {
      audioRef.current.play().catch(err => console.log('Audio playback prevented or failed:', err));
      setIsPlaying(true);
      
      // Animate the sound wave equalizer
      intervalRef.current = setInterval(() => {
        setWaveHeights(prev => 
          prev.map(() => Math.floor(Math.random() * 85) + 15)
        );
      }, 100);
    }
  };

  const handleAddReview = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!reviewName.trim() || !reviewComment.trim()) return;

    try {
      const response = await fetch('/api/reviews', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          productId: product.id,
          userName: reviewName,
          rating: reviewRating,
          comment: reviewComment
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to post review');
      }

      const addedReview = await response.json();
      setReviews(prev => [addedReview, ...prev]);
      setReviewName('');
      setReviewComment('');
      setReviewRating(5);
      setReviewSuccess(true);
      setTimeout(() => setReviewSuccess(false), 3000);
    } catch (err) {
      console.error(err);
      alert('Có lỗi xảy ra khi gửi đánh giá.');
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  return (
    <div className="space-y-12">
      {/* 1. Product Layout Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
        
        {/* Left Column: Gallery */}
        <div className="lg:col-span-6 space-y-4">
          <div className="aspect-square bg-white border border-stone-200 rounded-3xl flex items-center justify-center overflow-hidden relative group shadow-sm">
            {selectedImage ? (
              <img 
                src={selectedImage} 
                alt={product.name} 
                className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
              />
            ) : (
              <span className="text-8xl select-none group-hover:scale-105 transition-transform duration-500">🔊</span>
            )}
            <span className="absolute bottom-4 left-4 bg-white/90 backdrop-blur-sm border border-stone-200/60 px-3 py-1 rounded-full text-xs text-primary font-bold shadow-sm">
              {product.brand} Original
            </span>
          </div>
          {product.images.length > 1 && (
            <div className="flex gap-3">
              {product.images.map((img, index) => (
                <button
                  key={index}
                  onClick={() => setSelectedImage(img)}
                  className={`w-20 h-20 bg-white border rounded-xl flex items-center justify-center overflow-hidden hover:border-primary transition-all p-1 shadow-sm ${
                    selectedImage === img ? 'border-primary ring-2 ring-primary/10' : 'border-stone-200'
                  }`}
                >
                  <img src={img} alt="" className="w-full h-full object-cover rounded-lg" />
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Right Column: Information Panel */}
        <div className="lg:col-span-6 space-y-6 text-left">
          <div>
            <span className="text-xs font-black uppercase text-primary tracking-widest">{product.brand}</span>
            <h1 className="text-3xl font-extrabold text-stone-900 uppercase mt-1 leading-tight">{product.name}</h1>
            
            {/* Rating Stars */}
            <div className="flex items-center gap-2 mt-2">
              <div className="flex text-amber-500">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={`w-4 h-4 ${
                      i < Math.floor(product.rating) ? 'fill-amber-500 text-amber-500' : 'text-stone-200 fill-stone-100'
                    }`}
                  />
                ))}
              </div>
              <span className="text-xs font-bold text-stone-500">
                {product.rating} / 5.0 ({reviews.length} đánh giá)
              </span>
            </div>
          </div>

          {/* Pricing Box */}
          <div className="p-5 bg-white border border-stone-200 rounded-2xl flex items-center justify-between shadow-sm">
            <div className="space-y-1">
              <span className="text-xs text-stone-500 font-bold uppercase tracking-wider block">Giá bán lẻ đề xuất</span>
              <div className="flex items-center gap-3">
                <span className="text-2xl font-black text-primary">{formatPrice(product.price)}</span>
                {product.originalPrice && (
                  <span className="text-sm text-stone-400 line-through">{formatPrice(product.originalPrice)}</span>
                )}
              </div>
            </div>
            
            {/* Stock status */}
            <div className="text-right">
              <span className="text-xs text-stone-500 block font-semibold">Tình trạng kho</span>
              {product.stock > 0 ? (
                <span className="text-xs bg-green-500/10 text-green-700 font-extrabold px-2 py-0.5 rounded border border-green-500/20 mt-1 inline-block">
                  Còn {product.stock} Chiếc
                </span>
              ) : (
                <span className="text-xs bg-red-500/10 text-red-700 font-extrabold px-2 py-0.5 rounded border border-red-500/20 mt-1 inline-block">
                  Hết Hàng
                </span>
              )}
            </div>
          </div>

          {/* Short Description */}
          <p className="text-sm text-stone-600 leading-relaxed">{product.description}</p>

          {/* Dynamic Audio Player wave simulation */}
          <div className="p-5 bg-white border border-stone-200 rounded-2xl space-y-4 shadow-sm">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-primary animate-ping" />
                <span className="text-xs font-black uppercase text-stone-850 tracking-wider">Trải Nghiệm Phòng Lọc Âm Thanh</span>
              </div>
              <span className="text-[10px] text-stone-500 font-bold uppercase">Simulated Sound Profile</span>
            </div>

            <div className="flex items-center gap-4">
              <button
                onClick={handlePlayPause}
                className="w-12 h-12 bg-primary hover:bg-orange-700 rounded-full flex items-center justify-center text-white transition-all hover:scale-105 active:scale-95 shadow-lg shadow-primary/20 flex-shrink-0"
              >
                {isPlaying ? <Pause className="w-5 h-5 fill-white" /> : <Play className="w-5 h-5 fill-white ml-0.5" />}
              </button>

              {/* sound wave bar visualizer */}
              <div className="flex-1 h-14 flex items-end justify-between px-2 bg-stone-50 rounded-xl border border-stone-200 overflow-hidden py-1.5 relative">
                {waveHeights.map((h, i) => (
                  <div
                    key={i}
                    className="w-1.5 bg-primary rounded-full transition-all duration-100 origin-bottom"
                    style={{ 
                      height: `${h}%`,
                      opacity: isPlaying ? 0.9 : 0.25,
                      backgroundColor: isPlaying ? 'var(--primary)' : '#d6d3d1'
                    }}
                  />
                ))}
              </div>
            </div>
            
            <p className="text-[11px] text-stone-500 leading-tight">
              * Nhấn Play để nghe thử demo dải âm đặc trưng của loa qua máy phát âm thanh giả lập.
            </p>
          </div>

          {/* Purchase Controls */}
          {product.stock > 0 && (
            <div className="flex gap-4 pt-2">
              <div className="flex items-center bg-white border border-stone-200 rounded-xl shadow-sm">
                <button
                  onClick={() => setQuantity(q => Math.max(1, q - 1))}
                  className="px-4 py-3 text-stone-500 hover:text-stone-800 transition-colors"
                >
                  -
                </button>
                <span className="w-10 text-center text-stone-800 font-bold text-sm">{quantity}</span>
                <button
                  onClick={() => setQuantity(q => Math.min(product.stock, q + 1))}
                  className="px-4 py-3 text-stone-500 hover:text-stone-800 transition-colors"
                >
                  +
                </button>
              </div>

              <button
                onClick={() => addToCart(product, quantity)}
                className="flex-1 py-4 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-black rounded-xl hover:shadow-lg hover:shadow-primary/10 flex items-center justify-center gap-2 transition-all hover:scale-[1.01] active:scale-[0.99] shadow-md"
              >
                <ShoppingCart className="w-5 h-5" />
                Thêm Vào Giỏ Hàng
              </button>
            </div>
          )}
        </div>

      </div>

      {/* 2. Technical Specifications Table */}
      <div className="pt-6 border-t border-stone-200">
        <h2 className="text-xl font-extrabold text-stone-800 uppercase mb-6 tracking-wide text-left">Thông Số Kỹ Thuật</h2>
        <div className="bg-white border border-stone-200 rounded-2xl overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse">
            <tbody>
              {Object.entries(product.specs).map(([key, val], idx) => (
                <tr 
                  key={key}
                  className={`border-b border-stone-100 last:border-0 ${
                    idx % 2 === 0 ? 'bg-stone-50/50' : 'bg-transparent'
                  }`}
                >
                  <td className="px-6 py-4 text-xs font-bold text-stone-500 uppercase tracking-wider w-1/3 border-r border-stone-100">
                    {key}
                  </td>
                  <td className="px-6 py-4 text-sm text-stone-700">
                    {val}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 3. Review Sections */}
      <div className="pt-8 border-t border-stone-200 grid grid-cols-1 lg:grid-cols-12 gap-10">
        
        {/* Left: Review List */}
        <div className="lg:col-span-7 space-y-6 text-left">
          <h2 className="text-xl font-extrabold text-stone-800 uppercase tracking-wide">
            Đánh giá khách hàng ({reviews.length})
          </h2>

          <div className="space-y-4">
            {reviews.length === 0 ? (
              <p className="text-sm text-stone-500">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên chia sẻ cảm nhận!</p>
            ) : (
              reviews.map((rev) => (
                <div 
                  key={rev.id}
                  className="p-5 bg-white border border-stone-200 rounded-2xl space-y-3 shadow-sm"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-stone-100 border border-stone-200 flex items-center justify-center text-stone-600">
                        <User className="w-4 h-4" />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-stone-800 leading-none">{rev.userName}</h4>
                        <span className="text-[10px] text-stone-500 mt-1 block">Khách mua hàng thực tế</span>
                      </div>
                    </div>

                    <div className="flex text-amber-500">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star
                          key={i}
                          className={`w-3.5 h-3.5 ${
                            i < rev.rating ? 'fill-amber-500 text-amber-500' : 'text-stone-200 fill-stone-100'
                          }`}
                        />
                      ))}
                    </div>
                  </div>

                  <p className="text-sm text-stone-600 pl-10 leading-relaxed">
                    {rev.comment}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right: Write Review Form */}
        <div className="lg:col-span-5 text-left">
          <div className="p-6 bg-white border border-stone-200 rounded-3xl space-y-5 shadow-sm">
            <h3 className="text-base font-bold text-stone-850 uppercase tracking-wider border-l-2 border-primary pl-3">
              Viết đánh giá sản phẩm
            </h3>

            {reviewSuccess ? (
              <div className="p-4 bg-green-500/10 border border-green-500/20 text-green-700 rounded-xl flex items-start gap-2.5 animate-in fade-in duration-300">
                <CheckCircle2 className="w-5 h-5 flex-shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-sm font-bold">Gửi đánh giá thành công!</h4>
                  <p className="text-xs text-green-600/80 mt-0.5">Cảm ơn bạn đã đóng góp đánh giá sản phẩm của Poyken Sound.</p>
                </div>
              </div>
            ) : (
              <form onSubmit={handleAddReview} className="space-y-4">
                {/* Rating selection */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider block">Chọn Số Sao</label>
                  <div className="flex gap-1.5">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        key={star}
                        type="button"
                        onClick={() => setReviewRating(star)}
                        className="text-amber-500 hover:scale-110 transition-transform"
                      >
                        <Star 
                          className={`w-6 h-6 ${
                            star <= reviewRating ? 'fill-amber-500 text-amber-500' : 'text-stone-200 fill-stone-100'
                          }`} 
                        />
                      </button>
                    ))}
                  </div>
                </div>

                {/* Name */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider block">Họ Tên</label>
                  <input
                    type="text"
                    required
                    placeholder="Nhập họ tên của bạn..."
                    value={reviewName}
                    onChange={(e) => setReviewName(e.target.value)}
                    className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-2.5 text-xs text-stone-800 placeholder-stone-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                  />
                </div>

                {/* Comment */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-stone-500 uppercase tracking-wider block">Nhận xét</label>
                  <textarea
                    required
                    rows={4}
                    placeholder="Chia sẻ trải nghiệm của bạn về chất lượng âm thanh, độ hoàn thiện của sản phẩm..."
                    value={reviewComment}
                    onChange={(e) => setReviewComment(e.target.value)}
                    className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-2.5 text-xs text-stone-800 placeholder-stone-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 resize-none"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full py-3 bg-stone-800 hover:bg-primary text-white font-extrabold text-xs uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5 shadow-sm"
                >
                  <Send className="w-3.5 h-3.5" />
                  Gửi Đánh Giá
                </button>
              </form>
            )}
          </div>
        </div>

      </div>

    </div>
  );
}
