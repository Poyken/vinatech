'use client';

import React from 'react';
import { Product } from '../lib/types';
import { useCart } from '../context/CartContext';
import { ShoppingCart, Star, Eye } from 'lucide-react';
import Link from 'next/link';

interface ProductCardProps {
  product: Product;
}

export default function ProductCard({ product }: ProductCardProps) {
  const { addToCart } = useCart();

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const discount = product.originalPrice 
    ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)
    : 0;

  return (
    <div className="group relative bg-card border border-stone-200/80 rounded-2xl overflow-hidden hover-glow">
      
      {/* Discount Badge */}
      {discount > 0 && (
        <span className="absolute top-3 left-3 z-10 bg-primary text-white text-[10px] font-black uppercase px-2 py-0.5 rounded-md tracking-wider">
          -{discount}%
        </span>
      )}

      {/* Speaker Image Slot */}
      <div className="relative aspect-square w-full bg-stone-100/60 flex items-center justify-center overflow-hidden border-b border-stone-200/80">
        {/* Dynamic sound wave visualizer on card hover */}
        <div className="absolute inset-0 bg-gradient-to-tr from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        
        {/* Image rendering */}
        {product.images && product.images.length > 0 ? (
          <img 
            src={product.images[0]} 
            alt={product.name} 
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          />
        ) : (
          <div className="text-6xl transform group-hover:scale-110 transition-transform duration-500 select-none">
            🔊
          </div>
        )}
        
        <span className="absolute top-3 right-3 text-[10px] bg-white/90 backdrop-blur-sm text-stone-600 font-bold px-2 py-0.5 rounded border border-stone-200/40">
          {product.type}
        </span>

        {/* Hover Quick View / Shop Controls */}
        <div className="absolute inset-0 bg-black/10 backdrop-blur-[1px] flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100 transition-all duration-300">
          <Link
            href={`/product/${product.slug}`}
            className="p-3 bg-white hover:bg-stone-50 text-stone-800 rounded-full hover:scale-110 transition-all shadow-lg border border-stone-200"
            title="Xem chi tiết"
          >
            <Eye className="w-5 h-5 text-stone-600" />
          </Link>
          <button
            onClick={() => addToCart(product)}
            className="p-3 bg-primary hover:bg-orange-700 text-white rounded-full hover:scale-110 transition-all shadow-lg shadow-primary/20"
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
          <span className="text-[11px] font-bold uppercase tracking-widest text-stone-500">
            {product.brand}
          </span>
          {/* Name */}
          <Link href={`/product/${product.slug}`}>
            <h3 className="font-bold text-stone-900 text-base mt-1 line-clamp-1 group-hover:text-primary transition-colors">
              {product.name}
            </h3>
          </Link>
          {/* Rating */}
          <div className="flex items-center gap-1.5 mt-2">
            <div className="flex text-amber-500">
              {Array.from({ length: 5 }).map((_, i) => (
                <Star
                  key={i}
                  className={`w-3 h-3 ${
                    i < Math.floor(product.rating) 
                      ? 'fill-amber-500 text-amber-500' 
                      : 'text-stone-200 fill-stone-100'
                  }`}
                />
              ))}
            </div>
            <span className="text-[11px] font-semibold text-stone-500">
              {product.rating}
            </span>
          </div>
        </div>

        {/* Pricing & Add to Cart */}
        <div className="flex items-center justify-between gap-2 mt-4 pt-3 border-t border-stone-100">
          <div className="flex flex-col">
            {product.originalPrice && (
              <span className="text-xs text-stone-400 line-through">
                {formatPrice(product.originalPrice)}
              </span>
            )}
            <span className="font-extrabold text-base text-primary">
              {formatPrice(product.price)}
            </span>
          </div>

          <button
            onClick={() => addToCart(product)}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-stone-100 hover:bg-primary text-stone-700 hover:text-white text-xs font-semibold rounded-lg transition-all active:scale-95 group-hover:bg-primary group-hover:text-white"
          >
            <ShoppingCart className="w-3.5 h-3.5" />
            Mua
          </button>
        </div>
      </div>
      
    </div>
  );
}
