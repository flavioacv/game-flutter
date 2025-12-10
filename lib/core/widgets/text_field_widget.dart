import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/themes/extensions/responsive_extension.dart';
import 'package:pixel_adventure/core/types/types.dart';
import 'package:pixel_adventure/core/widgets/text_widget.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final Widget? label;
  final String? hintText;
  final TextAlign textAlign;
  final OnChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool osbscureText;
  final Color? colorHintText;
  final double? fontSizeHintText;
  final Widget? prefixIcon;
  final bool? autofocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const TextFieldWidget({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.onChanged,
    this.textAlign = TextAlign.center,
    this.validator,
    this.osbscureText = false,
    this.colorHintText,
    this.fontSizeHintText,
    this.prefixIcon,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool isUserInteraction = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textFieldListener);
  }

  void _textFieldListener() {
    if (isUserInteraction) return;

    setState(() {
      isUserInteraction = true;
    });
  }

  @override
  void didUpdateWidget(covariant TextFieldWidget oldWidget) {
    if (!isUserInteraction) {
      setState(() {
        isUserInteraction = true;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textFieldListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.label != null,
          child: Padding(
            padding: EdgeInsets.only(bottom: 6.0.h),
            child: widget.label,
          ),
        ),
        SizedBox(
          width: context.screenSize.width,
          child: TextFormField(
            focusNode: widget.focusNode,
            onFieldSubmitted: widget.onFieldSubmitted,
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus!,
            controller: widget.controller,
            textAlign: widget.textAlign,
            onChanged: widget.onChanged,
            obscureText: widget.osbscureText,
            maxLines: 1,
            style: TextWidget.fontMontserrat.copyWith(
              color: context.appColors.black,
              fontWeight: FontWeight.w600,
              fontSize: 30.p,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: widget.colorHintText,
                fontSize: widget.fontSizeHintText,
              ),
              isCollapsed: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 19.h,
              ),
              isDense: true,
              filled: true,
              fillColor: context.appColors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.w),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1.w,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.w),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1.w,
                ),
              ),
              prefixIcon: widget.prefixIcon,
            ),
          ),
        ),
        ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return Visibility(
                visible:
                    widget.validator?.call(widget.controller.text) != null &&
                        isUserInteraction,
                child: Padding(
                  padding: EdgeInsets.only(top: 6.0.h),
                  child: TextWidget(
                    widget.validator?.call(widget.controller.text) ?? '',
                    colorText: Colors.black,
                    fontSize: 30.p,
                  ),
                ),
              );
            })
      ],
    );
  }
}
