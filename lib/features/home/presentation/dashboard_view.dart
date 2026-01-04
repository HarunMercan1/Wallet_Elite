import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Cüzdan ekranını içeri alıyoruz ki gösterebilelim
import '../../wallet/presentation/add_transaction_sheet.dart';
import '../../wallet/presentation/wallet_view.dart';

// --- GEÇİCİ SAYFALAR (Placeholder) ---
// Henüz yapmadığımız sayfalar için boş ekranlar.
class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0F172A), body: Center(child: Text("Analiz Ekranı (Yakında)", style: TextStyle(color: Colors.white))));
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0F172A), body: Center(child: Text("Ayarlar (Yakında)", style: TextStyle(color: Colors.white))));
}
// ------------------------------------


class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Hangi sekmede olduğumuzu tutan değişken (0: Cüzdan, 1: Analiz, 2: Ayarlar)
  int _currentIndex = 0;

  // Gösterilecek Sayfaların Listesi
  final List<Widget> _pages = [
    const WalletView(),   // İndeks 0
    const AnalysisView(), // İndeks 1
    const SettingsView(), // İndeks 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gövde: Seçili olan indekse göre sayfayı değiştirir
      body: _pages[_currentIndex],

      // ORTADAKİ + BUTONU (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // BOTTOM SHEET AÇMA KODU:
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Tam ekran boyutu kullanabilmek için
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      // Butonu alt barın tam ortasına gömüyoruz
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ALT MENÜ (Bottom Navigation Bar)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Buton için ortayı oy
        notchMargin: 8.0, // Oyuk ile buton arasındaki boşluk
        color: const Color(0xFF1A1F38), // Koyu lacivert arka plan
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // İkonları yay
            children: [
              // SOL TARAFTAKİ İKONLAR
              _buildNavItem(icon: FontAwesomeIcons.wallet, label: 'Cüzdan', index: 0),
              _buildNavItem(icon: FontAwesomeIcons.chartPie, label: 'Analiz', index: 1),

              const SizedBox(width: 48), // Ortadaki + butonu için boşluk bırak

              // SAĞ TARAFTAKİ İKONLAR
              // Şimdilik 2 tane ayarlar koydum, ileride 'Kartlar' vs. yaparız
              _buildNavItem(icon: FontAwesomeIcons.solidCreditCard, label: 'Kartlar', index: 2),
              _buildNavItem(icon: FontAwesomeIcons.gear, label: 'Ayarlar', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  // Alt menüdeki her bir ikon için yardımcı fonksiyon
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    // Eğer bu ikonun indeksi seçili olan indekse eşitse rengi sarı yap
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index; // Tıklanan ikonun indeksini seçili yap
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.amber : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.amber : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}