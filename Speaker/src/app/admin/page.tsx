'use client';

import React, { useState, useEffect } from 'react';
import { Order, Product, Category } from '../../lib/types';
import { Package, ShieldCheck, ChevronDown, ChevronUp, Plus, Trash2, ListOrdered, PlusCircle, TrendingUp, AlertTriangle, Lock } from 'lucide-react';
import Link from 'next/link';

export default function AdminPage() {
  const [activeTab, setActiveTab] = useState<'orders' | 'add-product'>('orders');
  const [orders, setOrders] = useState<Order[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [expandedOrderId, setExpandedOrderId] = useState<string | null>(null);

  // Passcode security states
  const [isUnlocked, setIsUnlocked] = useState(false);
  const [passcode, setPasscode] = useState('');
  const [passcodeError, setPasscodeError] = useState(false);

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

  const [formSuccess, setFormSuccess] = useState(false);

  // Load orders, categories, and products on mount
  useEffect(() => {
    async function loadData() {
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
    }
    loadData();
  }, [activeTab, productCategoryId]);

  // Handle auto slug generation
  const handleNameChange = (name: string) => {
    setProductName(name);
    // Generate simple slug (lowercase, replace space with hyphen, remove accent characters)
    const slug = name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // remove accents
      .replace(/[^a-z0-9\s-]/g, '') // remove special characters
      .trim()
      .replace(/\s+/g, '-'); // replace spaces with hyphens
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

    // Convert specs array to Json Record
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
          images: ['https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop'],
          specs: specRecord,
          audioUrl: productAudioUrl || null,
        })
      });

      if (!response.ok) {
        throw new Error('Failed to create product');
      }

      // Clear Form
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
      setTimeout(() => setFormSuccess(false), 3000);
    } catch (err) {
      console.error('Failed to add product:', err);
      alert('Có lỗi xảy ra khi tạo sản phẩm.');
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const toggleOrderExpand = (id: string) => {
    setExpandedOrderId(expandedOrderId === id ? null : id);
  };

  // Calculate statistics metrics
  const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
  const lowStockCount = products.filter((p) => p.stock <= 5).length;

  // Passcode authentication screen
  if (!isUnlocked) {
    return (
      <div className="max-w-md mx-auto px-4 py-24 text-left">
        <div className="bg-white border border-stone-200 rounded-3xl p-8 shadow-lg space-y-6 animate-in fade-in duration-300">
          <div className="text-center space-y-2">
            <div className="w-12 h-12 bg-primary/10 border border-primary/20 text-primary rounded-full flex items-center justify-center mx-auto shadow-sm">
              <Lock className="w-6 h-6" />
            </div>
            <h1 className="text-xl font-extrabold text-stone-900 uppercase">Khu Vực Quản Trị</h1>
            <p className="text-xs text-stone-500 max-w-[280px] mx-auto leading-relaxed">
              Vui lòng nhập mật mã quản trị viên Poyken Sound để truy cập danh sách đơn hàng và quản lý sản phẩm.
            </p>
          </div>

          <form 
            onSubmit={(e) => {
              e.preventDefault();
              if (passcode === '1234') {
                setIsUnlocked(true);
                setPasscodeError(false);
              } else {
                setPasscodeError(true);
                setPasscode('');
              }
            }} 
            className="space-y-4"
          >
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider block">Mật mã truy cập</label>
              <input
                type="password"
                placeholder="Nhập mã bảo mật (Thử: 1234)..."
                value={passcode}
                onChange={(e) => setPasscode(e.target.value)}
                className={`w-full bg-stone-50 border rounded-xl px-4 py-3 text-xs text-stone-850 focus:bg-white focus:outline-none ${
                  passcodeError ? 'border-red-500 focus:border-red-500 focus:ring-red-100' : 'border-stone-250 focus:border-primary'
                }`}
              />
              {passcodeError && (
                <span className="text-[10px] text-red-650 font-bold block mt-1 animate-pulse">
                  Mật mã sai! Vui lòng thử lại hoặc sử dụng mã "1234".
                </span>
              )}
            </div>

            <button
              type="submit"
              className="w-full py-3 bg-stone-900 hover:bg-primary text-white font-extrabold text-xs uppercase tracking-wider rounded-xl transition-all shadow-sm flex items-center justify-center gap-1.5"
            >
              Xác Nhận Truy Cập
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex-1 text-left">
      
      {/* Page Header */}
      <div className="mb-10 flex flex-wrap justify-between items-end gap-4">
        <div>
          <span className="text-xs font-black uppercase text-primary tracking-widest">Hệ thống quản lý Poyken Sound</span>
          <h1 className="text-3xl font-extrabold text-stone-900 uppercase mt-1">Admin Dashboard</h1>
        </div>

        {/* Tab Controls */}
        <div className="flex bg-stone-100 border border-stone-200 p-1.5 rounded-xl shadow-inner">
          <button
            onClick={() => setActiveTab('orders')}
            className={`flex items-center gap-2 px-4 py-2 text-xs font-bold uppercase tracking-wider rounded-lg transition-all ${
              activeTab === 'orders'
                ? 'bg-primary text-white shadow-sm'
                : 'text-stone-600 hover:text-stone-900'
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
                : 'text-stone-600 hover:text-stone-900'
            }`}
          >
            <Plus className="w-4 h-4" />
            Thêm Loa Mới
          </button>
        </div>
      </div>

      {/* Key Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        <div className="bg-white border border-stone-200 p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-orange-500/10 border border-orange-500/25 flex items-center justify-center text-primary flex-shrink-0">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-stone-550 font-bold uppercase tracking-wide block">Tổng Doanh Thu</span>
            <span className="text-sm sm:text-base font-black text-stone-900">{formatPrice(totalRevenue)}</span>
          </div>
        </div>

        <div className="bg-white border border-stone-200 p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-green-500/10 border border-green-500/25 flex items-center justify-center text-green-700 flex-shrink-0">
            <ListOrdered className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-stone-550 font-bold uppercase tracking-wide block">Đơn Hàng Đã Nhận</span>
            <span className="text-sm sm:text-base font-black text-stone-900">{orders.length} Đơn Hàng</span>
          </div>
        </div>

        <div className="bg-white border border-stone-200 p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-stone-500/10 border border-stone-500/25 flex items-center justify-center text-stone-650 flex-shrink-0">
            <Package className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-stone-550 font-bold uppercase tracking-wide block">Tổng Loại Loa</span>
            <span className="text-sm sm:text-base font-black text-stone-900">{products.length} Loại</span>
          </div>
        </div>

        <div className="bg-white border border-stone-200 p-5 rounded-2xl shadow-sm flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/25 flex items-center justify-center text-red-600 flex-shrink-0">
            <AlertTriangle className="w-5 h-5" />
          </div>
          <div>
            <span className="text-[10px] text-stone-550 font-bold uppercase tracking-wide block">Cảnh Báo Hết Hàng</span>
            <span className="text-sm sm:text-base font-black text-stone-900">{lowStockCount} Sản Phẩm</span>
          </div>
        </div>
      </div>

      {/* Tab 1: Orders Management */}
      {activeTab === 'orders' && (
        <div className="space-y-6">
          <h2 className="text-lg font-bold text-stone-800 uppercase border-l-2 border-primary pl-3">
            Danh sách đơn hàng nhận được
          </h2>

          {orders.length === 0 ? (
            <div className="text-center py-16 bg-stone-50 border border-stone-200 rounded-2xl shadow-sm">
              <Package className="w-12 h-12 text-stone-400 mx-auto mb-4" />
              <h3 className="text-base font-bold text-stone-800 uppercase">Chưa có đơn hàng nào</h3>
              <p className="text-xs text-stone-500 mt-1">Hệ thống chưa ghi nhận giao dịch thanh toán nào trong phiên làm việc.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {orders.map((order) => {
                const isExpanded = expandedOrderId === order.id;
                const orderCode = order.id.substring(4, 12).toUpperCase();
                return (
                  <div 
                    key={order.id}
                    className="bg-white border border-stone-200 rounded-2xl overflow-hidden shadow-sm transition-all"
                  >
                    {/* Header Row */}
                    <div 
                      onClick={() => toggleOrderExpand(order.id)}
                      className="p-5 flex flex-wrap items-center justify-between gap-4 cursor-pointer hover:bg-stone-50/50 transition-colors"
                    >
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-stone-50 border border-stone-200 flex items-center justify-center text-primary font-bold font-mono text-sm shadow-inner">
                          {orderCode.slice(0, 2)}
                        </div>
                        <div>
                          <h4 className="text-sm font-bold text-stone-900 flex items-center gap-2">
                            Đơn hàng #{orderCode}
                            <span className="text-[10px] bg-amber-500/10 text-amber-800 font-extrabold px-1.5 py-0.5 rounded uppercase border border-amber-500/20">
                              {order.status}
                            </span>
                          </h4>
                          <p className="text-xs text-stone-500 mt-1">
                            Khách hàng: {order.customerName} | SĐT: {order.customerPhone}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-4">
                        <div className="text-right">
                          <span className="text-xs text-stone-500 block font-semibold">Tổng hóa đơn</span>
                          <span className="text-sm font-black text-primary">{formatPrice(order.total)}</span>
                        </div>
                        {isExpanded ? <ChevronUp className="w-5 h-5 text-stone-450" /> : <ChevronDown className="w-5 h-5 text-stone-450" />}
                      </div>
                    </div>

                    {/* Expandable Order Details Panel */}
                    {isExpanded && (
                      <div className="px-5 pb-5 pt-3 border-t border-stone-150 bg-stone-50/30 text-xs space-y-4 animate-in slide-in-from-top-2 duration-200">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-stone-600">
                          <div>
                            <h5 className="font-bold text-stone-800 uppercase mb-2">Chi tiết người nhận</h5>
                            <ul className="space-y-1.5">
                              <li><span className="text-stone-500 font-semibold">Tên:</span> {order.customerName}</li>
                              <li><span className="text-stone-500 font-semibold">Điện thoại:</span> {order.customerPhone}</li>
                              <li><span className="text-stone-500 font-semibold">Email:</span> {order.customerEmail}</li>
                              <li><span className="text-stone-500 font-semibold">Địa chỉ:</span> {order.address}</li>
                            </ul>
                          </div>
                          <div>
                            <h5 className="font-bold text-stone-800 uppercase mb-2">Thông tin thanh toán</h5>
                            <ul className="space-y-1.5">
                              <li>
                                <span className="text-stone-500 font-semibold">Phương thức:</span>{' '}
                                <span className="uppercase font-bold text-stone-700">{order.paymentMethod}</span>
                              </li>
                              <li><span className="text-stone-500 font-semibold">Ngày tạo:</span> {new Date(order.createdAt).toLocaleString('vi-VN')}</li>
                            </ul>
                          </div>
                        </div>

                        {/* Order Items Table */}
                        <div>
                          <h5 className="font-bold text-stone-800 uppercase mb-2">Sản phẩm đã chọn</h5>
                          <div className="border border-stone-200 rounded-xl overflow-hidden bg-white shadow-sm">
                            <table className="w-full text-left">
                              <thead>
                                <tr className="bg-stone-50 text-stone-500 border-b border-stone-200 text-[10px] uppercase font-bold tracking-wider">
                                  <th className="px-4 py-2">Loa</th>
                                  <th className="px-4 py-2 text-center">Hãng</th>
                                  <th className="px-4 py-2 text-center">Số lượng</th>
                                  <th className="px-4 py-2 text-right">Đơn giá</th>
                                  <th className="px-4 py-2 text-right">Thành tiền</th>
                                </tr>
                              </thead>
                              <tbody className="divide-y divide-stone-100 text-stone-650">
                                {order.items.map((item) => (
                                  <tr key={item.id}>
                                    <td className="px-4 py-3 font-semibold text-stone-800">{item.product?.name || 'Sản phẩm'}</td>
                                    <td className="px-4 py-3 text-center text-stone-500 uppercase font-bold">{item.product?.brand}</td>
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
        <form onSubmit={handleAddProductSubmit} className="bg-white border border-stone-200 p-6 sm:p-8 rounded-3xl space-y-6 shadow-sm">
          <div className="flex items-center justify-between pb-3 border-b border-stone-150">
            <h2 className="text-lg font-bold text-stone-850 uppercase border-l-2 border-primary pl-3">
              Thêm thiết bị loa mới vào hệ thống
            </h2>
            <Link href="/catalog" className="text-xs text-primary hover:underline font-bold">
              Xem cửa hàng →
            </Link>
          </div>

          {formSuccess && (
            <div className="p-4 bg-green-500/10 border border-green-500/20 text-green-700 rounded-xl flex items-start gap-2.5">
              <ShieldCheck className="w-5 h-5 flex-shrink-0 mt-0.5" />
              <div>
                <h4 className="text-sm font-bold">Đã lưu sản phẩm mới thành công!</h4>
                <p className="text-xs text-green-600/85 mt-0.5">Sản phẩm đã được bổ sung trực tiếp vào cơ sở dữ liệu và hiển thị trên cửa hàng.</p>
              </div>
            </div>
          )}

          {/* Form Rows */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Name */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Tên thiết bị loa *</label>
              <input
                type="text"
                required
                placeholder="Ví dụ: Loa JBL Boombox 3"
                value={productName}
                onChange={(e) => handleNameChange(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>
            
            {/* Slug */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Đường dẫn tĩnh (Slug) *</label>
              <input
                type="text"
                required
                placeholder="loa-jbl-boombox-3"
                value={productSlug}
                onChange={(e) => setProductSlug(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-5">
            {/* Brand */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Thương hiệu</label>
              <select
                value={productBrand}
                onChange={(e) => setProductBrand(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-3 py-3 text-xs text-stone-850 focus:bg-white focus:outline-none focus:border-primary"
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
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Kiểu thiết kế</label>
              <select
                value={productType}
                onChange={(e) => setProductType(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-3 py-3 text-xs text-stone-850 focus:bg-white focus:outline-none focus:border-primary"
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
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Danh mục hiển thị</label>
              <select
                value={productCategoryId}
                onChange={(e) => setProductCategoryId(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-3 py-3 text-xs text-stone-850 focus:bg-white focus:outline-none focus:border-primary"
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
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Số lượng nhập kho *</label>
              <input
                type="number"
                required
                min={0}
                placeholder="10"
                value={productStock}
                onChange={(e) => setProductStock(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
            {/* Price */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Giá khuyến mãi (VND) *</label>
              <input
                type="number"
                required
                placeholder="Giá thực tế bán..."
                value={productPrice}
                onChange={(e) => setProductPrice(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>

            {/* Original Price */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Giá niêm yết gốc (VND)</label>
              <input
                type="number"
                placeholder="Ví dụ: Giá khi chưa giảm..."
                value={productOriginalPrice}
                onChange={(e) => setProductOriginalPrice(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>

            {/* Audio Url */}
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Mẫu âm thanh nghe thử (Audio URL)</label>
              <input
                type="text"
                placeholder="Đường dẫn file .mp3..."
                value={productAudioUrl}
                onChange={(e) => setProductAudioUrl(e.target.value)}
                className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary"
              />
            </div>
          </div>

          {/* Description */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold text-stone-500 uppercase tracking-wider">Mô tả sản phẩm *</label>
            <textarea
              required
              rows={4}
              placeholder="Nhập giới thiệu chi tiết về sản phẩm..."
              value={productDescription}
              onChange={(e) => setProductDescription(e.target.value)}
              className="w-full bg-stone-50 border border-stone-250 rounded-xl px-4 py-3 text-xs text-stone-850 placeholder-stone-400 focus:bg-white focus:outline-none focus:border-primary resize-none"
            />
          </div>

          {/* Technical Specifications Builder */}
          <div className="space-y-4 text-left">
            <div className="flex items-center justify-between border-b border-stone-150 pb-2">
              <h3 className="text-xs font-bold text-stone-800 uppercase tracking-wider flex items-center gap-1">
                <PlusCircle className="w-4 h-4 text-primary" />
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
                    className="flex-1 bg-stone-50 border border-stone-200 rounded-xl px-4 py-2 text-xs text-stone-850 focus:bg-white focus:outline-none focus:border-primary"
                  />
                  <input
                    type="text"
                    required
                    placeholder="Giá trị (e.g. 100W)"
                    value={spec.value}
                    onChange={(e) => handleSpecChange(index, 'value', e.target.value)}
                    className="flex-1 bg-stone-50 border border-stone-200 rounded-xl px-4 py-2 text-xs text-stone-850 focus:bg-white focus:outline-none focus:border-primary"
                  />
                  <button
                    type="button"
                    onClick={() => handleRemoveSpecRow(index)}
                    className="p-2 text-stone-400 hover:text-red-650 hover:bg-red-50/80 rounded-lg transition-colors flex-shrink-0"
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
            className="w-full py-4 bg-gradient-to-r from-orange-600 to-amber-600 text-white font-extrabold uppercase text-xs tracking-wider rounded-xl transition-all hover:scale-[1.01] active:scale-[0.99] shadow-md shadow-primary/10"
          >
            Lưu Loa Mới Vào Cửa Hàng
          </button>

        </form>
      )}

    </div>
  );
}
