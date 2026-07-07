'use client';

import React, { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Category } from '../lib/types';
import { Search, X, Filter } from 'lucide-react';

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

  // Sync local search input with URL search param
  useEffect(() => {
    setSearchInput(searchParams.get('search') || '');
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

  const handleClearAll = () => {
    setSearchInput('');
    router.push('/catalog');
  };

  const hasActiveFilters = 
    searchParams.has('search') || 
    searchParams.has('categoryId') || 
    searchParams.has('brand') || 
    searchParams.has('type') ||
    searchParams.get('sort') !== 'newest' && searchParams.has('sort');

  return (
    <div className="space-y-6 bg-white border border-stone-200 p-6 rounded-2xl sticky top-24 shadow-sm text-left">
      <div className="flex items-center justify-between pb-4 border-b border-stone-100">
        <h2 className="text-base font-extrabold text-stone-850 uppercase flex items-center gap-2">
          <Filter className="w-4 h-4 text-primary" />
          Bộ lọc loa
        </h2>
        {hasActiveFilters && (
          <button
            onClick={handleClearAll}
            className="text-xs text-primary hover:text-orange-555 font-bold transition-colors flex items-center gap-0.5"
          >
            <X className="w-3.5 h-3.5" />
            Xóa Lọc
          </button>
        )}
      </div>

      {/* 1. Search Box */}
      <form onSubmit={handleSearchSubmit} className="space-y-2">
        <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Từ Khóa</label>
        <div className="relative">
          <input
            type="text"
            placeholder="Tìm loa, hãng..."
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            className="w-full bg-stone-50 border border-stone-200 rounded-xl pl-9 pr-4 py-2 text-xs text-stone-800 placeholder-stone-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
          />
          <Search className="w-3.5 h-3.5 text-stone-400 absolute left-3 top-3" />
        </div>
      </form>

      {/* 2. Sorting */}
      <div className="space-y-2">
        <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Sắp Xếp</label>
        <select
          value={activeSort}
          onChange={(e) => updateFilters('sort', e.target.value)}
          className="w-full bg-stone-50 border border-stone-200 rounded-xl px-3 py-2 text-xs text-stone-800 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
        >
          <option value="newest">Loa Mới Nhất</option>
          <option value="price-asc">Giá: Thấp Đến Cao</option>
          <option value="price-desc">Giá: Cao Đến Thấp</option>
          <option value="rating">Đánh Giá Cao Nhất</option>
        </select>
      </div>

      {/* 3. Category Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Dòng Loa</label>
        <div className="flex flex-col gap-1.5">
          <button
            onClick={() => updateFilters('categoryId', null)}
            className={`text-left text-xs py-1.5 px-3 rounded-lg transition-colors font-medium ${
              activeCategoryId === '' 
                ? 'bg-primary/10 text-primary font-bold' 
                : 'text-stone-600 hover:bg-stone-50 hover:text-stone-900'
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
                  : 'text-stone-600 hover:bg-stone-50 hover:text-stone-900'
              }`}
            >
              {cat.name}
            </button>
          ))}
        </div>
      </div>

      {/* 4. Brand Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Hãng Sản Xuất</label>
        <div className="flex flex-wrap gap-1.5">
          <button
            onClick={() => updateFilters('brand', null)}
            className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
              activeBrand === ''
                ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                : 'bg-stone-50 border-stone-200 text-stone-650 hover:text-stone-900 hover:border-stone-400'
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
                  : 'bg-stone-50 border-stone-200 text-stone-650 hover:text-stone-900 hover:border-stone-400'
              }`}
            >
              {brand}
            </button>
          ))}
        </div>
      </div>

      {/* 5. Type (Internal Layout type) Filter */}
      <div className="space-y-2.5">
        <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Kiểu Loa</label>
        <div className="flex flex-wrap gap-1.5">
          <button
            onClick={() => updateFilters('type', null)}
            className={`text-xs px-3 py-1.5 rounded-full border transition-all font-semibold ${
              activeType === ''
                ? 'bg-primary border-primary text-white shadow-sm shadow-primary/20'
                : 'bg-stone-50 border-stone-200 text-stone-650 hover:text-stone-900 hover:border-stone-400'
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
                  : 'bg-stone-50 border-stone-200 text-stone-650 hover:text-stone-900 hover:border-stone-400'
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
