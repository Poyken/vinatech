'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { Product } from '../lib/types';

interface CompareContextType {
  compareItems: Product[];
  addToCompare: (product: Product) => void;
  removeFromCompare: (productId: string) => void;
  clearCompare: () => void;
  isInCompare: (productId: string) => boolean;
  isCompareModalOpen: boolean;
  setCompareModalOpen: (open: boolean) => void;
}

const CompareContext = createContext<CompareContextType | undefined>(undefined);

export function CompareProvider({ children }: { children: React.ReactNode }) {
  const [compareItems, setCompareItems] = useState<Product[]>([]);
  const [isCompareModalOpen, setCompareModalOpen] = useState(false);

  // Load from local storage on mount
  useEffect(() => {
    try {
      const saved = localStorage.getItem('poyken_compare_list');
      if (saved) {
        setCompareItems(JSON.parse(saved));
      }
    } catch (e) {
      console.error('Failed to load compare items from localStorage', e);
    }
  }, []);

  // Save to local storage on change
  useEffect(() => {
    try {
      localStorage.setItem('poyken_compare_list', JSON.stringify(compareItems));
    } catch (e) {
      console.error('Failed to save compare items to localStorage', e);
    }
  }, [compareItems]);

  const addToCompare = (product: Product) => {
    setCompareItems((prev) => {
      if (prev.some((item) => item.id === product.id)) return prev;
      if (prev.length >= 3) {
        // Replace oldest or keep max 3
        return [...prev.slice(1), product];
      }
      return [...prev, product];
    });
  };

  const removeFromCompare = (productId: string) => {
    setCompareItems((prev) => prev.filter((item) => item.id !== productId));
  };

  const clearCompare = () => {
    setCompareItems([]);
  };

  const isInCompare = (productId: string) => {
    return compareItems.some((item) => item.id === productId);
  };

  return (
    <CompareContext.Provider
      value={{
        compareItems,
        addToCompare,
        removeFromCompare,
        clearCompare,
        isInCompare,
        isCompareModalOpen,
        setCompareModalOpen,
      }}
    >
      {children}
    </CompareContext.Provider>
  );
}

export function useCompare() {
  const context = useContext(CompareContext);
  if (!context) {
    throw new Error('useCompare must be used within a CompareProvider');
  }
  return context;
}
