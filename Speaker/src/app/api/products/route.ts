import { NextResponse } from 'next/server';
import { productService } from '../../../services/productService';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const categoryId = searchParams.get('categoryId') || undefined;
    const search = searchParams.get('search') || undefined;
    const brand = searchParams.get('brand') || undefined;
    const type = searchParams.get('type') || undefined;
    const sort = searchParams.get('sort') || undefined;

    const products = await productService.getProducts({
      categoryId,
      search,
      brand,
      type,
      sort,
    });

    return NextResponse.json(products);
  } catch (e) {
    console.error('API getProducts failed:', e);
    return NextResponse.json({ error: 'Failed to fetch products' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const product = await productService.addProduct(body);
    return NextResponse.json(product, { status: 201 });
  } catch (e) {
    console.error('API addProduct failed:', e);
    return NextResponse.json({ error: 'Failed to add product' }, { status: 500 });
  }
}
