import React from 'react';
import Header from '../../components/Header';
import Footer from '../../components/Footer';
import CartDrawer from '../../components/CartDrawer';
import PersistentAudioPlayer from '../../components/shop/PersistentAudioPlayer';
import ProductCompareModal from '../../components/shop/ProductCompareModal';

export default function StoreLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex flex-col bg-background text-foreground font-sans">
      <Header />
      <main className="flex-1 flex flex-col">
        {children}
      </main>
      <Footer />
      <CartDrawer />
      <PersistentAudioPlayer />
      <ProductCompareModal />
    </div>
  );
}
