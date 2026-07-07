import { NextResponse } from 'next/server';
import { dataService } from '../../../lib/dataService';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { productId, userName, rating, comment } = body;
    if (!productId || !userName || !rating || !comment) {
      return NextResponse.json({ error: 'Missing required review fields' }, { status: 400 });
    }
    const review = await dataService.addReview(productId, { userName, rating, comment });
    return NextResponse.json(review, { status: 201 });
  } catch (e) {
    console.error('API addReview failed:', e);
    return NextResponse.json({ error: 'Failed to add review' }, { status: 500 });
  }
}
