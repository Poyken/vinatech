'use client';

import React, { useState, useEffect } from 'react';
import { Product, Review } from '../lib/types';
import { useCart } from '../context/CartContext';
import { useAudio } from '../context/AudioContext';
import { useToast } from '../context/ToastContext';
import { Star, ShoppingCart, Play, Pause, Send, User, CheckCircle2, Volume2, Disc, ShieldCheck } from 'lucide-react';

interface ProductDetailInteractiveProps {
  product: Product;
  initialReviews: Review[];
}

export default function ProductDetailInteractive({ product, initialReviews }: ProductDetailInteractiveProps) {
  const { addToCart } = useCart();
  const { playProductAudio, currentProduct, isPlaying } = useAudio();
  const { showToast } = useToast();

  const [selectedImage, setSelectedImage] = useState(product.images[0] || '');
  const [quantity, setQuantity] = useState(1);
  const isAudioActive = currentProduct?.id === product.id && isPlaying;

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

  const handlePlayAudioDemo = () => {
    if (product.audioUrl) {
      playProductAudio(product);
      showToast(isAudioActive ? 'Tạm dừng bản nhạc thử' : 'Đang phát bản nhạc thử', product.name, 'info');
    } else {
      showToast('Chưa có mẫu âm thanh', product.name, 'info');
    }
  };

  const handleAddToCart = () => {
    addToCart(product, quantity);
    showToast('Đã thêm vào giỏ hàng', `${quantity}x ${product.name}`, 'success');
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
      showToast('Cảm ơn bạn đã gửi đánh giá!', product.name, 'success');
      setTimeout(() => setReviewSuccess(false), 3000);
    } catch (err) {
      console.error(err);
      showToast('Có lỗi xảy ra khi gửi đánh giá', 'Vui lòng thử lại sau', 'error');
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  return (
    <div className="space-y-12">
      {/* 1. Product Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
        
        {/* Left Column: Gallery */}
        <div className="lg:col-span-6 space-y-4">
          <div className="aspect-square bg-card border border-border rounded-3xl flex items-center justify-center overflow-hidden relative group shadow-lg transition-all duration-500 hover:border-primary/40">
            {selectedImage ? (
              <img 
                src={selectedImage} 
                alt={product.name} 
                className="w-full h-full object-cover transition-transform duration-700 ease-out group-hover:scale-105"
              />
            ) : (
              <span className="text-8xl select-none group-hover:scale-105 transition-transform duration-500">🔊</span>
            )}
            <span className="absolute bottom-4 left-4 bg-card/90 backdrop-blur-md border border-border px-3 py-1 rounded-full text-xs text-primary font-bold shadow-sm">
              {product.brand} Original
            </span>
          </div>

          {product.images.length > 1 && (
            <div className="flex gap-3">
              {product.images.map((img, index) => (
                <button
                  key={index}
                  onClick={() => setSelectedImage(img)}
                  className={`w-20 h-20 bg-input-bg border rounded-2xl flex items-center justify-center overflow-hidden hover:border-primary transition-all duration-300 p-1 shadow-sm ${
                    selectedImage === img ? 'border-primary ring-2 ring-primary/20 scale-105' : 'border-border opacity-70 hover:opacity-100'
                  }`}
                >
                  <img src={img} alt="" className="w-full h-full object-cover rounded-xl" />
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Right Column: Information Panel */}
        <div className="lg:col-span-6 space-y-6 text-left">
          <div>
            <span className="text-xs font-black uppercase text-primary tracking-widest">{product.brand} • {product.type}</span>
            <h1 className="text-3xl sm:text-4xl font-black text-foreground uppercase mt-1 leading-tight">{product.name}</h1>
            
            {/* Rating Stars */}
            <div className="flex items-center gap-2 mt-2">
              <div className="flex text-amber-500">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={`w-4 h-4 ${
                      i < Math.floor(product.rating) ? 'fill-amber-500 text-amber-500' : 'text-border fill-border'
                    }`}
                  />
                ))}
              </div>
              <span className="text-xs font-bold text-muted-text">
                {product.rating} / 5.0 ({reviews.length} đánh giá)
              </span>
            </div>
          </div>

          {/* Pricing Box */}
          <div className="p-5 bg-card border border-border rounded-2xl flex items-center justify-between shadow-sm">
            <div className="space-y-1">
              <span className="text-xs text-muted-text font-bold uppercase tracking-wider block">Giá bán lẻ đề xuất</span>
              <div className="flex items-center gap-3">
                <span className="text-2xl sm:text-3xl font-black text-primary">{formatPrice(product.price)}</span>
                {product.originalPrice && (
                  <span className="text-sm text-muted-text line-through font-medium">{formatPrice(product.originalPrice)}</span>
                )}
              </div>
            </div>
            
            {/* Stock status */}
            <div className="text-right">
              <span className="text-xs text-muted-text block font-semibold">Tình trạng kho</span>
              {product.stock > 0 ? (
                <span className="text-xs bg-green-500/10 text-green-500 font-extrabold px-2.5 py-1 rounded-full border border-green-500/20 mt-1 inline-block">
                  Còn {product.stock} Chiếc
                </span>
              ) : (
                <span className="text-xs bg-red-500/10 text-red-500 font-extrabold px-2.5 py-1 rounded-full border border-red-500/20 mt-1 inline-block">
                  Hết Hàng
                </span>
              )}
            </div>
          </div>

          {/* Short Description */}
          <p className="text-sm text-muted-text leading-relaxed">{product.description}</p>

          {/* Audio Player wave demo card */}
          {product.audioUrl && (
            <div className="p-5 bg-card border border-border rounded-2xl space-y-4 shadow-sm hover-glow">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Disc className={`w-4 h-4 text-primary ${isAudioActive ? 'animate-spin-slow' : ''}`} />
                  <span className="text-xs font-black uppercase text-foreground tracking-wider">Trải Nghiệm Mẫu Âm Thanh Loa</span>
                </div>
                <span className="text-[10px] text-amber-500 font-bold uppercase tracking-widest bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                  Hi-Fi Audio Sample
                </span>
              </div>

              <div className="flex items-center gap-4">
                <button
                  onClick={handlePlayAudioDemo}
                  className={`w-12 h-12 rounded-full flex items-center justify-center text-white transition-all duration-300 hover:scale-110 active:scale-95 shadow-lg flex-shrink-0 ${
                    isAudioActive
                      ? 'bg-amber-500 border-2 border-amber-400 shadow-amber-500/30 animate-pulse'
                      : 'bg-primary hover:bg-orange-700 shadow-primary/20 btn-premium'
                  }`}
                >
                  {isAudioActive ? <Pause className="w-5 h-5 fill-white" /> : <Play className="w-5 h-5 fill-white ml-0.5" />}
                </button>

                {/* Animated sound wave bars */}
                <div className="flex-1 h-12 flex items-end justify-center gap-1 px-3 bg-input-bg rounded-xl border border-border overflow-hidden py-1.5">
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-3 opacity-30'}`} style={{ animationDelay: '0.1s', height: isAudioActive ? '70%' : '20%' }} />
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-4 opacity-30'}`} style={{ animationDelay: '0.3s', height: isAudioActive ? '95%' : '30%' }} />
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-2 opacity-30'}`} style={{ animationDelay: '0.2s', height: isAudioActive ? '45%' : '15%' }} />
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-5 opacity-30'}`} style={{ animationDelay: '0.5s', height: isAudioActive ? '85%' : '25%' }} />
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-3 opacity-30'}`} style={{ animationDelay: '0.4s', height: isAudioActive ? '60%' : '20%' }} />
                  <div className={`sound-bar ${isAudioActive ? 'animate-wave' : 'h-2 opacity-30'}`} style={{ animationDelay: '0.6s', height: isAudioActive ? '90%' : '15%' }} />
                </div>
              </div>
            </div>
          )}

          {/* Purchase Controls */}
          {product.stock > 0 && (
            <div className="flex gap-4 pt-2">
              <div className="flex items-center bg-input-bg border border-border rounded-2xl shadow-sm">
                <button
                  onClick={() => setQuantity(q => Math.max(1, q - 1))}
                  className="px-4 py-3 text-muted-text hover:text-foreground font-bold text-base transition-colors"
                >
                  -
                </button>
                <span className="w-10 text-center text-foreground font-bold text-sm">{quantity}</span>
                <button
                  onClick={() => setQuantity(q => Math.min(product.stock, q + 1))}
                  className="px-4 py-3 text-muted-text hover:text-foreground font-bold text-base transition-colors"
                >
                  +
                </button>
              </div>

              <button
                onClick={handleAddToCart}
                className="flex-1 py-4 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-extrabold uppercase tracking-wider rounded-2xl hover:shadow-xl hover:shadow-primary/20 flex items-center justify-center gap-2 transition-all duration-300 hover:scale-[1.01] active:scale-[0.99] shadow-md shadow-primary/10 btn-premium text-xs sm:text-sm"
              >
                <ShoppingCart className="w-5 h-5" />
                Thêm Vào Giỏ Hàng
              </button>
            </div>
          )}
        </div>

      </div>

      {/* 2. Technical Specifications Table */}
      <div className="pt-6 border-t border-border">
        <h2 className="text-xl font-extrabold text-foreground uppercase mb-6 tracking-wide text-left">Thông Số Kỹ Thuật Chi Tiết</h2>
        <div className="bg-card border border-border rounded-2xl overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse">
            <tbody>
              {Object.entries(product.specs).map(([key, val], idx) => (
                <tr 
                  key={key}
                  className={`border-b border-border last:border-0 ${
                    idx % 2 === 0 ? 'bg-muted-bg/30' : 'bg-transparent'
                  }`}
                >
                  <td className="px-6 py-4 text-xs font-bold text-muted-text uppercase tracking-wider w-1/3 border-r border-border">
                    {key}
                  </td>
                  <td className="px-6 py-4 text-sm text-foreground">
                    {val}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 3. Review Sections */}
      <div className="pt-8 border-t border-border grid grid-cols-1 lg:grid-cols-12 gap-10">
        
        {/* Left: Review List */}
        <div className="lg:col-span-7 space-y-6 text-left">
          <h2 className="text-xl font-extrabold text-foreground uppercase tracking-wide">
            Đánh giá khách hàng ({reviews.length})
          </h2>

          <div className="space-y-4">
            {reviews.length === 0 ? (
              <p className="text-sm text-muted-text">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên chia sẻ cảm nhận!</p>
            ) : (
              reviews.map((rev) => (
                <div 
                  key={rev.id}
                  className="p-5 bg-card border border-border rounded-2xl space-y-3 shadow-sm hover:border-border-hover transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-input-bg border border-border flex items-center justify-center text-muted-text">
                        <User className="w-4 h-4" />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-foreground leading-none">{rev.userName}</h4>
                        <span className="text-[10px] text-muted-text/80 mt-1 block">Khách mua hàng thực tế</span>
                      </div>
                    </div>

                    <div className="flex text-amber-500">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star
                          key={i}
                          className={`w-3.5 h-3.5 ${
                            i < rev.rating ? 'fill-amber-500 text-amber-500' : 'text-border fill-border'
                          }`}
                        />
                      ))}
                    </div>
                  </div>

                  <p className="text-sm text-muted-text pl-10 leading-relaxed">
                    {rev.comment}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right: Write Review Form */}
        <div className="lg:col-span-5 text-left">
          <div className="p-6 bg-card border border-border rounded-3xl space-y-5 shadow-sm">
            <h3 className="text-base font-bold text-foreground uppercase tracking-wider border-l-2 border-primary pl-3">
              Viết đánh giá sản phẩm
            </h3>

            {reviewSuccess ? (
              <div className="p-4 bg-green-500/10 border border-green-500/20 text-green-500 rounded-xl flex items-start gap-2.5 animate-fade-in">
                <CheckCircle2 className="w-5 h-5 flex-shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-sm font-bold">Gửi đánh giá thành công!</h4>
                  <p className="text-xs text-green-500/80 mt-0.5">Cảm ơn bạn đã đóng góp đánh giá sản phẩm của Poyken Sound.</p>
                </div>
              </div>
            ) : (
              <form onSubmit={handleAddReview} className="space-y-4">
                {/* Rating selection */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Chọn Số Sao</label>
                  <div className="flex gap-1.5">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        key={star}
                        type="button"
                        onClick={() => setReviewRating(star)}
                        className="text-amber-500 hover:scale-125 transition-transform duration-200"
                      >
                        <Star 
                          className={`w-6 h-6 ${
                            star <= reviewRating ? 'fill-amber-500 text-amber-500' : 'text-border fill-border'
                          }`} 
                        />
                      </button>
                    ))}
                  </div>
                </div>

                {/* Name */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Họ Tên</label>
                  <input
                    type="text"
                    required
                    placeholder="Nhập họ tên của bạn..."
                    value={reviewName}
                    onChange={(e) => setReviewName(e.target.value)}
                    className="w-full bg-input-bg border border-border rounded-xl px-4 py-2.5 text-xs text-foreground placeholder-muted-text/70 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                  />
                </div>

                {/* Comment */}
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Nhận xét</label>
                  <textarea
                    required
                    rows={4}
                    placeholder="Chia sẻ trải nghiệm của bạn về chất lượng âm thanh, độ hoàn thiện của sản phẩm..."
                    value={reviewComment}
                    onChange={(e) => setReviewComment(e.target.value)}
                    className="w-full bg-input-bg border border-border rounded-xl px-4 py-2.5 text-xs text-foreground placeholder-muted-text/70 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 resize-none"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full py-3.5 bg-input-bg hover:bg-primary hover:text-white text-foreground border border-border font-extrabold text-xs uppercase tracking-wider rounded-xl transition-all duration-300 flex items-center justify-center gap-1.5 shadow-sm active:scale-95 btn-premium"
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
