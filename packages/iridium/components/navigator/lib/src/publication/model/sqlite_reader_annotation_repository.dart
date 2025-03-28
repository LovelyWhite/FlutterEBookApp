import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteReaderAnnotationRepository extends ReaderAnnotationRepository {
  static const String _tableName = "reader_annotations";
  static const String _columnId = "id";
  static const String _columnBookId = "book_id";
  static const String _columnLocation = "location";
  static const String _columnAnnotation = "annotation";
  static const String _columnStyle = "style";
  static const String _columnTint = "tint";
  static const String _columnAnnotationType = "annotation_type";
  
  final String _bookId;
  final Database _database;
  ReaderAnnotation? position;

  // Constructor takes a bookId (usually the book's filename or unique identifier)
  SqliteReaderAnnotationRepository(this._bookId, this._database);

  // Static method to create a database instance and repository
  static Future<SqliteReaderAnnotationRepository> create(String bookId) async {
    // Get a location for the database
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reader_annotations.db');
    
    // Create or open the database
    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            $_columnId TEXT PRIMARY KEY, 
            $_columnBookId TEXT NOT NULL,
            $_columnLocation TEXT NOT NULL,
            $_columnAnnotation TEXT,
            $_columnStyle INTEGER,
            $_columnTint INTEGER,
            $_columnAnnotationType INTEGER NOT NULL
          )
        ''');
      },
    );
    
    return SqliteReaderAnnotationRepository(bookId, database);
  }

  // Helper method to convert a database row to a ReaderAnnotation
  ReaderAnnotation _fromMap(Map<String, dynamic> map) => ReaderAnnotation(
    map[_columnId] as String,
    map[_columnBookId] as String,
    map[_columnLocation] as String,
    AnnotationType.from(map[_columnAnnotationType] as int),
    annotation: map[_columnAnnotation] as String?,
    style: HighlightStyle.from(map[_columnStyle] as int?),
    tint: map[_columnTint] as int?,
  );

  // Helper method to convert a ReaderAnnotation to a database row
  Map<String, dynamic> _toMap(ReaderAnnotation annotation) => {
    _columnId: annotation.id,
    _columnBookId: annotation.bookId,
    _columnLocation: annotation.location,
    _columnAnnotationType: annotation.annotationType.id,
    if (annotation.annotation != null) _columnAnnotation: annotation.annotation,
    if (annotation.style != null) _columnStyle: annotation.style!.id,
    if (annotation.tint != null) _columnTint: annotation.tint,
  };

  @override
  Future<List<ReaderAnnotation>> allWhere({
    Predicate<ReaderAnnotation> predicate = const AcceptAllPredicate()
  }) async {
    // Query all annotations for this book
    List<Map<String, dynamic>> rows = await _database.query(
      _tableName,
      where: '$_columnBookId = ?',
      whereArgs: [_bookId],
    );
    
    // Convert rows to ReaderAnnotation objects
    List<ReaderAnnotation> annotations = rows.map(_fromMap).toList();
    
    // Apply the predicate filter
    return annotations.where(predicate.test).toList();
  }

  @override
  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id, 
      _bookId,
      paginationInfo.locator.json, 
      AnnotationType.bookmark
    );
    
    await _database.insert(
      _tableName,
      _toMap(readerAnnotation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    notifyBookmark(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation> createHighlight(
    PaginationInfo? paginationInfo,
    Locator locator,
    HighlightStyle? style,
    int? tint,
    String? annotation
  ) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id,
      _bookId,
      locator.json,
      AnnotationType.highlight,
      style: style,
      tint: tint,
      annotation: annotation,
    );
    
    await _database.insert(
      _tableName,
      _toMap(readerAnnotation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> get(String id) async {
    List<Map<String, dynamic>> rows = await _database.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    return rows.isNotEmpty ? _fromMap(rows.first) : null;
  }

  @override
  Future<ReaderAnnotation?> getPosition() async => position;

  @override
  Future<ReaderAnnotation> savePosition(PaginationInfo paginationInfo) async {
    String id = "position-$_bookId";
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id, 
      _bookId,
      paginationInfo.locator.json, 
      AnnotationType.bookmark
    );
    
    // Delete any existing position
    await _database.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    
    // Insert new position
    await _database.insert(
      _tableName,
      _toMap(readerAnnotation),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    position = readerAnnotation;
    return readerAnnotation;
  }

  @override
  void save(ReaderAnnotation readerAnnotation) async {
    await _database.update(
      _tableName,
      _toMap(readerAnnotation),
      where: '$_columnId = ?',
      whereArgs: [readerAnnotation.id],
    );
  }

  @override
  Future<void> delete(Iterable<String> deletedIds) async {
    await _database.delete(
      _tableName,
      where: '$_columnId IN (${List.filled(deletedIds.length, '?').join(',')})',
      whereArgs: deletedIds.toList(),
    );
    
    super.delete(deletedIds);
  }

  // Method to close the database connection
  Future<void> close() async {
    await _database.close();
  }
} 