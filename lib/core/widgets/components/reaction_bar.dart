import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/format.dart';

/// 이야기 아래 반응 줄: "나도 이 노래로 버텼어" · 방명록 · 내 일기장에 담기
///
/// 하트 대신 공감 한 가지만 두어, 숫자보다 공감이라는 말이 먼저 보이게 한다.
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.resonanceCount,
    required this.resonated,
    required this.onResonance,
    required this.guestbookCount,
    required this.onGuestbook,
    required this.saved,
    required this.onSave,
    this.onImage = false,
  });

  final int resonanceCount;

  /// 내가 이미 공감했는지
  final bool resonated;
  final VoidCallback? onResonance;

  final int guestbookCount;
  final VoidCallback? onGuestbook;

  /// 내 일기장에 담았는지
  final bool saved;
  final VoidCallback? onSave;

  /// 앨범 이미지 위에 올릴 때 true (라운지 몰입형 카드)
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final iconColor = onImage ? Colors.white : context.colors.textPrimary;
    // 폭이 모자라면 공감 문구만 말줄임으로 줄이고, 방명록·담기 버튼은 항상 보이게 한다.
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: ResonanceButton(
                  count: resonanceCount,
                  active: resonated,
                  onPressed: onResonance,
                  onImage: onImage,
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: onGuestbook,
                style: TextButton.styleFrom(
                  foregroundColor: iconColor,
                  minimumSize: const Size(44, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle:
                      context.textStyles.labelLarge?.copyWith(fontSize: 13),
                ),
                icon: const Icon(Icons.sticky_note_2_outlined, size: 20),
                label: Text(formatReactionCount(guestbookCount)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSave,
          tooltip: saved ? '내 일기장에서 빼기' : '내 일기장에 담기',
          color: iconColor,
          icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
        ),
      ],
    );
  }
}

/// 공감 버튼: 하트 대신 "나도 이 노래로 버텼어"
class ResonanceButton extends StatelessWidget {
  const ResonanceButton({
    super.key,
    required this.count,
    required this.active,
    required this.onPressed,
    this.onImage = false,
  });

  final int count;
  final bool active;
  final VoidCallback? onPressed;
  final bool onImage;

  static const label = '나도 이 노래로 버텼어';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color background, Color foreground, Color border) =
        switch ((onImage, active)) {
      (true, _) => (Colors.white, const Color(0xFF111111), Colors.white),
      (false, true) => (c.accent, c.onAccent, c.accent),
      (false, false) => (Colors.transparent, c.accentText, c.accent),
    };
    return Semantics(
      toggled: active,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: border, width: 1.5),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const StadiumBorder(),
          textStyle: context.textStyles.labelLarge?.copyWith(fontSize: 13),
        ),
        icon: Icon(
            active ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
            size: 16),
        label: Text(
          '$label ${formatReactionCount(count)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
