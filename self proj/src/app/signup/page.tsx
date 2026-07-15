"use client";

import React, { useActionState } from "react";
import Link from "next/link";
import { signup } from "@/app/auth/actions";
import { User, Mail, Lock, ArrowRight, UserPlus } from "lucide-react";

export default function SignupPage() {
  const [state, formAction, isPending] = useActionState(signup, null);

  return (
    <div className="min-h-screen flex items-center justify-center bg-radial from-slate-100 via-zinc-50 to-slate-200 px-4 relative overflow-hidden">
      {/* Các vòng tròn ánh sáng mờ tạo chiều sâu */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-indigo-500/5 rounded-full blur-3xl animate-pulse"></div>
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-500/5 rounded-full blur-3xl animate-pulse delay-75"></div>

      <div className="w-full max-w-md z-10">
        {/* Logo / Brand */}
        <div className="flex flex-col items-center mb-8">
          <div className="w-12 h-12 bg-linear-to-tr from-indigo-550 to-violet-550 rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-500/10 mb-4 transition-transform hover:scale-105 duration-300">
            <UserPlus className="w-6 h-6 text-white" />
          </div>
          <h2 className="text-2xl font-bold bg-clip-text text-transparent bg-linear-to-r from-zinc-800 to-zinc-950 tracking-tight">
            Tạo tài khoản mới
          </h2>
          <p className="text-sm text-zinc-500 mt-1">Bắt đầu trải nghiệm mua sắm tại Vinatech</p>
        </div>

        {/* Card Box với hiệu ứng Glassmorphism màu sáng */}
        <div className="bg-white/70 backdrop-blur-xl border border-zinc-200/80 rounded-3xl p-8 shadow-2xl shadow-zinc-200/50">
          <form action={formAction} className="space-y-5">
            {state?.error && (
              <div className="bg-red-500/5 border border-red-500/10 text-red-600 text-xs rounded-xl p-3 flex items-center gap-2">
                <span className="w-1.5 h-1.5 bg-red-550 rounded-full animate-ping"></span>
                <span>{state.error}</span>
              </div>
            )}

            {/* Full Name Field */}
            <div className="space-y-2">
              <label className="text-xs font-semibold text-zinc-500 uppercase tracking-wider block">
                Họ và Tên
              </label>
              <div className="relative group">
                <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-zinc-400 group-focus-within:text-indigo-600 transition-colors">
                  <User className="w-4 h-4" />
                </span>
                <input
                  name="fullName"
                  type="text"
                  placeholder="Nguyễn Văn A"
                  required
                  className="w-full pl-10 pr-4 py-3 bg-white/50 border border-zinc-200 rounded-2xl text-sm text-zinc-800 placeholder-zinc-400 focus:outline-hidden focus:border-indigo-500/80 focus:ring-4 focus:ring-indigo-500/5 transition-all duration-300"
                />
              </div>
            </div>

            {/* Email Field */}
            <div className="space-y-2">
              <label className="text-xs font-semibold text-zinc-500 uppercase tracking-wider block">
                Email
              </label>
              <div className="relative group">
                <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-zinc-400 group-focus-within:text-indigo-600 transition-colors">
                  <Mail className="w-4 h-4" />
                </span>
                <input
                  name="email"
                  type="email"
                  placeholder="name@company.com"
                  required
                  className="w-full pl-10 pr-4 py-3 bg-white/50 border border-zinc-200 rounded-2xl text-sm text-zinc-800 placeholder-zinc-400 focus:outline-hidden focus:border-indigo-500/80 focus:ring-4 focus:ring-indigo-500/5 transition-all duration-300"
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-2">
              <label className="text-xs font-semibold text-zinc-500 uppercase tracking-wider block">
                Mật khẩu
              </label>
              <div className="relative group">
                <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-zinc-400 group-focus-within:text-indigo-600 transition-colors">
                  <Lock className="w-4 h-4" />
                </span>
                <input
                  name="password"
                  type="password"
                  placeholder="•••••••• (Tối thiểu 6 ký tự)"
                  required
                  minLength={6}
                  className="w-full pl-10 pr-4 py-3 bg-white/50 border border-zinc-200 rounded-2xl text-sm text-zinc-800 placeholder-zinc-400 focus:outline-hidden focus:border-indigo-500/80 focus:ring-4 focus:ring-indigo-500/5 transition-all duration-300"
                />
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isPending}
              className="w-full py-3 px-4 bg-linear-to-r from-indigo-550 to-violet-550 text-white font-medium rounded-2xl text-sm shadow-lg shadow-indigo-500/15 hover:from-indigo-600 hover:to-violet-600 transition-all duration-300 active:scale-98 flex items-center justify-center gap-2 group disabled:opacity-50 disabled:pointer-events-none cursor-pointer"
            >
              {isPending ? (
                <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
              ) : (
                <>
                  <span>Đăng ký</span>
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>

          {/* Footer Card */}
          <div className="mt-8 pt-6 border-t border-zinc-150 text-center">
            <p className="text-xs text-zinc-500">
              Đã có tài khoản?{" "}
              <Link
                href="/login"
                className="text-indigo-600 hover:text-indigo-700 transition-colors font-semibold"
              >
                Đăng nhập
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
