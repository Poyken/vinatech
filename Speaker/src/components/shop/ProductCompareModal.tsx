'use client';

import React from 'react';
import { useCompare } from '../../context/CompareContext';
import { useCart } from '../../context/CartContext';
import { useToast } from '../../context/ToastContext';
import Modal from '../ui/Modal';
import { ShoppingCart, Trash2, CheckCircle2 } from 'lucide-react';

export default function ProductCompareModal() {
  const { compareItems, removeFromCompare, clearCompare, isCompareModalOpen, setCompareModalOpen } = useCompare();
  const { addToCart } = useCart();
  const { showToast } = useToast();

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  if (compareItems.length === 0) return null;

  // Gather unique technical spec keys across all compared products
  const specKeysSet = new Set<string>();
  compareItems.forEach((p) => {
    if (p.specs) {
      Object.keys(p.specs).forEach((k) => specKeysSet.add(k));
    }
  });
  const specKeys = Array.from(specKeysSet);

  return (
    <Modal
      isOpen={isCompareModalOpen}
      onClose={() => setCompareModalOpen(false)}
      title={`So Sánh Loa (${compareItems.length}/3)`}
      maxWidth="4xl"
    >
      <div className="space-y-6 text-left">
        <div className="flex justify-between items-center pb-2 border-b border-border">
          <p className="text-xs text-muted-text">
            Đối chiếu thông số kỹ thuật chi tiết giữa các dòng loa chọn lọc.
          </p>
          <button
            onClick={clearCompare}
            className="text-xs text-red-400 hover:text-red-500 font-bold flex items-center gap-1 transition-colors"
          >
            <Trash2 className="w-3.5 h-3.5" />
            Xóa danh sách
          </button>
        </div>

        {/* Comparison Grid Table */}
        <div className="overflow-x-auto border border-border rounded-2xl bg-input-bg/30">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-border bg-card">
                <th className="p-4 w-40 text-xs font-bold uppercase text-muted-text">Thông số</th>
                {compareItems.map((product) => (
                  <th key={product.id} className="p-4 min-w-[220px] align-top border-l border-border relative">
                    <button
                      onClick={() => removeFromCompare(product.id)}
                      className="absolute top-2 right-2 p-1 text-muted-text hover:text-red-500 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                    <div className="w-20 h-20 bg-input-bg border border-border rounded-xl overflow-hidden mb-3">
                      {product.images?.[0] && (
                        <img src={product.images[0]} alt={product.name} className="w-full h-full object-cover" />
                      )}
                    </div>
                    <span className="text-[10px] text-primary font-extrabold uppercase tracking-widest block">{product.brand}</span>
                    <h4 className="text-xs font-bold text-foreground line-clamp-1">{product.name}</h4>
                    <span className="text-sm font-black text-primary block mt-1">{formatPrice(product.price)}</span>

                    <button
                      onClick={() => {
                        addToCart(product);
                        showToast('Đã thêm vào giỏ hàng', product.name);
                      }}
                      className="mt-3 w-full py-2 bg-primary hover:bg-orange-700 text-white font-extrabold text-[11px] uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5 shadow-sm"
                    >
                      <ShoppingCart className="w-3.5 h-3.5" />
                      Thêm giỏ hàng
                    </button>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-border text-xs">
              {/* Type row */}
              <tr>
                <td className="p-4 font-bold text-muted-text bg-card/50 uppercase text-[11px]">Kiểu loa</td>
                {compareItems.map((p) => (
                  <td key={p.id} className="p-4 border-l border-border font-semibold text-foreground">
                    {p.type}
                  </td>
                ))}
              </tr>

              {/* Rating row */}
              <tr>
                <td className="p-4 font-bold text-muted-text bg-card/50 uppercase text-[11px]">Đánh giá</td>
                {compareItems.map((p) => (
                  <td key={p.id} className="p-4 border-l border-border font-semibold text-amber-500">
                    ★ {p.rating} / 5.0
                  </td>
                ))}
              </tr>

              {/* Stock row */}
              <tr>
                <td className="p-4 font-bold text-muted-text bg-card/50 uppercase text-[11px]">Tình trạng kho</td>
                {compareItems.map((p) => (
                  <td key={p.id} className="p-4 border-l border-border">
                    {p.stock > 0 ? (
                      <span className="text-green-500 font-bold flex items-center gap-1">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        Còn hàng ({p.stock})
                      </span>
                    ) : (
                      <span className="text-red-400 font-bold">Hết hàng</span>
                    )}
                  </td>
                ))}
              </tr>

              {/* Dynamic specs rows */}
              {specKeys.map((key) => (
                <tr key={key}>
                  <td className="p-4 font-bold text-muted-text bg-card/50 uppercase text-[11px]">{key}</td>
                  {compareItems.map((p) => (
                    <td key={p.id} className="p-4 border-l border-border text-foreground/90">
                      {p.specs?.[key] || '—'}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Modal>
  );
}
