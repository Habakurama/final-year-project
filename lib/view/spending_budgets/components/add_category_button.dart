import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:untitled/view/add_subscription/add_subscription_view.dart';

class AddCategoryButton extends StatelessWidget {
  const AddCategoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: DottedBorder(
          dashPattern: const [8, 4],
          strokeWidth: 2,
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          color: theme.primaryColor.withOpacity(0.3),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Get.to(() => const AddSubScriptionView()),
              child: Container(
                height: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.05),
                      theme.primaryColor.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.primaryColor,
                        size: 24,
                      )
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Add New Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
