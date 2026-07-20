'use client';

import React from 'react';
import { useCart } from '../context/CartContext';
import { useToast } from '../context/ToastContext';
import { X, Trash2, Plus, Minus, ShoppingBag, Truck, Sparkles } from 'lucide-react';
import Link from 'next/link';

export default function CartDrawer() {
  const { cart, cartTotal, isCartOpen, setCartOpen, updateQuantity, removeFromCart } = useCart();
  const { showToast } = useToast();

  if (!isCartOpen) return null;

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const freeShippingThreshold = 2000000;
  const shippingProgress = Math.min(100, (cartTotal / freeShippingThreshold) * 100);
  const remainingForFreeShipping = Math.max(0, freeShippingThreshold - cartTotal);

  const handleRemove = (productId: string, productName: string) => {
    removeFromCart(productId);
    showToast('Đã xóa khỏi giỏ hàng', productName, 'info');
  };

  return (
    <div className="fixed inset-0 z-50 overflow-hidden text-left animate-fade-in">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-md transition-opacity duration-300"
        onClick={() => setCartOpen(false)}
      />

      <div className="absolute inset-y-0 right-0 max-w-full flex pl-10">
        {/* Panel */}
        <div className="w-screen max-w-md bg-card/95 backdrop-blur-2xl border-l border-border flex flex-col shadow-2xl shadow-black/80 animate-in slide-in-from-right duration-400 ease-[cubic-bezier(0.16,1,0.3,1)]">
          {/* Header */}
          <div className="px-6 py-5 border-b border-border flex items-center justify-between">
            <h2 className="text-lg font-black text-foreground flex items-center gap-2 uppercase tracking-wide">
              <ShoppingBag className="w-5 h-5 text-primary" />
              Giỏ Hàng ({cart.reduce((s,i) => s + i.quantity, 0)})
            </h2>
            <button 
              onClick={() => setCartOpen(false)}
              className="p-2 rounded-xl text-muted-text hover:text-foreground hover:bg-input-bg transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Free Shipping Progress Bar */}
          <div className="px-6 py-3.5 bg-input-bg/70 border-b border-border space-y-1.5">
            <div className="flex items-center justify-between text-[11px] font-bold">
              <span className="flex items-center gap-1 text-primary">
                <Truck className="w-3.5 h-3.5" />
                {shippingProgress >= 100 ? (
                  <span className="text-green-500 font-extrabold flex items-center gap-1">
                    <Sparkles className="w-3 h-3 text-amber-500 animate-spin-slow" />
                    Đã Đủ Điều Kiện Miễn Phí Giao Hàng!
                  </span>
                ) : (
                  <span>Mua thêm <strong className="text-foreground">{formatPrice(remainingForFreeShipping)}</strong> để Freeship</span>
                )}
              </span>
              <span className="text-muted-text">{Math.round(shippingProgress)}%</span>
            </div>
            <div className="w-full h-1.5 bg-border rounded-full overflow-hidden">
              <div 
                className="h-full bg-gradient-to-r from-orange-500 to-amber-500 transition-all duration-500 rounded-full"
                style={{ width: `${shippingProgress}%` }}
              />
            </div>
          </div>

          {/* Cart Content */}
          <div className="flex-1 py-6 overflow-y-auto px-6 space-y-4">
            {cart.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center space-y-4">
                <div className="p-5 bg-input-bg rounded-full border border-border text-muted-text">
                  <ShoppingBag className="w-12 h-12" />
                </div>
                <div>
                  <h3 className="text-lg font-extrabold text-foreground uppercase">Giỏ hàng trống</h3>
                  <p className="text-xs text-muted-text mt-1 max-w-xs mx-auto">Bạn chưa chọn thêm chiếc loa nào vào giỏ hàng Poyken Sound.</p>
                </div>
                <button 
                  onClick={() => setCartOpen(false)}
                  className="px-6 py-3 bg-primary hover:bg-orange-700 text-white font-extrabold rounded-full transition-all hover:scale-105 shadow-md shadow-primary/20 text-xs uppercase tracking-wider btn-premium"
                >
                  Khám Phá Cửa Hàng
                </button>
              </div>
            ) : (
              cart.map((item) => (
                <div 
                  key={item.product.id}
                  className="flex items-center gap-4 p-3.5 bg-input-bg/40 rounded-2xl border border-border hover:border-primary/30 transition-all duration-300 hover:shadow-md"
                >
                  {/* Speaker Image */}
                  <div className="relative w-20 h-20 bg-input-bg rounded-xl flex items-center justify-center overflow-hidden border border-border flex-shrink-0">
                    {item.product.images && item.product.images.length > 0 ? (
                      <img src={item.product.images[0]} alt={item.product.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="absolute inset-0 bg-gradient-to-tr from-primary/10 to-transparent flex items-center justify-center text-4xl">
                        🔊
                      </div>
                    )}
                  </div>

                  {/* Speaker Details */}
                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-bold text-foreground truncate">{item.product.name}</h4>
                    <p className="text-[10px] text-muted-text uppercase font-semibold mt-0.5">{item.product.brand} | {item.product.type}</p>
                    <p className="text-xs font-black text-primary mt-1">{formatPrice(item.product.price)}</p>

                    {/* Quantity Selector */}
                    <div className="flex items-center gap-2 mt-2">
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity - 1)}
                        className="p-1 rounded-md bg-card text-muted-text hover:text-foreground hover:bg-card-hover border border-border transition-colors"
                      >
                        <Minus className="w-3.5 h-3.5" />
                      </button>
                      <span className="text-xs text-foreground font-bold w-6 text-center">{item.quantity}</span>
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity + 1)}
                        className="p-1 rounded-md bg-card text-muted-text hover:text-foreground hover:bg-card-hover border border-border transition-colors"
                        disabled={item.quantity >= item.product.stock}
                      >
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>

                  {/* Delete Button */}
                  <button 
                    onClick={() => handleRemove(item.product.id, item.product.name)}
                    className="p-2 text-muted-text hover:text-red-400 hover:bg-red-500/10 rounded-xl transition-colors flex-shrink-0 ml-auto"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))
            )}
          </div>

          {/* Footer Panel */}
          {cart.length > 0 && (
            <div className="border-t border-border bg-card/95 px-6 py-6 space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-muted-text text-xs font-bold uppercase">Tổng thanh toán</span>
                <span className="text-xl font-black text-primary">{formatPrice(cartTotal)}</span>
              </div>
              
              <div className="grid grid-cols-1 gap-2 pt-2">
                <Link
                  href="/checkout"
                  onClick={() => setCartOpen(false)}
                  className="w-full py-3.5 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-extrabold text-center uppercase tracking-wider text-xs rounded-xl hover:shadow-xl hover:shadow-primary/20 hover:scale-[1.01] active:scale-[0.99] transition-all shadow-md btn-premium"
                >
                  Thanh Toán Ngay
                </Link>
                <button
                  onClick={() => setCartOpen(false)}
                  className="w-full py-3 bg-input-bg border border-border hover:border-border-hover hover:bg-card-hover text-foreground font-bold text-center uppercase tracking-wider text-xs rounded-xl transition-all"
                >
                  Tiếp Tục Chọn Loa
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
