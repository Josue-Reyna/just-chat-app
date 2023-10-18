// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/models/profile.dart';
import 'package:just_chat_app/pages/auth_page.dart';
import 'package:just_chat_app/provider/theme_provider.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:just_chat_app/widgets/change_language_button.dart';
import 'package:just_chat_app/widgets/change_theme_button.dart';
import 'package:just_chat_app/widgets/user_avatar.dart';
import 'package:just_chat_app/widgets/wrapper_color.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.userId,
    this.color,
    this.roomId,
    required this.isGroup,
  }) : super(key: key);

  final String userId;
  final int? color;
  final String? roomId;
  final bool isGroup;

  static Route<void> route(String userId, int? color, String? roomId,
      {bool isGroup = false}) {
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfilesCubit>(
            create: (context) => ProfilesCubit()..getProfile(userId),
          ),
        ],
        child: SettingsPage(
          userId: userId,
          color: color,
          roomId: roomId,
          isGroup: isGroup,
        ),
      ),
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  Profile? user;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  void _changeUsername(String userName) async {
    setState(() {
      _isLoading = true;
    });
    BlocProvider.of<ProfilesCubit>(context).updateUsername(userName);
    setState(() {
      _isLoading = false;
    });
  }

  void _deletePhoto() async {
    setState(() {
      _isLoading = true;
    });
    BlocProvider.of<ProfilesCubit>(context).deletePhoto(widget.userId);
    setState(() {
      _isLoading = false;
    });
  }

  void _updateBio(String bio) async {
    BlocProvider.of<ProfilesCubit>(context).updateBio(bio);
  }

  void _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 300,
      maxWidth: 500,
    );
    if (imageFile == null) {
      return;
    }
    final bytes = await imageFile.readAsBytes();

    final filePath = widget.userId.toString();
    bool update = true;

    setState(() {
      _isLoading = true;
    });
    if (user!.imageUrl != null) {
      update = false;
    }

    BlocProvider.of<ProfilesCubit>(context).uploadPhoto(
      bytes,
      filePath,
      imageFile.mimeType,
      user!.id,
      update,
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _updateStatus() async {
    BlocProvider.of<ProfilesCubit>(context).updateStatus(false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
          style: const TextStyle(
            fontFamily: 'Gilroy-ExtraBold',
          ),
        ),
        backgroundColor: widget.color != null
            ? themeColors[widget.color!]
            : Theme.of(context).appBarTheme.backgroundColor,
        actions: supabase.auth.currentUser!.id == widget.userId
            ? [
                const ChangeThemeButton(),
                IconButton(
                  onPressed: () async {
                    _updateStatus();
                    await supabase.auth.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      AuthPage.route(themeProvider.isLightMode),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: S.of(context).logOut,
                ),
              ]
            : [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const ChangeLanguage(),
      body: BlocBuilder<ProfilesCubit, ProfilesState>(
        builder: (context, state) {
          if (state is ProfilesLoaded) {
            user = state.profiles[widget.userId];
            _usernameController = TextEditingController(text: user!.username);
            _bioController = TextEditingController(text: user!.bio);
            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: size.width < 800
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flex(
                        direction:
                            size.width < 800 ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: size.width < 800
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              UserAvatar(
                                userId: user!.id,
                                isSettings: true,
                              ),
                              if (user!.id == supabase.auth.currentUser!.id)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _upload,
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size.fromRadius(20),
                                      shape: const CircleBorder(),
                                    ),
                                    child: Icon(
                                      user!.imageUrl == null
                                          ? Icons.add_a_photo
                                          : Icons.edit,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                user == null ? '..' : user!.username,
                                style: const TextStyle(fontSize: 30),
                              ),
                              height2,
                              if (user!.id == supabase.auth.currentUser!.id)
                                ElevatedButton(
                                  onPressed: () {
                                    showSomeDialog(
                                      context,
                                      S.of(context).changeUsername,
                                      [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: TextFormField(
                                            controller: _usernameController,
                                            decoration: InputDecoration(
                                              label:
                                                  Text(S.of(context).username),
                                              hintText: user!.username,
                                              labelStyle: TextStyle(
                                                color:
                                                    themeColors[widget.color!],
                                              ),
                                              floatingLabelStyle: TextStyle(
                                                color:
                                                    themeColors[widget.color!],
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: themeColors[
                                                      widget.color!],
                                                  width: 5,
                                                ),
                                              ),
                                              //focusColor: color,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: themeColors[
                                                      widget.color!],
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (val) {
                                              if (val == null || val.isEmpty) {
                                                return S
                                                    .of(context)
                                                    .requiredMessage;
                                              }
                                              final isValid = RegExp(
                                                      r'^[A-Za-z0-9_]{3,24}$')
                                                  .hasMatch(val);
                                              if (!isValid) {
                                                return S
                                                    .of(context)
                                                    .usernameRequired;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _isLoading
                                                  ? null
                                                  : _changeUsername(
                                                      _usernameController.text);
                                              Navigator.pop(context);
                                            },
                                            child: Text(S.of(context).update),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  child: Text(
                                    S.of(context).changeUsername,
                                  ),
                                ),
                              height2,
                              if (user!.id == supabase.auth.currentUser!.id)
                                if (user!.imageUrl != null)
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _deletePhoto,
                                    child: Text(
                                      S.of(context).deletePhoto,
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                      if (!widget.isGroup)
                        if (user!.bio != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 50,
                              right: 50,
                              bottom: 10,
                            ),
                            child: Text(
                              user!.bio!,
                              style: const TextStyle(
                                fontSize: 25,
                                fontFamily: 'Gilroy-Light',
                              ),
                            ),
                          ),
                      if (!widget.isGroup)
                        if (user!.id == supabase.auth.currentUser!.id)
                          ElevatedButton(
                            onPressed: () {
                              showSomeDialog(
                                context,
                                'Bio',
                                [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: TextFormField(
                                      controller: _bioController,
                                      decoration: InputDecoration(
                                        //label: const Text('Bio'),
                                        hintText: user!.bio,
                                        labelStyle: TextStyle(
                                          color: themeColors[widget.color!],
                                        ),
                                        floatingLabelStyle: TextStyle(
                                          color: themeColors[widget.color!],
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: themeColors[widget.color!],
                                            width: 5,
                                          ),
                                        ),
                                        //focusColor: color,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: themeColors[widget.color!],
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return S.of(context).requiredMessage;
                                        }
                                        final isValid =
                                            RegExp(r'^[A-Za-z0-9]{10,25}$')
                                                .hasMatch(val);
                                        if (!isValid) {
                                          return S.of(context).bioValidate;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _isLoading
                                            ? null
                                            : _updateBio(_bioController.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text(S.of(context).update),
                                    ),
                                  ),
                                ],
                              );
                            },
                            child: Text(
                              user!.bio == null
                                  ? S.of(context).addBio
                                  : S.of(context).changeBio,
                            ),
                          ),
                      height3,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              user!.id == supabase.auth.currentUser!.id
                                  ? null
                                  : themeColors[widget.color!],
                        ),
                        onPressed: () => showSomeDialog(
                          context,
                          S.of(context).changeColor,
                          [
                            WrapperColors(
                              id: user!.id,
                              isRoomColor:
                                  user!.id == supabase.auth.currentUser!.id
                                      ? false
                                      : true,
                              roomId: widget.roomId,
                            ),
                          ],
                        ),
                        child: Text(S.of(context).theme),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}
