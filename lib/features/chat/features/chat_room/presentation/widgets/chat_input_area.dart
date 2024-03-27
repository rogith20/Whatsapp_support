import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_ui_clone/features/camera/presentation/camera_screen.dart';

import '../../../../../../core/models/models.dart';
import '../../../../../../core/utils/extensions/target_platform.dart';
import '../../../../../../core/utils/themes/custom_colors.dart';
import '../../../../chat.dart';

class ChatInputArea extends StatelessWidget {
  const ChatInputArea({Key? key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessageInputBloc(),
      child: Theme.of(context).platform.isMobile
          ? _ChatInputAreaMobile(onSendPressed: _onSendPressed)
          : _ChatInputAreaDesktop(onSendPressed: _onSendPressed),
    );
  }

  /// Handle send button press
  void _onSendPressed(BuildContext context) {
    final messageInputBloc = context.read<MessageInputBloc>();
    if (messageInputBloc.state.isEmpty) {
      // voice record
      return;
    }

    // Add new message to Bloc
    context.read<ChatBloc>().add(
          ChatMessageSend(
            to: context.read<WhatsAppUser>(),
            message: Message.fromText(
              messageInputBloc.state.text.trim(),
              author: context.read<User>(),
            ),
          ),
        );
    messageInputBloc.add(const MessageInputSendButtonPressed());
  }
}

class _ChatInputAreaMobile extends StatelessWidget {
  const _ChatInputAreaMobile({
    Key? key,
    required this.onSendPressed,
  }) : super(key: key);

  final void Function(BuildContext context) onSendPressed;

  @override
  Widget build(BuildContext context) {
    final customColors = CustomColors.of(context);
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 1,
          offset: Offset(0, 0.5),
        )
      ],
    );

    final lineCount = context.select(
      (MessageInputBloc bloc) =>
          bloc.state.lineCount.clamp(1, 6), // maximum 6 line
    );

    return SizedBox(
      height: lineCount == 1
          ? kBottomNavigationBarHeight
          : (20 * lineCount) + 6 + 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5)
            .copyWith(top: 4, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: DecoratedBox(
                decoration: boxDecoration,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(kBottomNavigationBarHeight / 2),
                  child: ColoredBox(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : customColors.secondary!,
                    child: IconTheme(
                      data: IconThemeData(
                        color: customColors.iconMuted,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Emoji button
                          IconButton(
                            onPressed: () {
                              _showEmojiPicker(
                                  context, TextEditingController());
                            },
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),

                          // TextField
                          const Expanded(child: ChatTextField()),

                          // File attach button
                          IconButton(
                            onPressed: () {
                              _showFileAttachment(context);
                            },
                            icon: const Icon(Icons.attach_file),
                          ),

                          // Payment and camera buttons.
                          BlocSelector<MessageInputBloc, MessageInputState,
                              bool>(
                            selector: (state) => state.isEmpty,
                            builder: (context, isEmpty) {
                              return AnimatedAlign(
                                alignment: Alignment.bottomLeft,
                                widthFactor: isEmpty ? 1 : 0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeInOut,
                                child: Row(
                                  children: [
                                    // Payment button
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.currency_rupee),
                                    ),

                                    // Camera button
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    const CameraScreen()));
                                      },
                                      icon: const Icon(Icons.camera_alt),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Send/voice button
            SizedBox(
              height: kBottomNavigationBarHeight - 10,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: DecoratedBox(
                  decoration: boxDecoration,
                  child: ClipOval(
                    child: GestureDetector(
                      onTap: () => onSendPressed(context),
                      child: ColoredBox(
                        color: customColors.primary!,
                        child: BlocSelector<MessageInputBloc, MessageInputState,
                            bool>(
                          selector: (state) => state.isEmpty,
                          builder: (context, isMessageTextEmpty) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: isMessageTextEmpty
                                  ? const Icon(
                                      Icons.mic,
                                      key: Key('mic_icon'),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      key: Key('send_icon'),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(
      BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return emojiSelect(context, controller);
      },
    );
  }

  void _showFileAttachment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return bottomSheet(context);
      },
    );
  }
}

class _ChatInputAreaDesktop extends StatelessWidget {
  const _ChatInputAreaDesktop({
    Key? key,
    required this.onSendPressed,
  }) : super(key: key);

  final void Function(BuildContext context) onSendPressed;

  @override
  Widget build(BuildContext context) {
    final lineCount = context.select(
      (MessageInputBloc bloc) =>
          bloc.state.lineCount.clamp(1, 6), // maximum 6 line
    );

    return SizedBox(
      height: lineCount == 1
          ? kBottomNavigationBarHeight + 5
          : (18 * lineCount) + 16 + 20,
      child: ColoredBox(
        color: CustomColors.of(context).secondary!,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IconTheme(
            data: IconThemeData(
              color: CustomColors.of(context).onSecondaryMuted,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Emoji button
                IconButton(
                  onPressed: () {
                    _showEmojiPicker(context, TextEditingController());
                  },
                  icon: const Icon(Icons.emoji_emotions_rounded),
                ),

                // File attach button
                IconButton(
                  onPressed: () {
                    _showFileAttachment(context);
                  },
                  icon: const Icon(Icons.attach_file),
                ),
                const SizedBox(width: 10),

                // Text input
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xFF2A3942),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ChatTextField(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // send/voice button
                IconButton(
                  onPressed: () => onSendPressed(context),
                  icon: BlocSelector<MessageInputBloc, MessageInputState, bool>(
                    selector: (state) => state.isEmpty,
                    builder: (context, isMessageTextEmpty) {
                      if (isMessageTextEmpty) return const Icon(Icons.mic);
                      return const Icon(Icons.send);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker(
      BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return emojiSelect(context, controller);
      },
    );
  }

  void _showFileAttachment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return bottomSheet(context);
      },
    );
  }
}

Widget emojiSelect(BuildContext context, TextEditingController controller) {
  return Container(
    height: 320,
    child: EmojiPicker(
      config: const Config(),
      onEmojiSelected: (category, emoji) {
        controller.text = controller.text + emoji.emoji;
      },
    ),
  );
}

Widget bottomSheet(BuildContext context) {
  return Container(
    height: 395,
    width: MediaQuery.of(context).size.width,
    child: Card(
      margin: const EdgeInsets.all(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cardicon(Icons.insert_drive_file, Colors.indigo, "Document"),
                const SizedBox(width: 40),
                cardicon(Icons.camera_alt, Colors.pink, "Camera"),
                const SizedBox(width: 40),
                cardicon(Icons.photo, Colors.deepPurple, "Gallery"),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cardicon(Icons.headphones, Colors.deepOrange, "Audio"),
                const SizedBox(width: 40),
                cardicon(
                    Icons.location_on, const Color(0xFF1FA755), "Location"),
                const SizedBox(width: 40),
                cardicon(
                    Icons.currency_rupee, const Color(0xFF03A598), "Payment"),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cardicon(Icons.person, Colors.blue, "Contact"),
                const SizedBox(width: 40),
                cardicon(Icons.bar_chart, Colors.teal, "Poll"),
                const SizedBox(width: 100),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget cardicon(IconData icon, Color color, String text) {
  return InkWell(
    onTap: () {},
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 30,
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
