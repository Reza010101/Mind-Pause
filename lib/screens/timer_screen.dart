import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  final String userDecision;
  
  const TimerScreen({
    super.key,
    required this.userDecision,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  int _seconds = 60;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  // پیام‌های آگاه‌ساز
  final List<String> _messages = [
    "ذهنت فعاله، ولی تو تماشاچی‌ای",
    "این فقط فعالیت ذهنه، نه نیاز واقعی", 
    "این لحظه هم می‌گذره",
    "تو کنترل داری، نه ذهنت"
  ];
  
  String _currentMessage = "";
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTimer();
    _showInitialMessage();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    
    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  void _showInitialMessage() {
    // نمایش تصمیم کاربر در ابتدا
    _currentMessage = 'تو گفتی: "${widget.userDecision}"';
    
    // بعد از 3 ثانیه شروع پیام‌های آگاه‌ساز
    Timer(const Duration(seconds: 3), () {
      _showNextMessage();
    });
  }

  void _showNextMessage() {
    if (_seconds > 0) {
      setState(() {
        _currentMessage = _messages[_messageIndex % _messages.length];
        _messageIndex++;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          
          // هر 15 ثانیه پیام جدید
          if (_seconds > 0 && (_seconds == 45 || _seconds == 30 || _seconds == 15)) {
            _showNextMessage();
          }
          
          // پایان تایمر
          if (_seconds == 0) {
            _onTimerComplete();
          }
        }
      });
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.stop();
    
    // ثبت پیروزی
    _saveSuccess();
    
    // نمایش پیام تبریک
    _showSuccessDialog();
  }

  Future<void> _saveSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // افزایش تعداد مقاومت‌های موفق امروز
    final currentCount = prefs.getInt('success_$today') ?? 0;
    await prefs.setInt('success_$today', currentCount + 1);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration,
                size: 80,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 20),
              const Text(
                'تبریک! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'تو یک دقیقه مقاومت کردی\nاین لحظه ثبت شد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // بستن دیالوگ
                  Navigator.of(context).pop(); // برگشت به صفحه اصلی
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'عالی!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onExit() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.stop();
    
    // ثبت خروج زودهنگام
    _saveEarlyExit();
    
    Navigator.of(context).pop();
  }

  Future<void> _saveEarlyExit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // افزایش تعداد خروج‌های زودهنگام امروز
    final currentCount = prefs.getInt('exit_$today') ?? 0;
    await prefs.setInt('exit_$today', currentCount + 1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.indigo.shade900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // دکمه خروج
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _onExit,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // تایمر اصلی با انیمیشن
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // دایره پیش‌رفت
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _progressController.value,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.teal.shade300,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // دایره نابض اصلی
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 160 + (_pulseController.value * 20),
                          height: 160 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1 + _pulseController.value * 0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$_seconds',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // پیام آگاه‌ساز
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(_currentMessage),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _currentMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // راهنمایی
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'فقط تماشا کن. مذاکره نکن.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}