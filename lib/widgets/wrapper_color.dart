import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/provider/theme_provider.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:provider/provider.dart';

class WrapperColors extends StatelessWidget {
  const WrapperColors({
    Key? key,
    required this.id,
    required this.isRoomColor,
    required this.roomId,
  }) : super(key: key);

  final String id;
  final bool isRoomColor;
  final String? roomId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < 8; i++)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(100, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              backgroundColor: themeColors[i],
            ),
            onPressed: () async {
              if (!isRoomColor) {
                final provider =
                    Provider.of<ThemeProvider>(context, listen: false);
                provider.changeColor(i);
                BlocProvider.of<ProfilesCubit>(context).updateColor(i, id);
              }
              Navigator.pop;
            },
            child: Text(themeNameColors[i]),
          ),
      ],
    );
  }
}
