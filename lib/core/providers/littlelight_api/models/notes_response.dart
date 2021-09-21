import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';

class NotesResponse {
  List<ItemNotes> notes;
  List<ItemNotesTag> tags;

  NotesResponse({this.notes, this.tags});
}