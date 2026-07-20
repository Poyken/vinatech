import { dataService } from '../lib/dataService';
import { Order } from '../lib/types';
import { prisma } from '../lib/prisma';

export const orderService = {
  async getOrders(): Promise<Order[]> {
    return dataService.getOrders();
  },

  async createOrder(orderData: {
    customerName: string;
    customerEmail: string;
    customerPhone: string;
    address: string;
    paymentMethod: string;
    total: number;
    items: Array<{ productId: string; quantity: number; price: number }>;
  }): Promise<Order> {
    return dataService.createOrder(orderData);
  },

  async updateOrderStatus(orderId: string, status: string): Promise<boolean> {
    try {
      if (prisma) {
        await prisma.order.update({
          where: { id: orderId },
          data: { status }
        });
        return true;
      }
      return true;
    } catch (e) {
      console.warn(`Failed to update order status for ${orderId}:`, e);
      return false;
    }
  }
};
