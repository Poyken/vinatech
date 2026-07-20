import { dataService } from '../lib/dataService';
import { Category } from '../lib/types';

export const categoryService = {
  async getCategories(): Promise<Category[]> {
    return dataService.getCategories();
  }
};
