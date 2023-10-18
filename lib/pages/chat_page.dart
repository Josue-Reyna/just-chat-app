// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/models/group.dart';
import 'package:just_chat_app/widgets/expandable_fab.dart';
import 'package:just_chat_app/widgets/user_avatar.dart';
import 'package:just_chat_app/cubits/chat/chat_cubit.dart';

import 'package:just_chat_app/models/message.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:timeago/timeago.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    required this.roomColor,
    required this.roomId,
    required this.group,
  }) : super(key: key);

  final int roomColor;
  final String? otherUserId;
  final String? otherUserName;
  final String roomId;
  final Group? group;

  Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => ChatCubit()
          ..setMessagesListener(
            roomId,
            roomColor,
          ),
        child: ChatPage(
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          roomColor: roomColor,
          roomId: roomId,
          group: group,
        ),
      ),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isLoading = false;

  late TextEditingController _groupNameController;
  late TextEditingController _groupBioController;
  late bool _edit;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(
      text: widget.group?.name,
    );
    _groupBioController = TextEditingController(
      text: widget.group?.groupBio,
    );
    _edit = false;
  }

  @override
  void dispose() {
    super.dispose();
    _groupNameController.dispose();
    _groupBioController.dispose();
  }

  _updateColor(int color) async {
    BlocProvider.of<ChatCubit>(context).updateChatColor(
      color,
      widget.otherUserId!,
      widget.roomId,
    );
    Navigator.pop(context);
  }

  FloatingActionButtonLocation floatingActionButtonLocation() =>
      FloatingActionButtonLocation.startFloat;

  Widget floatingActionButton(int color) {
    return ExpandableFab(
      color: themeColors[color],
      distance: 112.0,
      children: [
        ActionButton(
          color: themeColors[color],
          onPressed: () {
            _isLoading ? null : _upload(true, true);
          },
          icon: const Icon(
            Icons.gif,
          ),
        ),
        ActionButton(
          color: themeColors[color],
          onPressed: () => showSomeButtons(
            context,
            S.of(context).sendVideo,
            [
              Icons.video_library,
              Icons.videocam,
            ],
            themeColors[color],
            null,
            [
              () {
                _isLoading ? null : _upload(false, true);
                Navigator.pop;
              },
              () {
                _isLoading ? null : _upload(false, false);
                Navigator.pop;
              }
            ],
          ),
          icon: const Icon(
            Icons.video_library,
          ),
        ),
        ActionButton(
          color: themeColors[color],
          onPressed: () => showSomeButtons(
            context,
            S.of(context).sendImage,
            [Icons.image, Icons.camera_alt],
            themeColors[color],
            null,
            [
              () {
                _isLoading ? null : _upload(true, true);
                Navigator.pop(context);
              },
              () {
                _isLoading ? null : _upload(true, false);
                Navigator.pop(context);
              }
            ],
          ),
          icon: const Icon(
            Icons.image,
          ),
        ),
      ],
    );
  }

  void _upload(bool option, bool source) async {
    final picker = ImagePicker();
    final imageFile = option
        ? await picker.pickImage(
            source: !source ? ImageSource.gallery : ImageSource.camera,
            maxHeight: 600,
            maxWidth: 600,
          )
        : await picker.pickVideo(
            source: !source ? ImageSource.gallery : ImageSource.camera,
          );
    if (imageFile == null) {
      return;
    }
    final bytes = await imageFile.readAsBytes();
    final filePath =
        '${widget.roomId}-chat/${DateTime.now().toIso8601String()}';
    setState(() {
      _isLoading = true;
    });

    BlocProvider.of<ChatCubit>(context).sendPicture(
      bytes,
      filePath,
      imageFile.mimeType,
      !option,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _uploadGroupImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: //!isGallery ?
          ImageSource.gallery,
      // : ImageSource.camera,
      maxHeight: 300,
      maxWidth: 500,
    );

    if (imageFile == null) {
      return;
    }

    final bytes = await imageFile.readAsBytes();
    final filePath = widget.roomId;
    bool update = true;

    setState(() {
      _isLoading = true;
    });
    if (widget.group?.image != null) {
      update = false;
    }

    final group = widget.group!.toMap();

    BlocProvider.of<ChatCubit>(context).uploadGroupPhoto(
      bytes,
      filePath,
      imageFile.mimeType,
      filePath,
      update,
      group,
    );
    Navigator.pop(context);
    setState(() {
      _isLoading = false;
    });
  }

  void _changeGroupName(Map<String, dynamic> group, String groupName) async {
    setState(() {
      _isLoading = true;
    });
    BlocProvider.of<ChatCubit>(context).updateGroupName(
      group,
      groupName,
      widget.roomId,
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _changeGroupBio(Map<String, dynamic> group, String groupBio) async {
    setState(() {
      _isLoading = true;
    });
    BlocProvider.of<ChatCubit>(context).updateGroupBio(
      group,
      groupBio,
      widget.roomId,
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          context.showErrorSnackBar(message: state.message);
        }
      },
      builder: (context, state) {
        if (state is ChatInitial) {
          return const Scaffold(body: preloader);
        } else if (state is ChatLoaded) {
          final messages = state.messages;
          final color = state.color;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.group == null
                    ? widget.otherUserName!
                    : widget.group!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Gilroy-ExtraBold',
                ),
              ),
              backgroundColor: themeColors[color],
              actions: [
                IconButton(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: 8,
                    right: 16,
                  ),
                  onPressed: () {
                    if (widget.group == null) {
                      showSomeDialog(
                        context,
                        '',
                        [
                          BlocBuilder<ProfilesCubit, ProfilesState>(
                            builder: (context, state) {
                              if (state is ProfilesLoaded) {
                                final user = state.profiles[widget.otherUserId];
                                final group =
                                    widget.group == null ? false : true;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        !group
                                            ? widget.otherUserName!
                                            : widget.group!.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: UserAvatar(
                                          userId:
                                              !group ? user!.id : widget.roomId,
                                          isSettings: true,
                                        ),
                                      ),
                                      if (user!.bio != null && !group)
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            user.bio!,
                                            style: const TextStyle(
                                              fontFamily: 'Gilroy-Light',
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      height1,
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: themeColors[color],
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showSomeWrap(context, '', [
                                            for (var i = 0; i < 8; i++)
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize:
                                                      const Size(100, 50),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      themeColors[i],
                                                ),
                                                onPressed: () async {
                                                  await _updateColor(i);
                                                  Navigator.pop;
                                                },
                                                child: Text(themeNameColors[i]),
                                              ),
                                          ]);
                                        },
                                        child: Text(S.of(context).theme),
                                      ),
                                      height1,
                                    ],
                                  ),
                                );
                              } else {
                                return preloader;
                              }
                            },
                          )
                        ],
                      );
                    } else {
                      showSomeDialog(
                        context,
                        '',
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.group!.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Stack(
                                  children: [
                                    ClipOval(
                                      child: widget.group!.image == null
                                          ? CircleAvatar(
                                              radius: 100,
                                              //backgroundColor: Theme.of(context).primaryColorLight,
                                              child: Icon(Icons.group,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 200),
                                            )
                                          : Image.network(
                                              widget.group!.image!,
                                              fit: BoxFit.contain,
                                              width: 200,
                                            ),
                                    ),
                                    if (widget.group!.creator ==
                                        supabase.auth.currentUser!.id)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _uploadGroupImage,
                                          style: ElevatedButton.styleFrom(
                                            fixedSize:
                                                const Size.fromRadius(20),
                                            shape: const CircleBorder(),
                                            backgroundColor:
                                                themeColors[widget.roomColor],
                                          ),
                                          child: Icon(
                                            widget.group!.image == null
                                                ? Icons.add_a_photo
                                                : Icons.edit,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(widget.group!.groupBio),
                                if (widget.group!.creator ==
                                    supabase.auth.currentUser!.id)
                                  height1,
                                if (widget.group!.creator ==
                                        supabase.auth.currentUser!.id &&
                                    !_edit)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColors[color],
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSomeDialog(
                                        context,
                                        '',
                                        [
                                          height2,
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  themeColors[color],
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              showSomeDialog(
                                                context,
                                                S.of(context).name,
                                                [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: TextFormField(
                                                      controller:
                                                          _groupNameController,
                                                      decoration:
                                                          InputDecoration(
                                                        label: Text(S
                                                            .of(context)
                                                            .groupName),
                                                        hintText:
                                                            widget.group!.name,
                                                        labelStyle: TextStyle(
                                                          color: themeColors[
                                                              widget.roomColor],
                                                        ),
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                          color: themeColors[
                                                              widget.roomColor],
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                            color: themeColors[
                                                                widget
                                                                    .roomColor],
                                                            width: 5,
                                                          ),
                                                        ),
                                                        //focusColor: color,
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                            color: themeColors[
                                                                widget
                                                                    .roomColor],
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      validator: (val) {
                                                        if (val == null ||
                                                            val.isEmpty) {
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
                                                            : _changeGroupName(
                                                                widget.group!
                                                                    .toMap(),
                                                                _groupNameController
                                                                    .text);
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            themeColors[widget
                                                                .roomColor],
                                                      ),
                                                      child: Text(
                                                          S.of(context).update),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            child: Text(S.of(context).name),
                                          ),
                                          height3,
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  themeColors[color],
                                            ),
                                            onPressed: () {
                                              _groupNameController =
                                                  TextEditingController(
                                                text: widget.group!.name,
                                              );
                                              _groupBioController =
                                                  TextEditingController(
                                                text: widget.group!.groupBio,
                                              );
                                              Navigator.pop(context);
                                              showSomeDialog(
                                                context,
                                                'Bio',
                                                [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      20.0,
                                                    ),
                                                    child: TextFormField(
                                                      controller:
                                                          _groupBioController,
                                                      decoration:
                                                          InputDecoration(
                                                        label: Text(S
                                                            .of(context)
                                                            .groupBio),
                                                        hintText:
                                                            widget.group!.name,
                                                        labelStyle: TextStyle(
                                                          color: themeColors[
                                                              widget.roomColor],
                                                        ),
                                                        floatingLabelStyle:
                                                            TextStyle(
                                                          color: themeColors[
                                                              widget.roomColor],
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                            color: themeColors[
                                                                widget
                                                                    .roomColor],
                                                            width: 5,
                                                          ),
                                                        ),
                                                        //focusColor: color,
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          borderSide:
                                                              BorderSide(
                                                            color: themeColors[
                                                                widget
                                                                    .roomColor],
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      validator: (val) {
                                                        if (val == null ||
                                                            val.isEmpty) {
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
                                                            : _changeGroupBio(
                                                                widget.group!
                                                                    .toMap(),
                                                                _groupBioController
                                                                    .text);
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            themeColors[widget
                                                                .roomColor],
                                                      ),
                                                      child: Text(
                                                          S.of(context).update),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            child: const Text('Bio'),
                                          ),
                                          height2,
                                        ],
                                      );
                                    },
                                    child: Text(S.of(context).edit),
                                  ),
                                if (widget.group!.creator ==
                                        supabase.auth.currentUser!.id &&
                                    _edit)
                                  height1,
                                height1,
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColors[color],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showSomeWrap(context, '', [
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
                                            await _updateColor(i);
                                            Navigator.pop;
                                          },
                                          child: Text(themeNameColors[i]),
                                        ),
                                    ]);
                                  },
                                  child: Text(S.of(context).theme),
                                ),
                                height1,
                              ],
                            ),
                          )
                        ],
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  tooltip: widget.group == null
                      ? S.of(context).chatSettings
                      : S.of(context).groupSettings,
                ),
              ],
            ),
            floatingActionButton: floatingActionButton(color),
            floatingActionButtonLocation: floatingActionButtonLocation(),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _ChatBubble(
                        message: message,
                        color: color,
                      );
                    },
                  ),
                ),
                _MessageBar(
                  roomId: widget.roomId,
                  roomColor: color,
                ),
              ],
            ),
          );
        } else if (state is ChatEmpty) {
          final color = state.color;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.group == null
                    ? widget.otherUserName!
                    : widget.group!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Gilroy-ExtraBold',
                ),
              ),
              backgroundColor: themeColors[color],
              actions: [
                IconButton(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: 8,
                    right: 16,
                  ),
                  onPressed: () {
                    showSomeDialog(
                      context,
                      '',
                      [
                        BlocBuilder<ProfilesCubit, ProfilesState>(
                            builder: (context, state) {
                          if (state is ProfilesLoaded) {
                            final user = state.profiles[widget.otherUserId];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.otherUserName!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: UserAvatar(
                                      userId: user!.id,
                                      isSettings: true,
                                    ),
                                  ),
                                  if (user.bio != null)
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        user.bio!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy-Light',
                                          fontSize: 20,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  height1,
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColors[color],
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSomeWrap(
                                        context,
                                        '',
                                        [
                                          for (var i = 0; i < 8; i++)
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: const Size(100, 50),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                                backgroundColor: themeColors[i],
                                              ),
                                              onPressed: () async {
                                                await _updateColor(i);
                                                Navigator.pop;
                                              },
                                              child: Text(themeNameColors[i]),
                                            ),
                                        ],
                                      );
                                    },
                                    child: Text(S.of(context).theme),
                                  ),
                                  height1,
                                ],
                              ),
                            );
                          } else {
                            return preloader;
                          }
                        })
                      ],
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  tooltip: widget.group == null
                      ? S.of(context).chatSettings
                      : S.of(context).groupSettings,
                ),
              ],
            ),
            floatingActionButton: floatingActionButton(color),
            floatingActionButtonLocation: floatingActionButtonLocation(),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(S.of(context).startConversation),
                  ),
                ),
                _MessageBar(
                  roomId: widget.roomId,
                  roomColor: color,
                ),
              ],
            ),
          );
        } else if (state is ChatError) {
          return Center(
            child: Text(
              state.message,
            ),
          );
        }
        throw UnimplementedError();
      },
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
    required this.roomId,
    required this.roomColor,
  }) : super(key: key);
  final String roomId;
  final int roomColor;
  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              width6,
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: S.of(context).message,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return;
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () => _submitMessage(),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromRadius(20),
                    shadowColor: Theme.of(context).primaryColorLight,
                    elevation: 20,
                    backgroundColor: themeColors[widget.roomColor],
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    color: white,
                    Icons.send,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.color,
  }) : super(key: key);

  final Message message;
  final int? color;

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  void _deleteMessage(String id) async {
    BlocProvider.of<ChatCubit>(context).deleteMessage(id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!widget.message.isMine)
        UserAvatar(
          userId: widget.message.profileId,
        ),
      width1,
      Flexible(
        child: GestureDetector(
          onLongPress: () {
            if (!widget.message.isMine) {
              return;
            } else {
              showSomeButtons(
                context,
                S.of(context).deleteMessage,
                [
                  Icons.close,
                  Icons.check,
                ],
                Colors.redAccent,
                checkColor,
                [
                  () => Navigator.pop(context),
                  () => _deleteMessage(widget.message.id),
                ],
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: widget.message.isMine
                  ? Colors.grey[300]
                  : widget.color != null
                      ? themeColors[widget.color!]
                      : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.message.isText
                ? Text(
                    widget.message.content,
                    style: TextStyle(
                      fontFamily: 'Gilroy-Light',
                      color: widget.message.isMine
                          ? black
                          : widget.color! != 6
                              ? white
                              : black,
                    ),
                  )
                : !widget.message.isVideo
                    ? Hero(
                        tag: widget.message.content,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _ImageMessage(
                                imageUrl: widget.message.content,
                                color: themeColors[widget.color!],
                              ),
                            ),
                          ),
                          child: Image.network(
                            widget.message.content,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 90,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _VideoPlayerWidget(
                                videoUrl: widget.message.content,
                                color: themeColors[widget.color!],
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColors[widget.color!],
                          ),
                          child: const Text(
                            'Video',
                          ),
                        ),
                      ),
          ),
        ),
      ),
      width1,
      Text(
        format(
          widget.message.createdAt,
          locale: S.of(context).localeTime,
        ),
        style: const TextStyle(
          fontFamily: 'Gilroy-Light',
        ),
      ),
      width6,
    ];
    if (widget.message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment: widget.message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  const _ImageMessage({
    Key? key,
    required this.imageUrl,
    required this.color,
  }) : super(key: key);

  final String imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.color,
  }) : super(key: key);

  final String videoUrl;
  final Color color;

  @override
  State<_VideoPlayerWidget> createState() => __VideoPlayerWidgetState();
}

class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.videoUrl,
      ),
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  String _videoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [minutes, seconds].join(':');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                SizedBox(
                  height: size.height * 0.7,
                  width: size.width * 0.7,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                height1,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, value, child) {
                        return Text(
                          _videoDuration(value.position),
                        );
                      },
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 20,
                        child: VideoProgressIndicator(
                          _controller,
                          colors: VideoProgressColors(
                            playedColor: widget.color,
                          ),
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _controller.value.duration.toString().substring(2, 7),
                    )
                  ],
                )
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.color,
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
