'use client';

import React, { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Category } from '../lib/types';
import { Search, X, Filter, Volume2 } from 'lucide-react';

interface CatalogFiltersProps {
  categories: Category[];
  brands: string[];
  types: string[];
}

export default function CatalogFilters({ categories, brands, types }: CatalogFiltersProps) {
  const router = useRouter();
  const searchParams = useSearchParams();

  // Local state for search to avoid lagging the URL on each keystroke
  const [searchInput, setSearchInput] = useState(searchParams.get('search') || '');
  const [minPriceInput, setMinPriceInput] = useState(searchParams.get('minPrice') || '');
  const [maxPriceInput, setMaxPriceInput] = useState(searchParams.get('maxPrice') || '');

  // Sync local search input with URL search param
  useEffect(() => {
    setSearchInput(searchParams.get('search') || '');
    setMinPriceInput(searchParams.get('minPrice') || '');
    setMaxPriceInput(searchParams.get('maxPrice') || '');
  }, [searchParams]);

  const activeCategoryId = searchParams.get('categoryId') || '';
  const activeBrand = searchParams.get('brand') || '';
  const activeType = searchParams.get('type') || '';
  const activeSort = searchParams.get('sort') || 'newest';

  const updateFilters = (key: string, value: string | null) => {
    const params = new URLSearchParams(searchParams.toString());
    if (value === null || value === '') {
      params.delete(key);
    } else {
      params.set(key, value);
    }
    router.push(`/catalog?${params.toString()}`);
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateFilters('search', searchInput.trim() || null);
  };

  const handlePriceFilterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const params = new URLSearchParams(searchParams.toString());
    if (minPriceInput) params.set('minPrice', minPriceInput);
    else params.delete('minPrice');

    if (maxPriceInput) params.set('maxPrice', maxPriceInput);
    else params.delete('maxPrice');

    router.push(`/catalog?${params.toString()}`);
  };

  const handleClearAll = () => {
    setSearchInput('');
    setMinPriceInput('');
    setMaxPriceInput('');
    router.push('/catalog');
  };

  const hasActiveFilters = 
    searchParams.has('search') || 
    searchParams.has('categoryId') || 
    searchParams.has('brand') || 
    searchParams.has('type') ||
    searchParams.has('minPrice') ||
    searchParams.has('maxPrice') ||
    (searchParams.get('sort') !== 'newest' && searchParams.has('sort'));

  return (
    <div className="space-y-6 bg-card border border-border p-6 rounded-2xl sticky top-24 shadow-lg shadow-black/5 dark:shadow-black/20 text-left">
      <div className="flex items-center justify-between pb-4 border-b border-border">
        <h2 className="text-base font-extrabold text-foreground uppercase flex items-center gap-2">
          <Filter className="w-4 h-4 text-primary" />
          Bộ lọc loa
        </h2>
        {hasActiveFilters && (
          <button
            onClick={handleClearAll}
            className="text-xs text-primary hover:text-orange-400 font-bold transition-colors flex items-center gap-0.5"
          >
            <X className="w-3.5 h-3.5" />
            Xóa Lọc
          </button>
        )}
      </div>

      {/* 1. Search Box */}
      <form onSubmit={handleSearchSubmit} className="space-y-2">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Từ Khóa</label>
        <div className="relative">
          <input
            type="text"
            placeholder="Tìm loa, hãng..."
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            className="w-full bg-input-bg border border-border rounded-xl pl-9 pr-4 py-2 text-xs text-foreground placeholder-muted-text/70 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
          />
          <Search className="w-3.5 h-3.5 text-muted-text absolute left-3 top-3" />
        </div>
      </form>

      {/* 2. Sorting */}
      <div className="space-y-2">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Sắp Xếp</label>
        <select
          value={activeSort}
          onChange={(e) => updateFilters('sort', e.target.value)}
          className="w-full bg-input-bg border border-border rounded-xl px-3 py-2 text-xs text-foreground focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
        >
          <option value="newest">Loa Mới Nhất</option>
          <option value="price-asc">Giá: Thấp Đến Cao</option>
          <option value="price-desc">Giá: Cao Đến Thấp</option>
          <option value="rating">Đánh Giá Cao Nhất</option>
        </select>
      </div>

      {/* 3. Price Filter */}
      <form onSubmit={handlePriceFilterSubmit} className="space-y-2">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider block">Khoảng Giá (VND)</label>
        <div className="flex items-center gap-2">
          <input
            type="number"
            placeholder="Từ"
            value={minPriceInput}
            onChange={(e) => setMinPriceInput(e.target.value)}
            className="w-full bg-input-bg border border-border rounded-xl px-3 py-2 text-xs text-foreground focus:outline-none focus:border-primary"
          />
          <span className="text-muted-text text-xs font-bold">-</span>
          <input
            type="number"
            placeholder="Đến"
            value={maxPriceInput}
            onChange={(e) => setMaxPriceInput(e.target.value)}
            className="w-full bg-input-bg border border-border rounded-xl px-3 py-2 text-xs text-foreground focus:outline-none focus:border-primary"
          />
        </div>
        <button
          type="submit"
          className="w-full py-2 bg-input-bg hover:bg-card-hover border border-border text-foreground text-xs font-bold rounded-xl transition-all"
        >
          Áp Dụng Giá
        </button>
      </form>

      {/* 4. Category Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Dòng Loa</label>
        <div className="flex flex-col gap-1.5">
          <button
            onClick={() => updateFilters('categoryId', null)}
            className={`text-left text-xs py-1.5 px-3 rounded-lg transition-colors font-medium ${
              activeCategoryId === '' 
                ? 'bg-primary/10 text-primary font-bold' 
                : 'text-muted-text hover:bg-card-hover hover:text-foreground'
            }`}
          >
            Tất Cả Dòng Loa
          </button>
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => updateFilters('categoryId', cat.id)}
              className={`text-left text-xs py-1.5 px-3 rounded-lg transition-colors font-medium ${
                activeCategoryId === cat.id 
                  ? 'bg-primary/10 text-primary font-bold' 
                  : 'text-muted-text hover:bg-card-hover hover:text-foreground'
              }`}
            >
              {cat.name}
            </button>
          ))}
        </div>
      </div>

      {/* 5. Brand Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Hãng Sản Xuất</label>
        <div className="flex flex-wrap gap-1.5">
          <button
            onClick={() => updateFilters('brand', null)}
            className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
              activeBrand === ''
                ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                : 'bg-input-bg border-border text-muted-text hover:text-foreground hover:border-border-hover'
            }`}
          >
            Tất Cả
          </button>
          {brands.map((brand) => (
            <button
              key={brand}
              onClick={() => updateFilters('brand', brand)}
              className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
                activeBrand.toLowerCase() === brand.toLowerCase()
                  ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                  : 'bg-input-bg border-border text-muted-text hover:text-foreground hover:border-border-hover'
              }`}
            >
              {brand}
            </button>
          ))}
        </div>
      </div>

      {/* 6. Type Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Kiểu Loa</label>
        <div className="flex flex-wrap gap-1.5">
          <button
            onClick={() => updateFilters('type', null)}
            className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
              activeType === ''
                ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                : 'bg-input-bg border-border text-muted-text hover:text-foreground hover:border-border-hover'
            }`}
          >
            Tất Cả
          </button>
          {types.map((type) => (
            <button
              key={type}
              onClick={() => updateFilters('type', type)}
              className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
                activeType === type
                  ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                  : 'bg-input-bg border-border text-muted-text hover:text-foreground hover:border-border-hover'
              }`}
            >
              {type}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
