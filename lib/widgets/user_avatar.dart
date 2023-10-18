import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/utils/constants.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    required this.userId,
    this.isSettings = false,
  }) : super(key: key);

  final String? userId;
  final bool isSettings;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, state) {
        if (state is ProfilesLoaded) {
          final user = state.profiles[userId];
          return ClipOval(
            child: user?.imageUrl == null || user!.imageUrl!.isEmpty
                ? CircleAvatar(
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    radius: !isSettings ? 20 : 100,
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Theme.of(context).primaryColor,
                      size: !isSettings ? 40 : 200,
                    ),
                  )
                : Image.network(
                    user.imageUrl!,
                    fit: BoxFit.contain,
                    width: !isSettings ? 50 : 200,
                  ),
          );
        } else {
          return const CircleAvatar(child: preloader);
        }
      },
    );
  }
}
