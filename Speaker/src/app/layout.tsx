import type { Metadata } from 'next';
import { Inter, Plus_Jakarta_Sans } from 'next/font/google';
import './globals.css';
import { CartProvider } from '../context/CartContext';
import { ThemeProvider } from '../context/ThemeContext';
import { ToastProvider } from '../context/ToastContext';
import { AudioProvider } from '../context/AudioContext';
import { CompareProvider } from '../context/CompareContext';

const inter = Inter({
  variable: '--font-inter',
  subsets: ['latin', 'vietnamese'],
});

const plusJakartaSans = Plus_Jakarta_Sans({
  variable: '--font-plus-jakarta',
  subsets: ['latin', 'vietnamese'],
});

export const metadata: Metadata = {
  title: 'Poyken Sound | Thế Giới Loa Hi-Fi & Studio Cao Cấp',
  description: 'Nhà phân phối loa chính hãng JBL, Marshall, KEF, Klipsch uy tín. Âm thanh đỉnh cao, giao hàng miễn phí toàn quốc.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="vi"
      className={`${inter.variable} ${plusJakartaSans.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-background text-foreground font-sans selection:bg-primary/20 selection:text-primary">
        <ThemeProvider>
          <ToastProvider>
            <AudioProvider>
              <CompareProvider>
                <CartProvider>
                  {children}
                </CartProvider>
              </CompareProvider>
            </AudioProvider>
          </ToastProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
