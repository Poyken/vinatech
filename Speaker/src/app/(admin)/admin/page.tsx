'use client';

import React, { useState, useEffect } from 'react';
import { Order, Product, Category } from '../../../lib/types';
import { useToast } from '../../../context/ToastContext';
import { Package, ShieldCheck, ChevronDown, ChevronUp, Plus, Trash2, ListOrdered, TrendingUp, AlertTriangle, LogOut, CheckCircle2, Clock, XCircle, RefreshCw } from 'lucide-react';
import Link from 'next/link';
import { useSession, signOut } from 'next-auth/react';
import { useRouter } from 'next/navigation';

export default function AdminPage() {
  const router = useRouter();
  const { data: session, status } = useSession();
  const { showToast } = useToast();
  const [activeTab, setActiveTab] = useState<'orders' | 'add-product'>('orders');
  const [orders, setOrders] = useState<Order[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [expandedOrderId, setExpandedOrderId] = useState<string | null>(null);
  const [updatingOrderId, setUpdatingOrderId] = useState<string | null>(null);

  // Redirect to login if unauthenticated
  useEffect(() => {
    if (status === 'unauthenticated') {
      router.push('/admin/login');
    }
  }, [status, router]);

  // Form states for new product
  const [productName, setProductName] = useState('');
  const [productSlug, setProductSlug] = useState('');
  const [productBrand, setProductBrand] = useState('JBL');
  const [productType, setProductType] = useState('Bookshelf');
  const [productPrice, setProductPrice] = useState('');
  const [productOriginalPrice, setProductOriginalPrice] = useState('');
  const [productCategoryId, setProductCategoryId] = useState('');
  const [productStock, setProductStock] = useState('10');
  const [productDescription, setProductDescription] = useState('');
  const [productAudioUrl, setProductAudioUrl] = useState('');
  const [specs, setSpecs] = useState<Array<{ key: string; value: string }>>([
    { key: 'Công suất', value: '50W RMS' },
    { key: 'Tần số đáp ứng', value: '50Hz - 20kHz' },
    { key: 'Kết nối', value: 'Bluetooth 5.0, AUX' },
  ]);

  const [productImage, setProductImage] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [formSuccess, setFormSuccess] = useState(false);

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      });
      if (res.ok) {
        const data = await res.json();
        setProductImage(data.url);
        showToast('Tải ảnh thành công', 'Ảnh sản phẩm đã sẵn sàng', 'success');
      } else {
        showToast('Tải ảnh thất bại', 'Vui lòng kiểm tra lại file ảnh', 'error');
      }
    } catch (err) {
      console.error(err);
      showToast('Lỗi tải ảnh', 'Không thể kết nối đến server upload', 'error');
    } finally {
      setIsUploading(false);
    }
  };

  // Load orders, categories, and products on mount
  const loadData = async () => {
    try {
      const ordersRes = await fetch('/api/orders');
      if (ordersRes.ok) {
        const allOrders = await ordersRes.json();
        setOrders(allOrders);
      }

      const catsRes = await fetch('/api/categories');
      if (catsRes.ok) {
        const allCategories = await catsRes.json();
        setCategories(allCategories);
        if (allCategories.length > 0 && !productCategoryId) {
          setProductCategoryId(allCategories[0].id);
        }
      }

      const productsRes = await fetch('/api/products');
      if (productsRes.ok) {
        const allProducts = await productsRes.json();
        setProducts(allProducts);
      }
    } catch (err) {
      console.error('Failed to load admin data:', err);
    }
  };

  useEffect(() => {
    loadData();
  }, [activeTab, productCategoryId]);

  // Handle status update
  const handleUpdateOrderStatus = async (orderId: string, newStatus: string) => {
    setUpdatingOrderId(orderId);
    try {
      const res = await fetch('/api/orders', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ orderId, status: newStatus }),
      });

      if (res.ok) {
        setOrders((prev) =>
          prev.map((o) => (o.id === orderId ? { ...o, status: newStatus } : o))
        );
        showToast('Cập nhật trạng thái thành công', `Đơn hàng #${orderId.substring(4, 10).toUpperCase()} -> ${newStatus}`, 'success');
      } else {
        showToast('Cập nhật trạng thái thất bại', 'Có lỗi xảy ra', 'error');
      }
    } catch (err) {
      console.error(err);
      showToast('Lỗi kết nối', 'Không thể gửi yêu cầu đến server', 'error');
    } finally {
      setUpdatingOrderId(null);
    }
  };

  // Handle auto slug generation
  const handleNameChange = (name: string) => {
    setProductName(name);
    const slug = name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s-]/g, '')
      .trim()
      .replace(/\s+/g, '-');
    setProductSlug(slug);
  };

  const handleAddSpecRow = () => {
    setSpecs([...specs, { key: '', value: '' }]);
  };

  const handleSpecChange = (index: number, field: 'key' | 'value', value: string) => {
    const updated = [...specs];
    updated[index][field] = value;
    setSpecs(updated);
  };

  const handleRemoveSpecRow = (index: number) => {
    setSpecs(specs.filter((_, idx) => idx !== index));
  };

  const handleAddProductSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!productName || !productSlug || !productPrice || !productCategoryId) return;

    const specRecord: Record<string, string> = {};
    specs.forEach((item) => {
      if (item.key.trim() && item.value.trim()) {
        specRecord[item.key.trim()] = item.value.trim();
      }
    });

    try {
      const response = await fetch('/api/products', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: productName,
          slug: productSlug,
          brand: productBrand,
          type: productType,
          price: Number(productPrice),
          originalPrice: productOriginalPrice ? Number(productOriginalPrice) : null,
          description: productDescription,
          categoryId: productCategoryId,
          stock: Number(productStock),
          images: productImage ? [productImage] : ['https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop'],
          specs: specRecord,
          audioUrl: productAudioUrl || null,
        })
      });

      if (!response.ok) {
        throw new Error('Failed to create product');
      }

      setProductImage('');
      setProductName('');
      setProductSlug('');
      setProductPrice('');
      setProductOriginalPrice('');
      setProductDescription('');
      setProductAudioUrl('');
      setProductStock('10');
      setSpecs([
        { key: 'Công suất', value: '50W RMS' },
        { key: 'Tần số đáp ứng', value: '50Hz - 20kHz' },
        { key: 'Kết nối', value: 'Bluetooth 5.0, AUX' },
      ]);
      setFormSuccess(true);
      showToast('Đã thêm sản phẩm loa mới', productName, 'success');
      setTimeout(() => setFormSuccess(false), 3000);
    } catch (err) {
      console.error('Failed to add product:', err);
      showToast('Lỗi tạo sản phẩm', 'Không thể lưu sản phẩm mới.', 'error');
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const toggleOrderExpand = (id: string) => {
    setExpandedOrderId(expandedOrderId === id ? null : id);
  };

  const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
  const lowStockCount = products.filter((p) => p.stock <= 5).length;

  if (status === 'loading') {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto" />
          <p className="text-xs text-muted-text font-bold tracking-wider uppercase">Đang tải cấu hình bảo mật...</p>
        </div>
      </div>
    );
  }

  if (!session) {
    return null;
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex-1 text-left">
      
      {/* Page Header */}
      <div className="mb-10 flex flex-wrap justify-between items-end gap-4">
        <div>
          <span className="text-xs font-black uppercase text-primary tracking-widest">Hệ thống quản lý Poyken Sound</span>
          <h1 className="text-3xl font-extrabold text-foreground uppercase mt-1">Admin Dashboard</h1>
        </div>

        {/* Tab Controls */}
        <div className="flex items-center gap-3">
          <div className="flex bg-input-bg border border-border p-1.5 rounded-xl shadow-inner">
            <button
              onClick={() => setActiveTab('orders')}
              className={`flex items-center gap-2 px-4 py-2 text-xs font-bold uppercase tracking-wider rounded-lg transition-all ${
                activeTab === 'orders'
                  ? 'bg-primary text-white shadow-sm'
                  : 'text-muted-text hover:text-foreground'
              }`}
            >
              <ListOrdered className="w-4 h-4" />
              Đơn Hàng ({orders.length})
            </button>
            
            <button
              onClick={() => setActiveTab('add-product')}
              className={`flex items-center gap-2 px-4 py-2 text-xs font-bold uppercase tracking-wider rounded-lg transition-all ${
                activeTab === 'add-product'
                  ? 'bg-primary text-white shadow-sm'
                  : 'text-muted-text hover:text-foreground'
              }`}
            >
              <Plus className="w-4 h-4" />
              Thêm Loa Mới
            </button>
          </div>

          <button
            onClick={() => signOut({ callbackUrl: '/admin/login' })}
            className="flex items-center gap-1.5 px-4 py-3 bg-red-500/10 hover:bg-red-500 hover:text-white border border-red-950/40 hover:border-red-500 rounded-xl text-xs font-extrabold text-red-400 transition-all active:scale-95 shadow-sm"
          >
            <LogOut className="w-4 h-4" />
            Đăng Xuất
          </button>
        </div>
      </div>

      {/* Key Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        <div className="bg-card border border-border p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-orange-500/10 border border-orange-500/25 flex items-center justify-center text-primary flex-shrink-0">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-muted-text font-bold uppercase tracking-wide block">Tổng Doanh Thu</span>
            <span className="text-sm sm:text-base font-black text-foreground">{formatPrice(totalRevenue)}</span>
          </div>
        </div>

        <div className="bg-card border border-border p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-green-500/10 border border-green-500/25 flex items-center justify-center text-green-400 flex-shrink-0">
            <ListOrdered className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-muted-text font-bold uppercase tracking-wide block">Đơn Hàng Đã Nhận</span>
            <span className="text-sm sm:text-base font-black text-foreground">{orders.length} Đơn Hàng</span>
          </div>
        </div>

        <div className="bg-card border border-border p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-stone-500/10 border border-stone-500/25 flex items-center justify-center text-muted-text flex-shrink-0">
            <Package className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-muted-text font-bold uppercase tracking-wide block">Tổng Loại Loa</span>
            <span className="text-sm sm:text-base font-black text-foreground">{products.length} Loại</span>
          </div>
        </div>

        <div className="bg-card border border-border p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/25 flex items-center justify-center text-red-400 flex-shrink-0">
            <AlertTriangle className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-muted-text font-bold uppercase tracking-wide block">Cảnh Báo Hết Hàng</span>
            <span className="text-sm sm:text-base font-black text-foreground">{lowStockCount} Sản Phẩm</span>
          </div>
        </div>
      </div>

      {/* Tab 1: Orders Management */}
      {activeTab === 'orders' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-bold text-foreground uppercase border-l-2 border-primary pl-3">
              Danh sách đơn hàng nhận được
            </h2>
            <button
              onClick={loadData}
              className="text-xs text-primary font-bold flex items-center gap-1 hover:underline"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              Làm mới
            </button>
          </div>

          {orders.length === 0 ? (
            <div className="text-center py-16 bg-card border border-border rounded-2xl shadow-sm">
              <Package className="w-12 h-12 text-muted-text/80 mx-auto mb-4" />
              <h3 className="text-base font-bold text-foreground uppercase">Chưa có đơn hàng nào</h3>
              <p className="text-xs text-muted-text mt-1">Hệ thống chưa ghi nhận giao dịch thanh toán nào trong phiên làm việc.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {orders.map((order) => {
                const isExpanded = expandedOrderId === order.id;
                const orderCode = order.id.substring(4, 12).toUpperCase();

                const getStatusColor = (st: string) => {
                  switch (st) {
                    case 'COMPLETED':
                      return 'bg-green-500/10 text-green-500 border-green-500/20';
                    case 'PROCESSING':
                      return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
                    case 'CANCELLED':
                      return 'bg-red-500/10 text-red-500 border-red-500/20';
                    case 'PENDING':
                    default:
                      return 'bg-amber-500/10 text-amber-500 border-amber-500/20';
                  }
                };

                return (
                  <div 
                    key={order.id}
                    className="bg-card border border-border rounded-2xl overflow-hidden shadow-sm transition-all"
                  >
                    {/* Header Row */}
                    <div 
                      onClick={() => toggleOrderExpand(order.id)}
                      className="p-5 flex flex-wrap items-center justify-between gap-4 cursor-pointer hover:bg-card-hover transition-colors"
                    >
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-input-bg border border-border flex items-center justify-center text-primary font-bold font-mono text-sm shadow-inner">
                          {orderCode.slice(0, 2)}
                        </div>
                        <div>
                          <h4 className="text-sm font-bold text-foreground flex items-center gap-2">
                            Đơn hàng #{orderCode}
                            <span className={`text-[10px] font-extrabold px-2 py-0.5 rounded uppercase border ${getStatusColor(order.status)}`}>
                              {order.status}
                            </span>
                          </h4>
                          <p className="text-xs text-muted-text mt-1">
                            Khách hàng: {order.customerName} | SĐT: {order.customerPhone}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-4">
                        <div className="text-right">
                          <span className="text-xs text-muted-text font-semibold block">Tổng hóa đơn</span>
                          <span className="text-sm font-black text-primary">{formatPrice(order.total)}</span>
                        </div>
                        {isExpanded ? <ChevronUp className="w-5 h-5 text-muted-text" /> : <ChevronDown className="w-5 h-5 text-muted-text" />}
                      </div>
                    </div>

                    {/* Expandable Order Details & Status Update Panel */}
                    {isExpanded && (
                      <div className="px-5 pb-5 pt-3 border-t border-border bg-muted-bg/10 text-xs space-y-4 animate-fade-in">
                        {/* Status Change Buttons */}
                        <div className="p-3 bg-card border border-border rounded-xl flex flex-wrap items-center justify-between gap-3">
                          <span className="font-bold text-foreground uppercase text-[11px]">Cập nhật trạng thái đơn:</span>
                          <div className="flex flex-wrap gap-2">
                            <button
                              onClick={() => handleUpdateOrderStatus(order.id, 'PENDING')}
                              disabled={updatingOrderId === order.id}
                              className={`px-3 py-1.5 rounded-lg border text-[11px] font-bold flex items-center gap-1 transition-all ${
                                order.status === 'PENDING' ? 'bg-amber-500 text-white border-amber-500' : 'bg-input-bg border-border text-muted-text hover:text-foreground'
                              }`}
                            >
                              <Clock className="w-3.5 h-3.5" />
                              Pending
                            </button>

                            <button
                              onClick={() => handleUpdateOrderStatus(order.id, 'PROCESSING')}
                              disabled={updatingOrderId === order.id}
                              className={`px-3 py-1.5 rounded-lg border text-[11px] font-bold flex items-center gap-1 transition-all ${
                                order.status === 'PROCESSING' ? 'bg-blue-500 text-white border-blue-500' : 'bg-input-bg border-border text-muted-text hover:text-foreground'
                              }`}
                            >
                              <RefreshCw className="w-3.5 h-3.5" />
                              Processing
                            </button>

                            <button
                              onClick={() => handleUpdateOrderStatus(order.id, 'COMPLETED')}
                              disabled={updatingOrderId === order.id}
                              className={`px-3 py-1.5 rounded-lg border text-[11px] font-bold flex items-center gap-1 transition-all ${
                                order.status === 'COMPLETED' ? 'bg-green-500 text-white border-green-500' : 'bg-input-bg border-border text-muted-text hover:text-foreground'
                              }`}
                            >
                              <CheckCircle2 className="w-3.5 h-3.5" />
                              Completed
                            </button>

                            <button
                              onClick={() => handleUpdateOrderStatus(order.id, 'CANCELLED')}
                              disabled={updatingOrderId === order.id}
                              className={`px-3 py-1.5 rounded-lg border text-[11px] font-bold flex items-center gap-1 transition-all ${
                                order.status === 'CANCELLED' ? 'bg-red-500 text-white border-red-500' : 'bg-input-bg border-border text-muted-text hover:text-foreground'
                              }`}
                            >
                              <XCircle className="w-3.5 h-3.5" />
                              Cancelled
                            </button>
                          </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-muted-text">
                          <div>
                            <h5 className="font-bold text-foreground uppercase mb-2">Chi tiết người nhận</h5>
                            <ul className="space-y-1.5">
                              <li><span className="text-muted-text/90 font-semibold">Tên:</span> {order.customerName}</li>
                              <li><span className="text-muted-text/90 font-semibold">Điện thoại:</span> {order.customerPhone}</li>
                              <li><span className="text-muted-text/90 font-semibold">Email:</span> {order.customerEmail}</li>
                              <li><span className="text-muted-text/90 font-semibold">Địa chỉ:</span> {order.address}</li>
                            </ul>
                          </div>
                          <div>
                            <h5 className="font-bold text-foreground uppercase mb-2">Thông tin thanh toán</h5>
                            <ul className="space-y-1.5">
                              <li>
                                <span className="text-muted-text/90 font-semibold">Phương thức:</span>{' '}
                                <span className="uppercase font-bold text-foreground">{order.paymentMethod}</span>
                              </li>
                              <li><span className="text-muted-text/90 font-semibold">Ngày tạo:</span> {new Date(order.createdAt).toLocaleString('vi-VN')}</li>
                            </ul>
                          </div>
                        </div>

                        {/* Order Items Table */}
                        <div>
                          <h5 className="font-bold text-foreground uppercase mb-2">Sản phẩm đã chọn</h5>
                          <div className="border border-border rounded-xl overflow-hidden bg-input-bg shadow-sm">
                            <table className="w-full text-left">
                              <thead>
                                <tr className="bg-card text-muted-text border-b border-border text-[10px] uppercase font-bold tracking-wider">
                                  <th className="px-4 py-2">Loa</th>
                                  <th className="px-4 py-2 text-center">Hãng</th>
                                  <th className="px-4 py-2 text-center">Số lượng</th>
                                  <th className="px-4 py-2 text-right">Đơn giá</th>
                                  <th className="px-4 py-2 text-right">Thành tiền</th>
                                </tr>
                              </thead>
                              <tbody className="divide-y divide-border text-muted-text">
                                {order.items.map((item) => (
                                  <tr key={item.id}>
                                    <td className="px-4 py-3 font-semibold text-foreground">{item.product?.name || 'Sản phẩm'}</td>
                                    <td className="px-4 py-3 text-center text-muted-text uppercase font-bold">{item.product?.brand}</td>
                                    <td className="px-4 py-3 text-center">{item.quantity}</td>
                                    <td className="px-4 py-3 text-right">{formatPrice(item.price)}</td>
                                    <td className="px-4 py-3 text-right text-primary font-bold">{formatPrice(item.price * item.quantity)}</td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* Tab 2: Add New Product Form */}
      {activeTab === 'add-product' && (
        <form onSubmit={handleAddProductSubmit} className="bg-card border border-border p-6 sm:p-8 rounded-3xl space-y-6 shadow-sm">
          <div className="flex items-center justify-between pb-3 border-b border-border">
            <h2 className="text-lg font-bold text-foreground uppercase border-l-2 border-primary pl-3">
              Thêm thiết bị loa mới vào hệ thống
            </h2>
            <Link href="/catalog" className="text-xs text-primary hover:underline font-bold">
              Xem cửa hàng →
            </Link>
          </div>

          {formSuccess && (
            <div className="p-4 bg-green-500/10 border border-green-500/20 text-green-400 rounded-xl flex items-start gap-2.5">
              <ShieldCheck className="w-5 h-5 flex-shrink-0 mt-0.5" />
              <div>
                <h4 className="text-sm font-bold">Đã lưu sản phẩm mới thành công!</h4>
                <p className="text-xs text-green-400/85 mt-0.5">Sản phẩm đã được bổ sung trực tiếp vào cơ sở dữ liệu và hiển thị trên cửa hàng.</p>
              </div>
            </div>
          )}

          {/* Form Rows */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Name */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Tên thiết bị loa *</label>
              <input
                type="text"
                required
                placeholder="Ví dụ: Loa JBL Boombox 3"
                value={productName}
                onChange={(e) => handleNameChange(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
            
            {/* Slug */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Đường dẫn tĩnh (Slug) *</label>
              <input
                type="text"
                required
                placeholder="loa-jbl-boombox-3"
                value={productSlug}
                onChange={(e) => setProductSlug(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-5">
            {/* Brand */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Thương hiệu</label>
              <select
                value={productBrand}
                onChange={(e) => setProductBrand(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-3 py-3 text-xs text-foreground focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              >
                <option value="JBL">JBL</option>
                <option value="Marshall">Marshall</option>
                <option value="KEF">KEF</option>
                <option value="Klipsch">Klipsch</option>
                <option value="KRK">KRK</option>
                <option value="Yamaha">Yamaha</option>
              </select>
            </div>

            {/* Type */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Kiểu thiết kế</label>
              <select
                value={productType}
                onChange={(e) => setProductType(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-3 py-3 text-xs text-foreground focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              >
                <option value="Bookshelf">Bookshelf</option>
                <option value="Floorstanding">Floorstanding</option>
                <option value="Bluetooth">Bluetooth</option>
                <option value="Soundbar">Soundbar</option>
                <option value="Monitor">Studio Monitor</option>
              </select>
            </div>

            {/* Category */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Danh mục hiển thị</label>
              <select
                value={productCategoryId}
                onChange={(e) => setProductCategoryId(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-3 py-3 text-xs text-foreground focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              >
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Stock */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Số lượng nhập kho *</label>
              <input
                type="number"
                required
                min={0}
                placeholder="10"
                value={productStock}
                onChange={(e) => setProductStock(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-5">
            {/* Price */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Giá khuyến mãi (VND) *</label>
              <input
                type="number"
                required
                placeholder="Giá thực tế bán..."
                value={productPrice}
                onChange={(e) => setProductPrice(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>

            {/* Original Price */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Giá niêm yết gốc (VND)</label>
              <input
                type="number"
                placeholder="Ví dụ: Giá khi chưa giảm..."
                value={productOriginalPrice}
                onChange={(e) => setProductOriginalPrice(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>

            {/* Audio Url */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Mẫu âm thanh nghe thử (Audio URL)</label>
              <input
                type="text"
                placeholder="Đường dẫn file .mp3..."
                value={productAudioUrl}
                onChange={(e) => setProductAudioUrl(e.target.value)}
                className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
              />
            </div>

            {/* Image Upload Input */}
            <div className="space-y-1.5 text-left">
              <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Hình Ảnh Sản Phẩm</label>
              <div className="flex gap-2">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                  id="image-upload-file"
                />
                <label
                  htmlFor="image-upload-file"
                  className="flex-1 bg-input-bg hover:bg-card-hover border border-border rounded-xl px-4 py-3 text-xs text-foreground font-semibold cursor-pointer text-center truncate transition-colors flex items-center justify-center min-h-[44px]"
                >
                  {isUploading ? 'Đang tải lên...' : productImage ? '✓ Đã tải ảnh' : 'Chọn ảnh...'}
                </label>
                {productImage && (
                  <div className="w-11 h-11 border border-border rounded-xl overflow-hidden flex-shrink-0">
                    <img src={productImage} alt="Preview" className="w-full h-full object-cover" />
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Description */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-muted-text uppercase tracking-wider">Mô tả sản phẩm *</label>
            <textarea
              required
              rows={4}
              placeholder="Nhập giới thiệu chi tiết về sản phẩm..."
              value={productDescription}
              onChange={(e) => setProductDescription(e.target.value)}
              className="w-full bg-input-bg border border-border rounded-xl px-4 py-3 text-xs text-foreground placeholder-muted-text/70 focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 resize-none"
            />
          </div>

          {/* Technical Specifications Builder */}
          <div className="space-y-4 text-left">
            <div className="flex items-center justify-between border-b border-border pb-2">
              <h3 className="text-xs font-bold text-foreground uppercase tracking-wider flex items-center gap-1">
                <Plus className="w-4 h-4 text-primary" />
                Bộ thông số kỹ thuật chi tiết
              </h3>
              <button
                type="button"
                onClick={handleAddSpecRow}
                className="text-xs text-primary hover:text-orange-700 font-bold flex items-center gap-0.5 transition-colors"
              >
                + Thêm hàng
              </button>
            </div>

            <div className="space-y-2">
              {specs.map((spec, index) => (
                <div key={index} className="flex gap-4 items-center">
                  <input
                    type="text"
                    required
                    placeholder="Tên thông số (e.g. Công suất)"
                    value={spec.key}
                    onChange={(e) => handleSpecChange(index, 'key', e.target.value)}
                    className="flex-1 bg-input-bg border border-border rounded-xl px-4 py-2 text-xs text-foreground focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                  />
                  <input
                    type="text"
                    required
                    placeholder="Giá trị (e.g. 100W)"
                    value={spec.value}
                    onChange={(e) => handleSpecChange(index, 'value', e.target.value)}
                    className="flex-1 bg-input-bg border border-border rounded-xl px-4 py-2 text-xs text-foreground focus:bg-card focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                  />
                  <button
                    type="button"
                    onClick={() => handleRemoveSpecRow(index)}
                    className="p-2 text-muted-text hover:text-red-500 hover:bg-red-500/10 rounded-lg transition-colors flex-shrink-0"
                    disabled={specs.length <= 1}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Submit */}
          <button
            type="submit"
            className="w-full py-4 bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-700 hover:to-amber-700 text-white font-extrabold uppercase text-xs tracking-wider rounded-xl transition-all hover:scale-[1.01] active:scale-[0.99] shadow-md shadow-primary/10 btn-premium"
          >
            Lưu Loa Mới Vào Cửa Hàng
          </button>

        </form>
      )}

    </div>
  );
}
