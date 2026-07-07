export interface Category {
  id: string;
  name: string;
  slug: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface Review {
  id: string;
  userName: string;
  rating: number;
  comment: string;
  productId: string;
  createdAt: Date;
}

export interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  price: number;
  originalPrice?: number | null;
  images: string[];
  brand: string;
  type: string;
  specs: Record<string, string>;
  stock: number;
  rating: number;
  audioUrl?: string | null;
  categoryId: string;
  reviews?: Review[];
  createdAt?: Date;
  updatedAt?: Date;
}

export interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  product?: Product;
  quantity: number;
  price: number;
}

export interface Order {
  id: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
  address: string;
  paymentMethod: string;
  status: string;
  total: number;
  items: OrderItem[];
  createdAt: Date;
  updatedAt?: Date;
}
