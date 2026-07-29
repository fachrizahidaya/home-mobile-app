import 'package:dio/dio.dart';
import 'package:homesync/data/models/note_model.dart';
import 'package:homesync/data/services/api_service.dart';

class NoteService {
  final ApiService _apiService = ApiService();

  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await _apiService.get(
        '/notes',
      );

      return (response.data['data'] as List)
          .map(
            (e) => NoteModel.fromJson(e),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  Future<NoteModel> getNote(
    int id,
  ) async {
    final response = await _apiService.get(
      '/notes/$id',
    );

    return NoteModel.fromJson(
      response.data['data'],
    );
  }

  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    await _apiService.post(
      '/notes',
      data: {
        'title': title,
        'content': content,
      },
    );
  }

  Future<void> updateNote({
    required int noteId,
    required String title,
    required String content,
  }) async {
    await _apiService.put(
      '/notes/$noteId',
      data: {
        'title': title,
        'content': content,
      },
    );
  }

  Future<void> deleteNote(
    int noteId,
  ) async {
    await _apiService.delete(
      '/notes/$noteId',
    );
  }
}
