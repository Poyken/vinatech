'use client';

import React from 'react';
import { Product } from '../lib/types';
import { useCart } from '../context/CartContext';
import { useAudio } from '../context/AudioContext';
import { useCompare } from '../context/CompareContext';
import { useToast } from '../context/ToastContext';
import { ShoppingCart, Star, Eye, Volume2, SlidersHorizontal, Check, Disc } from 'lucide-react';
import Link from 'next/link';

interface ProductCardProps {
  product: Product;
}

export default function ProductCard({ product }: ProductCardProps) {
  const { addToCart } = useCart();
  const { playProductAudio, currentProduct, isPlaying } = useAudio();
  const { addToCompare, removeFromCompare, isInCompare } = useCompare();
  const { showToast } = useToast();

  const isAudioActive = currentProduct?.id === product.id && isPlaying;
  const isCompared = isInCompare(product.id);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const discount = product.originalPrice 
    ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)
    : 0;

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    addToCart(product);
    showToast('Đã thêm vào giỏ hàng', product.name, 'success');
  };

  const handleToggleCompare = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (isCompared) {
      removeFromCompare(product.id);
      showToast('Đã xóa khỏi danh sách so sánh', product.name, 'info');
    } else {
      addToCompare(product);
      showToast('Đã thêm vào so sánh', product.name, 'success');
    }
  };

  const handlePlayAudio = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (product.audioUrl) {
      playProductAudio(product);
      showToast(isAudioActive ? 'Tạm dừng bản nhạc thử' : 'Đang phát bản nhạc thử', product.name, 'info');
    } else {
      showToast('Chưa có mẫu âm thanh', product.name, 'info');
    }
  };

  return (
    <div className="group relative bg-card border border-border rounded-2xl overflow-hidden hover-glow">
      
      {/* Top Left Badges */}
      <div className="absolute top-3 left-3 z-10 flex flex-col gap-1.5 pointer-events-none">
        {discount > 0 && (
          <span className="bg-primary text-white text-[10px] font-black uppercase px-2 py-0.5 rounded-md tracking-wider shadow-md shadow-primary/20">
            -{discount}%
          </span>
        )}
        {product.audioUrl && (
          <span className="bg-card/90 backdrop-blur-md text-amber-500 border border-amber-500/30 text-[9px] font-extrabold uppercase px-2 py-0.5 rounded-md tracking-wide shadow-sm flex items-center gap-1">
            <Disc className={`w-3 h-3 ${isAudioActive ? 'animate-spin-slow text-primary' : ''}`} />
            Audio Demo
          </span>
        )}
      </div>

      {/* Top Right Quick Actions */}
      <div className="absolute top-3 right-3 z-10 flex gap-1.5">
        <button
          onClick={handleToggleCompare}
          className={`p-2 rounded-xl border backdrop-blur-md transition-all duration-300 active:scale-90 ${
            isCompared 
              ? 'bg-primary text-white border-primary shadow-md shadow-primary/20 scale-105' 
              : 'bg-card/85 text-muted-text hover:text-foreground hover:bg-card border-border/80 shadow-sm'
          }`}
          title={isCompared ? 'Bỏ so sánh' : 'Thêm vào so sánh'}
        >
          {isCompared ? <Check className="w-3.5 h-3.5" /> : <SlidersHorizontal className="w-3.5 h-3.5" />}
        </button>
      </div>

      {/* Speaker Image Slot */}
      <div className="relative aspect-square w-full bg-muted-bg/40 flex items-center justify-center overflow-hidden border-b border-border">
        {/* Dynamic gradient overlay on hover */}
        <div className="absolute inset-0 bg-gradient-to-tr from-primary/10 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
        
        {/* Image rendering with ultra-smooth zoom */}
        {product.images && product.images.length > 0 ? (
          <img 
            src={product.images[0]} 
            alt={product.name} 
            className="w-full h-full object-cover transition-transform duration-700 ease-out group-hover:scale-110"
          />
        ) : (
          <div className="text-6xl transform group-hover:scale-110 transition-transform duration-700 ease-out select-none">
            🔊
          </div>
        )}

        {/* Hover Quick View / Shop Controls with spring physics */}
        <div className="absolute inset-0 bg-black/40 backdrop-blur-[2px] flex items-center justify-center gap-2.5 opacity-0 group-hover:opacity-100 transition-all duration-300 pointer-events-none group-hover:pointer-events-auto">
          {product.audioUrl && (
            <button
              onClick={handlePlayAudio}
              className={`p-3.5 rounded-full hover:scale-110 active:scale-95 shadow-xl border transform translate-y-6 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-400 ease-[cubic-bezier(0.16,1,0.3,1)] ${
                isAudioActive
                  ? 'bg-amber-500 text-white border-amber-400 animate-pulse'
                  : 'bg-card hover:bg-card-hover text-primary border-border'
              }`}
              title="Nghe thử âm thanh"
            >
              <Volume2 className="w-5 h-5" />
            </button>
          )}
          
          <Link
            href={`/product/${product.slug}`}
            className="p-3.5 bg-card hover:bg-card-hover text-foreground rounded-full hover:scale-110 active:scale-95 shadow-xl border border-border transform translate-y-6 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-400 delay-[60ms] ease-[cubic-bezier(0.16,1,0.3,1)]"
            title="Xem chi tiết"
          >
            <Eye className="w-5 h-5 text-muted-text" />
          </Link>

          <button
            onClick={handleAddToCart}
            className="p-3.5 bg-primary hover:bg-orange-700 text-white rounded-full hover:scale-110 active:scale-95 shadow-xl shadow-primary/30 transform translate-y-6 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-400 delay-[120ms] ease-[cubic-bezier(0.16,1,0.3,1)] btn-premium"
            title="Thêm vào giỏ hàng"
          >
            <ShoppingCart className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Info details */}
      <div className="p-5 flex flex-col justify-between min-h-[160px] text-left">
        <div>
          {/* Brand */}
          <span className="text-[11px] font-extrabold uppercase tracking-widest text-muted-text">
            {product.brand} • {product.type}
          </span>
          {/* Name */}
          <Link href={`/product/${product.slug}`}>
            <h3 className="font-bold text-foreground text-base mt-1 line-clamp-1 group-hover:text-primary transition-colors duration-300">
              {product.name}
            </h3>
          </Link>
          {/* Rating */}
          <div className="flex items-center gap-1.5 mt-2">
            <div className="flex text-amber-500">
              {Array.from({ length: 5 }).map((_, i) => (
                <Star
                  key={i}
                  className={`w-3.5 h-3.5 ${
                    i < Math.floor(product.rating) 
                      ? 'fill-amber-500 text-amber-500' 
                      : 'text-border fill-border'
                  }`}
                />
              ))}
            </div>
            <span className="text-[11px] font-bold text-muted-text">
              {product.rating}
            </span>
          </div>
        </div>

        {/* Pricing & Add to Cart */}
        <div className="flex items-center justify-between gap-2 mt-4 pt-3 border-t border-border">
          <div className="flex flex-col">
            {product.originalPrice && (
              <span className="text-xs text-muted-text line-through font-medium">
                {formatPrice(product.originalPrice)}
              </span>
            )}
            <span className="font-black text-base text-primary">
              {formatPrice(product.price)}
            </span>
          </div>

          <button
            onClick={handleAddToCart}
            className="flex items-center gap-1.5 px-3.5 py-2 bg-input-bg hover:bg-primary text-foreground hover:text-white text-xs font-bold rounded-xl transition-all duration-300 active:scale-95 group-hover:bg-primary group-hover:text-white border border-border group-hover:border-primary shadow-sm"
          >
            <ShoppingCart className="w-3.5 h-3.5" />
            Mua
          </button>
        </div>
      </div>
      
    </div>
  );
}
