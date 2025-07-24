part of 'onboarding_controller.dart';

class _OnboardingView extends StatelessWidget {
  final OnBoardingController controller;

  const _OnboardingView(this.controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Center(child: _selectRole(context)));
  }

  Widget _selectRole(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _roleCard(color: Colors.blue.shade600, icon: Icons.admin_panel_settings, title: 'Admin', onTap: () => Get.dialog(_adminRole())),
          const SizedBox(width: 20),
          _roleCard(color: Colors.green.shade600, icon: Icons.person, title: 'User', onTap: () => Get.dialog(_userRole())),
        ],
      ),
    );
  }

  Widget _roleCard({required Color color, required IconData icon, required String title, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminRole() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Admin Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Obx(
              () =>
                  controller._isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            onChanged: controller._handleAdminRole,
                          ),
                          const SizedBox(height: 12),
                          const Text('Masukkan Password untuk masuk sebagai Admin', style: TextStyle(fontSize: 16)),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userRole() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('User Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: controller._key,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller._name,
                    decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    validator: controller._validateName,
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller._address,
                    decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
                    validator: controller._validateAddress,
                    maxLength: 255,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () =>
                  controller._isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                        onPressed: controller._saveUserData,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
