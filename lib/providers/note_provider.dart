import 'package:flutter/material.dart';
import 'package:homesync/data/models/note_model.dart';
import 'package:homesync/data/services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  List<NoteModel> notes = [];

  NoteModel? selectedNote;

  Future<void> fetchNotes() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      notes = await _service.getNotes();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNote(
    int id,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedNote = await _service.getNote(
        id,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectNote(
    NoteModel note,
  ) {
    selectedNote = note;
    notifyListeners();
  }

  Future<bool> createNote({
    required String title,
    required String content,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.createNote(
        title: title,
        content: content,
      );

      await fetchNotes();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateNote({
    required int noteId,
    required String title,
    required String content,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.updateNote(
        noteId: noteId,
        title: title,
        content: content,
      );

      await fetchNotes();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNote(
    int noteId,
  ) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.deleteNote(
        noteId,
      );

      notes.removeWhere(
        (e) => e.id == noteId,
      );

      if (selectedNote?.id == noteId) {
        selectedNote = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
