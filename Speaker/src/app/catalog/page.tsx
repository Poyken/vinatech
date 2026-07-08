import React from 'react';
import { dataService } from '../../lib/dataService';
import ProductCard from '../../components/ProductCard';
import CatalogFilters from '../../components/CatalogFilters';
import { SlidersHorizontal } from 'lucide-react';

interface PageProps {
  searchParams: Promise<{
    categoryId?: string;
    search?: string;
    brand?: string;
    type?: string;
    sort?: string;
  }>;
}

export const revalidate = 0; // Bypass cache to ensure real-time search/filters

export default async function CatalogPage({ searchParams }: PageProps) {
  const resolvedParams = await searchParams;
  
  // Extract parameters
  const categoryId = resolvedParams.categoryId || undefined;
  const search = resolvedParams.search || undefined;
  const brand = resolvedParams.brand || undefined;
  const type = resolvedParams.type || undefined;
  const sort = resolvedParams.sort || undefined;

  // Fetch filtered products
  const products = await dataService.getProducts({
    categoryId,
    search,
    brand,
    type,
    sort,
  });

  // Fetch categories for filters
  const categories = await dataService.getCategories();

  // Preset static filter lists to make UI look professional and structured
  const brands = ['JBL', 'Marshall', 'KEF', 'Klipsch', 'KRK', 'Yamaha'];
  const types = ['Bookshelf', 'Floorstanding', 'Bluetooth', 'Soundbar', 'Monitor'];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex-1">
      {/* Header Info */}
      <div className="mb-10 text-left">
        <span className="text-xs font-black uppercase text-primary tracking-widest">
          Danh mục thiết bị
        </span>
        <h1 className="text-3xl sm:text-4xl font-extrabold text-foreground uppercase mt-1">
          Loa & Thiết Bị Âm Thanh
        </h1>
        <p className="text-sm text-muted-text mt-2">
          Hiển thị {products.length} sản phẩm phù hợp với bộ lọc của bạn.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">
        {/* Left Filters - Sticky Column */}
        <aside className="lg:col-span-1">
          <CatalogFilters 
            categories={categories}
            brands={brands}
            types={types}
          />
        </aside>

        {/* Right Grid */}
        <main className="lg:col-span-3">
          {products.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20 bg-muted-bg/30 border border-border rounded-2xl text-center space-y-4 shadow-sm">
              <div className="p-4 bg-input-bg border border-border rounded-full text-muted-text">
                <SlidersHorizontal className="w-10 h-10" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-foreground uppercase">Không tìm thấy loa</h3>
                <p className="text-sm text-muted-text mt-1 max-w-xs mx-auto">
                  Rất tiếc, không có sản phẩm nào đáp ứng được các bộ lọc tìm kiếm hiện tại của bạn.
                </p>
              </div>
              <a
                href="/catalog"
                className="px-6 py-2 bg-input-bg hover:bg-card-hover text-foreground text-xs font-bold border border-border rounded-full transition-all shadow-sm"
              >
                Đặt Lại Bộ Lọc
              </a>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
              {products.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </main>
      </div>
    </div>
  );
}
