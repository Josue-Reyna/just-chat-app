import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_chat_app/models/profile.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  ProfilesCubit() : super(ProfilesInitial());

  final Map<String, Profile?> _profiles = {};

  void updateColor(int color, String id) async {
    try {
      await supabase.from('profiles').update({'color': color}).eq('id', id);
      emit(ProfilesLoaded(
        profiles: _profiles,
      ));
    } catch (_) {
      emit(ProfilesError('Error saving new color'));
    }
  }

  void updateBio(String bio) async {
    try {
      final data = await supabase
          .from('profiles')
          .update({'bio': bio})
          .eq(
            'id',
            supabase.auth.currentUser!.id,
          )
          .single();
      _profiles[supabase.auth.currentUser!.id] = Profile.fromMap(data);
      emit(ProfilesLoaded(
        profiles: _profiles,
      ));
    } catch (e) {
      emit(ProfilesError('Error savig bio: $e'));
    }
  }

  void updateStatus(bool status) async {
    try {
      final data = await supabase
          .from('profiles')
          .update({'status': status})
          .eq(
            'id',
            supabase.auth.currentUser!.id,
          )
          .single();
      _profiles[supabase.auth.currentUser!.id] = Profile.fromMap(data);
      emit(ProfilesLoaded(
        profiles: _profiles,
      ));
    } catch (e) {
      emit(ProfilesError('Error: $e'));
    }
  }

  void updateUsername(String newUserName) async {
    try {
      final data = await supabase
          .from('profiles')
          .update({
            'username': newUserName,
          })
          .eq(
            'id',
            supabase.auth.currentUser!.id,
          )
          .select()
          .single();
      _profiles[supabase.auth.currentUser!.id] = Profile.fromMap(data);
      emit(ProfilesLoaded(
        profiles: _profiles,
      ));
    } catch (_) {
      emit(ProfilesError('Error saving new color'));
    }
  }

  Future<void> getProfile(String userId) async {
    if (_profiles[userId] != null) {
      return;
    }

    final data = await supabase.from('profiles').select().match({
      'id': userId,
    }).single();

    if (data == null) {
      return;
    }
    _profiles[userId] = Profile.fromMap(data);

    emit(ProfilesLoaded(profiles: _profiles));
  }

  Future<Profile> getUserProfile(String userId) async {
    final data =
        await supabase.from('profiles').select().match({'id': userId}).single();

    final Profile profile = Profile.fromMap(data);
    return profile;
  }

  void deletePhoto(userId) async {
    try {
      await supabase.storage.from('avatars').remove([userId]);
      final data = await supabase
          .from('profiles')
          .update({
            'avatar_url': null,
          })
          .eq('id', userId)
          .select()
          .single();
      _profiles[userId] = Profile.fromMap(data);
    } on StorageException catch (_) {
      emit(
        ProfilesError(
          'Error deleting photo:',
        ),
      );
    } catch (_) {
      emit(
        ProfilesError(
          'Error deleting photo:',
        ),
      );
    }
  }

  void uploadPhoto(
    Uint8List bytes,
    String filePath,
    String? contentType,
    String userId,
    bool update,
  ) async {
    try {
      String imageUrl = '';
      if (update) {
        await supabase.storage.from('avatars').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: contentType,
              ),
            );
        imageUrl = await supabase.storage
            .from('avatars')
            .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      } else {
        final profile = _profiles[userId];
        final path = userId;
        imageUrl = profile!.imageUrl!;
        await supabase.storage.from('avatars').updateBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: contentType,
              ),
            );
        imageUrl = await supabase.storage
            .from('avatars')
            .createSignedUrl(path, 60 * 60 * 24 * 365 * 10);
      }
      final data = await supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', userId)
          .select()
          .single();
      _profiles[userId] = Profile.fromMap(data);
      emit(
        ProfilesLoaded(
          profiles: _profiles,
        ),
      );
    } on StorageException catch (error) {
      emit(
        ProfilesError(
          'Error saving photo: ${error.message}',
        ),
      );
    } catch (error) {
      emit(
        ProfilesError(
          'Error uploading photo: $error',
        ),
      );
    }
  }
}
