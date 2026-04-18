import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/question_template.dart';
import '../theme/doutang_theme.dart';

/// Carte affichant une seule question du questionnaire de visite.
///
/// L'interaction varie selon [QuestionTemplate.type] :
/// - [QuestionType.score]  : 5 étoiles cliquables (1–5), tap sur l'étoile
///   courante pour déselectionner.
/// - [QuestionType.yesNo]  : 3 boutons **Oui / Non / ?** (non répondu).
/// - [QuestionType.text]   : champ texte libre (TextField).
/// - [QuestionType.photo]  : dégradé vers TextField en attendant #007.
///
/// [value] : `int?` pour score, `bool?` pour yesNo, `String?` pour text.
/// `null` = question non répondue (toujours autorisé).
class QuestionCard extends StatefulWidget {
  final QuestionTemplate question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const QuestionCard({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final isText = widget.question.type == QuestionType.text ||
        widget.question.type == QuestionType.photo;
    _textController = TextEditingController(
      text: isText ? (widget.value as String?) ?? '' : '',
    );
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isText = widget.question.type == QuestionType.text ||
        widget.question.type == QuestionType.photo;
    if (isText && widget.value != oldWidget.value) {
      final newText = (widget.value as String?) ?? '';
      if (_textController.text != newText) {
        _textController.text = newText;
        _textController.selection = TextSelection.collapsed(
          offset: newText.length,
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── Couleur de niveau ──────────────────────────────────────────────────────

  Color get _levelColor => switch (widget.question.level) {
        QuestionLevel.critical => DoutangTheme.danger,
        QuestionLevel.important => DoutangTheme.accent,
        QuestionLevel.nice => DoutangTheme.border,
      };

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _levelColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DRadius.md),
                  bottomLeft: Radius.circular(DRadius.md),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: DoutangTheme.textPrimary,
                      ),
                    ),
                    if (q.hint != null) ...[
                      const SizedBox(height: DSpacing.xs),
                      Text(
                        q.hint!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DoutangTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: DSpacing.sm + 2),
                    _buildInput(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return switch (widget.question.type) {
      QuestionType.score => _buildStarRating(),
      QuestionType.yesNo => _buildYesNoButtons(),
      QuestionType.text || QuestionType.photo => _buildTextField(),
      QuestionType.multiChoice => _buildMultiChoiceChips(),
    };
  }

  // ── Score : 5 étoiles ──────────────────────────────────────────────────────

  Widget _buildStarRating() {
    final current = widget.value as int?;
    return Row(
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final filled = current != null && current >= starValue;
        return GestureDetector(
          onTap: () =>
              widget.onChanged(current == starValue ? null : starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: DSpacing.xs),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 34,
              color: filled ? DoutangTheme.accent : DoutangTheme.textHint,
            ),
          ),
        );
      }),
    );
  }

  // ── Oui / Non / ? ─────────────────────────────────────────────────────────

  Widget _buildYesNoButtons() {
    final current = widget.value as bool?;
    // Use a sentinel to distinguish "not answered" (null) from false.
    // The "?" button sets value to null.
    return Row(
      children: [
        _ynButton(label: 'Oui', target: true, current: current),
        const SizedBox(width: DSpacing.sm),
        _ynButton(label: 'Non', target: false, current: current),
        const SizedBox(width: DSpacing.sm),
        _ynButton(label: '?', target: null, current: current, isSkip: true),
      ],
    );
  }

  Widget _ynButton({
    required String label,
    required bool? target,
    required bool? current,
    bool isSkip = false,
  }) {
    // "?" is selected when current == null and the question has been explicitly
    // skipped — we don't distinguish from "not yet answered" here for simplicity.
    final isSelected = isSkip ? false : (current == target && current != null);

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isSelected) {
      if (target == true) {
        // Oui sélectionné : vert foncé sur fond vert clair
        borderColor = DoutangTheme.primary;
        bgColor = DoutangTheme.primarySurface;
        textColor = DoutangTheme.primary;
      } else {
        // Non sélectionné : rouge foncé sur fond rouge clair
        borderColor = DoutangTheme.danger;
        bgColor = const Color(0xFFFFEBEB);
        textColor = DoutangTheme.danger;
      }
    } else if (isSkip) {
      // ? : gris foncé sur fond gris clair, toujours
      borderColor = const Color(0xFFCED4DA);
      bgColor = const Color(0xFFE9ECEF);
      textColor = DoutangTheme.textSecondary;
    } else {
      // Oui / Non non sélectionnés
      borderColor = DoutangTheme.textHint;
      bgColor = DoutangTheme.surface;
      textColor = DoutangTheme.textSecondary;
    }

    return GestureDetector(
      onTap: () => widget.onChanged(isSkip ? null : target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: DSpacing.md,
          vertical: DSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: DRadius.button,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // ── MultiChoice : chips ────────────────────────────────────────────────────

  Widget _buildMultiChoiceChips() {
    final options = widget.question.options;
    final current = (widget.value as List<String>?) ?? const <String>[];
    return Wrap(
      spacing: DSpacing.sm,
      runSpacing: DSpacing.xs,
      children: options.map((option) {
        final selected = current.contains(option);
        return FilterChip(
          label: Text(option),
          selected: selected,
          selectedColor: DoutangTheme.primarySurface,
          checkmarkColor: DoutangTheme.primary,
          side: BorderSide(
            color: selected ? DoutangTheme.primary : DoutangTheme.border,
          ),
          onSelected: (on) {
            final next = List<String>.from(current);
            if (on) {
              next.add(option);
            } else {
              next.remove(option);
            }
            widget.onChanged(next.isEmpty ? null : next);
          },
        );
      }).toList(),
    );
  }

  // ── TextField ──────────────────────────────────────────────────────────────

  Widget _buildTextField() {
    final isMultiline = const {
      'q_coup_de_coeur',
      'q_point_redhibitoire',
      'q_departure_reason',
      'q_transport_type',
      'q_mobility_services',
    }.contains(widget.question.id);

    return TextField(
      controller: _textController,
      onChanged: widget.onChanged,
      maxLines: isMultiline ? 3 : 1,
      textInputAction:
          isMultiline ? TextInputAction.newline : TextInputAction.done,
      style: const TextStyle(
        fontSize: 15,
        color: DoutangTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.question.hint ?? 'Votre réponse…',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: DoutangTheme.textHint,
        ),
      ),
    );
  }
}
