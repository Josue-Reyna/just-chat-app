// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';

import 'package:just_chat_app/cubits/rooms/rooms_cubit.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/models/group.dart';
import 'package:just_chat_app/models/profile.dart';
import 'package:just_chat_app/pages/chat_page.dart';
import 'package:just_chat_app/pages/settings_page.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:just_chat_app/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({
    Key? key,
  }) : super(key: key);

  static String ruta = '/home';
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) => RoomCubit()..initializeRooms(context),
        child: const RoomsPage(),
      ),
    );
  }

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  bool _add = false;
  List<Profile?> otherUsers = [];

  void _deleteRoom(String roomId) async {
    BlocProvider.of<RoomCubit>(context).deleteRoom(
      roomId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: IconButton(
        onPressed: () async {
          Navigator.of(context).push(
            SettingsPage.route(
              supabase.auth.currentUser!.id,
              null,
              null,
            ),
          );
        },
        icon: const Icon(
          Icons.settings,
        ),
        tooltip: S.of(context).settings,
      ),
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return preloader;
          } else if (state is RoomsLoaded) {
            final newUsers = state.newUsers;
            final rooms = state.rooms;
            final groups = state.groups;
            final total = rooms.length - groups;
            if (rooms.isEmpty && groups > 0) {
              return const Text('data');
            } else {
              return BlocBuilder<ProfilesCubit, ProfilesState>(
                builder: (context, state) {
                  if (state is ProfilesLoaded) {
                    final profiles = state.profiles;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          height2,
                          Text(
                            S.of(context).users,
                            style: const TextStyle(fontSize: 24),
                          ),
                          height0,
                          _NewUsers(
                            newUsers: newUsers,
                          ),
                          height0,
                          const Text(
                            'Chats',
                            style: TextStyle(fontSize: 24),
                          ),
                          height0,
                          Expanded(
                            child: ListView.builder(
                              cacheExtent: 5,
                              itemCount: rooms.length,
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                final otherUser = profiles[room.otherUserId];
                                if (room.group == null) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      shape: const StadiumBorder(),
                                      tileColor: otherUsers.contains(otherUser)
                                          ? Theme.of(context).primaryColor
                                          : null,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          ChatPage(
                                            otherUserName: otherUser!.username,
                                            otherUserId: otherUser.id,
                                            roomColor: room.color,
                                            roomId: room.id,
                                            group: null,
                                          ).route(),
                                        );
                                      },
                                      onLongPress: () {
                                        showSomeButtons(
                                          context,
                                          S.of(context).deleteChat,
                                          [Icons.close, Icons.check],
                                          Colors.redAccent,
                                          checkColor,
                                          [
                                            () => Navigator.of(context).pop(),
                                            () {
                                              _deleteRoom(room.id);
                                              Navigator.of(context).pop();
                                            },
                                          ],
                                        );
                                      },
                                      leading: GestureDetector(
                                        onTap: () {
                                          if (_add) {
                                            if (!otherUsers
                                                .contains(otherUser)) {
                                              setState(() {
                                                otherUsers.add(otherUser);
                                              });
                                            }
                                          }
                                        },
                                        onDoubleTap: () {
                                          if (_add) {
                                            if (otherUsers
                                                .contains(otherUser)) {
                                              setState(() {
                                                otherUsers.remove(otherUser);
                                              });
                                            }
                                          }
                                        },
                                        child: UserAvatar(
                                          userId: otherUser?.id,
                                        ),
                                      ),
                                      title: Text(
                                        otherUser == null
                                            ? S.of(context).loading
                                            : otherUser.username,
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy-Light',
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: room.lastMessage != null
                                          ? Text(
                                              room.lastMessage!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(S.of(context).chatCreated),
                                      trailing: Text(
                                        format(
                                          room.messageTime ?? room.createdAt,
                                          locale: S.of(context).localeTime,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      shape: const StadiumBorder(),
                                      onTap: () {
                                        if (_add) {
                                          setState(() {
                                            otherUsers.clear();
                                            _add = false;
                                          });
                                        }
                                        Navigator.of(context).push(
                                          ChatPage(
                                            otherUserId:
                                                supabase.auth.currentUser!.id,
                                            otherUserName: null,
                                            roomColor: room.color,
                                            roomId: room.id,
                                            group: room.group,
                                          ).route(),
                                        );
                                      },
                                      onLongPress: () {
                                        showSomeButtons(
                                          context,
                                          S.of(context).deleteGroup,
                                          [Icons.close, Icons.check],
                                          Colors.redAccent,
                                          checkColor,
                                          [
                                            () => Navigator.of(context).pop(),
                                            () {
                                              _deleteRoom(room.id);
                                              Navigator.of(context).pop();
                                            },
                                          ],
                                        );
                                      },
                                      leading: ClipOval(
                                        child: room.group!.image == null
                                            ? CircleAvatar(
                                                radius: 100,
                                                child: Icon(Icons.group,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 30),
                                              )
                                            : Image.network(
                                                room.group!.image!,
                                                fit: BoxFit.contain,
                                                width: 30,
                                              ),
                                      ),
                                      title: Text(
                                        room.group!.name,
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy-Light',
                                        ),
                                      ),
                                      subtitle: room.lastMessage != null
                                          ? Text(
                                              room.lastMessage!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(S.of(context).groupCreated),
                                      trailing: Text(
                                        format(
                                          room.messageTime ?? room.createdAt,
                                          locale: S.of(context).localeTime,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          if (total > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_add) {
                                    if (otherUsers.length > 1 &&
                                        otherUsers.length < 10) {
                                      showSomeButtons(
                                        context,
                                        S.of(context).confirm,
                                        [Icons.close, Icons.check],
                                        Colors.redAccent,
                                        checkColor,
                                        [
                                          () {
                                            setState(() {
                                              otherUsers.clear();
                                              _add = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          () async {
                                            List<String> otherUsersIds = [];
                                            for (var other in otherUsers) {
                                              otherUsersIds.add(other!.id);
                                            }
                                            final group = {
                                              'name': S.of(context).newGroup,
                                              'image': null,
                                              'members':
                                                  otherUsersIds.length + 1,
                                              'creator':
                                                  supabase.auth.currentUser!.id,
                                            };
                                            final roomColor =
                                                themeColors.indexOf(
                                              Theme.of(context).primaryColor,
                                            );
                                            final roomId = await BlocProvider
                                                    .of<RoomCubit>(context)
                                                .createGroupParameters(
                                              otherUsersIds,
                                              roomColor,
                                              group,
                                            );
                                            setState(() {
                                              otherUsers.clear();
                                              _add = false;
                                            });
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              ChatPage(
                                                otherUserId: null,
                                                otherUserName: null,
                                                roomColor: roomColor,
                                                roomId: roomId,
                                                group: Group.fromMap(group),
                                              ).route(),
                                            );
                                          },
                                        ],
                                        others: Container(
                                          height: otherUsers.length + 1 < 4
                                              ? 150
                                              : 175,
                                          width: 200,
                                          padding: const EdgeInsets.all(8),
                                          child: ListView.builder(
                                            itemCount: otherUsers.length,
                                            itemBuilder: (context, index1) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ListTile(
                                                  shape: const StadiumBorder(),
                                                  leading: UserAvatar(
                                                      userId:
                                                          otherUsers[index1]!
                                                              .id),
                                                  title: Text(
                                                      otherUsers[index1]!
                                                          .username),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else if (otherUsers.length < 2) {
                                      context.showSnackBar(
                                        message: S.of(context).minGroup,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                      );
                                    } else if (otherUsers.length > 9) {
                                      context.showSnackBar(
                                        message: S.of(context).maxGroup,
                                      );
                                    }
                                  } else {
                                    showSomeButtons(
                                      context,
                                      S.of(context).createGroup,
                                      [
                                        Icons.close,
                                        Icons.check,
                                      ],
                                      Colors.redAccent,
                                      checkColor,
                                      [
                                        () => Navigator.pop(context),
                                        () {
                                          setState(() {
                                            _add = !_add;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ],
                                      others: SizedBox(
                                        width: 40,
                                        child: Text(
                                          S.of(context).groupInstructions,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 20,
                                  fixedSize: const Size.fromRadius(30),
                                  backgroundColor: _add
                                      ? checkColor
                                      : Theme.of(context).primaryColor,
                                  shape: const CircleBorder(),
                                ),
                                child: Icon(
                                  _add ? Icons.check : Icons.add,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return preloader;
                  }
                },
              );
            }
          } else if (state is RoomsEmpty) {
            final newUsers = state.newUsers;
            return Column(
              children: [
                _NewUsers(
                  newUsers: newUsers,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      S.of(context).startChat,
                    ),
                  ),
                ),
              ],
            );
          } else if (state is RoomsError) {
            return Center(
              child: Text(
                state.message,
              ),
            );
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class _NewUsers extends StatelessWidget {
  const _NewUsers({
    Key? key,
    required this.newUsers,
  }) : super(key: key);

  final List<Profile> newUsers;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: newUsers
              .map<Widget>(
                (user) => InkWell(
                  onTap: () async {
                    try {
                      final exists = await BlocProvider.of<RoomCubit>(context)
                          .roomExistsNew(user.id);
                      if (exists['exists'].toString() == 'true') {
                        Navigator.of(context).push(
                          ChatPage(
                            otherUserName: user.username,
                            otherUserId: user.id,
                            roomColor: int.parse(exists['color']),
                            roomId: exists['room_id'].toString(),
                            group: null,
                          ).route(),
                        );
                      } else {
                        showSomeButtons(
                          context,
                          user.username,
                          [Icons.close, Icons.check],
                          Colors.redAccent,
                          const Color.fromARGB(255, 79, 185, 141),
                          [
                            () => Navigator.of(context).pop(),
                            () async {
                              try {
                                final room =
                                    await BlocProvider.of<RoomCubit>(context)
                                        .createRoom(user.id);
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  ChatPage(
                                    otherUserName: user.username,
                                    otherUserId: user.id,
                                    roomColor: room['color'],
                                    roomId: room['id'],
                                    group: null,
                                  ).route(),
                                );
                              } catch (_) {
                                context.showErrorSnackBar(
                                    message: S.of(context).failedRoom);
                              }
                            },
                          ],
                          others: Container(
                            height: size.height * 0.53,
                            width: 100,
                            padding: const EdgeInsets.all(3.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (user.bio != null)
                                  Text(
                                    user.bio!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Gilroy-Light',
                                    ),
                                  ),
                                UserAvatar(
                                  userId: user.id,
                                  isSettings: true,
                                ),
                                height0,
                                Text(
                                  S.of(context).chatear,
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      context.showErrorSnackBar(
                        message: 'Error $e',
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              UserAvatar(
                                userId: user.id,
                              ),
                              Positioned(
                                right: 4,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: user.status
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 8,
                                  height: 8,
                                ),
                              ),
                            ],
                          ),
                          height1,
                          Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Gilroy-Light',
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
