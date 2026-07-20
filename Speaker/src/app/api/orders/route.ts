import { NextResponse } from 'next/server';
import { orderService } from '../../../services/orderService';
import { sendOrderEmails } from '../../../lib/emailTemplates';

export async function GET() {
  try {
    const orders = await orderService.getOrders();
    return NextResponse.json(orders);
  } catch (e) {
    return NextResponse.json({ error: 'Failed to fetch orders' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const order = await orderService.createOrder(body);
    
    // Fire email notifications in the background
    sendOrderEmails(order).catch((err) => {
      console.error('Failed to trigger transactional order emails:', err);
    });

    return NextResponse.json(order, { status: 201 });
  } catch (e) {
    console.error('API createOrder failed:', e);
    return NextResponse.json({ error: 'Failed to create order' }, { status: 500 });
  }
}

export async function PATCH(request: Request) {
  try {
    const body = await request.json();
    const { orderId, status } = body;
    if (!orderId || !status) {
      return NextResponse.json({ error: 'Order ID and status are required' }, { status: 400 });
    }

    const success = await orderService.updateOrderStatus(orderId, status);
    if (success) {
      return NextResponse.json({ success: true, orderId, status });
    } else {
      return NextResponse.json({ error: 'Failed to update order status' }, { status: 500 });
    }
  } catch (e) {
    console.error('API PATCH order status failed:', e);
    return NextResponse.json({ error: 'Failed to update order status' }, { status: 500 });
  }
}
