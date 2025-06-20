import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/budgetController.dart' as budget_ctrl;
import 'package:untitled/controller/expense_controller.dart';
import 'components/budget_header.dart';
import 'components/budget_arc.dart';
import 'components/budget_card.dart';
import 'components/expense_history_section.dart';
import 'components/add_category_button.dart';
import 'widgets/budget_alert_dialog.dart';

class SpendingBudgetsView extends StatefulWidget {
  const SpendingBudgetsView({super.key});

  @override
  State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

class _SpendingBudgetsViewState extends State<SpendingBudgetsView>
    with TickerProviderStateMixin {
  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  bool _dialogShown = false;
  BuildContext? _dialogContext;

  // Animation controllers
  AnimationController? _mainController;
  AnimationController? _arcController;
  AnimationController? _cardController;

  // Animations
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController!,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController!,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController!,
      curve: Curves.elasticOut,
    ));

    _mainController?.forward();
    _arcController?.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController?.forward();
    });
  }

  @override
  void dispose() {
    _mainController?.dispose();
    _arcController?.dispose();
    _cardController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<budget_ctrl.BudgetController>(builder: (ctrl) {
      _handleBudgetAlert(ctrl);

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _fadeAnimation == null
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: _fadeAnimation!,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation!.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation!.value),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            BudgetHeader(),
                            BudgetArcSection(
                              controller: ctrl,
                              arcController: _arcController,
                            ),
                            const SizedBox(height: 30),
                            BudgetCard(
                              controller: ctrl,
                              scaleAnimation: _scaleAnimation,
                            ),
                            const SizedBox(height: 30),
                            ExpenseHistorySection(
                              expenseController: expenseCtrl,
                            ),
                            const SizedBox(height: 20),
                            const AddCategoryButton(),
                            const SizedBox(height: 110),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }

  void _handleBudgetAlert(budget_ctrl.BudgetController ctrl) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = ctrl.totalBudgetAmount.value;
      final used = ctrl.usedBudgetAmount.value;

      if (total > 0) {
        final percentUsed = (used / total) * 100;

        if (percentUsed >= 75 && !_dialogShown) {
          _dialogShown = true;
          _showBudgetAlert(context, percentUsed);
        } else if (_dialogShown &&
            percentUsed < 75 &&
            _dialogContext != null) {
          Navigator.of(_dialogContext!).pop();
          _dialogShown = false;
          _dialogContext = null;
        }
      }
    });
  }

  void _showBudgetAlert(BuildContext context, double percentUsed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return BudgetAlertDialog(
          percentUsed: percentUsed,
          onDismiss: () {
            Navigator.of(_dialogContext!).pop();
            _dialogShown = false;
            _dialogContext = null;
          },
        );
      },
    );
  }
}