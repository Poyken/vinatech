import { NextResponse } from 'next/server';
import { dataService } from '../../../lib/dataService';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const product = await dataService.addProduct(body);
    return NextResponse.json(product, { status: 201 });
  } catch (e) {
    console.error('API addProduct failed:', e);
    return NextResponse.json({ error: 'Failed to add product' }, { status: 500 });
  }
}
