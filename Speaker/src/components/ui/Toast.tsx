'use client';

import React from 'react';
import { CheckCircle2, AlertCircle, Info, X } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info';

interface ToastProps {
  type: ToastType;
  title: string;
  message?: string;
  onClose: () => void;
}

export default function Toast({ type, title, message, onClose }: ToastProps) {
  const getIcon = () => {
    switch (type) {
      case 'success':
        return <CheckCircle2 className="w-5 h-5 text-emerald-500 flex-shrink-0" />;
      case 'error':
        return <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0" />;
      case 'info':
      default:
        return <Info className="w-5 h-5 text-primary flex-shrink-0" />;
    }
  };

  return (
    <div className="flex items-start gap-3 p-4 rounded-2xl bg-card/95 backdrop-blur-xl border border-border shadow-xl shadow-black/10 text-foreground animate-fade-in-up">
      <div className="mt-0.5">{getIcon()}</div>
      <div className="flex-1 min-w-0 text-left">
        <h4 className="text-xs font-extrabold uppercase tracking-wide">{title}</h4>
        {message && <p className="text-[11px] text-muted-text mt-0.5 leading-normal">{message}</p>}
      </div>
      <button
        onClick={onClose}
        className="p-1 rounded-lg text-muted-text hover:text-foreground hover:bg-input-bg transition-colors"
      >
        <X className="w-4 h-4" />
      </button>
    </div>
  );
}
