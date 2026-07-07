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
        <div className="w-screen max-w-md bg-white border-l border-stone-200 flex flex-col shadow-2xl animate-in slide-in-from-right duration-300">
          {/* Header */}
          <div className="px-6 py-5 border-b border-stone-200 flex items-center justify-between">
            <h2 className="text-xl font-bold text-stone-850 flex items-center gap-2">
              <ShoppingBag className="w-5 h-5 text-primary" />
              Giỏ Hàng Của Bạn
            </h2>
            <button 
              onClick={() => setCartOpen(false)}
              className="p-1 rounded-full text-stone-400 hover:text-stone-800 hover:bg-stone-100 transition-colors"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Cart Content */}
          <div className="flex-1 py-6 overflow-y-auto px-6 space-y-4">
            {cart.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center space-y-4">
                <div className="p-4 bg-stone-50 rounded-full border border-stone-200">
                  <ShoppingBag className="w-12 h-12 text-stone-400" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-stone-800">Giỏ hàng trống</h3>
                  <p className="text-sm text-stone-500 mt-1">Bạn chưa thêm sản phẩm loa nào vào giỏ hàng.</p>
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
                  className="flex items-center gap-4 p-3 bg-stone-50 rounded-xl border border-stone-200 hover:border-stone-300 hover:shadow-sm transition-all"
                >
                  {/* Speaker Image */}
                  <div className="relative w-20 h-20 bg-white rounded-lg flex items-center justify-center overflow-hidden border border-stone-200 flex-shrink-0">
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
                    <h4 className="text-sm font-bold text-stone-900 truncate">{item.product.name}</h4>
                    <p className="text-xs text-stone-500 mt-0.5">{item.product.brand} | {item.product.type}</p>
                    <p className="text-sm font-semibold text-primary mt-1">{formatPrice(item.product.price)}</p>

                    {/* Quantity Selector */}
                    <div className="flex items-center gap-2 mt-2">
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity - 1)}
                        className="p-1 rounded-md bg-stone-200/60 text-stone-600 hover:text-stone-900 hover:bg-stone-200 transition-colors"
                      >
                        <Minus className="w-3.5 h-3.5" />
                      </button>
                      <span className="text-sm text-stone-850 font-bold w-6 text-center">{item.quantity}</span>
                      <button
                        onClick={() => updateQuantity(item.product.id, item.quantity + 1)}
                        className="p-1 rounded-md bg-stone-200/60 text-stone-600 hover:text-stone-900 hover:bg-stone-200 transition-colors"
                        disabled={item.quantity >= item.product.stock}
                      >
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>

                  {/* Delete Button */}
                  <button 
                    onClick={() => removeFromCart(item.product.id)}
                    className="p-2 text-stone-400 hover:text-red-650 hover:bg-red-50/80 rounded-lg transition-colors flex-shrink-0"
                  >
                    <Trash2 className="w-5 h-5" />
                  </button>
                </div>
              ))
            )}
          </div>

          {/* Footer Panel */}
          {cart.length > 0 && (
            <div className="border-t border-stone-200 bg-stone-50/95 px-6 py-6 space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-stone-500 text-sm">Tổng cộng ({cart.reduce((s,i) => s + i.quantity, 0)} chiếc)</span>
                <span className="text-xl font-black text-primary">{formatPrice(cartTotal)}</span>
              </div>
              <p className="text-xs text-stone-450">Thuế và phí giao hàng sẽ được tính ở trang thanh toán.</p>
              
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
                  className="w-full py-2.5 bg-white border border-stone-250 hover:border-stone-350 hover:bg-stone-50 text-stone-700 font-bold text-center rounded-xl transition-all text-sm"
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
