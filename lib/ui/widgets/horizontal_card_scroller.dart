import 'package:app/constants/constants.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

class HorizontalCardScroller extends StatelessWidget {
  final Iterable<Widget> cards;
  final String? headingText;

  const HorizontalCardScroller({
    Key? key,
    required this.cards,
    this.headingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headingText = this.headingText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (headingText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.horizontalPadding,
            ),
            child: Heading5(text: headingText),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...cards.expand(
                (card) => <Widget>[
                  const SizedBox(width: AppDimensions.horizontalPadding),
                  card,
                ],
              ),
              const SizedBox(width: AppDimensions.horizontalPadding),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceholderCard extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;

  const PlaceholderCard({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 18,
          cornerSmoothing: .5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 144,
        width: 144,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Icon(icon, size: 32),
          style: ElevatedButton.styleFrom(
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 24,
                cornerSmoothing: .8,
              ),
            ),
            backgroundColor: AppColors.highlight,
          ),
        ),
      ),
    );
  }
}
