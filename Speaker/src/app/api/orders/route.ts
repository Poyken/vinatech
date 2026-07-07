import { NextResponse } from 'next/server';
import { dataService } from '../../../lib/dataService';

export async function GET() {
  try {
    const orders = await dataService.getOrders();
    return NextResponse.json(orders);
  } catch (e) {
    return NextResponse.json({ error: 'Failed to fetch orders' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const order = await dataService.createOrder(body);
    return NextResponse.json(order, { status: 201 });
  } catch (e) {
    console.error('API createOrder failed:', e);
    return NextResponse.json({ error: 'Failed to create order' }, { status: 500 });
  }
}
