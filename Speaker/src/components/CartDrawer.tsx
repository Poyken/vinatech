'use client';

import React from 'react';
import { useCart } from '../context/CartContext';
import { X, Trash2, Plus, Minus, ShoppingBag } from 'lucide-react';
import Link from 'next/link';

export default function CartDrawer() {
  const { cart, cartTotal, isCartOpen, setCartOpen, updateQuantity, removeFromCart } = useCart();

  if (!isCartOpen) return null;

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  return (
    <div className="fixed inset-0 z-50 overflow-hidden text-left">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity"
        onClick={() => setCartOpen(false)}
      />

      <div className="absolute inset-y-0 right-0 max-w-full flex pl-10">
        {/* Panel */}
        <div className="w-screen max-w-md bg-card border-l border-border flex flex-col shadow-2xl shadow-black/10 dark:shadow-black/80 animate-in slide-in-from-right duration-300">
          {/* Header */}
          <div className="px-6 py-5 border-b border-border flex items-center justify-between">
            <h2 className="text-xl font-bold text-foreground flex items-center gap-2">
              <ShoppingBag className="w-5 h-5 text-primary" />
              Giỏ Hàng Của Bạn
            </h2>
            <button 
              onClick={() => setCartOpen(false)}
              className="p-1 rounded-full text-muted-text hover:text-foreground hover:bg-card-hover transition-colors"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Cart Content */}
          <div className="flex-1 py-6 overflow-y-auto px-6 space-y-4">
            {cart.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center space-y-4">
                <div className="p-4 bg-input-bg rounded-full border border-border">
                  <ShoppingBag className="w-12 h-12 text-muted-text" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-foreground">Giỏ hàng trống</h3>
                  <p className="text-sm text-muted-text mt-1">Bạn chưa thêm sản phẩm loa nào vào giỏ hàng.</p>
                </div>
                <button 
                  onClick={() => setCartOpen(false)}
                  className="px-6 py-2.5 bg-primary hover:bg-orange-700 text-white font-bold rounded-full transition-all hover:scale-105 shadow-md shadow-primary/10 text-sm"
                >
                  Tiếp Tục Mua Sắm
                </button>
              </div>
            ) : (
              cart.map((item) => (
                <div 
                  key={item.product.id}
                  className="flex items-center gap-4 p-3 bg-muted-bg/40 rounded-xl border border-border hover:border-border-hover hover:shadow-sm transition-all"
                >
                  {/* Speaker Image */}
                  <div className="relative w-20 h-20 bg-input-bg rounded-lg flex items-center justify-center overflow-hidden border border-border flex-shrink-0">
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
                    <h4 className="text-sm font-bold text-foreground truncate">{item.product.name}</h4>
                    <p className="text-xs text-muted-text mt-0.5">{item.product.brand} | {item.product.type}</p>
                    <p className="text-sm font-semibold text-primary mt-1">{formatPrice(item.product.price)}</p>

                    {/* Quantity Selector */}
                    <div className="flex items-center gap-2 mt-2">
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity - 1)}
                        className="p-1 rounded-md bg-muted-bg text-muted-text hover:text-foreground hover:bg-card-hover border border-border/50 transition-colors"
                      >
                        <Minus className="w-3.5 h-3.5" />
                      </button>
                      <span className="text-sm text-foreground font-bold w-6 text-center">{item.quantity}</span>
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity + 1)}
                        className="p-1 rounded-md bg-muted-bg text-muted-text hover:text-foreground hover:bg-card-hover border border-border/50 transition-colors"
                        disabled={item.quantity >= item.product.stock}
                      >
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>

                  {/* Delete Button */}
                  <button 
                    onClick={() => removeFromCart(item.product.id)}
                    className="p-2 text-muted-text hover:text-red-400 hover:bg-red-950/20 rounded-lg transition-colors flex-shrink-0"
                  >
                    <Trash2 className="w-5 h-5" />
                  </button>
                </div>
              ))
            )}
          </div>

          {/* Footer Panel */}
          {cart.length > 0 && (
            <div className="border-t border-border bg-card/95 px-6 py-6 space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-muted-text text-sm">Tổng cộng ({cart.reduce((s,i) => s + i.quantity, 0)} chiếc)</span>
                <span className="text-xl font-black text-primary">{formatPrice(cartTotal)}</span>
              </div>
              <p className="text-xs text-muted-text/80">Thuế và phí giao hàng sẽ được tính ở trang thanh toán.</p>
              
              <div className="grid grid-cols-1 gap-2 pt-2">
                <Link
                  href="/checkout"
                  onClick={() => setCartOpen(false)}
                  className="w-full py-3 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-extrabold text-center rounded-xl hover:shadow-lg hover:shadow-primary/10 hover:scale-[1.01] active:scale-[0.99] transition-all text-sm shadow-md"
                >
                  Thanh Toán Ngay
                </Link>
                <button
                  onClick={() => setCartOpen(false)}
                  className="w-full py-2.5 bg-input-bg border border-border hover:border-border-hover hover:bg-card-hover text-foreground font-bold text-center rounded-xl transition-all text-sm"
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
