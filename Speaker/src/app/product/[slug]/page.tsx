import React from 'react';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { dataService } from '../../../lib/dataService';
import ProductDetailInteractive from '../../../components/ProductDetailInteractive';
import ProductCard from '../../../components/ProductCard';
import { Metadata } from 'next';

interface PageProps {
  params: Promise<{ slug: string }>;
}

export const revalidate = 0; // Ensure data is loaded in real-time

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const resolvedParams = await params;
  const { slug } = resolvedParams;
  const product = await dataService.getProductBySlug(slug);

  if (!product) {
    return {
      title: 'Không Tìm Thấy Loa - Poyken Sound',
      description: 'Sản phẩm loa không tồn tại hoặc đã bị gỡ bỏ.',
    };
  }

  return {
    title: `${product.name} | Loa ${product.brand} Chính Hãng - Poyken Sound`,
    description: `${product.description.substring(0, 150)}...`,
  };
}

export default async function ProductDetailPage({ params }: PageProps) {
  const resolvedParams = await params;
  const { slug } = resolvedParams;

  const product = await dataService.getProductBySlug(slug);

  if (!product) {
    notFound();
  }

  // Fetch related products (same category, excluding current product)
  const allRelated = await dataService.getProducts({ 
    categoryId: product.categoryId 
  });
  const relatedProducts = allRelated
    .filter(p => p.id !== product.id)
    .slice(0, 3); // limit to 3 items

  // Fetch category name
  const categories = await dataService.getCategories();
  const category = categories.find(c => c.id === product.categoryId);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1">
      {/* 1. Breadcrumbs */}
      <nav className="flex items-center gap-2 text-xs font-semibold text-muted-text mb-8 uppercase tracking-wider">
        <Link href="/" className="hover:text-primary transition-colors">
          Trang Chủ
        </Link>
        <span>/</span>
        <Link href="/catalog" className="hover:text-primary transition-colors">
          Cửa Hàng
        </Link>
        <span>/</span>
        {category && (
          <>
            <Link 
              href={`/catalog?categoryId=${category.id}`} 
              className="hover:text-primary transition-colors"
            >
              {category.name}
            </Link>
            <span>/</span>
          </>
        )}
        <span className="text-foreground truncate max-w-[200px]">
          {product.name}
        </span>
      </nav>

      {/* 2. Interactive Product Display */}
      <ProductDetailInteractive 
        product={product} 
        initialReviews={product.reviews || []} 
      />

      {/* 3. Related Products Slider */}
      {relatedProducts.length > 0 && (
        <div className="mt-20 pt-10 border-t border-border text-left">
          <div>
            <span className="text-xs font-black uppercase text-primary tracking-widest">
              Gợi ý cho bạn
            </span>
            <h2 className="text-2xl font-extrabold text-foreground uppercase mt-1 mb-8">
              Sản Phẩm Tương Tự
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {relatedProducts.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
