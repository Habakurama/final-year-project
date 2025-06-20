import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class RoundedTextField extends StatefulWidget {
  final String title;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextAlign? titleAlign;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  const RoundedTextField({
    super.key,
    required this.title,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.titleAlign,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
  });

  @override
  State<RoundedTextField> createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Dynamic colors based on focus state
    // final borderColor = _isFocused 
    //     ? theme.primaryColor 
    //     : (isDark ? TColor.gray10 : TColor.gray10);
    
    final backgroundColor = isDark ? TColor.gray80 : TColor.white;
    final textColor = isDark ? TColor.white : TColor.gray60;
    final hintColor = isDark 
        ? TColor.white.withOpacity(0.6) 
        : TColor.gray60.withOpacity(0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with improved styling
        Text(
          widget.title,
          textAlign: widget.titleAlign,
          style: TextStyle(
            color: isDark ? TColor.white : TColor.gray,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Enhanced TextField Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.maxLines == 1 ? 56 : null,
          width: double.infinity,
          constraints: widget.maxLines != 1 
              ? const BoxConstraints(minHeight: 56)
              : null,
          decoration: BoxDecoration(
            border: Border.all(
              // color: borderColor,
              width: _isFocused ? 2 : 1,
            ),
            color: widget.enabled ? backgroundColor : backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            style: TextStyle(
              color: widget.enabled ? textColor : textColor.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              isCollapsed: false,
              contentPadding: EdgeInsets.symmetric(
                vertical: widget.maxLines == 1 ? 16 : 14,
                horizontal: 16,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: widget.hintText ?? "Type here...",
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12, left: 8),
                      child: widget.suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              counterText: "", // Hide character counter
            ),
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
          ),
        ),
      ],
    );
  }
}