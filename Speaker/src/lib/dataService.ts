import { prisma } from './prisma';

import { Category, Product, Review, Order, OrderItem } from './types';

export type { Category, Product, Review, Order, OrderItem };

// -------------------------------------------------------------
// RICH LOCAL FALLBACK DATA (PREMIUM AUDIO SYSTEM THEME)
// -------------------------------------------------------------

const fallbackCategories: Category[] = [
  { id: 'cat-bookshelf', name: 'Loa Bookshelf', slug: 'loa-bookshelf' },
  { id: 'cat-floorstanding', name: 'Loa Cột (Floorstanding)', slug: 'loa-cot' },
  { id: 'cat-bluetooth', name: 'Loa Bluetooth Di Động', slug: 'loa-bluetooth' },
  { id: 'cat-soundbar', name: 'Loa Soundbar (Tivi)', slug: 'loa-soundbar' },
  { id: 'cat-monitor', name: 'Loa Kiểm Âm (Studio)', slug: 'loa-kiem-am' },
];

const fallbackReviews: Review[] = [
  { id: 'rev-1', userName: 'Nguyễn Văn Hùng', rating: 5, comment: 'Âm thanh chi tiết tuyệt vời, tiếng treble sáng và không chói. Rất đáng đồng tiền bát gạo.', productId: 'prod-jbl-l52', createdAt: new Date() },
  { id: 'rev-2', userName: 'Trần Minh Tuấn', rating: 4, comment: 'Bass đầm, trung âm mượt. Thiết kế vân gỗ óc chó cực đẹp và vintage.', productId: 'prod-jbl-l52', createdAt: new Date() },
  { id: 'rev-3', userName: 'Lê Hoàng Nam', rating: 5, comment: 'Đậm chất Marshall! Loa để trưng phòng khách rất sang, âm trường rộng nghe nhạc trữ tình rất phê.', productId: 'prod-marshall-stanmore', createdAt: new Date() },
  { id: 'rev-4', userName: 'Phạm Thanh Sơn', rating: 5, comment: 'Uy lực khủng khiếp, xem phim hành động không cần loa sub ngoài vẫn rung chuyển cả nhà.', productId: 'prod-klipsch-rp8000', createdAt: new Date() },
];

const fallbackProducts: Product[] = [
  {
    id: 'prod-jbl-l52',
    name: 'JBL L52 Classic',
    slug: 'jbl-l52-classic',
    description: 'Loa bookshelf cổ điển từ thương hiệu JBL nổi tiếng Hoa Kỳ. Sở hữu củ loa woofer 5.25 inch hình nón bằng giấy màu trắng đặc trưng và thiết kế thùng loa vân gỗ óc chó sang trọng kết hợp tấm lưới bọt Quadrex nổi bật (có 3 màu Cam, Xanh dương, Đen). Âm thanh trung thực, dải trung ngọt ngào và dải cao tách bạch.',
    price: 24500000,
    originalPrice: 28000000,
    images: [
      'https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1582730147233-ac811214045e?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'JBL',
    type: 'Bookshelf',
    specs: {
      'Củ loa trầm': '5.25" (133mm) Pure Pulp cone woofer (JW135PW-4)',
      'Củ loa cao': '0.75" (20mm) Titanium dome tweeter (JT020TI1-4)',
      'Công suất đề xuất': '10 - 75W RMS',
      'Tần số đáp ứng': '47Hz - 24kHz (-6dB)',
      'Độ nhạy': '85dB',
      'Trở kháng': '4 Ohms',
      'Kích thước': '330.2 x 196.6 x 216.2 mm',
      'Trọng lượng': '5.0 kg/loa'
    },
    stock: 12,
    rating: 4.8,
    audioUrl: '/audio/jbl_l52_demo.mp3',
    categoryId: 'cat-bookshelf',
  },
  {
    id: 'prod-kef-q350',
    name: 'KEF Q350',
    slug: 'kef-q350',
    description: 'Loa bookshelf Hi-Fi sở hữu công nghệ đồng trục Uni-Q độc quyền thế hệ thứ 11 của hãng KEF Anh Quốc. Thiết kế tối giản, hiện đại và thanh lịch. Với driver đồng trục, âm thanh từ loa treble và loa mid-bass phát ra từ cùng một điểm trong không gian giúp loại bỏ hiện tượng lệch pha, mang lại âm hình chính xác vượt trội.',
    price: 18900000,
    originalPrice: 21500000,
    images: [
      'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1606220838315-056192d5e927?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1524282745852-a463fa495977?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'KEF',
    type: 'Bookshelf',
    specs: {
      'Kiến trúc driver': 'Đồng trục Uni-Q',
      'Củ loa': '6.5" nhôm Uni-Q + 1" tweeter nhôm thông khí',
      'Công suất đề xuất': '15 - 120W',
      'Tần số đáp ứng': '63Hz - 28kHz (±3dB)',
      'Độ nhạy': '87dB',
      'Trở kháng': '8 Ohms',
      'Kích thước': '358 x 210 x 306 mm',
      'Trọng lượng': '7.6 kg'
    },
    stock: 8,
    rating: 4.6,
    audioUrl: '/audio/kef_q350_demo.mp3',
    categoryId: 'cat-bookshelf',
  },
  {
    id: 'prod-marshall-stanmore',
    name: 'Marshall Stanmore III',
    slug: 'marshall-stanmore-iii',
    description: 'Chiếc loa bluetooth gia đình mang tính biểu tượng của Marshall. Thế hệ thứ III sở hữu âm trường rộng hơn thế hệ trước, mang lại âm thanh đặc trưng tràn ngập căn phòng. Hệ thống củ loa được thiết kế lại hướng ra ngoài và các ống dẫn sóng được cập nhật để mang lại âm thanh chắc chắn nhất quán. Bảng điều khiển phía trên đậm nét cổ điển với núm xoay kim loại điều chỉnh Bass, Treble, Volume.',
    price: 9490000,
    originalPrice: 10990000,
    images: [
      'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'Marshall',
    type: 'Bluetooth',
    specs: {
      'Bộ khuếch đại': '1 x 50W Class D (Woofer) + 2 x 15W Class D (Tweeters)',
      'Kết nối không dây': 'Bluetooth 5.2 (Hỗ trợ LE Audio)',
      'Kết nối có dây': 'AUX 3.5mm, RCA',
      'Dải tần đáp ứng': '45Hz - 20kHz',
      'Độ lớn tối đa': '97dB @ 1m',
      'Ứng dụng di động': 'Marshall Bluetooth App',
      'Kích thước': '350 x 203 x 188 mm',
      'Trọng lượng': '4.25 kg'
    },
    stock: 25,
    rating: 4.9,
    audioUrl: '/audio/marshall_demo.mp3',
    categoryId: 'cat-bluetooth',
  },
  {
    id: 'prod-marshall-emberton',
    name: 'Marshall Emberton II',
    slug: 'marshall-emberton-ii',
    description: 'Dòng loa di động bán chạy nhất của Marshall hiện nay. Siêu nhỏ gọn, cứng cáp với khả năng kháng nước kháng bụi chuẩn IP67 tuyệt đối. Loa sử dụng công nghệ True Stereophonic - một dạng âm thanh đa hướng độc đáo từ Marshall, giúp trải nghiệm âm thanh 360 độ sống động ở bất kỳ đâu. Pin cực khỏe lên tới 30 giờ chơi nhạc chỉ với một lần sạc.',
    price: 3990000,
    originalPrice: 4500000,
    images: [
      'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'Marshall',
    type: 'Bluetooth',
    specs: {
      'Driver': '2 x 2" toàn dải + 2 màng thụ động',
      'Công suất': '2 x 10W Class D',
      'Chuẩn kháng nước': 'IP67 (Chống bụi và chìm dưới nước 1m trong 30p)',
      'Thời lượng pin': '30+ giờ (Sạc nhanh 20p được 4 giờ)',
      'Kết nối': 'Bluetooth 5.1',
      'Kích thước': '68 x 160 x 76 mm',
      'Trọng lượng': '0.7 kg'
    },
    stock: 40,
    rating: 4.7,
    audioUrl: '/audio/emberton_demo.mp3',
    categoryId: 'cat-bluetooth',
  },
  {
    id: 'prod-klipsch-rp8000',
    name: 'Klipsch Reference Premiere RP-8000F II',
    slug: 'klipsch-rp-8000f-ii',
    description: 'Loa cột nghe nhạc và xem phim đầu bảng thuộc dòng Reference Premiere thế hệ II của Klipsch Mỹ. Thiết kế họng kèn Tractrix Horn bằng hợp chất silicon đúc lớn hơn giúp cải thiện rõ rệt dải âm cao trung thực, mượt mà. Hai củ loa woofer Cerametallic 8 inch phủ đồng ánh kim mang lại dải trầm uy lực sâu lắng, là mảnh ghép hoàn hảo cho phòng phim gia đình cao cấp.',
    price: 36500000,
    originalPrice: 42000000,
    images: [
      'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1582730147233-ac811214045e?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'Klipsch',
    type: 'Floorstanding',
    specs: {
      'Củ loa': '1" Titanium LTS Tweeter họng kèn + kép 8" Cerametallic Woofers',
      'Tần số đáp ứng': '35Hz - 25kHz (±3dB)',
      'Độ nhạy': '98dB @ 2.83V / 1m (Cực kỳ nhạy, dễ kéo amply)',
      'Công suất': '150W RMS / 600W Peak',
      'Trở kháng': '8 Ohms',
      'Kích thước': '1095 x 275 x 463 mm',
      'Trọng lượng': '27.85 kg / chiếc'
    },
    stock: 6,
    rating: 4.9,
    audioUrl: '/audio/klipsch_demo.mp3',
    categoryId: 'cat-floorstanding',
  },
  {
    id: 'prod-jbl-bar1000',
    name: 'JBL Bar 1000',
    slug: 'jbl-bar-1000',
    description: 'Hệ thống loa thanh Soundbar cao cấp nhất của JBL mang rạp chiếu phim Dolby Atmos và DTS:X thực sự vào ngôi nhà của bạn. Hệ thống sở hữu loa vòm không dây có thể tháo rời chạy bằng pin và một loa sub siêu trầm không dây 10 inch. Tổng công suất hệ thống đạt 880W mang lại hiệu ứng âm thanh vòm 3D điện ảnh cực kỳ mạnh mẽ, hoành tráng.',
    price: 22900000,
    originalPrice: 26900000,
    images: [
      'https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1545454675-3531b543be5d?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'JBL',
    type: 'Soundbar',
    specs: {
      'Cấu hình kênh': '7.1.4 kênh (Dolby Atmos & DTS:X)',
      'Tổng công suất': '880W (Loa thanh: 440W, Loa vòm: 2x70W, Loa sub: 300W)',
      'Loa Subwoofer': '10" (260mm) Driver không dây',
      'Kết nối': '1 HDMI In, 1 HDMI eARC Out (4K Passthrough), Optical, Wi-Fi, AirPlay 2',
      'Công nghệ': 'PureVoice đối thoại thông minh',
      'Kích thước loa chính': '1020 x 58 x 139 mm',
      'Kích thước loa vòm': '202 x 58 x 139 mm (mỗi bên)'
    },
    stock: 15,
    rating: 4.8,
    audioUrl: null,
    categoryId: 'cat-soundbar',
  },
  {
    id: 'prod-krk-rokit5',
    name: 'KRK ROKIT 5 G4',
    slug: 'krk-rokit-5-g4',
    description: 'Loa kiểm âm phòng thu chuyên nghiệp bán chạy hàng đầu thế giới dành cho các nhà sản xuất nhạc, DJ và kỹ sư âm thanh. Thế hệ thứ 4 (G4) được thiết kế lại hoàn toàn với củ loa trầm và loa treble làm từ sợi Kevlar cao cấp màu vàng đen đặc trưng, mang lại độ chính xác cực cao, hạn chế méo tiếng. Tích hợp màn hình LCD hiển thị EQ trực quan phía sau loa.',
    price: 8800000,
    originalPrice: 9800000,
    images: [
      'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1598653222000-6b7b7a552625?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'KRK',
    type: 'Monitor',
    specs: {
      'Củ loa': '5" Kevlar® Aramid Fiber Woofer + 1" Kevlar® Tweeter',
      'Bộ khuếch đại': 'Bi-amped Class D (55W tổng công suất)',
      'Dải tần đáp ứng': '43Hz - 40kHz',
      'Kết nối': 'XLR / TRS Combo Jack cân bằng',
      'Màn hình điều khiển': 'LCD EQ DSP (25 cấu hình EQ tích hợp)',
      'Kích thước': '285 x 190 x 241 mm',
      'Trọng lượng': '4.85 kg'
    },
    stock: 18,
    rating: 4.7,
    audioUrl: '/audio/krk_demo.mp3',
    categoryId: 'cat-monitor',
  },
  {
    id: 'prod-yamaha-hs5',
    name: 'Yamaha HS5',
    slug: 'yamaha-hs-5',
    description: 'Loa kiểm âm phòng thu huyền thoại mang tính biểu tượng với củ loa bass màng màu trắng đặc trưng của Yamaha Nhật Bản. Loa được thiết kế để mang lại tần số đáp ứng phẳng nhất có thể, hoàn toàn trung thực, giúp bạn phát hiện mọi lỗi nhỏ trong bản phối nhạc. Là lựa chọn tin cậy của hàng ngàn phòng thu chuyên nghiệp trên toàn thế giới.',
    price: 9500000,
    originalPrice: 10500000,
    images: [
      'https://images.unsplash.com/photo-1598653222000-6b7b7a552625?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=800&auto=format&fit=crop'
    ],
    brand: 'Yamaha',
    type: 'Monitor',
    specs: {
      'Củ loa': '5" Cone Woofer + 1" Dome Tweeter',
      'Kiểu loa': 'Bi-amp 2 đường tiếng (45W LF + 25W HF)',
      'Dải tần': '54Hz - 30kHz',
      'Kết nối': 'XLR3-31, PHONE (Balanced)',
      'Điều khiển': 'ROOM CONTROL, HIGH TRIM',
      'Kích thước': '170 x 285 x 222 mm',
      'Trọng lượng': '5.3 kg'
    },
    stock: 14,
    rating: 4.7,
    audioUrl: '/audio/yamaha_demo.mp3',
    categoryId: 'cat-monitor',
  }
];

// Memory state for orders and reviews added in the UI session
const localOrders: Order[] = [];
const localReviews: Review[] = [...fallbackReviews];

// -------------------------------------------------------------
// DATA SERVICE IMPLEMENTATION (TRY PRISMA -> FALLBACK TO LOCAL)
// -------------------------------------------------------------

export const dataService = {
  // CATEGORIES
  async getCategories(): Promise<Category[]> {
    try {
      if (!prisma) return fallbackCategories;
      const categories = await prisma.category.findMany({
        orderBy: { name: 'asc' },
      });
      if (categories.length > 0) return categories;
      return fallbackCategories;
    } catch (e) {
      console.warn('Prisma getCategories failed, falling back to mock data:', e);
      return fallbackCategories;
    }
  },

  // PRODUCTS
  async getProducts(options: {
    categoryId?: string;
    search?: string;
    brand?: string;
    type?: string;
    sort?: string;
    minPrice?: number;
    maxPrice?: number;
  } = {}): Promise<Product[]> {
    try {
      if (!prisma) return this.getFallbackProductsFiltered(options);
      // Build Prisma query clauses
      const where: any = {};
      if (options.categoryId) where.categoryId = options.categoryId;
      if (options.type) where.type = options.type;
      if (options.brand) where.brand = { contains: options.brand, mode: 'insensitive' };
      if (options.search) {
        where.OR = [
          { name: { contains: options.search, mode: 'insensitive' } },
          { description: { contains: options.search, mode: 'insensitive' } },
          { brand: { contains: options.search, mode: 'insensitive' } },
        ];
      }
      
      if (options.minPrice !== undefined || options.maxPrice !== undefined) {
        where.price = {};
        if (options.minPrice !== undefined) where.price.gte = options.minPrice;
        if (options.maxPrice !== undefined) where.price.lte = options.maxPrice;
      }

      let orderBy: any = { createdAt: 'desc' };
      if (options.sort === 'price-asc') orderBy = { price: 'asc' };
      if (options.sort === 'price-desc') orderBy = { price: 'desc' };
      if (options.sort === 'rating') orderBy = { rating: 'desc' };

      const products = await prisma.product.findMany({
        where,
        orderBy,
        include: { reviews: true }
      });

      if (products.length > 0) return products as unknown as Product[];
      
      // Fallback filtering if prisma is empty or offline
      return this.getFallbackProductsFiltered(options);
    } catch (e) {
      console.warn('Prisma getProducts failed, falling back to mock data:', e);
      return this.getFallbackProductsFiltered(options);
    }
  },

  getFallbackProductsFiltered(options: {
    categoryId?: string;
    search?: string;
    brand?: string;
    type?: string;
    sort?: string;
    minPrice?: number;
    maxPrice?: number;
  }) {
    let result = [...fallbackProducts];

    // Embed reviews
    result = result.map(p => ({
      ...p,
      reviews: localReviews.filter(r => r.productId === p.id)
    }));

    if (options.categoryId) {
      result = result.filter(p => p.categoryId === options.categoryId);
    }
    if (options.type) {
      result = result.filter(p => p.type === options.type);
    }
    if (options.brand) {
      result = result.filter(p => p.brand.toLowerCase() === options.brand!.toLowerCase());
    }
    if (options.search) {
      const searchLower = options.search.toLowerCase();
      result = result.filter(
        p => p.name.toLowerCase().includes(searchLower) || 
             p.description.toLowerCase().includes(searchLower) ||
             p.brand.toLowerCase().includes(searchLower)
      );
    }
    if (options.minPrice !== undefined) {
      result = result.filter(p => p.price >= options.minPrice!);
    }
    if (options.maxPrice !== undefined) {
      result = result.filter(p => p.price <= options.maxPrice!);
    }

    if (options.sort === 'price-asc') {
      result.sort((a, b) => a.price - b.price);
    } else if (options.sort === 'price-desc') {
      result.sort((a, b) => b.price - a.price);
    } else if (options.sort === 'rating') {
      result.sort((a, b) => b.rating - a.rating);
    } else {
      // default: newer first
      result.reverse();
    }

    return result;
  },

  // PRODUCT BY SLUG
  async getProductBySlug(slug: string): Promise<Product | null> {
    try {
      if (!prisma) {
        const localP = fallbackProducts.find(p => p.slug === slug);
        if (localP) {
          return {
            ...localP,
            reviews: localReviews.filter(r => r.productId === localP.id)
          };
        }
        return null;
      }
      const product = await prisma.product.findUnique({
        where: { slug },
        include: { reviews: true }
      });
      if (product) return product as unknown as Product;
      
      const localP = fallbackProducts.find(p => p.slug === slug);
      if (localP) {
        return {
          ...localP,
          reviews: localReviews.filter(r => r.productId === localP.id)
        };
      }
      return null;
    } catch (e) {
      console.warn('Prisma getProductBySlug failed, falling back to mock data:', e);
      const localP = fallbackProducts.find(p => p.slug === slug);
      if (localP) {
        return {
          ...localP,
          reviews: localReviews.filter(r => r.productId === localP.id)
        };
      }
      return null;
    }
  },

  // ADD REVIEW
  async addReview(productId: string, data: { userName: string; rating: number; comment: string }): Promise<Review> {
    try {
      if (!prisma) {
        const mockReview: Review = {
          id: `rev-${Date.now()}`,
          userName: data.userName,
          rating: data.rating,
          comment: data.comment,
          productId,
          createdAt: new Date(),
        };
        localReviews.push(mockReview);
        
        // Update local product rating
        const product = fallbackProducts.find(p => p.id === productId);
        if (product) {
          const pReviews = localReviews.filter(r => r.productId === productId);
          const avg = pReviews.reduce((sum, r) => sum + r.rating, 0) / pReviews.length;
          product.rating = Number(avg.toFixed(1));
        }

        return mockReview;
      }
      const newReview = await prisma.review.create({
        data: {
          productId,
          userName: data.userName,
          rating: data.rating,
          comment: data.comment,
        }
      });
      
      // Re-calculate product rating in background if possible
      try {
        const allReviews = await prisma.review.findMany({ where: { productId } });
        const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;
        await prisma.product.update({
          where: { id: productId },
          data: { rating: Number(avgRating.toFixed(1)) }
        });
      } catch (innerErr) {
        console.error('Failed to update product rating on DB', innerErr);
      }

      return newReview;
    } catch (e) {
      console.warn('Prisma addReview failed, saving to local session memory:', e);
      const mockReview: Review = {
        id: `rev-${Date.now()}`,
        userName: data.userName,
        rating: data.rating,
        comment: data.comment,
        productId,
        createdAt: new Date(),
      };
      localReviews.push(mockReview);
      
      // Update local product rating
      const product = fallbackProducts.find(p => p.id === productId);
      if (product) {
        const pReviews = localReviews.filter(r => r.productId === productId);
        const avg = pReviews.reduce((sum, r) => sum + r.rating, 0) / pReviews.length;
        product.rating = Number(avg.toFixed(1));
      }

      return mockReview;
    }
  },

  // CREATE ORDER
  async createOrder(orderData: {
    customerName: string;
    customerEmail: string;
    customerPhone: string;
    address: string;
    paymentMethod: string;
    total: number;
    items: Array<{ productId: string; quantity: number; price: number }>;
  }): Promise<Order> {
    try {
      if (!prisma) {
        const orderItemsMock: OrderItem[] = orderData.items.map((item, idx) => {
          const product = fallbackProducts.find(p => p.id === item.productId);
          // Deduct local stock
          if (product) {
            product.stock = Math.max(0, product.stock - item.quantity);
          }
          return {
            id: `ord-item-${Date.now()}-${idx}`,
            orderId: `ord-${Date.now()}`,
            productId: item.productId,
            product,
            quantity: item.quantity,
            price: item.price
          };
        });

        const mockOrder: Order = {
          id: `ord-${Date.now()}`,
          customerName: orderData.customerName,
          customerEmail: orderData.customerEmail,
          customerPhone: orderData.customerPhone,
          address: orderData.address,
          paymentMethod: orderData.paymentMethod,
          status: 'PENDING',
          total: orderData.total,
          items: orderItemsMock,
          createdAt: new Date(),
        };
        
        localOrders.push(mockOrder);
        return mockOrder;
      }
      const order = await prisma.order.create({
        data: {
          customerName: orderData.customerName,
          customerEmail: orderData.customerEmail,
          customerPhone: orderData.customerPhone,
          address: orderData.address,
          paymentMethod: orderData.paymentMethod,
          status: 'PENDING',
          total: orderData.total,
          items: {
            create: orderData.items.map(item => ({
              productId: item.productId,
              quantity: item.quantity,
              price: item.price
            }))
          }
        },
        include: {
          items: {
            include: { product: true }
          }
        }
      });
      
      // Deduct stock
      for (const item of orderData.items) {
        try {
          await prisma.product.update({
            where: { id: item.productId },
            data: { stock: { decrement: item.quantity } }
          });
        } catch (stockErr) {
          console.error(`Failed to decrement stock for product ${item.productId}`, stockErr);
        }
      }

      return order as unknown as Order;
    } catch (e) {
      console.warn('Prisma createOrder failed, saving to local session memory:', e);
      
      const orderItemsMock: OrderItem[] = orderData.items.map((item, idx) => {
        const product = fallbackProducts.find(p => p.id === item.productId);
        // Deduct local stock
        if (product) {
          product.stock = Math.max(0, product.stock - item.quantity);
        }
        return {
          id: `ord-item-${Date.now()}-${idx}`,
          orderId: `ord-${Date.now()}`,
          productId: item.productId,
          product,
          quantity: item.quantity,
          price: item.price
        };
      });

      const mockOrder: Order = {
        id: `ord-${Date.now()}`,
        customerName: orderData.customerName,
        customerEmail: orderData.customerEmail,
        customerPhone: orderData.customerPhone,
        address: orderData.address,
        paymentMethod: orderData.paymentMethod,
        status: 'PENDING',
        total: orderData.total,
        items: orderItemsMock,
        createdAt: new Date(),
      };
      
      localOrders.push(mockOrder);
      return mockOrder;
    }
  },

  // GET ALL ORDERS (FOR ADMIN PANEL)
  async getOrders(): Promise<Order[]> {
    try {
      if (!prisma) return localOrders;
      const orders = await prisma.order.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          items: {
            include: { product: true }
          }
        }
      });
      if (orders.length > 0) return orders as unknown as Order[];
      return localOrders;
    } catch (e) {
      console.warn('Prisma getOrders failed, returning local session orders:', e);
      return localOrders;
    }
  },

  // ADD NEW PRODUCT (FOR ADMIN PANEL)
  async addProduct(productData: Omit<Product, 'id' | 'reviews' | 'createdAt' | 'updatedAt' | 'rating'>): Promise<Product> {
    try {
      if (!prisma) {
        const mockProduct: Product = {
          id: `prod-${Date.now()}`,
          ...productData,
          rating: 0.0,
          reviews: [],
          createdAt: new Date(),
          updatedAt: new Date()
        };
        fallbackProducts.push(mockProduct);
        return mockProduct;
      }
      const newProduct = await prisma.product.create({
        data: {
          name: productData.name,
          slug: productData.slug,
          description: productData.description,
          price: productData.price,
          originalPrice: productData.originalPrice,
          images: productData.images,
          brand: productData.brand,
          type: productData.type,
          specs: productData.specs,
          stock: productData.stock,
          rating: 0.0,
          audioUrl: productData.audioUrl,
          categoryId: productData.categoryId,
        }
      });
      return newProduct as unknown as Product;
    } catch (e) {
      console.warn('Prisma addProduct failed, saving to local memory:', e);
      const mockProduct: Product = {
        id: `prod-${Date.now()}`,
        ...productData,
        rating: 0.0,
        reviews: [],
        createdAt: new Date(),
        updatedAt: new Date()
      };
      fallbackProducts.push(mockProduct);
      return mockProduct;
    }
  }
};
