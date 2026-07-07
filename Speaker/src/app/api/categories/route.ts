import { NextResponse } from 'next/server';
import { dataService } from '../../../lib/dataService';

export async function GET() {
  try {
    const categories = await dataService.getCategories();
    return NextResponse.json(categories);
  } catch (e) {
    return NextResponse.json({ error: 'Failed to fetch categories' }, { status: 500 });
  }
}
