import 'package:awaken_quest/app/pages/jornal/Journal.dart';
import 'package:awaken_quest/app/pages/profile/Status.dart';
import 'package:awaken_quest/app/pages/quests/Quest.dart';
import 'package:awaken_quest/utils/App_Theme.dart';
import '../../../utils/manager/Import_Manager.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
        ()=> Scaffold(
        body: SafeArea(child: [
          Quest(),
          Status(),
          Journal()
        ][controller.currentTab.value]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          selectedItemColor: AppTheme.glowingBlue,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          currentIndex: controller.currentTab.value,
          onTap: (index){
            controller.currentTab.value = index;
          },
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.calendar2_event, size: 18,),
              activeIcon: _glowingIcon(BootstrapIcons.calendar2_event),
              label: '퀘스트',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.file_diff , size: 18,),
              activeIcon:  _glowingIcon(BootstrapIcons.file_diff),
              label: '상태창',
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.journal_bookmark, size: 18,),
              activeIcon: _glowingIcon(BootstrapIcons.journal_bookmark),
              label: '일지',
            ),
          ],
        ),
      ),
    );
  }


  Widget _glowingIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowingBlue.withValues(alpha: 0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.glowingBlue, size: 18,),
    );
  }
}
