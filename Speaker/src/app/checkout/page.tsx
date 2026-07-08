'use client';

import React, { useState } from 'react';
import { useCart } from '../../context/CartContext';
import { Order } from '../../lib/types';
import Link from 'next/link';
import { ShoppingBag, CreditCard, CheckCircle, ArrowLeft, Send } from 'lucide-react';

export default function CheckoutPage() {
  const { cart, cartTotal, clearCart } = useCart();
  
  // Form fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [paymentMethod, setPaymentMethod] = useState('COD'); // COD or BankTransfer
  
  // Checkout progress
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successOrder, setSuccessOrder] = useState<Order | null>(null);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const handlePlaceOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    if (cart.length === 0 || isSubmitting) return;

    setIsSubmitting(true);

    try {
      const response = await fetch('/api/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          customerName: name,
          customerEmail: email,
          customerPhone: phone,
          address: address,
          paymentMethod: paymentMethod,
          total: cartTotal,
          items: cart.map(item => ({
            productId: item.product.id,
            quantity: item.quantity,
            price: item.product.price
          }))
        })
      });

      if (!response.ok) {
        throw new Error('Failed to create order');
      }

      const order = await response.json();
      setSuccessOrder(order);
      clearCart();
    } catch (err) {
      console.error('Checkout failed:', err);
      alert('Có lỗi xảy ra khi tạo đơn hàng. Vui lòng thử lại!');
    } finally {
      setIsSubmitting(false);
    }
  };

  // If order placed successfully, show success panel
  if (successOrder) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-16 text-center space-y-6 flex-1 flex flex-col items-center justify-center text-left">
        <div className="p-4 bg-green-500/10 border border-green-500/20 text-green-600 rounded-full animate-bounce">
          <CheckCircle className="w-16 h-16" />
        </div>
        
        <div className="space-y-2 text-center">
          <span className="text-xs font-black uppercase text-green-600 tracking-wider">Đặt Hàng Thành Công</span>
          <h1 className="text-3xl sm:text-4xl font-extrabold text-foreground uppercase">Cảm ơn bạn đã mua hàng!</h1>
          <p className="text-muted-text text-sm max-w-md mx-auto leading-relaxed">
            Đơn hàng của bạn đã được tiếp nhận và đang trong quá trình xử lý. Nhân viên Poyken Sound sẽ liên hệ với bạn trong vòng 15 phút.
          </p>
        </div>

        {/* Invoice Summary */}
        <div className="w-full bg-card border border-border rounded-2xl p-6 text-left space-y-4 max-w-lg shadow-sm">
          <div className="flex justify-between pb-3 border-b border-border">
            <span className="text-xs text-muted-text font-bold uppercase">Mã đơn hàng</span>
            <span className="text-sm font-mono font-bold text-foreground uppercase">{successOrder.id.substring(4, 12)}</span>
          </div>
          <div className="space-y-2 text-xs">
            <div className="flex justify-between">
              <span className="text-muted-text">Họ và tên:</span>
              <span className="font-semibold text-foreground">{successOrder.customerName}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-text">Số điện thoại:</span>
              <span className="font-semibold text-foreground">{successOrder.customerPhone}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-text">Phương thức:</span>
              <span className="font-semibold text-foreground uppercase">
                {successOrder.paymentMethod === 'COD' ? 'Thanh toán COD' : 'Chuyển khoản NH'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-text">Địa chỉ giao:</span>
              <span className="font-semibold text-foreground text-right max-w-[200px] truncate">{successOrder.address}</span>
            </div>
          </div>
          <div className="flex justify-between pt-3 border-t border-border text-sm">
            <span className="font-bold text-muted-text">Tổng thanh toán:</span>
            <span className="font-bold text-primary">{formatPrice(successOrder.total)}</span>
          </div>
        </div>

        <div className="pt-4 flex flex-wrap gap-4 justify-center">
          <Link
            href="/catalog"
            className="px-8 py-3.5 bg-gradient-to-r from-orange-600 to-amber-600 text-white font-extrabold tracking-wide rounded-full transition-all hover:scale-105 active:scale-95 text-sm shadow-md shadow-primary/10"
          >
            Tiếp Tục Mua Sắm
          </Link>
          <Link
            href="/"
            className="px-8 py-3.5 bg-input-bg border border-border hover:border-border-hover text-foreground font-bold rounded-full transition-all text-sm"
          >
            Quay Về Trang Chủ
          </Link>
        </div>
      </div>
    );
  }

  // If cart is empty, show prompt
  if (cart.length === 0) {
    return (
      <div className="max-w-md mx-auto px-4 py-20 text-center space-y-6 flex-1 flex flex-col items-center justify-center">
        <div className="p-4 bg-input-bg border border-border rounded-full text-muted-text shadow-sm">
          <ShoppingBag className="w-16 h-16" />
        </div>
        <div className="space-y-1.5">
          <h1 className="text-2xl font-black text-foreground uppercase">Giỏ hàng trống</h1>
          <p className="text-sm text-muted-text leading-relaxed max-w-xs mx-auto">
            Vui lòng thêm sản phẩm loa vào giỏ hàng trước khi tiến hành thanh toán đơn hàng.
          </p>
        </div>
        <Link
          href="/catalog"
          className="px-6 py-2.5 bg-primary hover:bg-orange-700 text-white font-extrabold rounded-full transition-all hover:scale-105 text-sm shadow-md"
        >
          Đến Cửa Hàng
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex-1 text-left">
      {/* Back button */}
      <Link href="/catalog" className="inline-flex items-center gap-1 text-xs font-bold text-muted-text hover:text-primary transition-colors uppercase tracking-wider mb-6">
        <ArrowLeft className="w-4 h-4" />
        Quay lại chọn loa
      </Link>

      <div className="mb-10">
        <span className="text-xs font-black uppercase text-primary tracking-widest">Thanh toán đơn hàng</span>
        <h1 className="text-3xl font-extrabold text-foreground uppercase mt-1">Thông Tin Đơn Hàng</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-start">
        
        {/* Left: Customer Info Form */}
        <form onSubmit={handlePlaceOrder} className="lg:col-span-7 bg-card border border-border p-6 sm:p-8 rounded-3xl space-y-6 shadow-sm">
          <h2 className="text-lg font-bold text-foreground uppercase border-l-2 border-primary pl-3">
            Thông Tin Giao Hàng
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Name */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Họ và tên *</label>
              <input
                type="text"
                required
                placeholder="Nhập họ tên của bạn..."
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
            
            {/* Phone */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Số điện thoại *</label>
              <input
                type="tel"
                required
                placeholder="Ví dụ: 0987xxxxxx"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
          </div>

          {/* Email */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Địa chỉ Email *</label>
            <input
              type="email"
              required
              placeholder="Nhập địa chỉ email để nhận hóa đơn..."
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
            />
          </div>

          {/* Address */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Địa chỉ nhận hàng *</label>
            <textarea
              required
              rows={3}
              placeholder="Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố..."
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 resize-none"
            />
          </div>

          {/* Payment Method */}
          <div className="space-y-3">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Phương thức thanh toán</label>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              
              {/* COD */}
              <div
                onClick={() => setPaymentMethod('COD')}
                className={`p-4 rounded-2xl border cursor-pointer flex items-center gap-3 transition-all ${
                  paymentMethod === 'COD' 
                    ? 'bg-primary/5 border-primary shadow-sm' 
                    : 'bg-input-bg border-border hover:border-border-hover'
                }`}
              >
                <div className={`w-4 h-4 rounded-full border flex items-center justify-center flex-shrink-0 ${
                  paymentMethod === 'COD' ? 'border-primary' : 'border-border/80'
                }`}>
                  {paymentMethod === 'COD' && <div className="w-2.5 h-2.5 rounded-full bg-primary" />}
                </div>
                <div>
                  <h3 className="text-xs font-bold text-foreground uppercase">Thanh Toán COD</h3>
                  <p className="text-[10px] text-muted-text mt-0.5">Trả tiền khi nhận hàng</p>
                </div>
              </div>

              {/* Bank Transfer */}
              <div
                onClick={() => setPaymentMethod('BankTransfer')}
                className={`p-4 rounded-2xl border cursor-pointer flex items-center gap-3 transition-all ${
                  paymentMethod === 'BankTransfer' 
                    ? 'bg-primary/5 border-primary shadow-sm' 
                    : 'bg-input-bg border-border hover:border-border-hover'
                }`}
              >
                <div className={`w-4 h-4 rounded-full border flex items-center justify-center flex-shrink-0 ${
                  paymentMethod === 'BankTransfer' ? 'border-primary' : 'border-border/80'
                }`}>
                  {paymentMethod === 'BankTransfer' && <div className="w-2.5 h-2.5 rounded-full bg-primary" />}
                </div>
                <div>
                  <h3 className="text-xs font-bold text-foreground uppercase">Chuyển Khoản Ngân Hàng</h3>
                  <p className="text-[10px] text-muted-text mt-0.5">Thanh toán qua mã QR</p>
                </div>
              </div>

            </div>
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full py-4 bg-gradient-to-r from-orange-600 to-amber-600 text-white font-extrabold uppercase text-xs tracking-wider rounded-xl transition-all hover:scale-[1.01] active:scale-[0.99] disabled:opacity-50 flex items-center justify-center gap-1.5 shadow-md shadow-primary/10"
          >
            {isSubmitting ? (
              'Đang Xử Lý Đơn Hàng...'
            ) : (
              <>
                <Send className="w-4 h-4" />
                Xác Nhận Đặt Hàng ({formatPrice(cartTotal)})
              </>
            )}
          </button>
        </form>

        {/* Right: Order Summary Panel */}
        <aside className="lg:col-span-5 bg-card border border-border p-6 rounded-3xl space-y-6 shadow-sm">
          <h2 className="text-base font-extrabold text-foreground uppercase border-l-2 border-primary pl-3">
            Tóm Tắt Đơn Hàng
          </h2>

          <div className="max-h-[300px] overflow-y-auto pr-2 space-y-4">
            {cart.map((item) => (
              <div 
                key={item.product.id}
                className="flex items-center gap-3 py-2 border-b border-border/60 last:border-0"
              >
                {/* Speaker image */}
                <div className="w-12 h-12 bg-input-bg border border-border rounded-lg flex items-center justify-center overflow-hidden flex-shrink-0">
                  {item.product.images && item.product.images.length > 0 ? (
                    <img src={item.product.images[0]} alt="" className="w-full h-full object-cover" />
                  ) : (
                    <span className="text-xl">🔊</span>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="text-xs font-bold text-foreground truncate">{item.product.name}</h4>
                  <span className="text-[10px] text-muted-text font-semibold uppercase">{item.product.brand} x {item.quantity}</span>
                </div>
                <span className="text-xs font-bold text-foreground flex-shrink-0">
                  {formatPrice(item.product.price * item.quantity)}
                </span>
              </div>
            ))}
          </div>

          {/* Pricing breakdown */}
          <div className="pt-4 border-t border-border space-y-2 text-xs">
            <div className="flex justify-between">
              <span className="text-muted-text font-bold uppercase">Tổng giá sản phẩm</span>
              <span className="font-semibold text-foreground">{formatPrice(cartTotal)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-text font-bold uppercase">Phí vận chuyển</span>
              <span className="font-extrabold text-green-600 uppercase">Miễn Phí</span>
            </div>
            <div className="flex justify-between pt-3 border-t border-border text-sm">
              <span className="font-bold text-foreground">Cần thanh toán</span>
              <span className="font-extrabold text-primary">{formatPrice(cartTotal)}</span>
            </div>
          </div>
          
          <div className="p-4 bg-input-bg border border-border rounded-2xl flex gap-3 items-start">
            <CreditCard className="w-5 h-5 text-primary flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="text-xs font-bold text-foreground uppercase">Thông Tin Thanh Toán</h4>
              <p className="text-[10px] text-muted-text leading-normal mt-0.5">
                Nếu chọn chuyển khoản, mã QR thanh toán kèm hướng dẫn chi tiết sẽ được gửi đến email của bạn ngay sau khi hoàn tất đặt hàng.
              </p>
            </div>
          </div>
        </aside>

      </div>
    </div>
  );
}
