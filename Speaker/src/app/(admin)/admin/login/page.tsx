'use client';

import React, { useState } from 'react';
import { signIn } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { Lock, User, Sparkles, AlertCircle } from 'lucide-react';
import Link from 'next/link';

export default function AdminLoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username || !password) return;

    setIsLoading(true);
    setError('');

    try {
      const result = await signIn('credentials', {
        redirect: false,
        username,
        password,
      });

      if (result?.error) {
        setError('Tên đăng nhập hoặc mật khẩu không chính xác.');
      } else {
        router.push('/admin');
        router.refresh();
      }
    } catch (err) {
      console.error(err);
      setError('Đã xảy ra lỗi kết nối. Vui lòng thử lại.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center bg-background px-4">
      {/* Background radial glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[30rem] h-[30rem] rounded-full bg-orange-500/5 blur-[120px] pointer-events-none" />

      <div className="w-full max-w-md bg-card border border-border rounded-3xl p-8 shadow-2xl relative z-10 space-y-6 animate-fade-in-up">
        
        {/* Header */}
        <div className="text-center space-y-2">
          <Link href="/" className="inline-flex items-center gap-1.5 px-3 py-1 bg-input-bg border border-border rounded-full text-[10px] font-bold text-muted-text tracking-wider hover:text-primary hover:border-primary transition-colors">
            <Sparkles className="w-3 h-3 text-primary animate-pulse" />
            VỀ CỬA HÀNG POYKEN
          </Link>
          
          <h1 className="text-2xl font-black text-foreground uppercase pt-2">Đăng Nhập Quản Trị</h1>
          <p className="text-xs text-muted-text max-w-[280px] mx-auto leading-relaxed">
            Nhập tài khoản quản lý hệ thống bán hàng và đơn hàng Poyken Sound.
          </p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="p-3.5 bg-red-500/10 border border-red-500/20 text-red-400 rounded-xl flex items-start gap-2 text-xs animate-pulse">
            <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4 text-left">
          
          {/* Username */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Tên Đăng Nhập</label>
            <div className="relative">
              <input
                type="text"
                required
                placeholder="Nhập tên đăng nhập (Thử: admin)..."
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl pl-10 pr-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all"
              />
              <User className="w-4 h-4 text-muted-text/80 absolute left-3.5 top-3.5" />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Mật Khẩu</label>
            <div className="relative">
              <input
                type="password"
                required
                placeholder="Nhập mật khẩu (Thử: admin123)..."
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl pl-10 pr-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all"
              />
              <Lock className="w-4 h-4 text-muted-text/80 absolute left-3.5 top-3.5" />
            </div>
          </div>

          {/* Helper instructions */}
          <div className="p-3 bg-input-bg border border-border rounded-xl text-[10px] text-muted-text leading-normal">
            * Tài khoản demo hệ thống: <strong className="font-bold text-foreground">admin</strong> / mật khẩu: <strong className="font-bold text-foreground">admin123</strong>
          </div>

          {/* Submit */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3.5 bg-input-bg border border-border hover:bg-primary hover:text-white hover:border-primary text-foreground font-extrabold text-xs uppercase tracking-wider rounded-xl transition-all shadow-sm flex items-center justify-center gap-1.5 disabled:opacity-50 btn-premium"
          >
            {isLoading ? 'Đang xác thực...' : 'ĐĂNG NHẬP HỆ THỐNG'}
          </button>

        </form>

      </div>
    </div>
  );
}
