import 'package:flutter/material.dart';

void main() {
  runApp(const FoodApp());
}


class Food {
  final String name;
  final String description;
  final double price;
  final String emoji;

  const Food(this.name, this.description, this.price, this.emoji);
}

const foods = [
  Food('ข้าวผัดกุ้ง', 'ข้าวผัดหอม ๆ พร้อมกุ้งสด', 60, '🍤'),
  Food('ผัดกะเพราหมู', 'กะเพราหมูรสจัดจ้าน', 50, '🍳'),
  Food('ต้มยำกุ้ง', 'ต้มยำกุ้งน้ำข้น', 100, '🍲'),
  Food('ผัดไทย', 'ผัดไทยเส้นเหนียวนุ่ม', 55, '🍜'),
  Food('ส้มตำ', 'ส้มตำไทยรสแซ่บ', 45, '🥗'),
  Food('ข้าวมันไก่', 'ข้าวมันหอม ไก่นุ่ม', 50, '🍗'),
];

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Menu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int page = 0;
  String search = '';
  final Map<Food, int> cart = {};

  double get total => cart.entries.fold(
        0,
        (sum, item) => sum + item.key.price * item.value,
      );

  void addFood(Food food) {
    setState(() {
      cart[food] = (cart[food] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เพิ่ม${food.name}ลงตะกร้าแล้ว'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void changeQuantity(Food food, int amount) {
    setState(() {
      final quantity = (cart[food] ?? 0) + amount;
      if (quantity <= 0) {
        cart.remove(food);
      } else {
        cart[food] = quantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = foods
        .where((food) => food.name.contains(search))
        .toList();

    final pages = [
      // 1. หน้าหลัก - เปลี่ยนตามโค้ดที่ให้มา
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset(
              'assets/images/chum-removebg-preview.png',
              width: 280,
              height: 320,
              fit: BoxFit.contain,
            ), 
            const Text(
              'ยินดีต้อนรับ',
              style: TextStyle(fontSize: 40),
            ),
            const Text('ซัม บักเก็ต'),
            ElevatedButton(
              onPressed: () => setState(() => page = 1),
              child: const Text('ดูเมนูอาหาร'),
            ),
          ],
        ),
      ),

      // 2. เมนูอาหาร
      ListView(
        padding: const EdgeInsets.all(16),
        children: foods.map((food) => foodCard(food)).toList(),
      ),

      // 3. ค้นหาอาหาร
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => search = value);
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่ออาหาร...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  filtered.map((food) => foodCard(food)).toList(),
            ),
          ),
        ],
      ),

      // 4. เมนูแนะนำ
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'เมนูแนะนำประจำวัน ⭐',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...foods.map((food) => foodCard(food)),
        ],
      ),

      // 5. ตะกร้าอาหาร
      cart.isEmpty
          ? const Center(
              child: Text(
                '🛒 ยังไม่มีอาหารในตะกร้า',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.entries.map((entry) {
                  final food = entry.key;
                  final quantity = entry.value;

                  return Card(
                    child: ListTile(
                      title: Text('${food.emoji} ${food.name}'),
                      subtitle: Text(
                        '${food.price.toStringAsFixed(0)} บาท x $quantity',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                changeQuantity(food, -1),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                            ),
                          ),
                          Text('$quantity'),
                          IconButton(
                            onPressed: () =>
                                changeQuantity(food, 1),
                            icon: const Icon(
                              Icons.add_circle_outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Text(
                  'ยอดรวม ${total.toStringAsFixed(0)} บาท',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('ยืนยันการชำระเงิน'),
                        content: Text(
                          'ยอดรวม ${total.toStringAsFixed(0)} บาท',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text('ยกเลิก'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              setState(() => cart.clear());
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('สั่งอาหารสำเร็จ'),
                                ),
                              );
                            },
                            child: const Text('ยืนยัน'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('จ่ายเงิน'),
                ),
              ],
            ),
    ];
    return Scaffold(
      body: Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/chum back.jpg'),
      fit: BoxFit.cover,
    ),
  ),
  child: IndexedStack(
    index: page,
    children: pages,
  ),
),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (index) {
          setState(() => page = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'เมนู',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'ค้นหา',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            label: 'แนะนำ',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'ตะกร้า',
          ),
        ],
      ),
    );
  }

  Widget foodCard(Food food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Text(
          food.emoji,
          style: const TextStyle(fontSize: 38),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${food.description}\n${food.price.toStringAsFixed(0)} บาท',
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: () => addFood(food),
          icon: const Icon(
            Icons.add_shopping_cart,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}