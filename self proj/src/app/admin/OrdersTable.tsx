"use client";

import React, { useState } from "react";
import { updateOrderStatus } from "@/app/admin/actions";
import { 
  Clock, 
  CheckCircle, 
  XCircle, 
  Truck,
  CreditCard,
  MapPin,
  Calendar
} from "lucide-react";

interface Order {
  id: string;
  userId: string | null;
  status: string;
  totalAmount: string;
  shippingAddress: string;
  paymentStatus: string;
  paymentMethod: string;
  createdAt: Date;
}

export default function OrdersTable({ initialOrders }: { initialOrders: any[] }) {
  const [ordersList, setOrdersList] = useState<Order[]>(initialOrders);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const handleStatusChange = async (orderId: string, newStatus: string) => {
    setUpdatingId(orderId);
    const result = await updateOrderStatus(orderId, newStatus);
    setUpdatingId(null);

    if (result.success) {
      setOrdersList((prev) =>
        prev.map((o) => (o.id === orderId ? { ...o, status: newStatus } : o))
      );
    } else {
      alert(result.error || "Không thể cập nhật trạng thái đơn hàng.");
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "paid":
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-green-50 text-green-700 border border-green-150">
            <CheckCircle className="w-3.5 h-3.5" />
            <span>Đã thanh toán</span>
          </span>
        );
      case "shipped":
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-150">
            <Truck className="w-3.5 h-3.5" />
            <span>Đang giao hàng</span>
          </span>
        );
      case "cancelled":
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-red-50 text-red-700 border border-red-150">
            <XCircle className="w-3.5 h-3.5" />
            <span>Đã hủy</span>
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-150 animate-pulse">
            <Clock className="w-3.5 h-3.5" />
            <span>Chờ thanh toán</span>
          </span>
        );
    }
  };

  return (
    <div className="bg-white border border-zinc-200/80 rounded-3xl shadow-xs overflow-hidden">
      {ordersList.length === 0 ? (
        <div className="text-center py-20 text-zinc-405">
          Chưa có đơn hàng nào được đặt.
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-left text-sm">
            <thead>
              <tr className="bg-slate-50/50 border-b border-zinc-150 text-zinc-500 font-semibold">
                <th className="px-6 py-4">Mã Đơn Hàng</th>
                <th className="px-6 py-4">Khách Hàng / Địa Chỉ</th>
                <th className="px-6 py-4">Tổng Tiền</th>
                <th className="px-6 py-4">Thanh Toán</th>
                <th className="px-6 py-4">Trạng Thái</th>
                <th className="px-6 py-4 text-right">Thao Tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {ordersList.map((order) => (
                <tr key={order.id} className="hover:bg-slate-50/20 transition-colors">
                  {/* Mã đơn hàng */}
                  <td className="px-6 py-5">
                    <span className="font-mono text-xs font-bold text-zinc-700">
                      {order.id}
                    </span>
                    <div className="flex items-center gap-1 text-[10px] text-zinc-400 mt-1">
                      <Calendar className="w-3 h-3" />
                      <span>{new Date(order.createdAt).toLocaleString("vi-VN")}</span>
                    </div>
                  </td>

                  {/* Địa chỉ & Khách hàng */}
                  <td className="px-6 py-5">
                    <div className="flex items-start gap-1.5 max-w-xs">
                      <MapPin className="w-3.5 h-3.5 text-zinc-400 mt-0.5 shrink-0" />
                      <span className="text-xs text-zinc-600 line-clamp-2">
                        {order.shippingAddress}
                      </span>
                    </div>
                  </td>

                  {/* Tổng tiền */}
                  <td className="px-6 py-5">
                    <span className="font-bold text-zinc-900">
                      {parseFloat(order.totalAmount).toLocaleString("vi-VN")} đ
                    </span>
                  </td>

                  {/* Thanh toán */}
                  <td className="px-6 py-5">
                    <div className="flex items-center gap-1.5 text-xs text-zinc-500">
                      <CreditCard className="w-3.5 h-3.5 text-zinc-450" />
                      <span className="uppercase">{order.paymentMethod}</span>
                      <span className="text-[10px]">({order.paymentStatus})</span>
                    </div>
                  </td>

                  {/* Trạng thái đơn hàng */}
                  <td className="px-6 py-5">
                    {getStatusBadge(order.status)}
                  </td>

                  {/* Cập nhật Trạng thái */}
                  <td className="px-6 py-5 text-right">
                    <div className="inline-flex gap-2">
                      {order.status !== "shipped" && order.status !== "cancelled" && (
                        <>
                          <button
                            onClick={() => handleStatusChange(order.id, "shipped")}
                            disabled={updatingId === order.id}
                            className="px-2.5 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-bold rounded-lg transition-colors cursor-pointer disabled:opacity-50"
                          >
                            Giao Hàng
                          </button>
                          <button
                            onClick={() => handleStatusChange(order.id, "cancelled")}
                            disabled={updatingId === order.id}
                            className="px-2.5 py-1.5 bg-red-550/10 hover:bg-red-550/20 text-red-600 text-xs font-bold rounded-lg transition-colors cursor-pointer disabled:opacity-50"
                          >
                            Hủy Đơn
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
