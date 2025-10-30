import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecisionScreen extends StatefulWidget {
  final VoidCallback onDecisionSaved;
  
  const DecisionScreen({
    super.key,
    required this.onDecisionSaved,
  });

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  final TextEditingController _decisionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _decisionController.dispose();
    super.dispose();
  }

  Future<void> _saveDecision() async {
    final decision = _decisionController.text.trim();
    
    if (decision.isEmpty) {
      _showSnackBar('لطفاً تصمیم خود را بنویسید');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_decision', decision);
      await prefs.setString('decision_date', DateTime.now().toIso8601String());
      
      _showSnackBar('تصمیم شما ثبت شد!');
      
      // کمی تأخیر برای نمایش پیام
      await Future.delayed(const Duration(seconds: 1));
      
      widget.onDecisionSaved();
    } catch (e) {
      _showSnackBar('خطا در ذخیره‌سازی');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // آیکون و عنوان
              const Icon(
                Icons.psychology,
                size: 80,
                color: Colors.teal,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'مکث',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'لحظه‌ای برای تصمیم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // راهنمایی
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'ابتدا تصمیم خود را بنویسید. این تصمیم در لحظات سخت به شما یادآوری خواهد شد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // فیلد ورودی
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _decisionController,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'مثلاً: من تصمیم گرفتم سیگار نکشم',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // دکمه ثبت
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDecision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ثبت تصمیم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // متن توضیحی
              Text(
                'این تصمیم فقط برای شماست و هیچ‌جا ارسال نمی‌شود',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}