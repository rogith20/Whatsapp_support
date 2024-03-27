import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/chat.dart';
import '../../home_screen.dart';

/// FloatingActionButton
class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSearchOpen = context.select(
      (ChatSearchBloc bloc) => bloc.state is ChatSearchOpenState,
    );

    if (isSearchOpen) return const SizedBox.shrink();

    return FloatingActionButton(
      backgroundColor: Color(0xFF00a884),
      child: BlocSelector<TabViewBloc, TabViewState, TabView>(
        selector: (state) => state.tabView,
        builder: (context, tabView) {
          switch (tabView) {
            case TabView.chats:
              return const Icon(
                Icons.message,
                color: Colors.black,
              );
            case TabView.status:
              return const Icon(Icons.camera_alt, color: Colors.black);
            case TabView.calls:
              return const Icon(Icons.add_call, color: Colors.black);
          }
        },
      ),
      onPressed: () {
        switch (context.read<TabViewBloc>().state.tabView) {
          case TabView.chats:
            context.read<NewChatBloc>().add(const NewChatSelectionScreenOpen());
            break;
          case TabView.status:
          case TabView.calls:
        }
      },
    );
  }
}
