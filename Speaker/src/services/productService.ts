import { dataService } from '../lib/dataService';
import { Product, Review } from '../lib/types';

export const productService = {
  async getProducts(options: {
    categoryId?: string;
    search?: string;
    brand?: string;
    type?: string;
    sort?: string;
    minPrice?: number;
    maxPrice?: number;
  } = {}): Promise<Product[]> {
    return dataService.getProducts(options);
  },

  async getProductBySlug(slug: string): Promise<Product | null> {
    return dataService.getProductBySlug(slug);
  },

  async addProduct(productData: Omit<Product, 'id' | 'reviews' | 'createdAt' | 'updatedAt' | 'rating'>): Promise<Product> {
    return dataService.addProduct(productData);
  },

  async addReview(productId: string, data: { userName: string; rating: number; comment: string }): Promise<Review> {
    return dataService.addReview(productId, data);
  }
};
