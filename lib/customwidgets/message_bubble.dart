import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message_model.dart';
import '../theme.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showRegenerate;
  final bool showSpeak;
  final VoidCallback? onCopy;
  final VoidCallback? onSpeak;
  final VoidCallback? onRegenerate;
  final VoidCallback? onPreviousVersion;
  final VoidCallback? onNextVersion;
  final RxBool? isRegenerating;

  const MessageBubble({
    super.key,
    required this.message,
    this.showRegenerate = true,
    this.isRegenerating,
    this.showSpeak=true,
    this.onCopy,
    this.onSpeak,
    this.onRegenerate,
    this.onPreviousVersion,
    this.onNextVersion,

  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.type == MessageType.user;

    return Obx(() {
      final isLoading = !isUser && message.isLoading.value;

      if (isLoading) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 23,top: 5,bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,//40
                width: 86,//60
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  repeat: true,
                ),
              ),
            ],
          ),
        );
      }

      // Full bubble (unchanged from your original code)
      return Padding(
        padding: const EdgeInsets.only(left: 23, right: 23),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: isUser ? appContainerColor(context) : purpleBackground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? appContainerColor(context)
                      : appAccentContainerColor(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: isUser
                          ? Text(
                        message.message,
                        style: TextStyle(
                          color: appTextColor(context),
                          fontFamily: 'SfProDisplay',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                          : MarkdownBody(
                        data: message.message,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: appTextColor(context),
                            fontFamily: 'SfProDisplay',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          strong: TextStyle(
                            color: appTextColor(context),
                            fontFamily: 'SfProDisplay',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          em: TextStyle(
                            color: appTextColor(context),
                            fontFamily: 'SfProDisplay',
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                          code: TextStyle(
                            backgroundColor: purpleBackground.withOpacity(0.15),
                            color: appTextColor(context),
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: purpleBackground.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: purpleBackground.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          listBullet: TextStyle(
                            color: appTextColor(context),
                            fontFamily: 'SfProDisplay',
                            fontSize: 14,
                          ),
                          a: TextStyle(
                            color: purpleBackground,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTapLink: (text, href, title) async {
                          if (href == null || href.isEmpty) return;
                          final uri = Uri.parse(href);
                          try {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              Get.snackbar('Error', 'Could not open the link.');
                            }
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to launch: $e');
                          }
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isUser
                          ? appDividerColor(context)
                          : purpleBackground.withOpacity(0.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => onCopy?.call(),
                            child: SvgPicture.asset(
                              message.copy.value
                                  ? 'assets/icons/copied.svg'
                                  : 'assets/icons/copy.svg',
                              height: 18,
                              colorFilter: message.copy.value
                                  ? null
                                  : ColorFilter.mode(
                                appIconColor(context),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!isUser && showSpeak)
                            Obx(() => GestureDetector(
                              onTap: () => onSpeak?.call(),
                              child: SvgPicture.asset(
                                message.speak.value
                                    ? 'assets/icons/volumeon.svg'
                                    : 'assets/icons/volumeoff.svg',
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  appIconColor(context),
                                  BlendMode.srcIn,
                                ),
                              ),
                            )),
                          const SizedBox(width: 12),
                          if (!isUser && showRegenerate)
                            Obx(() {
                              final regenerating = isRegenerating?.value ?? false;
                              return GestureDetector(
                                onTap: regenerating ? null : () => onRegenerate?.call(),
                                child: SvgPicture.asset(
                                  'assets/icons/regenerate.svg',
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    appIconColor(context),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              );
                            }),
                          if (message.hasMultipleVersions) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: message.canGoPrevious
                                  ? () => onPreviousVersion?.call()
                                  : null,
                              child: Icon(
                                Icons.chevron_left,
                                size: 18,
                                color: message.canGoPrevious ? appIconColor(context) : Colors.grey,
                              ),
                            ),
                            Text(
                              '${message.currentVersionIndex.value + 1}/${message.versions.length}',
                              style: TextStyle(fontSize: 12, color: appTextColor(context)),
                            ),
                            GestureDetector(
                              onTap: message.canGoNext ? () => onNextVersion?.call() : null,
                              child: Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: message.canGoNext ? appIconColor(context) : Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

